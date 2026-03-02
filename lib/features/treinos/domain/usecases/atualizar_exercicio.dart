// atualizar_exercicio.dart
//
// Use case: atualiza os dados de um exercício existente.
//
// CAMPOS EDITÁVEIS: nomeExercicio, series, repeticoes, carga, observacao.
// A ordem NÃO é editada aqui — use ReordenarExercicios para isso.
//
// COMO USAR (na presentation):
//   O provider faz exercicio.copyWith(series: '5') e passa ao use case.
//
//   Exemplo:
//     final editado = exercicio.copyWith(carga: '25kg', series: '5');
//     await atualizarExercicio(editado);

import '../../../../core/errors/exceptions.dart';
import '../entities/treino_exercicio.dart';
import '../repositories/treino_repository.dart';

class AtualizarExercicio {
  final TreinoRepository _repository;

  AtualizarExercicio(this._repository);

  /// Executa o use case.
  ///
  /// [exercicio] deve ter [TreinoExercicio.id] preenchido.
  /// Use [TreinoExercicio.copyWith] para criar a versão atualizada antes de chamar.
  ///
  /// Lança [NomeObrigatorioException] se nomeExercicio estiver vazio.
  /// Lança [SeriesObrigatorioException] se series estiver vazio.
  /// Lança [ExercicioNaoEncontradoException] se o exercício não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(TreinoExercicio exercicio) async {
    // ── Validação ─────────────────────────────────────────────────────────────
    if (exercicio.nomeExercicio.trim().isEmpty) {
      throw const NomeObrigatorioException();
    }
    if (exercicio.series.trim().isEmpty) {
      throw const SeriesObrigatorioException();
    }

    // ── Normalização + timestamp ───────────────────────────────────────────────
    // Aplica trim nos campos de texto e atualiza dataAtualizacao.
    // A `ordem` não é tocada aqui — ReordenarExercicios cuida disso.
    final exercicioAtualizado = exercicio.copyWith(
      nomeExercicio: exercicio.nomeExercicio.trim(),
      series: exercicio.series.trim(),
      repeticoes: exercicio.repeticoes?.trim(),
      carga: exercicio.carga?.trim(),
      observacao: exercicio.observacao?.trim(),
      dataAtualizacao: DateTime.now(),
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    await _repository.atualizarExercicio(exercicioAtualizado);
  }
}
