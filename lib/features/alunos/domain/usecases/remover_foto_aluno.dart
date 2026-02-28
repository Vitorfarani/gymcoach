// remover_foto_aluno.dart
//
// Use case: remove a foto de um aluno.
//
// COMPORTAMENTO (doc4):
//   1. Deleta o arquivo físico do dispositivo
//   2. Limpa foto_path no banco (seta para NULL)
//
// As duas operações são coordenadas pelo repository para garantir
// que arquivo e banco nunca fiquem dessincronizados.

import '../repositories/aluno_repository.dart';

class RemoverFotoAluno {
  final AlunoRepository _repository;

  RemoverFotoAluno(this._repository);

  /// Remove a foto do aluno com o [id] informado.
  ///
  /// Lança [AlunoNaoEncontradoException] se o id não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(int id) async {
    await _repository.removerFoto(id);
  }
}
