// aluno_dao.dart
//
// Data Access Object para a tabela `alunos`.
//
// RESPONSABILIDADE ÚNICA:
//   Executar queries SQL e converter entre Map<String,dynamic> e Aluno.
//   Nenhuma regra de negócio aqui — isso é trabalho dos use cases.
//
// TRATAMENTO DE ERROS:
//   Exceções do sqflite são capturadas e relançadas como DatabaseException
//   (nossa exceção de domínio definida em core/errors/exceptions.dart).
//   Assim as camadas superiores nunca precisam conhecer detalhes do sqflite.
//
// RETORNO NULLABLE EM BUSCAS:
//   buscarPorId retorna Aluno? (null se não encontrar).
//   O RepositoryImpl converte null → AlunoNaoEncontradoException.

import 'package:sqflite/sqflite.dart' show Database;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/aluno.dart';

class AlunoDao {
  final Database _db;

  /// Recebe a instância do banco aberta pelo DatabaseHelper.
  /// Nunca abre o banco sozinho.
  AlunoDao(this._db);

  // ── Constante ─────────────────────────────────────────────────────────────

  static const String _table = 'alunos';

  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Insere um novo aluno e retorna o mesmo aluno com o id gerado pelo banco.
  Future<Aluno> inserir(Aluno aluno) async {
    try {
      // _toMap não inclui 'id' — deixa o banco gerar via AUTOINCREMENT
      final id = await _db.insert(_table, _toMap(aluno));
      return aluno.copyWith(id: id);
    } catch (e) {
      throw DatabaseException('Erro ao inserir aluno: $e');
    }
  }

  /// Atualiza todos os campos editáveis de um aluno existente.
  Future<Aluno> atualizar(Aluno aluno) async {
    try {
      await _db.update(
        _table,
        _toMap(aluno),
        where: 'id = ?',
        whereArgs: [aluno.id],
      );
      return aluno;
    } catch (e) {
      throw DatabaseException('Erro ao atualizar aluno: $e');
    }
  }

  /// Soft delete: preenche `deletado_em` com o timestamp atual.
  ///
  /// Retorna o número de linhas afetadas (0 = id não existe ou já deletado).
  Future<int> softDelete(int id) async {
    try {
      return _db.update(
        _table,
        {'deletado_em': DateTime.now().toIso8601String()},
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao deletar aluno: $e');
    }
  }

  /// Atualiza apenas `ultimo_acesso` para agora.
  ///
  /// Retorna o número de linhas afetadas.
  Future<int> atualizarUltimoAcesso(int id) async {
    try {
      return _db.update(
        _table,
        {'ultimo_acesso': DateTime.now().toIso8601String()},
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao atualizar último acesso: $e');
    }
  }

  /// Atualiza apenas `foto_path`.
  ///
  /// Passa [fotoPath] = null para limpar a foto (removerFoto).
  /// Retorna o número de linhas afetadas.
  Future<int> atualizarFotoPath(int id, String? fotoPath) async {
    try {
      return _db.update(
        _table,
        {'foto_path': fotoPath},
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao atualizar foto: $e');
    }
  }

  // ── Leitura ───────────────────────────────────────────────────────────────

  /// Busca aluno pelo id.
  ///
  /// Retorna null se não encontrado ou se já foi soft-deletado.
  /// O RepositoryImpl converte null → AlunoNaoEncontradoException.
  Future<Aluno?> buscarPorId(int id) async {
    try {
      final rows = await _db.query(
        _table,
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _fromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Erro ao buscar aluno: $e');
    }
  }

  /// Lista alunos ativos, ordenados por nome.
  ///
  /// Se [query] informado, filtra por nome (LIKE %query% — case-insensitive).
  Future<List<Aluno>> listar({String? query}) async {
    try {
      final List<Map<String, dynamic>> rows;

      if (query != null) {
        // LIKE com % em ambos os lados = busca em qualquer posição do nome
        rows = await _db.query(
          _table,
          where: 'deletado_em IS NULL AND nome LIKE ?',
          whereArgs: ['%$query%'],
          orderBy: 'nome ASC',
        );
      } else {
        rows = await _db.query(
          _table,
          where: 'deletado_em IS NULL',
          orderBy: 'nome ASC',
        );
      }

      return rows.map(_fromMap).toList();
    } catch (e) {
      throw DatabaseException('Erro ao listar alunos: $e');
    }
  }

  /// Retorna os [limite] últimos alunos acessados, por `ultimo_acesso DESC`.
  Future<List<Aluno>> listarUltimosAcessados(int limite) async {
    try {
      final rows = await _db.query(
        _table,
        where: 'deletado_em IS NULL AND ativo = 1',
        orderBy: 'ultimo_acesso DESC',
        limit: limite,
      );
      return rows.map(_fromMap).toList();
    } catch (e) {
      throw DatabaseException('Erro ao listar últimos alunos: $e');
    }
  }

  /// Conta alunos ativos (deletado_em IS NULL AND ativo = 1).
  Future<int> contarAtivos() async {
    try {
      // rawQuery para usar COUNT — mais eficiente que carregar todas as linhas
      final result = await _db.rawQuery(
        'SELECT COUNT(*) AS total FROM $_table WHERE deletado_em IS NULL AND ativo = 1',
      );
      return result.first['total'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Erro ao contar alunos: $e');
    }
  }

  // ── Conversão Map ↔ Aluno ─────────────────────────────────────────────────

  /// Converte uma linha do banco (Map) para o objeto Aluno do domínio.
  ///
  /// Lida com as diferenças de tipo entre SQLite e Dart:
  ///   - TEXT ISO 8601  →  DateTime
  ///   - INTEGER 0/1    →  bool
  ///   - NULL           →  null (campos opcionais)
  Aluno _fromMap(Map<String, dynamic> map) {
    return Aluno(
      id: map['id'] as int,
      nome: map['nome'] as String,
      fotoPath: map['foto_path'] as String?,
      idade: map['idade'] as int?,

      // SQLite armazena REAL — cast explícito garante double em todos os casos
      peso: (map['peso'] as num?)?.toDouble(),
      altura: (map['altura'] as num?)?.toDouble(),

      objetivo: map['objetivo'] as String?,
      observacoes: map['observacoes'] as String?,

      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataUltimaAvaliacao: map['data_ultima_avaliacao'] != null
          ? DateTime.parse(map['data_ultima_avaliacao'] as String)
          : null,
      ultimoAcesso: DateTime.parse(map['ultimo_acesso'] as String),

      // SQLite não tem bool — armazenado como INTEGER 1 (true) ou 0 (false)
      ativo: (map['ativo'] as int) == 1,

      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),

      deletadoEm: map['deletado_em'] != null
          ? DateTime.parse(map['deletado_em'] as String)
          : null,
    );
  }

  /// Converte um objeto Aluno para Map para INSERT ou UPDATE.
  ///
  /// Não inclui 'id' — no INSERT o banco gera; no UPDATE o id vai no WHERE.
  Map<String, dynamic> _toMap(Aluno aluno) {
    return {
      'nome': aluno.nome,
      'foto_path': aluno.fotoPath,
      'idade': aluno.idade,
      'peso': aluno.peso,
      'altura': aluno.altura,
      'objetivo': aluno.objetivo,
      'observacoes': aluno.observacoes,
      'data_inicio': aluno.dataInicio.toIso8601String(),
      'data_ultima_avaliacao': aluno.dataUltimaAvaliacao?.toIso8601String(),
      'ultimo_acesso': aluno.ultimoAcesso.toIso8601String(),

      // bool → INTEGER para SQLite
      'ativo': aluno.ativo ? 1 : 0,

      'created_at': aluno.createdAt.toIso8601String(),
      'updated_at': aluno.updatedAt.toIso8601String(),
      'deletado_em': aluno.deletadoEm?.toIso8601String(),
    };
  }
}
