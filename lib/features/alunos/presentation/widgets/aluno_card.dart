// aluno_card.dart
//
// Card reutilizável que representa um aluno na lista.
//
// RESPONSABILIDADE:
//   Exibir foto (ou avatar com inicial), nome e objetivo do aluno.
//   Notificar o pai via [onTap] quando o usuário toca no card.
//
// POR QUE É UM WIDGET SEPARADO:
//   1. A lista_alunos_screen.dart ficaria longa demais com a lógica do card
//      embutida. Separar respeita a regra "1 arquivo = 1 responsabilidade".
//   2. Outros locais (ex: dashboard) poderão reutilizar este widget.
//
// STATELESS porque:
//   O card não gerencia estado próprio — ele apenas exibe os dados do [aluno]
//   e delega interações para o pai via [onTap].

import 'dart:io'; // Necessário para abrir o arquivo de foto pelo caminho

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/aluno.dart';

/// Card que representa um aluno na lista.
///
/// Exibe:
/// - Avatar circular: foto do aluno se disponível, ou inicial do nome
/// - Nome (texto primário)
/// - Objetivo (texto secundário, se cadastrado)
/// - Seta indicando que o item é navegável
class AlunoCard extends StatelessWidget {
  /// Dados do aluno a exibir.
  final Aluno aluno;

  /// Callback invocado quando o usuário toca no card.
  /// A tela pai decide o que fazer (ex: navegar para o perfil).
  final VoidCallback onTap;

  const AlunoCard({
    super.key,
    required this.aluno,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      // Espaço abaixo de cada card para separar os itens da lista.
      padding: const EdgeInsets.only(bottom: AppDimensions.cardGap),
      child: Card(
        // Card sem elevação — estética flat do dark theme (ver AppDimensions).
        elevation: AppDimensions.cardElevation,
        child: InkWell(
          onTap: onTap,
          // borderRadius deve ser igual ao do Card para o ripple não vazar.
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingS,
            ),
            child: Row(
              children: [
                // ── Avatar ──────────────────────────────────────────────────
                _AlunoAvatar(
                  fotoPath: aluno.fotoPath,
                  nome: aluno.nome,
                ),

                const SizedBox(width: AppDimensions.paddingM),

                // ── Textos ──────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nome — texto principal
                      Text(
                        aluno.nome,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Objetivo — exibido apenas quando preenchido
                      if (aluno.objetivo != null &&
                          aluno.objetivo!.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          aluno.objetivo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Seta de navegação ────────────────────────────────────────
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconM,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGET PRIVADO — Avatar circular do aluno
// ════════════════════════════════════════════════════════════════════════════
//
// Separado em classe própria para manter o build() do AlunoCard limpo.
// É "privado" (sem export) porque só faz sentido dentro deste arquivo.

class _AlunoAvatar extends StatelessWidget {
  /// Caminho absoluto da foto no dispositivo. Null quando sem foto.
  final String? fotoPath;

  /// Nome do aluno — usado para gerar a inicial quando sem foto.
  final String nome;

  const _AlunoAvatar({required this.fotoPath, required this.nome});

  @override
  Widget build(BuildContext context) {
    // Tenta carregar o arquivo de foto se o caminho existir.
    // File() não lança exceção no construtor — apenas quando lido.
    // FileImage lida com arquivo inexistente mostrando o fallback (child).
    final ImageProvider? imagem =
        fotoPath != null ? FileImage(File(fotoPath!)) : null;

    return CircleAvatar(
      radius: AppDimensions.avatarS / 2, // avatarS = 44dp → raio = 22dp
      backgroundColor: AppColors.surfaceVariant,
      backgroundImage: imagem,
      // child só aparece quando backgroundImage é null (sem foto).
      // Quando há imagem, o Flutter ignora o child automaticamente.
      child: imagem == null
          ? Text(
              // Usa a primeira letra do nome em maiúsculo como avatar textual.
              // O operador "?" garante segurança caso nome seja vazio.
              nome.isNotEmpty ? nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppDimensions.fontL,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
