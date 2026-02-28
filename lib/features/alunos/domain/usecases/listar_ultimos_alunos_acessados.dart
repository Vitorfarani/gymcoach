// listar_ultimos_alunos_acessados.dart
//
// Use case: retorna os últimos alunos acessados pelo professor.
//
// COMPORTAMENTO:
//   - Ordenação: ultimo_acesso DESC
//   - Limite fixo de 5 (definido no dashboard — doc4)
//   - Usado exclusivamente pelo dashboard como atalho rápido
//
// Por que o limite fica no use case e não no widget?
// Porque "mostrar apenas 5 alunos recentes" é uma regra de negócio do
// dashboard, não uma decisão visual da tela.

import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class ListarUltimosAlunosAcessados {
  final AlunoRepository _repository;

  // Limite definido pelo doc4 — não deve ser configurável pela UI no MVP.
  static const int _limite = 5;

  ListarUltimosAlunosAcessados(this._repository);

  /// Retorna os últimos [_limite] alunos acessados.
  ///
  /// Lança [DatabaseException] em falha de leitura.
  Future<List<Aluno>> call() async {
    return _repository.listarUltimosAcessados(_limite);
  }
}
