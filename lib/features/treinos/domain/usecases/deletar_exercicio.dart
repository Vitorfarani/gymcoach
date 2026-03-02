// deletar_exercicio.dart
//
// Use case: remove um exercício da lista de um treino (soft delete).
//
// COMPORTAMENTO:
//   Preenche `deletado_em` com o timestamp atual — o exercício some da UI.
//
// ATENÇÃO — ordenação após deleção:
//   Após deletar um exercício, os demais ficam com "buracos" no campo `ordem`.
//   Exemplo: exercícios de ordem [0, 1, 2, 3] → deleta o 1 → ficam [0, 2, 3].
//   A lista ainda funciona corretamente (ORDER BY ordem ASC), mas os valores
//   ficam não-contíguos. Isso é aceitável no MVP — a reordenação normaliza
//   os valores quando o professor usa subir/descer.
//
// QUANDO USAR:
//   Na DetalhesTreinoScreen, quando o professor desliza/clica em "remover exercício".

import '../repositories/treino_repository.dart';

class DeletarExercicio {
  final TreinoRepository _repository;

  DeletarExercicio(this._repository);

  /// Executa o soft delete do exercício com o [id] informado.
  ///
  /// Lança [ExercicioNaoEncontradoException] se o id não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(int id) async {
    await _repository.deletarExercicio(id);
  }
}
