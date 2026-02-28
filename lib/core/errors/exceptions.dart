// exceptions.dart
//
// Define todas as exceções de domínio do app GymCoach.
//
// QUANDO USAR: lance (throw) uma dessas exceções quando algo der errado
// dentro de um DAO, repository ou use case.
//
// CONVENÇÃO: exceções são capturadas (try/catch) na camada imediatamente
// acima e convertidas em Failure (veja failures.dart) para a UI tratar.

// =============================================================================
// BASE
// =============================================================================

/// Classe base de todas as exceções do app.
///
/// Implementa [Exception] (não [Error]) porque são situações esperadas
/// pelo domínio — não são bugs do programa, são cenários tratáveis.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  /// Permite que o Flutter mostre a mensagem em logs automaticamente.
  @override
  String toString() => 'AppException: $message';
}

// =============================================================================
// VALIDAÇÃO — campos obrigatórios e fora de range
// =============================================================================

/// Nome não foi informado (vazio ou nulo).
/// Use em: CriarAluno, EditarAluno, CriarTreino, EditarTreino,
///         CriarExercicio, EditarExercicio
class NomeObrigatorioException extends AppException {
  const NomeObrigatorioException() : super('O nome é obrigatório.');
}

/// Nome fora do range permitido (< 2 ou > 60 caracteres).
/// Regra: doc1 — campo nome do aluno.
class NomeInvalidoException extends AppException {
  const NomeInvalidoException()
      : super('O nome deve ter entre 2 e 60 caracteres.');
}

/// Idade fora do range permitido (< 10 ou > 99).
/// Regra: doc1 — campo idade do aluno.
class IdadeInvalidaException extends AppException {
  const IdadeInvalidaException()
      : super('A idade deve estar entre 10 e 99 anos.');
}

/// Peso fora do range permitido (< 30 ou > 250 kg).
/// Regra: doc1 — campo peso do aluno.
class PesoInvalidoException extends AppException {
  const PesoInvalidoException()
      : super('O peso deve estar entre 30 e 250 kg.');
}

/// Altura fora do range permitido (< 100 ou > 250 cm).
/// Regra: doc1 — campo altura do aluno.
class AlturaInvalidaException extends AppException {
  const AlturaInvalidaException()
      : super('A altura deve estar entre 100 e 250 cm.');
}

/// Séries não foram informadas em um exercício.
/// Regra: doc4 — CriarExercicio exige nome_exercicio + series.
class SeriesObrigatorioException extends AppException {
  const SeriesObrigatorioException()
      : super('O número de séries é obrigatório.');
}

// =============================================================================
// NÃO ENCONTRADO — entidade buscada não existe no banco
// =============================================================================

/// Aluno com o id informado não existe (ou foi deletado).
class AlunoNaoEncontradoException extends AppException {
  const AlunoNaoEncontradoException() : super('Aluno não encontrado.');
}

/// Treino com o id informado não existe.
class TreinoNaoEncontradoException extends AppException {
  const TreinoNaoEncontradoException() : super('Treino não encontrado.');
}

/// Exercício com o id informado não existe.
class ExercicioNaoEncontradoException extends AppException {
  const ExercicioNaoEncontradoException()
      : super('Exercício não encontrado.');
}

/// Sessão com o id informado não existe.
class SessaoNaoEncontradaException extends AppException {
  const SessaoNaoEncontradaException() : super('Sessão não encontrada.');
}

/// Registro de execução com o id informado não existe.
class RegistroNaoEncontradoException extends AppException {
  const RegistroNaoEncontradoException()
      : super('Registro de execução não encontrado.');
}

// =============================================================================
// REGRAS DE NEGÓCIO
// =============================================================================

/// Tentativa de reordenar exercício além dos limites da lista.
/// Ex: subir o primeiro exercício ou descer o último.
/// Regra: doc4 — ReordenarExercicio.
class ReordenacaoImpossivelException extends AppException {
  const ReordenacaoImpossivelException()
      : super('Não é possível reordenar nessa direção.');
}

// =============================================================================
// INFRAESTRUTURA — banco de dados e arquivos
// =============================================================================

/// Erro ao ler ou escrever no banco SQLite.
///
/// Recebe [message] dinâmica para encapsular a mensagem técnica do sqflite,
/// preservando o contexto do erro para debug sem vazar detalhes ao usuário.
class DatabaseException extends AppException {
  const DatabaseException(super.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Imagem selecionada ultrapassa o limite de 5 MB.
/// Regra: doc1 — foto do aluno.
class ImagemMuitoGrandeException extends AppException {
  const ImagemMuitoGrandeException()
      : super('A imagem não pode ser maior que 5 MB.');
}

/// Falha ao redimensionar ou comprimir a imagem.
/// Pode ocorrer por formato não suportado ou arquivo corrompido.
class ErroAoProcessarImagemException extends AppException {
  const ErroAoProcessarImagemException()
      : super('Erro ao processar a imagem. Tente outra foto.');
}
