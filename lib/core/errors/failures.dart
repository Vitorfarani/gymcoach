// failures.dart
//
// Define os tipos de Failure que a camada de apresentação (providers/UI)
// usa para representar erros de forma estruturada.
//
// POR QUE FAILURES ALÉM DE EXCEPTIONS?
// Exceções interrompem o fluxo — são lançadas e capturadas.
// Failures são *valores* — podem ser guardados, comparados e inspecionados.
// O Riverpod armazena failures em AsyncValue.error; a UI faz switch no tipo.
//
// FLUXO COMPLETO:
//   DAO lança DatabaseException
//   → UseCase captura e relança como AppException
//   → Provider captura e o AsyncValue.error armazena a exception diretamente
//   → UI usa failureFromException() para converter e exibir mensagem certa
//
// DART 3 SEALED CLASSES:
// "sealed" garante que todo switch sobre Failure seja exaustivo.
// O compilador avisa se você esquecer de tratar um subtipo — segurança de tipo
// sem precisar de biblioteca externa como dartz.

import 'exceptions.dart';

// =============================================================================
// BASE SEALED
// =============================================================================

/// Classe base selada de todos os failures do app.
///
/// Por ser [sealed], todos os subtipos devem estar neste arquivo.
/// Isso permite usar switch exhaustivo na UI:
///
/// ```dart
/// switch (failure) {
///   case ValidationFailure() => mostrarErroDeValidacao(failure.message),
///   case NotFoundFailure()   => mostrarNaoEncontrado(failure.message),
///   case DatabaseFailure()   => mostrarErroBanco(failure.message),
///   case ImageFailure()      => mostrarErroImagem(failure.message),
///   case BusinessFailure()   => mostrarRegraDeNegocio(failure.message),
/// }
/// ```
sealed class Failure {
  final String message;

  const Failure(this.message);
}

// =============================================================================
// SUBTIPOS
// =============================================================================

/// Falha de validação de entrada.
/// Ocorre quando campos obrigatórios estão ausentes ou fora do range.
/// Exemplos: nome vazio, idade < 10, peso > 250.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Entidade não encontrada no banco de dados.
/// Ocorre quando um id buscado não corresponde a nenhum registro ativo.
/// Exemplos: aluno deletado, treino inexistente.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Falha ao acessar ou gravar no banco SQLite.
/// Ocorre por corrupção de banco, falta de espaço ou bug de query.
final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Falha relacionada a imagem ou arquivo de mídia.
/// Ocorre quando a imagem é grande demais ou não pode ser processada.
final class ImageFailure extends Failure {
  const ImageFailure(super.message);
}

/// Regra de negócio violada.
/// Ocorre quando a operação é inválida no contexto atual.
/// Exemplo: tentar subir o primeiro exercício da lista.
final class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}

// =============================================================================
// UTILITÁRIO — conversão de exception para failure
// =============================================================================

/// Converte qualquer [AppException] no [Failure] correspondente.
///
/// Use nos providers ao capturar exceções:
///
/// ```dart
/// } catch (e) {
///   final failure = failureFromException(e);
///   state = AsyncValue.error(failure, StackTrace.current);
/// }
/// ```
Failure failureFromException(Object exception) {
  return switch (exception) {
    // Validação
    NomeObrigatorioException()     => ValidationFailure(exception.message),
    NomeInvalidoException()        => ValidationFailure(exception.message),
    IdadeInvalidaException()       => ValidationFailure(exception.message),
    PesoInvalidoException()        => ValidationFailure(exception.message),
    AlturaInvalidaException()      => ValidationFailure(exception.message),
    SeriesObrigatorioException()   => ValidationFailure(exception.message),

    // Não encontrado
    AlunoNaoEncontradoException()  => NotFoundFailure(exception.message),
    TreinoNaoEncontradoException() => NotFoundFailure(exception.message),
    ExercicioNaoEncontradoException() => NotFoundFailure(exception.message),
    SessaoNaoEncontradaException() => NotFoundFailure(exception.message),
    RegistroNaoEncontradoException() => NotFoundFailure(exception.message),

    // Regras de negócio
    ReordenacaoImpossivelException() => BusinessFailure(exception.message),

    // Infraestrutura — imagem
    ImagemMuitoGrandeException()     => ImageFailure(exception.message),
    ErroAoProcessarImagemException() => ImageFailure(exception.message),

    // Infraestrutura — banco
    DatabaseException()            => DatabaseFailure(exception.message),

    // Qualquer outra coisa inesperada
    AppException()                 => DatabaseFailure(exception.message),
    _                              => const DatabaseFailure(
                                       'Erro inesperado. Tente novamente.',
                                     ),
  };
}
