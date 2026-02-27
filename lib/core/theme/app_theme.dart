/// Define o tema visual global do GymCoach.
///
/// Centralizar o tema aqui significa que mudar uma cor ou estilo
/// reflete em todo o app automaticamente — nunca hardcode cor direto
/// em widget. Se amanhã o cliente quiser trocar o azul por verde,
/// muda só aqui.
import 'package:flutter/material.dart';

class AppTheme {
  // Construtor privado: essa classe não deve ser instanciada.
  AppTheme._();

  /// Azul principal — usado em botões, ícones ativos e destaques.
  static const Color primary = Color(0xFF1E88E5);

  /// Fundo geral das telas — quase preto para reduzir cansaço visual
  /// em ambientes de academia com iluminação artificial intensa.
  static const Color background = Color(0xFF121212);

  /// Fundo de cards e superfícies elevadas.
  static const Color surface = Color(0xFF1E1E1E);

  /// Fundo de inputs e elementos de formulário.
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  /// Cor do texto e ícones sobre fundo primário (azul).
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Cor do texto principal sobre o fundo geral.
  static const Color onBackground = Color(0xFFFFFFFF);

  /// Cor do texto sobre cards e superfícies.
  static const Color onSurface = Color(0xFFE0E0E0);

  /// Cor do texto secundário e placeholders.
  static const Color onSurfaceVariant = Color(0xFF9E9E9E);

  /// Cor para estados de erro em formulários e alertas.
  static const Color error = Color(0xFFCF6679);

  /// Retorna o ThemeData completo do app.
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        // Em Material 3 moderno, surface substitui background.
        surface: background,
        onSurface: onBackground,
        error: error,
      ),

      scaffoldBackgroundColor: background,

      // CardThemeData (renomeado no Flutter 3.18+) — sem elevação,
      // separação visual feita pela diferença de cor entre surface e background.
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // AppBar sem elevação para visual flat e moderno.
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),

      // Altura mínima de 52px — área de toque recomendada pelo Material Design
      // para evitar erros com mãos suadas em academia.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Borda só aparece no foco — reduz ruído visual no formulário.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurfaceVariant),
        floatingLabelStyle: const TextStyle(color: primary),
      ),
    );
  }
}