// listar_alunos.dart
//
// Use case: retorna a lista de alunos ativos, com busca opcional por nome.
//
// COMPORTAMENTO:
//   - Apenas alunos com `deletado_em IS NULL` aparecem
//   - Ordenação: nome ASC
//   - Se [query] for informado, filtra por nome (busca parcial, case-insensitive)
//   - Retorna lista vazia se não houver alunos — não lança exceção

import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class ListarAlunos {
  final AlunoRepository _repository;

  ListarAlunos(this._repository);

  /// Retorna a lista de alunos ativos.
  ///
  /// [query] é opcional. Quando informado, filtra por nome.
  /// Lança [DatabaseException] em falha de leitura.
  Future<List<Aluno>> call({String? query}) async {
    // Normaliza query vazia para null — sem filtro
    final queryNormalizada = (query?.trim().isEmpty ?? true) ? null : query!.trim();
    return _repository.listar(query: queryNormalizada);
  }
}
