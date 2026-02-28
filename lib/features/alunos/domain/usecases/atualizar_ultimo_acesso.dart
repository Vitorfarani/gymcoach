// atualizar_ultimo_acesso.dart
//
// Use case: atualiza o campo `ultimo_acesso` de um aluno para agora.
//
// QUANDO CHAMAR:
//   Sempre que o professor abrir o perfil de um aluno (PerfilAlunoScreen).
//   Deve ser chamado silenciosamente em background — não bloqueia a UI.
//
// POR QUE É UM USE CASE PRÓPRIO:
//   É uma operação com semântica própria ("registrar acesso"), separada
//   de "editar aluno". Manter separado facilita chamar sem passar o objeto
//   Aluno completo — apenas o id é necessário.

import '../repositories/aluno_repository.dart';

class AtualizarUltimoAcesso {
  final AlunoRepository _repository;

  AtualizarUltimoAcesso(this._repository);

  /// Atualiza `ultimo_acesso` do aluno com o [id] para [DateTime.now()].
  ///
  /// Lança [AlunoNaoEncontradoException] se o id não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(int id) async {
    await _repository.atualizarUltimoAcesso(id);
  }
}
