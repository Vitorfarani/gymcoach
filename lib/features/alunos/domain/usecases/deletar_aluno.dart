// deletar_aluno.dart
//
// Use case: soft delete de um aluno.
//
// COMPORTAMENTO:
//   Preenche `deletado_em` com o timestamp atual — o aluno some da UI mas
//   o dado permanece no banco. Não há tela de recuperação no MVP.
//
//   O cascade do banco cuida do resto:
//   aluno → treinos → exercícios → sessões → registros de execução

import '../repositories/aluno_repository.dart';

class DeletarAluno {
  final AlunoRepository _repository;

  DeletarAluno(this._repository);

  /// Executa o soft delete do aluno com o [id] informado.
  ///
  /// Lança [AlunoNaoEncontradoException] se o id não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(int id) async {
    await _repository.deletar(id);
  }
}
