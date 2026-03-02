// listar_exercicios.dart
//
// Use case: retorna a lista de exercícios ativos de um treino.
//
// COMPORTAMENTO:
//   - Apenas exercícios com `deletado_em IS NULL` aparecem
//   - Ordenados por `ordem ASC` (o campo que o professor controla com subir/descer)
//   - Retorna lista vazia se o treino não tiver exercícios — não lança exceção
//
// QUANDO USAR:
//   Na DetalhesTreinoScreen, para popular a lista de exercícios.
//   Também chamado internamente por ReordenarExercicios e AdicionarExercicio.

import '../entities/treino_exercicio.dart';
import '../repositories/treino_repository.dart';

class ListarExercicios {
  final TreinoRepository _repository;

  ListarExercicios(this._repository);

  /// Retorna os exercícios ativos do treino com [treinoId], ordenados por [ordem].
  ///
  /// Lança [TreinoNaoEncontradoException] se o treino não existir.
  /// Lança [DatabaseException] em falha de leitura.
  Future<List<TreinoExercicio>> call(int treinoId) async {
    return _repository.listarExercicios(treinoId);
  }
}
