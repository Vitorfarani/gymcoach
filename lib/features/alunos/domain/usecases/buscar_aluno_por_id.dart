// buscar_aluno_por_id.dart
//
// Use case: busca um único aluno pelo id.
//
// Usado ao abrir o perfil de um aluno ou antes de editar.
// Garante que a tela sempre trabalha com dados frescos do banco.

import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class BuscarAlunoPorId {
  final AlunoRepository _repository;

  BuscarAlunoPorId(this._repository);

  /// Retorna o [Aluno] correspondente ao [id].
  ///
  /// Lança [AlunoNaoEncontradoException] se o id não existir ou se o aluno
  /// tiver sido deletado (soft delete).
  /// Lança [DatabaseException] em falha de leitura.
  Future<Aluno> call(int id) async {
    return _repository.buscarPorId(id);
  }
}
