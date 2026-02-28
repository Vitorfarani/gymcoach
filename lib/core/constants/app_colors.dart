// app_colors.dart
//
// Paleta de cores do GymCoach — tema dark.
//
// CORES PRIMÁRIAS: definidas no CLAUDE.md.
// CORES DERIVADAS: calculadas para garantir contraste e consistência visual.
//
// USO: sempre importe AppColors em vez de usar Color(0xFF...) diretamente
// no código de UI. Isso garante que uma mudança aqui reflita em todo o app.
//
// REFERÊNCIA de contraste: texto claro (#E0E0E0) sobre fundo escuro (#121212)
// atinge ratio 12:1 — bem acima do mínimo WCAG AA (4.5:1).

import 'package:flutter/material.dart';

class AppColors {
  // Impede instanciação — apenas namespace de constantes.
  AppColors._();

  // ===========================================================================
  // CORES PRINCIPAIS — definidas no CLAUDE.md
  // ===========================================================================

  /// Azul de destaque — botões primários, FAB, links, ícones ativos.
  static const primary = Color(0xFF1E88E5);

  /// Fundo geral do app — cor mais escura, usada em Scaffold.
  static const background = Color(0xFF121212);

  /// Superfície de cards e bottom sheets — ligeiramente mais clara que o fundo.
  static const surface = Color(0xFF1E1E1E);

  /// Variante de superfície — usada em campos de input e itens secundários.
  static const surfaceVariant = Color(0xFF2C2C2C);

  /// Cor de erro — mensagens de validação e estados de erro.
  static const error = Color(0xFFCF6679);

  // ===========================================================================
  // "ON" COLORS — texto/ícones SOBRE cada cor base
  // ===========================================================================

  // "on" significa "o que vai em cima de". Garante contraste legível.

  /// Texto/ícone sobre a cor primary (azul). Branco puro.
  static const onPrimary = Colors.white;

  /// Texto/ícone sobre o fundo (background). Cinza claro quase branco.
  static const onBackground = Color(0xFFE0E0E0);

  /// Texto/ícone sobre surface e surfaceVariant.
  static const onSurface = Color(0xFFE0E0E0);

  /// Texto/ícone sobre a cor de erro. Branco puro.
  static const onError = Colors.white;

  // ===========================================================================
  // TEXTO — hierarquia tipográfica
  // ===========================================================================

  /// Texto principal — títulos, nomes, conteúdo primário.
  static const textPrimary = Color(0xFFE0E0E0);

  /// Texto secundário — subtítulos, labels, metadados.
  static const textSecondary = Color(0xFF9E9E9E);

  /// Texto desabilitado — campos inativos, botões desabilitados.
  static const textDisabled = Color(0xFF616161);

  /// Hint de input — placeholder dentro de campos de texto.
  static const textHint = Color(0xFF757575);

  // ===========================================================================
  // ESTADOS
  // ===========================================================================

  /// Verde — snackbars de sucesso.
  static const success = Color(0xFF4CAF50);

  /// Amarelo — alertas e avisos.
  static const warning = Color(0xFFFFC107);

  // ===========================================================================
  // ESTRUTURA — bordas, divisores, separadores
  // ===========================================================================

  /// Linha divisória entre itens de lista.
  static const divider = Color(0xFF2C2C2C);

  /// Borda de cards e campos com contorno explícito.
  static const border = Color(0xFF3D3D3D);

  // ===========================================================================
  // CAMPOS DE INPUT
  // ===========================================================================

  /// Preenchimento (fill) dos campos de texto no formulário.
  static const inputFill = Color(0xFF2C2C2C);

  // ===========================================================================
  // AÇÕES DESTRUTIVAS
  // ===========================================================================

  /// Vermelho para botões de deletar e avisos de ação irreversível.
  /// Intencionalmente igual ao [error] — mesma semântica visual.
  static const destructive = Color(0xFFCF6679);

  /// Texto sobre fundo destrutivo (botão vermelho com label branca).
  static const onDestructive = Colors.white;
}
