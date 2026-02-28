// salvar_foto_aluno.dart
//
// Use case: processa e persiste a foto de um aluno.
//
// COMPORTAMENTO (doc4):
//   1. Valida que o arquivo tem menos de 5 MB
//   2. Redimensiona para 800×800px e comprime (feito pelo repository/image_helper)
//   3. Salva no diretório de arquivos do app
//   4. Atualiza foto_path no banco
//
// POR QUE A VALIDAÇÃO DE 5MB FICA AQUI E NÃO NO REPOSITORY:
//   É uma regra de negócio do domínio ("não aceitar fotos grandes demais"),
//   não uma restrição de infraestrutura. O repository apenas executa.

import 'dart:io' show File;

import '../../../../core/errors/exceptions.dart';
import '../repositories/aluno_repository.dart';

class SalvarFotoAluno {
  final AlunoRepository _repository;

  // Limite definido em doc1 e doc4.
  static const int _limiteBytes = 5 * 1024 * 1024; // 5 MB

  SalvarFotoAluno(this._repository);

  /// Processa e salva a foto do aluno com o [id] informado.
  ///
  /// Retorna o caminho absoluto do arquivo salvo no dispositivo.
  ///
  /// Lança [ImagemMuitoGrandeException] se [foto] ultrapassar 5 MB.
  /// Lança [AlunoNaoEncontradoException] se o id não existir.
  /// Lança [ErroAoProcessarImagemException] em falha de processamento.
  /// Lança [DatabaseException] em falha de persistência.
  Future<String> call(int id, File foto) async {
    // ── Validação de tamanho ──────────────────────────────────────────────────
    final tamanhoBytes = await foto.length();
    if (tamanhoBytes > _limiteBytes) {
      throw const ImagemMuitoGrandeException();
    }

    // ── Processamento e persistência ──────────────────────────────────────────
    // O repository cuida do resize (800×800px), compressão e gravação no disco.
    return _repository.salvarFoto(id, foto);
  }
}
