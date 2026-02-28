// editar_aluno.dart
//
// Use case: atualiza os dados de um aluno existente.
//
// RESPONSABILIDADE:
//   1. Valida os campos editáveis
//   2. Garante que updatedAt reflete o momento da edição
//   3. Delega a persistência ao repositório
//   4. Retorna o Aluno com os dados atualizados
//
// COMO USAR (na presentation):
//   O provider faz aluno.copyWith(...campos editados...) e passa ao use case.
//   Exemplo:
//     final atualizado = aluno.copyWith(nome: 'Novo Nome', peso: 85.0);
//     await editarAluno(atualizado);

import '../../../../core/errors/exceptions.dart';
import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class EditarAluno {
  final AlunoRepository _repository;

  EditarAluno(this._repository);

  /// Executa o use case.
  ///
  /// [aluno] deve ter [Aluno.id] preenchido — é um aluno que já existe no banco.
  /// Use [Aluno.copyWith] para criar a versão editada antes de chamar este use case.
  Future<Aluno> call(Aluno aluno) async {
    // ── Validação ─────────────────────────────────────────────────────────────
    // Mesmas regras de CriarAluno — doc1 não distingue create de update.
    if (aluno.nome.trim().isEmpty) throw const NomeObrigatorioException();
    final tamanhoNome = aluno.nome.trim().length;
    if (tamanhoNome < 2 || tamanhoNome > 60) throw const NomeInvalidoException();

    if (aluno.idade != null && (aluno.idade! < 10 || aluno.idade! > 99)) {
      throw const IdadeInvalidaException();
    }
    if (aluno.peso != null && (aluno.peso! < 30 || aluno.peso! > 250)) {
      throw const PesoInvalidoException();
    }
    if (aluno.altura != null && (aluno.altura! < 100 || aluno.altura! > 250)) {
      throw const AlturaInvalidaException();
    }

    // ── Atualiza timestamp de modificação ────────────────────────────────────
    // updatedAt deve refletir o momento exato da edição, não o valor anterior.
    final alunoAtualizado = aluno.copyWith(
      nome: aluno.nome.trim(),
      objetivo: aluno.objetivo?.trim(),
      observacoes: aluno.observacoes?.trim(),
      updatedAt: DateTime.now(),
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    // Pode lançar AlunoNaoEncontradoException ou DatabaseException.
    return _repository.editar(alunoAtualizado);
  }
}
