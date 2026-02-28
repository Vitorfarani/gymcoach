// contar_alunos_ativos.dart
//
// Use case: retorna o total de alunos ativos.
//
// Usado pelo dashboard para exibir o número em destaque.
// "Ativo" = deletado_em IS NULL AND ativo = 1

import '../repositories/aluno_repository.dart';

class ContarAlunosAtivos {
  final AlunoRepository _repository;

  ContarAlunosAtivos(this._repository);

  /// Retorna o total de alunos ativos como [int].
  ///
  /// Lança [DatabaseException] em falha de leitura.
  Future<int> call() async {
    return _repository.contarAtivos();
  }
}
