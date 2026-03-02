// atualizar_treino.dart
//
// Use case: atualiza nome e/ou descrição de um treino existente.
//
// COMO USAR (na presentation):
//   O provider faz treino.copyWith(nome: 'Novo Nome') e passa ao use case.
//   O use case aplica trim, atualiza o timestamp e delega ao repositório.
//
//   Exemplo:
//     final treinoEditado = treino.copyWith(nome: 'Treino B');
//     await atualizarTreino(treinoEditado);

import '../../../../core/errors/exceptions.dart';
import '../entities/treino.dart';
import '../repositories/treino_repository.dart';

class AtualizarTreino {
  final TreinoRepository _repository;

  AtualizarTreino(this._repository);

  /// Executa o use case.
  ///
  /// [treino] deve ter [Treino.id] preenchido — é um treino que já existe no banco.
  /// Use [Treino.copyWith] para criar a versão atualizada antes de chamar.
  ///
  /// Lança [NomeObrigatorioException] se o nome estiver vazio.
  /// Lança [TreinoNaoEncontradoException] se o treino não existir no banco.
  /// Lança [DatabaseException] em falha de persistência.
  Future<void> call(Treino treino) async {
    // ── Validação ─────────────────────────────────────────────────────────────
    if (treino.nome.trim().isEmpty) throw const NomeObrigatorioException();

    // ── Normalização + timestamp ───────────────────────────────────────────────
    // Aplica trim no nome e atualiza dataAtualizacao para o momento exato da edição.
    // O copyWith preserva todos os outros campos (alunoId, dataCriacao, etc.).
    final treinoAtualizado = treino.copyWith(
      nome: treino.nome.trim(),
      descricao: treino.descricao?.trim(),
      dataAtualizacao: DateTime.now(),
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    await _repository.atualizar(treinoAtualizado);
  }
}
