// dashboard_providers.dart
//
// Providers Riverpod específicos do dashboard.
//
// RESPONSABILIDADE:
//   Agregar dados das features de alunos e expô-los ao DashboardScreen.
//   Cada provider chama o use case correspondente e retorna o resultado.
//
// POR QUE FutureProvider (sem @riverpod)?
//   Os providers do dashboard são simples: "obter use case → executar → retornar".
//   Não precisamos de notifier/estado mutável, então o estilo manual
//   `FutureProvider((ref) async { ... })` é suficiente e evita build_runner.
//
// CICLO DE VIDA (.autoDispose):
//   Com .autoDispose, o provider é descartado quando nenhum widget o assiste
//   (ex: usuário navega para longe do dashboard). Ao voltar, os dados são
//   recarregados automaticamente — sem cache desatualizado.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../alunos/domain/entities/aluno.dart';
import '../../../alunos/presentation/providers/aluno_providers.dart';

// ════════════════════════════════════════════════════════════════════════════
// PROVIDERS DO DASHBOARD
// ════════════════════════════════════════════════════════════════════════════

/// Retorna os últimos 5 alunos acessados pelo professor.
///
/// Usado pela seção "Alunos Recentes" do dashboard.
/// Ordenação: ORDER BY ultimo_acesso DESC LIMIT 5 (feita no use case/DAO).
final dashboardUltimosAlunosProvider =
    FutureProvider.autoDispose<List<Aluno>>((ref) async {
  // 1. Obtém a instância do use case (que já tem o repositório injetado).
  final uc = await ref.watch(listarUltimosAlunosAcessadosProvider.future);
  // 2. Executa e retorna a lista.
  return uc();
});

/// Retorna o total de alunos ativos (deletado_em IS NULL AND ativo = 1).
///
/// Usado no subtitle do AppBar para exibir "N alunos ativos".
final dashboardTotalAtivosProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final uc = await ref.watch(contarAlunosAtivosProvider.future);
  return uc();
});
