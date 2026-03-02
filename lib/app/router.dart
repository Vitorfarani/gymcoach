// router.dart
//
// Configura todas as rotas do GymCoach usando GoRouter.
//
// RESPONSABILIDADE:
//   Declarar o mapa completo de rotas do app e expor o GoRouter
//   via routerProvider para que o app.dart possa consumi-lo.
//
// ESTRUTURA DE ROTAS:
//   /                          → DashboardScreen
//   /alunos                    → ListaAlunosScreen
//   /alunos/novo               → CadastroAlunoScreen
//   /alunos/:alunoId           → PerfilAlunoScreen
//   /alunos/:alunoId/editar    → EdicaoAlunoScreen
//   /alunos/:alunoId/treinos   → placeholder (feature futura)
//   /alunos/:alunoId/sessoes   → placeholder (feature futura)
//
// ROTA 404: onException redireciona para /alunos.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/alunos/presentation/screens/cadastro_aluno_screen.dart';
import '../features/alunos/presentation/screens/edicao_aluno_screen.dart';
import '../features/alunos/presentation/screens/lista_alunos_screen.dart';
import '../features/alunos/presentation/screens/perfil_aluno_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
// ROUTER PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// Expõe o GoRouter para toda a árvore de widgets via Riverpod.
///
/// Usamos [Provider] simples (sem @riverpod / build_runner) porque o router
/// é um singleton puro: não depende de outros providers e nunca precisa ser
/// recriado durante a vida do app.
///
/// [Provider<T>] (sem `.autoDispose`) é keepAlive por padrão — o objeto
/// persiste enquanto o [ProviderScope] existir.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Tela inicial ao abrir o app.
    initialLocation: '/',

    // onException é chamado quando uma rota não é encontrada (404) ou
    // ocorre qualquer outro erro de navegação.
    // Redirecionamos para /alunos em vez de mostrar uma tela de erro.
    onException: (_, __, router) => router.go('/alunos'),

    routes: [
      // ── Dashboard ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),

      // ── Alunos ────────────────────────────────────────────────────────────
      //
      // As subrotas são declaradas com caminho RELATIVO ao pai.
      // Ex: path 'novo' sob '/alunos' = rota completa '/alunos/novo'.
      GoRoute(
        path: '/alunos',
        builder: (context, state) => const ListaAlunosScreen(),
        routes: [
          // ⚠️ ORDEM IMPORTA: 'novo' (literal) deve vir ANTES de ':alunoId'
          // (parâmetro). GoRouter avalia subrotas em ordem; se ':alunoId'
          // viesse primeiro, a string "novo" seria capturada como um ID →
          // crash em int.parse("novo").
          GoRoute(
            path: 'novo',
            builder: (context, state) => const CadastroAlunoScreen(),
          ),

          GoRoute(
            path: ':alunoId',
            builder: (context, state) {
              // pathParameters retorna sempre String — convertemos para int.
              // O app é 100% offline, então IDs inválidos não chegam via
              // deep links externos; int.parse é seguro aqui.
              final alunoId = int.parse(state.pathParameters['alunoId']!);
              return PerfilAlunoScreen(alunoId: alunoId);
            },
            routes: [
              GoRoute(
                path: 'editar',
                builder: (context, state) {
                  final alunoId = int.parse(state.pathParameters['alunoId']!);
                  return EdicaoAlunoScreen(alunoId: alunoId);
                },
              ),

              // Placeholders — serão substituídos quando as features de
              // treinos e sessões forem implementadas.
              GoRoute(
                path: 'treinos',
                builder: (context, state) =>
                    const _PlaceholderScreen(texto: 'Treinos em breve'),
              ),
              GoRoute(
                path: 'sessoes',
                builder: (context, state) =>
                    const _PlaceholderScreen(texto: 'Sessões em breve'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ════════════════════════════════════════════════════════════════════════════
// TELAS TEMPORÁRIAS (placeholders)
// ════════════════════════════════════════════════════════════════════════════
//
// Widgets privados (prefixo _) — só visíveis dentro deste arquivo.
// Serão deletados quando as features reais forem implementadas.

/// Placeholder genérico para rotas ainda não implementadas.
///
/// Recebe um [texto] descritivo que aparece no AppBar e no centro da tela.
/// O botão voltar é exibido automaticamente pelo GoRouter quando há uma
/// rota anterior na pilha de navegação.
class _PlaceholderScreen extends StatelessWidget {
  final String texto;

  const _PlaceholderScreen({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(texto)),
      body: Center(
        child: Text(
          texto,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
