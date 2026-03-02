// app.dart
//
// Widget raiz do aplicativo GymCoach.
//
// RESPONSABILIDADE:
//   Conectar o tema (AppTheme) e o router (GoRouter) em um único ponto,
//   mantendo o main.dart limpo — ele só chama runApp.
//
// POR QUE ConsumerWidget?
//   Para acessar o ref e obter o routerProvider. Sem ref, não teríamos
//   como passar o GoRouter para MaterialApp.router.
//
// POR QUE MaterialApp.router e não MaterialApp?
//   MaterialApp.router é a variante que integra com pacotes de navegação
//   externos (como GoRouter). Ao invés de 'home:', toda navegação é
//   gerenciada pelo routerConfig.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class GymCoachApp extends ConsumerWidget {
  const GymCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch (não read) para que o app reconstrua se o router mudar.
    // Na prática isso nunca acontece, mas é a forma correta de observar
    // um provider em um ConsumerWidget.
    final router = ref.watch(routerProvider);

    // MaterialApp.router entrega o controle de navegação inteiramente
    // para o GoRouter via routerConfig. Não usamos 'home:', 'routes:' etc.
    return MaterialApp.router(
      title: AppStrings.appNome,
      theme: AppTheme.dark,
      // Remove o banner vermelho "DEBUG" do canto superior direito.
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
