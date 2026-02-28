// app_theme.dart
//
// Define o ThemeData completo do GymCoach (dark theme).
//
// REGRA: nenhuma cor ou dimensão deve ser hardcoded nos widgets.
// Sempre referencie AppColors e AppDimensions aqui — ou acesse o tema
// via Theme.of(context) nas telas.
//
// Se amanhã uma cor mudar, muda só em AppColors e reflete em todo o app.

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  // Impede instanciação — apenas namespace com o getter do tema.
  AppTheme._();

  /// ThemeData dark do app. Usado em MaterialApp(theme: AppTheme.dark).
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ColorScheme é o "sistema nervoso" do Material 3 — define quais cores
      // vão em quais papéis (primary, surface, error, etc.).
      // Widgets do Flutter leem daqui automaticamente.
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        // No Material 3, "surface" substituiu "background" como slot principal.
        // Passamos AppColors.background aqui para que o Scaffold use a cor certa.
        surface: AppColors.background,
        onSurface: AppColors.onBackground,
        error: AppColors.error,
        onError: AppColors.onError,
        // surfaceContainerHighest é o slot do M3 que mapeia para o que
        // antes era surfaceVariant — usado em chips, inputs e outros elementos.
        surfaceContainerHighest: AppColors.surfaceVariant,
      ),

      scaffoldBackgroundColor: AppColors.background,

      // -------------------------------------------------------------------------
      // AppBar
      // -------------------------------------------------------------------------
      // Flat (elevation 0) — separação visual feita pela diferença de cor,
      // não por sombra. Mais limpo no dark theme.
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.onBackground,
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.onBackground),
      ),

      // -------------------------------------------------------------------------
      // Cards
      // -------------------------------------------------------------------------
      // Elevation 0 — sem sombra. A diferença de cor entre surface (#1E1E1E)
      // e background (#121212) já cria a hierarquia visual.
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.radiusL),
          ),
        ),
      ),

      // -------------------------------------------------------------------------
      // ElevatedButton — botão primário (ex: "Salvar", "Iniciar Sessão")
      // -------------------------------------------------------------------------
      // minimumSize garante área de toque de 52dp de altura — importante
      // para uso com mãos suadas em ambiente de academia.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),

      // -------------------------------------------------------------------------
      // TextButton — botão secundário (ex: "Cancelar", links)
      // -------------------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, AppDimensions.buttonHeight),
        ),
      ),

      // -------------------------------------------------------------------------
      // FloatingActionButton — botões flutuantes (ex: "Novo Aluno")
      // -------------------------------------------------------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
      ),

      // -------------------------------------------------------------------------
      // Campos de texto (TextField / TextFormField)
      // -------------------------------------------------------------------------
      // filled + fillColor: campo com fundo colorido, sem borda por padrão.
      // Borda só aparece no foco (focusedBorder) — reduz ruído visual
      // quando o formulário tem muitos campos.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        hintStyle: const TextStyle(color: AppColors.textHint),
        errorStyle: const TextStyle(color: AppColors.error),
      ),

      // -------------------------------------------------------------------------
      // Divisores entre itens de lista
      // -------------------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // -------------------------------------------------------------------------
      // SnackBar — notificações de sucesso e erro
      // -------------------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
