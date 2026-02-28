// image_helper.dart
//
// Utilitário para processar e salvar fotos de alunos no dispositivo.
//
// RESPONSABILIDADE ÚNICA:
//   Processar o arquivo de imagem: resize, compressão e gravação em disco.
//   Não sabe nada sobre alunos, banco de dados ou regras de negócio.
//
// POR QUE FICA EM core/utils/ E NÃO EM features/alunos/?
//   Processar imagens é capacidade de infraestrutura, não regra de negócio
//   de alunos. Em tese, outras features poderiam usar o mesmo utilitário.
//
// DEPENDÊNCIAS (pacotes em pubspec.yaml):
//   - path_provider: localiza o diretório de documentos do app no dispositivo
//   - flutter_image_compress: faz resize e compressão JPEG
//   - path: monta caminhos de arquivo (já usado pelo DatabaseHelper)

import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../errors/exceptions.dart';

class ImageHelper {
  // Dimensão máxima: imagem será redimensionada para caber em 800×800px.
  // Imagens menores não são ampliadas — só reduzidas se necessário.
  static const int _tamanhoMaxPx = 800;

  // Qualidade JPEG: 85 = boa qualidade visual com tamanho razoável no disco.
  static const int _qualidadeJpeg = 85;

  // Subdiretório dentro dos documentos do app onde as fotos ficam.
  static const String _dirFotos = 'fotos_alunos';

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  /// Processa uma imagem e a salva no diretório de documentos do app.
  ///
  /// Passos:
  /// 1. Garante que o diretório `fotos_alunos/` existe
  /// 2. Redimensiona para no máximo 800×800px (proporção preservada)
  /// 3. Comprime em JPEG com qualidade 85
  /// 4. Grava como `aluno_<alunoId>.jpg`
  ///
  /// Retorna o caminho absoluto do arquivo salvo.
  ///
  /// Lança [ErroAoProcessarImagemException] se o processamento falhar.
  static Future<String> processarESalvar(int alunoId, File imagem) async {
    try {
      // getApplicationDocumentsDirectory() → caminho permanente do app.
      // Ex: /data/user/0/com.example.gymcoach/app_flutter/
      // Diferente do cache (que pode ser apagado pelo sistema).
      final appDir = await getApplicationDocumentsDirectory();

      // Cria o subdiretório fotos_alunos/ se ainda não existir.
      final dirFotos = Directory(p.join(appDir.path, _dirFotos));
      if (!dirFotos.existsSync()) {
        await dirFotos.create(recursive: true);
      }

      // O nome do arquivo é fixo por aluno: "aluno_42.jpg".
      // Ao trocar a foto, o arquivo antigo é sobrescrito automaticamente.
      final destino = p.join(dirFotos.path, 'aluno_$alunoId.jpg');

      // compressAndGetFile faz resize + compressão e grava no destino.
      // minWidth/minHeight = dimensão máxima (não mínima, apesar do nome).
      // Retorna XFile? — null indica falha no processamento.
      final resultado = await FlutterImageCompress.compressAndGetFile(
        imagem.absolute.path, // arquivo fonte
        destino, // arquivo destino
        minWidth: _tamanhoMaxPx,
        minHeight: _tamanhoMaxPx,
        quality: _qualidadeJpeg,
        format: CompressFormat.jpeg,
      );

      if (resultado == null) throw const ErroAoProcessarImagemException();

      return resultado.path;
    } on AppException {
      // Nossas próprias exceções passam direto sem modificação.
      rethrow;
    } catch (_) {
      // Qualquer outra falha (formato inválido, arquivo corrompido, etc.)
      // é convertida para a exceção de domínio.
      throw const ErroAoProcessarImagemException();
    }
  }

  /// Deleta um arquivo do dispositivo pelo caminho absoluto.
  ///
  /// Operação idempotente: não lança exceção se o arquivo não existir.
  /// Erros de I/O são silenciados — a foto pode já ter sido deletada
  /// manualmente ou o caminho pode estar inconsistente.
  static Future<void> deletarArquivo(String caminho) async {
    try {
      final arquivo = File(caminho);
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } catch (_) {
      // Ignora — não interrompe o fluxo principal por causa de um arquivo.
    }
  }
}
