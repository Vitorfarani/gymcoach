// treino_dao.dart
//
// Data Access Object para as tabelas `treinos` e `treino_exercicios`.
//
// RESPONSABILIDADE ÚNICA:
//   Executar queries SQL e converter entre Map<String,dynamic> e as entidades
//   Treino / TreinoExercicio. Nenhuma regra de negócio aqui — isso é papel
//   dos use cases e do TreinoRepositoryImpl.
//
// POR QUE DUAS TABELAS NO MESMO DAO?
//   Exercícios existem apenas no contexto de um treino (ciclo de vida idêntico).
//   Dois DAOs separados criariam dependência mútua sem ganho real no MVP.
//
// SOFT DELETE:
//   Treinos e exercícios não são deletados permanentemente pelo DAO.
//   `softDeleteTreino` e `softDeleteExercicio` apenas preenchem `deletado_em`.
//   Todos os SELECTs filtram `WHERE deletado_em IS NULL`.
//
// BATCH TRANSACIONAL:
//   `atualizarOrdemExercicios` usa db.transaction() — ou todos os UPDATEs
//   de ordem são persistidos, ou nenhum é. Banco nunca fica inconsistente.

import 'package:sqflite/sqflite.dart' show Database;

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/treino.dart';
import '../../domain/entities/treino_exercicio.dart';

class TreinoDao {
  final Database _db;

  /// Recebe a instância do banco aberta pelo DatabaseHelper.
  /// O DAO nunca abre o banco sozinho.
  TreinoDao(this._db);

  // ── Constantes de tabela ──────────────────────────────────────────────────

  static const String _tableTreinos = 'treinos';
  static const String _tableExercicios = 'treino_exercicios';

  // ══════════════════════════════════════════════════════════════════════════
  // TREINOS — escrita
  // ══════════════════════════════════════════════════════════════════════════

  /// Insere um novo treino e retorna o id gerado pelo banco (AUTOINCREMENT).
  Future<int> inserirTreino(Treino treino) async {
    try {
      // _treinoToMap não inclui 'id' — o banco gera via AUTOINCREMENT
      return await _db.insert(_tableTreinos, _treinoToMap(treino));
    } catch (e) {
      throw DatabaseException('Erro ao inserir treino: $e');
    }
  }

  /// Atualiza todos os campos editáveis de um treino existente.
  Future<void> atualizarTreino(Treino treino) async {
    try {
      await _db.update(
        _tableTreinos,
        _treinoToMap(treino),
        where: 'id = ?',
        whereArgs: [treino.id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao atualizar treino: $e');
    }
  }

  /// Soft delete: preenche `deletado_em` com o timestamp atual.
  ///
  /// Retorna o número de linhas afetadas.
  /// 0 = id não existe ou treino já estava soft-deletado.
  Future<int> softDeleteTreino(int id) async {
    try {
      return await _db.update(
        _tableTreinos,
        {'deletado_em': DateTime.now().toIso8601String()},
        // AND deletado_em IS NULL evita "deletar duas vezes" e garante
        // que 0 linhas afetadas significa "não encontrado".
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao deletar treino: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TREINOS — leitura
  // ══════════════════════════════════════════════════════════════════════════

  /// Busca treino pelo id.
  ///
  /// Retorna null se não encontrado ou se já foi soft-deletado.
  /// O RepositoryImpl converte null → TreinoNaoEncontradoException.
  Future<Treino?> buscarTreinoPorId(int id) async {
    try {
      final rows = await _db.query(
        _tableTreinos,
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _treinoFromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Erro ao buscar treino: $e');
    }
  }

  /// Lista todos os treinos ativos de um aluno, ordenados por `created_at ASC`.
  ///
  /// `created_at ASC` respeita o doc4 (ListarTreinosDoAluno ordena por criação).
  /// Retorna lista vazia se o aluno não tiver treinos — não lança exceção.
  Future<List<Treino>> listarTreinosPorAluno(int alunoId) async {
    try {
      final rows = await _db.query(
        _tableTreinos,
        where: 'aluno_id = ? AND deletado_em IS NULL',
        whereArgs: [alunoId],
        orderBy: 'created_at ASC',
      );
      return rows.map(_treinoFromMap).toList();
    } catch (e) {
      throw DatabaseException('Erro ao listar treinos: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXERCÍCIOS — escrita
  // ══════════════════════════════════════════════════════════════════════════

  /// Insere um novo exercício e retorna o id gerado pelo banco.
  Future<int> inserirExercicio(TreinoExercicio exercicio) async {
    try {
      return await _db.insert(_tableExercicios, _exercicioToMap(exercicio));
    } catch (e) {
      throw DatabaseException('Erro ao inserir exercício: $e');
    }
  }

  /// Atualiza os campos editáveis de um exercício existente.
  ///
  /// NÃO usa este método para atualizar `ordem` — use [atualizarOrdemExercicios].
  Future<void> atualizarExercicio(TreinoExercicio exercicio) async {
    try {
      await _db.update(
        _tableExercicios,
        _exercicioToMap(exercicio),
        where: 'id = ?',
        whereArgs: [exercicio.id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao atualizar exercício: $e');
    }
  }

  /// Soft delete de exercício: preenche `deletado_em` com o timestamp atual.
  ///
  /// Retorna o número de linhas afetadas.
  /// 0 = id não existe ou já estava soft-deletado.
  Future<int> softDeleteExercicio(int id) async {
    try {
      return await _db.update(
        _tableExercicios,
        {'deletado_em': DateTime.now().toIso8601String()},
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Erro ao deletar exercício: $e');
    }
  }

  /// Persiste a nova `ordem` de vários exercícios em uma única transação.
  ///
  /// Chamado pelo use case ReordenarExercicios após calcular as novas ordens.
  /// A transação garante atomicidade: ou todos os UPDATEs são aplicados,
  /// ou nenhum — banco nunca fica em estado inconsistente.
  Future<void> atualizarOrdemExercicios(
    List<TreinoExercicio> exercicios,
  ) async {
    try {
      await _db.transaction((txn) async {
        for (final exercicio in exercicios) {
          await txn.update(
            _tableExercicios,
            {
              'ordem': exercicio.ordem,
              'updated_at': exercicio.dataAtualizacao.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [exercicio.id],
          );
        }
      });
    } catch (e) {
      throw DatabaseException('Erro ao reordenar exercícios: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXERCÍCIOS — leitura
  // ══════════════════════════════════════════════════════════════════════════

  /// Busca exercício pelo id.
  ///
  /// Retorna null se não encontrado ou se já foi soft-deletado.
  Future<TreinoExercicio?> buscarExercicioPorId(int id) async {
    try {
      final rows = await _db.query(
        _tableExercicios,
        where: 'id = ? AND deletado_em IS NULL',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _exercicioFromMap(rows.first);
    } catch (e) {
      throw DatabaseException('Erro ao buscar exercício: $e');
    }
  }

  /// Lista todos os exercícios ativos de um treino, ordenados por `ordem ASC`.
  ///
  /// Usa o índice `idx_exercicios_treino_ordem(treino_id, ordem)` (doc2),
  /// garantindo performance mesmo com muitos exercícios.
  /// Retorna lista vazia se o treino não tiver exercícios — não lança exceção.
  Future<List<TreinoExercicio>> listarExercicios(int treinoId) async {
    try {
      final rows = await _db.query(
        _tableExercicios,
        where: 'treino_id = ? AND deletado_em IS NULL',
        whereArgs: [treinoId],
        orderBy: 'ordem ASC',
      );
      return rows.map(_exercicioFromMap).toList();
    } catch (e) {
      throw DatabaseException('Erro ao listar exercícios: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONVERSÃO Map ↔ Entidades
  // ══════════════════════════════════════════════════════════════════════════

  /// Converte uma linha do banco (Map) para a entidade Treino.
  ///
  /// Lida com as diferenças de tipo entre SQLite e Dart:
  ///   - TEXT ISO 8601 → DateTime (dataCriacao, dataAtualizacao, deletadoEm)
  ///   - NULL           → null (descricao, deletadoEm)
  Treino _treinoFromMap(Map<String, dynamic> map) {
    return Treino(
      id: map['id'] as int,
      alunoId: map['aluno_id'] as int,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String?,
      dataCriacao: DateTime.parse(map['created_at'] as String),
      dataAtualizacao: DateTime.parse(map['updated_at'] as String),
      deletadoEm: map['deletado_em'] != null
          ? DateTime.parse(map['deletado_em'] as String)
          : null,
    );
  }

  /// Converte Treino para Map para INSERT ou UPDATE.
  ///
  /// Não inclui 'id' — no INSERT o banco gera; no UPDATE o id vai no WHERE.
  Map<String, dynamic> _treinoToMap(Treino treino) {
    return {
      'aluno_id': treino.alunoId,
      'nome': treino.nome,
      'descricao': treino.descricao,
      'created_at': treino.dataCriacao.toIso8601String(),
      'updated_at': treino.dataAtualizacao.toIso8601String(),
      'deletado_em': treino.deletadoEm?.toIso8601String(),
    };
  }

  /// Converte uma linha do banco (Map) para a entidade TreinoExercicio.
  TreinoExercicio _exercicioFromMap(Map<String, dynamic> map) {
    return TreinoExercicio(
      id: map['id'] as int,
      treinoId: map['treino_id'] as int,
      nomeExercicio: map['nome_exercicio'] as String,
      series: map['series'] as String,
      repeticoes: map['repeticoes'] as String?,
      carga: map['carga'] as String?,
      observacao: map['observacao'] as String?,
      ordem: map['ordem'] as int,
      dataCriacao: DateTime.parse(map['created_at'] as String),
      dataAtualizacao: DateTime.parse(map['updated_at'] as String),
      deletadoEm: map['deletado_em'] != null
          ? DateTime.parse(map['deletado_em'] as String)
          : null,
    );
  }

  /// Converte TreinoExercicio para Map para INSERT ou UPDATE.
  ///
  /// Não inclui 'id' — no INSERT o banco gera; no UPDATE o id vai no WHERE.
  Map<String, dynamic> _exercicioToMap(TreinoExercicio exercicio) {
    return {
      'treino_id': exercicio.treinoId,
      'nome_exercicio': exercicio.nomeExercicio,
      'series': exercicio.series,
      'repeticoes': exercicio.repeticoes,
      'carga': exercicio.carga,
      'observacao': exercicio.observacao,
      'ordem': exercicio.ordem,
      'created_at': exercicio.dataCriacao.toIso8601String(),
      'updated_at': exercicio.dataAtualizacao.toIso8601String(),
      'deletado_em': exercicio.deletadoEm?.toIso8601String(),
    };
  }
}
