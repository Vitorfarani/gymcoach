// deletar_treino.dart
//
// Use case: soft delete de um treino.
//
// COMPORTAMENTO (doc1 e doc4):
//   Preenche `deletado_em` com o timestamp atual — o treino some da UI.
//
//   O banco cuida do cascade automaticamente:
//   treino → exercícios (ON DELETE CASCADE)
//   sessoes.treino_id → NULL (ON DELETE SET NULL)
//   — o histórico de sessões é preservado, só perde o link com o treino.
//
// QUANDO USAR:
//   Na tela de detalhes do treino, quando o professor confirma a exclusão.

import '../repositories/treino_repository.dart';

class DeletarTreino {
  final TreinoRepository _repository;

  DeletarTreino(this._repository);

  /// Executa o soft delete do treino com o [id] informado.
  ///
  /// Lança [TreinoNaoEncontradoException] se o id não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(int id) async {
    await _repository.deletar(id);
  }
}
