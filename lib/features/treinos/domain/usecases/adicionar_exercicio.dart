// adicionar_exercicio.dart
//
// Use case: adiciona um novo exercício ao final da lista de um treino.
//
// RESPONSABILIDADE:
//   1. Valida campos obrigatórios (nome_exercicio e series — doc1)
//   2. Calcula a ordem: busca os exercícios existentes e usa `count` como índice
//   3. Monta o objeto TreinoExercicio com timestamps
//   4. Delega a persistência ao repositório
//   5. Retorna o TreinoExercicio com o id gerado
//
// POR QUE BUSCAR A LISTA AQUI (e não receber `ordem` como parâmetro)?
//   A responsabilidade de calcular a ordem é do domínio, não da presentation.
//   O provider não deve saber como a ordenação funciona internamente.
//   Buscar os existentes garante que `ordem` nunca fique inconsistente mesmo
//   que o provider não tenha a lista atualizada.

import '../../../../core/errors/exceptions.dart';
import '../entities/treino_exercicio.dart';
import '../repositories/treino_repository.dart';

class AdicionarExercicio {
  final TreinoRepository _repository;

  AdicionarExercicio(this._repository);

  /// Executa o use case.
  ///
  /// [treinoId] é o treino ao qual o exercício será adicionado.
  /// [nomeExercicio] é obrigatório.
  /// [series] é obrigatório — ex: "4", "3-4 séries".
  /// [repeticoes], [carga] e [observacao] são opcionais — texto livre.
  ///
  /// Retorna o [TreinoExercicio] criado com o [TreinoExercicio.id] preenchido.
  ///
  /// Lança [NomeObrigatorioException] se nomeExercicio estiver vazio.
  /// Lança [SeriesObrigatorioException] se series estiver vazio.
  /// Lança [DatabaseException] em falha de persistência.
  Future<TreinoExercicio> call({
    required int treinoId,
    required String nomeExercicio,
    required String series,
    String? repeticoes,
    String? carga,
    String? observacao,
  }) async {
    // ── Validação ─────────────────────────────────────────────────────────────
    if (nomeExercicio.trim().isEmpty) throw const NomeObrigatorioException();
    if (series.trim().isEmpty) throw const SeriesObrigatorioException();

    // ── Calcula a ordem ───────────────────────────────────────────────────────
    // O novo exercício vai para o final da lista.
    // `ordem` usa índice 0-based: se há 3 exercícios (ordens 0,1,2),
    // o novo recebe `ordem = 3`.
    final existentes = await _repository.listarExercicios(treinoId);
    final proximaOrdem = existentes.length;

    // ── Construção do objeto ───────────────────────────────────────────────────
    final agora = DateTime.now();

    final novoExercicio = TreinoExercicio(
      // id: null — será preenchido pelo banco no INSERT
      treinoId: treinoId,
      nomeExercicio: nomeExercicio.trim(),
      series: series.trim(),
      repeticoes: repeticoes?.trim(),
      carga: carga?.trim(),
      observacao: observacao?.trim(),
      ordem: proximaOrdem,
      dataCriacao: agora,
      dataAtualizacao: agora,
      deletadoEm: null,
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    final id = await _repository.adicionarExercicio(novoExercicio);

    return novoExercicio.copyWith(id: id);
  }
}
