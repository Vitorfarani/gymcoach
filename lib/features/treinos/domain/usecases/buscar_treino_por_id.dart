// buscar_treino_por_id.dart
//
// Use case: busca um treino específico pelo seu id.
//
// QUANDO USAR:
//   Na DetalhesTreinoScreen — ao entrar na tela, o provider carrega
//   o treino completo pelo id recebido como parâmetro de rota.
//   Também usado internamente por outros use cases que precisam do treino atual.

import '../entities/treino.dart';
import '../repositories/treino_repository.dart';

class BuscarTreinoPorId {
  final TreinoRepository _repository;

  BuscarTreinoPorId(this._repository);

  /// Retorna o treino com o [id] informado.
  ///
  /// Lança [TreinoNaoEncontradoException] se o id não existir ou treino deletado.
  /// Lança [DatabaseException] em falha de leitura.
  Future<Treino> call(int id) async {
    return _repository.buscarPorId(id);
  }
}
