// listar_treinos_do_aluno.dart
//
// Use case: retorna a lista de treinos ativos de um aluno.
//
// COMPORTAMENTO:
//   - Apenas treinos com `deletado_em IS NULL` aparecem
//   - Ordenação: `created_at ASC` (ordem de criação — doc4)
//   - Retorna lista vazia se o aluno não tiver treinos — não lança exceção
//
// QUANDO USAR:
//   Na tela de lista de treinos de um aluno (ListaTreinosScreen).
//   O provider chama este use case sempre que o aluno for aberto.

import '../entities/treino.dart';
import '../repositories/treino_repository.dart';

class ListarTreinosDoAluno {
  final TreinoRepository _repository;

  ListarTreinosDoAluno(this._repository);

  /// Retorna os treinos ativos do aluno com [alunoId].
  ///
  /// Lança [AlunoNaoEncontradoException] se o aluno não existir.
  /// Lança [DatabaseException] em falha de leitura.
  Future<List<Treino>> call(int alunoId) async {
    return _repository.listarPorAluno(alunoId);
  }
}
