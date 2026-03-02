// treino_repository_impl.dart
//
// Implementação concreta do contrato TreinoRepository.
//
// PAPEL NA ARQUITETURA:
//   Esta classe fica em data/ e conecta os use cases (que conhecem apenas o
//   contrato abstrato TreinoRepository de domain/) com o TreinoDao (que fala
//   SQL). A camada domain/ nunca sabe que sqflite existe.
//
// PADRÃO GERAL:
//   - Métodos de leitura: delegam diretamente ao DAO.
//   - Métodos de escrita que precisam verificar existência (atualizar, deletar):
//     buscam primeiro → null → lançam exceção de domínio → executam operação.
//   - Soft delete: verifica pelo número de linhas afetadas (0 = não encontrado).
//
// VALIDAÇÃO:
//   Propositalmente ausente aqui. Regras de negócio (nome obrigatório, etc.)
//   são responsabilidade dos use cases. O RepositoryImpl recebe dados já
//   validados e apenas persiste.
//
// INJEÇÃO DE DEPENDÊNCIA:
//   Recebe o TreinoDao via construtor. Quem cria e injeta é o provider Riverpod
//   (presentation/providers) — esta classe não conhece DatabaseHelper.

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/treino.dart';
import '../../domain/entities/treino_exercicio.dart';
import '../../domain/repositories/treino_repository.dart';
import '../datasources/treino_dao.dart';

class TreinoRepositoryImpl implements TreinoRepository {
  final TreinoDao _dao;

  /// Recebe o DAO via construtor — padrão de injeção de dependência.
  TreinoRepositoryImpl(this._dao);

  // ══════════════════════════════════════════════════════════════════════════
  // TREINOS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<Treino>> listarPorAluno(int alunoId) {
    // Delegação direta — lista vazia é retorno válido, não é erro.
    return _dao.listarTreinosPorAluno(alunoId);
  }

  @override
  Future<Treino> buscarPorId(int id) async {
    // O DAO retorna null quando o id não existe (ou treino foi deletado).
    // Aqui convertemos null → exceção de domínio.
    final treino = await _dao.buscarTreinoPorId(id);
    if (treino == null) throw const TreinoNaoEncontradoException();
    return treino;
  }

  @override
  Future<int> criar(Treino treino) {
    // Validações já foram feitas pelo use case CriarTreino.
    // Apenas persiste e retorna o id gerado pelo banco.
    return _dao.inserirTreino(treino);
  }

  @override
  Future<void> atualizar(Treino treino) async {
    // Verifica existência antes de atualizar.
    // O DAO não distingue "id inexistente" de "id existente" no UPDATE
    // (ambos executam silenciosamente, afetando 0 ou 1 linha).
    final existente = await _dao.buscarTreinoPorId(treino.id!);
    if (existente == null) throw const TreinoNaoEncontradoException();
    await _dao.atualizarTreino(treino);
  }

  @override
  Future<void> deletar(int id) async {
    // softDeleteTreino retorna int: linhas afetadas.
    // 0 = id não existe ou treino já foi deletado → não encontrado.
    final afetadas = await _dao.softDeleteTreino(id);
    if (afetadas == 0) throw const TreinoNaoEncontradoException();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXERCÍCIOS
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<TreinoExercicio>> listarExercicios(int treinoId) {
    // Delegação direta — lista vazia é válida (treino sem exercícios).
    return _dao.listarExercicios(treinoId);
  }

  @override
  Future<int> adicionarExercicio(TreinoExercicio exercicio) {
    // O campo `ordem` já foi calculado pelo use case AdicionarExercicio.
    // Apenas persiste e retorna o id gerado pelo banco.
    return _dao.inserirExercicio(exercicio);
  }

  @override
  Future<void> atualizarExercicio(TreinoExercicio exercicio) async {
    // Verifica existência antes de atualizar.
    final existente = await _dao.buscarExercicioPorId(exercicio.id!);
    if (existente == null) throw const ExercicioNaoEncontradoException();
    await _dao.atualizarExercicio(exercicio);
  }

  @override
  Future<void> deletarExercicio(int id) async {
    // softDeleteExercicio retorna int: linhas afetadas.
    final afetadas = await _dao.softDeleteExercicio(id);
    if (afetadas == 0) throw const ExercicioNaoEncontradoException();
  }

  @override
  Future<void> reordenarExercicios(List<TreinoExercicio> exercicios) {
    // O use case ReordenarExercicios já calculou as novas ordens.
    // Persiste em batch — a transação no DAO garante atomicidade.
    return _dao.atualizarOrdemExercicios(exercicios);
  }
}
