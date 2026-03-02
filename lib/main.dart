// main.dart
//
// Ponto de entrada do aplicativo GymCoach.
//
// RESPONSABILIDADES:
//   1. Envolver tudo em ProviderScope — habilita o Riverpod em toda a árvore
//   2. Chamar runApp com GymCoachApp (que configura tema, router, etc.)
//
// REGRA: main.dart deve ser o mais simples possível.
// Toda configuração fica em app/app.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope é o "container" global do Riverpod.
  // Todo provider definido no app só funciona dentro deste escopo.
  // Ele deve envolver o widget raiz — nada deve ficar fora dele.
  runApp(
    const ProviderScope(
      child: GymCoachApp(),
    ),
  );
}
