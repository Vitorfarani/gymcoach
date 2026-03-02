// reordenar_exercicios.dart
//
// Use case: move um exercício para cima ou para baixo na lista do treino.
//
// COMPORTAMENTO (doc4):
//   Troca o valor de `ordem` entre o exercício alvo e o seu vizinho na direção.
//   Exemplo: lista [A(0), B(1), C(2)] — mover B para cima:
//     A(0) ← troca → B(1)   →   resultado: B(0), A(1), C(2)
//
// POR QUE NÃO É UMA DELEGAÇÃO SIMPLES?
//   Este use case PRECISA de lógica — sem ela, não existe funcionalidade.
//   O repositório só sabe salvar. Quem decide "qual exercício troca com qual"
//   é o domínio, aqui neste use case.
//
// FLUXO:
//   1. Busca a lista atual do treino (ordenada por `ordem ASC`)
//   2. Encontra o exercício e valida que existe
//   3. Valida que a direção é possível (não está no limite)
//   4. Troca os valores de `ordem` entre o exercício e o vizinho
//   5. Persiste a lista completa em batch (reordenarExercicios)

import '../../../../core/errors/exceptions.dart';
import '../entities/treino_exercicio.dart';
import '../repositories/treino_repository.dart';

/// Define a direção do movimento na lista.
enum DirecaoReordenacao {
  /// Move o exercício uma posição acima (ordem menor).
  subir,

  /// Move o exercício uma posição abaixo (ordem maior).
  descer,
}

class ReordenarExercicios {
  final TreinoRepository _repository;

  ReordenarExercicios(this._repository);

  /// Executa o use case.
  ///
  /// [treinoId] é o treino que contém o exercício.
  /// [exercicioId] é o exercício a ser movido.
  /// [direcao] é [DirecaoReordenacao.subir] ou [DirecaoReordenacao.descer].
  ///
  /// Lança [ExercicioNaoEncontradoException] se o exercício não estiver na lista.
  /// Lança [ReordenacaoImpossivelException] se já estiver no limite (primeiro/último).
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call({
    required int treinoId,
    required int exercicioId,
    required DirecaoReordenacao direcao,
  }) async {
    // ── Busca a lista atual ────────────────────────────────────────────────────
    // Lista já vem ordenada por `ordem ASC` do repositório.
    final lista = await _repository.listarExercicios(treinoId);

    // ── Encontra o exercício pelo id ───────────────────────────────────────────
    // `indexWhere` retorna -1 se não encontrar — tratamos como "não encontrado".
    final indice = lista.indexWhere((e) => e.id == exercicioId);
    if (indice == -1) throw const ExercicioNaoEncontradoException();

    // ── Valida se a reordenação é possível ────────────────────────────────────
    // Não dá para subir o primeiro ou descer o último.
    if (direcao == DirecaoReordenacao.subir && indice == 0) {
      throw const ReordenacaoImpossivelException();
    }
    if (direcao == DirecaoReordenacao.descer && indice == lista.length - 1) {
      throw const ReordenacaoImpossivelException();
    }

    // ── Calcula o índice do vizinho ────────────────────────────────────────────
    // Subir = trocar com o item anterior (índice - 1)
    // Descer = trocar com o item seguinte (índice + 1)
    final indiceVizinho =
        direcao == DirecaoReordenacao.subir ? indice - 1 : indice + 1;

    // ── Troca os valores de `ordem` entre os dois exercícios ──────────────────
    final exercicioAlvo = lista[indice];
    final exercicioVizinho = lista[indiceVizinho];
    final agora = DateTime.now();

    // Cria a lista atualizada com os dois exercícios trocados.
    // List.from() cria uma cópia mutável — a lista original não é modificada.
    final listaAtualizada = List<TreinoExercicio>.from(lista);

    listaAtualizada[indice] = exercicioAlvo.copyWith(
      ordem: exercicioVizinho.ordem,  // assume o `ordem` do vizinho
      dataAtualizacao: agora,
    );
    listaAtualizada[indiceVizinho] = exercicioVizinho.copyWith(
      ordem: exercicioAlvo.ordem,     // assume o `ordem` original do alvo
      dataAtualizacao: agora,
    );

    // ── Persiste a lista completa em batch ────────────────────────────────────
    // O repositório faz um UPDATE para cada item na lista.
    // Passamos a lista completa (com apenas 2 itens modificados) para manter
    // consistência com o contrato do repositório.
    await _repository.reordenarExercicios(listaAtualizada);
  }
}
