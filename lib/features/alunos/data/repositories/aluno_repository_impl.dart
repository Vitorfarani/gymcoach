// aluno_repository_impl.dart
//
// Implementação concreta do contrato AlunoRepository.
//
// POR QUE FICA EM data/ E NÃO EM domain/?
//   A regra da Clean Architecture é: domain não depende de nada externo.
//   Esta classe depende de AlunoDao (SQLite) e ImageHelper (disco) — ou seja,
//   depende de infraestrutura. Por isso fica em data/, que PODE depender
//   de detalhes de implementação.
//
//   O contrato (abstract class AlunoRepository) fica em domain/ e não sabe
//   que SQLite existe. Os use cases dependem só do contrato — jamais desta
//   implementação concreta.
//
// PADRÃO GERAL:
//   - Métodos de escrita que precisam verificar existência: busca → checa null
//     → lança AlunoNaoEncontradoException → executa operação
//   - Métodos de leitura: delega direto ao DAO
//   - Foto: delega ao ImageHelper o processamento; ao DAO, apenas o path
//
// VALIDAÇÃO:
//   Propositalmente ausente aqui. As regras de negócio (nome 2–60 chars,
//   peso 30–250 kg, etc.) são responsabilidade dos use cases (CriarAluno,
//   EditarAluno). O RepositoryImpl recebe dados já validados.

import 'dart:io' show File;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/image_helper.dart';
import '../../domain/entities/aluno.dart';
import '../../domain/repositories/aluno_repository.dart';
import '../datasources/aluno_dao.dart';

class AlunoRepositoryImpl implements AlunoRepository {
  final AlunoDao _dao;

  /// Recebe o DAO via construtor — padrão de injeção de dependência.
  ///
  /// Quem cria o AlunoDao e injeta aqui é o provider Riverpod (camada de
  /// apresentação). O RepositoryImpl não conhece DatabaseHelper diretamente.
  AlunoRepositoryImpl(this._dao);

  // ── Escrita ───────────────────────────────────────────────────────────────

  @override
  Future<Aluno> criar(Aluno aluno) {
    // Validação já foi feita no use case CriarAluno.
    // Aqui apenas persiste e retorna o aluno com id gerado pelo banco.
    return _dao.inserir(aluno);
  }

  @override
  Future<Aluno> editar(Aluno aluno) async {
    // Verifica existência antes de atualizar — o DAO não distingue
    // "atualizado com sucesso" de "id inexistente" (ambos são silenciosos).
    final existente = await _dao.buscarPorId(aluno.id!);
    if (existente == null) throw const AlunoNaoEncontradoException();

    return _dao.atualizar(aluno);
  }

  @override
  Future<void> deletar(int id) async {
    // softDelete retorna int: número de linhas afetadas.
    // 0 = id não existe no banco ou já foi deletado → erro.
    final afetadas = await _dao.softDelete(id);
    if (afetadas == 0) throw const AlunoNaoEncontradoException();
  }

  @override
  Future<void> atualizarUltimoAcesso(int id) async {
    final afetadas = await _dao.atualizarUltimoAcesso(id);
    if (afetadas == 0) throw const AlunoNaoEncontradoException();
  }

  // ── Leitura ───────────────────────────────────────────────────────────────

  @override
  Future<Aluno> buscarPorId(int id) async {
    // O DAO retorna null quando o id não existe (ou aluno foi deletado).
    // Aqui convertemos null → exceção de domínio.
    // Este é o único lugar do app onde essa conversão acontece para alunos.
    final aluno = await _dao.buscarPorId(id);
    if (aluno == null) throw const AlunoNaoEncontradoException();
    return aluno;
  }

  @override
  Future<List<Aluno>> listar({String? query}) {
    // Delegação direta — lista vazia é retorno válido, não é erro.
    return _dao.listar(query: query);
  }

  @override
  Future<List<Aluno>> listarUltimosAcessados(int limite) {
    return _dao.listarUltimosAcessados(limite);
  }

  @override
  Future<int> contarAtivos() {
    return _dao.contarAtivos();
  }

  // ── Foto ──────────────────────────────────────────────────────────────────

  @override
  Future<String> salvarFoto(int id, File imagemOriginal) async {
    // 1. Garante que o aluno existe antes de gastar tempo processando imagem.
    final aluno = await _dao.buscarPorId(id);
    if (aluno == null) throw const AlunoNaoEncontradoException();

    // 2. Se já tinha uma foto, deleta o arquivo antigo do disco.
    //    O nome do arquivo novo é o mesmo (aluno_<id>.jpg), então seria
    //    sobrescrito de qualquer forma — mas deletar explicitamente é mais seguro.
    if (aluno.fotoPath != null) {
      await ImageHelper.deletarArquivo(aluno.fotoPath!);
    }

    // 3. Processa (resize + comprime) e salva no diretório do app.
    //    Pode lançar ErroAoProcessarImagemException — deixamos propagar.
    //    A validação de tamanho (< 5MB) já foi feita pelo use case.
    final novoPath = await ImageHelper.processarESalvar(id, imagemOriginal);

    // 4. Atualiza foto_path no banco.
    //    Se falhar aqui, deleta o arquivo recém-salvo para evitar arquivo
    //    órfão (arquivo no disco sem referência no banco).
    final afetadas = await _dao.atualizarFotoPath(id, novoPath);
    if (afetadas == 0) {
      await ImageHelper.deletarArquivo(novoPath);
      throw const DatabaseException('Falha ao atualizar foto_path no banco.');
    }

    return novoPath;
  }

  @override
  Future<void> removerFoto(int id) async {
    final aluno = await _dao.buscarPorId(id);
    if (aluno == null) throw const AlunoNaoEncontradoException();

    // Operação idempotente: se não tem foto, não faz nada.
    if (aluno.fotoPath == null) return;

    // 1. Deleta o arquivo físico do dispositivo.
    await ImageHelper.deletarArquivo(aluno.fotoPath!);

    // 2. Limpa foto_path no banco (passa null = SET NULL).
    await _dao.atualizarFotoPath(id, null);
  }
}
