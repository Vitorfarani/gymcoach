// foto_picker_widget.dart
//
// Widget reutilizável para seleção e exibição da foto do aluno.
//
// RESPONSABILIDADE:
//   - Exibir o avatar circular com a foto atual (ou ícone placeholder)
//   - Ao tocar: abrir bottom sheet com opções câmera / galeria
//   - Validar o tamanho da imagem (limite de 5 MB conforme doc1)
//   - Chamar os callbacks do pai após seleção ou remoção válidas
//
// POR QUE StatelessWidget?
//   Este widget não guarda estado — a foto selecionada e a flag "fotoRemovida"
//   são estado das telas pai (CadastroAlunoScreen, EdicaoAlunoScreen).
//   O widget apenas exibe o que recebe e avisa o pai via callbacks.
//
// POR QUE CALLBACKS E NÃO USE CASES DIRETOS?
//   O mesmo widget é usado em dois contextos:
//   - Cadastro: aluno ainda não existe → foto é guardada para salvar junto
//   - Edição: aluno existe → foto pode ser salva imediatamente via SalvarFotoAluno
//   A decisão de "quando salvar" fica no pai, não no widget.
//
// FLUXO DE SELEÇÃO:
//   Toque → bottom sheet → câmera ou galeria → ImagePicker → valida 5MB →
//   onFotoSelecionada(file) → pai decide o que fazer

import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class FotoPickerWidget extends StatelessWidget {
  // Foto salva no banco (path de arquivo no dispositivo). Null se não tem foto.
  final String? fotoPath;

  // Foto nova selecionada nesta sessão, ainda não salva.
  // Usada no cadastro para mostrar preview antes de submeter o formulário.
  final File? novaFoto;

  // True quando o usuário removeu a foto durante a edição.
  // Necessário para não mostrar fotoPath depois de uma remoção.
  final bool fotoRemovida;

  // Chamado com o File selecionado após validação do tamanho.
  // O pai decide: guardar para salvar depois (cadastro) ou salvar agora (edição).
  final Future<void> Function(File foto) onFotoSelecionada;

  // Chamado quando o usuário pede para remover a foto.
  // O pai decide: limpar o estado (cadastro) ou chamar RemoverFotoAluno (edição).
  final VoidCallback onRemoverFoto;

  const FotoPickerWidget({
    super.key,
    this.fotoPath,
    this.novaFoto,
    this.fotoRemovida = false,
    required this.onFotoSelecionada,
    required this.onRemoverFoto,
  });

  // Determina se há alguma foto para exibir (nova ou existente não removida).
  bool get _temFoto {
    if (novaFoto != null) return true;
    if (!fotoRemovida && fotoPath != null) return true;
    return false;
  }

  // Constrói o ImageProvider correto dependendo do estado da foto.
  ImageProvider? get _imagemProvider {
    if (novaFoto != null) return FileImage(novaFoto!);
    if (!fotoRemovida && fotoPath != null) return FileImage(File(fotoPath!));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Avatar clicável ──────────────────────────────────────────────────
        // GestureDetector envolve o avatar para capturar o toque.
        GestureDetector(
          onTap: () => _abrirOpcoes(context),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Círculo da foto — 100dp de diâmetro (AppDimensions.avatarL)
              CircleAvatar(
                radius: AppDimensions.avatarL / 2,
                backgroundColor: AppColors.surfaceVariant,
                // Se tem foto, usa FileImage; caso contrário mostra ícone
                backgroundImage: _imagemProvider,
                child: _temFoto
                    ? null
                    : const Icon(
                        Icons.person,
                        size: AppDimensions.iconXL,
                        color: AppColors.textSecondary,
                      ),
              ),

              // Ícone de câmera sobreposto no canto inferior direito
              // Dá a dica visual de que o avatar é clicável
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.camera_alt,
                  size: AppDimensions.iconS,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // ── Botão de remover (só aparece quando há foto) ────────────────────
        if (_temFoto) ...[
          const SizedBox(height: AppDimensions.paddingXS),
          TextButton.icon(
            onPressed: onRemoverFoto,
            icon: const Icon(Icons.delete_outline, size: AppDimensions.iconS),
            label: const Text(AppStrings.fotoRemover),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  // ── Seleção de foto ──────────────────────────────────────────────────────

  /// Abre o bottom sheet com as opções de câmera e galeria.
  ///
  /// O contexto é capturado ANTES do showModalBottomSheet para poder
  /// mostrar SnackBar e chamar callbacks mesmo depois de fechar o sheet.
  void _abrirOpcoes(BuildContext context) {
    // Capturamos o ScaffoldMessenger antes de qualquer await ou context switch
    // para garantir acesso ao Scaffold correto após operações assíncronas.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusL),
        ),
      ),
      builder: (ctx) => _BottomSheetFoto(
        // A câmera/galeria é aberta APÓS fechar o sheet (Navigator.pop)
        // para evitar conflito de contexto entre o sheet e a câmera do SO.
        onCamera: () {
          Navigator.pop(ctx); // fecha o bottom sheet primeiro
          _selecionarFoto(context, scaffoldMessenger, ImageSource.camera);
        },
        onGaleria: () {
          Navigator.pop(ctx);
          _selecionarFoto(context, scaffoldMessenger, ImageSource.gallery);
        },
      ),
    );
  }

  /// Chama o ImagePicker, valida o tamanho e avisa o pai via callback.
  Future<void> _selecionarFoto(
    BuildContext context,
    ScaffoldMessengerState scaffoldMessenger,
    ImageSource source,
  ) async {
    final picker = ImagePicker();

    // pickImage abre a câmera ou galeria do SO.
    // Retorna null se o usuário cancelou.
    final resultado = await picker.pickImage(source: source);
    if (resultado == null) return; // usuário cancelou → sem ação

    final file = File(resultado.path);

    // ── Validação de tamanho (5 MB conforme doc1) ────────────────────────
    final tamanhoBytes = await file.length();
    const limiteBytes = 5 * 1024 * 1024; // 5 MB em bytes

    if (tamanhoBytes > limiteBytes) {
      // Imagem muito grande — informa o usuário e cancela.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.erroImagemGrande)),
      );
      return;
    }

    // Imagem válida → avisa o pai para processar
    await onFotoSelecionada(file);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGET PRIVADO — Bottom Sheet de opções
// ════════════════════════════════════════════════════════════════════════════

/// Bottom sheet com as opções de origem da foto.
///
/// Separado em classe para manter o build() do widget principal limpo.
/// Privado (_) porque só faz sentido dentro deste arquivo.
class _BottomSheetFoto extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGaleria;

  const _BottomSheetFoto({
    required this.onCamera,
    required this.onGaleria,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
        child: Column(
          mainAxisSize: MainAxisSize.min, // altura mínima necessária
          children: [
            // Título do bottom sheet
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingS,
                horizontal: AppDimensions.paddingM,
              ),
              child: Text(
                AppStrings.fotoOpcoes,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const Divider(height: 1),

            // Opção: tirar foto com a câmera
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(AppStrings.fotoTirar),
              onTap: onCamera,
            ),

            // Opção: escolher da galeria
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.fotoGaleria),
              onTap: onGaleria,
            ),
          ],
        ),
      ),
    );
  }
}
