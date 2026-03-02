// dashboard_screen.dart
//
// Tela inicial do GymCoach — rota: /
//
// RESPONSABILIDADE:
//   Mostrar um resumo rápido para o professor:
//   - Total de alunos ativos (subtitle do AppBar)
//   - Card de boas-vindas
//   - Os 5 alunos acessados mais recentemente ("Alunos Recentes")
//   Gerenciar os 4 estados de UI: loading, data, empty, error.
//
// POR QUE ConsumerWidget (stateless)?
//   Não há formulários nem TextEditingControllers, então não precisamos de
//   StatefulWidget. O estado é 100% gerenciado pelos providers Riverpod.
//
// FLUXO DE DADOS:
//   dashboardUltimosAlunosProvider → AsyncValue<List<Aluno>>
//   dashboardTotalAtivosProvider   → AsyncValue<int>
//
// ATUALIZAÇÃO AO VOLTAR DO PERFIL:
//   context.push() retorna um Future que completa quando o usuário pressiona
//   voltar. Fazemos `await context.push(...)` e depois invalidamos os providers
//   para refletir o ultimo_acesso atualizado pelo PerfilAlunoScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../alunos/domain/entities/aluno.dart';
import '../../../alunos/presentation/widgets/aluno_card.dart';
import '../providers/dashboard_providers.dart';

// ════════════════════════════════════════════════════════════════════════════
// TELA PRINCIPAL
// ════════════════════════════════════════════════════════════════════════════

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assina os dois providers. Cada vez que um mudar, o widget reconstrói.
    final ultimosAsync = ref.watch(dashboardUltimosAlunosProvider);
    final totalAsync = ref.watch(dashboardTotalAtivosProvider);

    return Scaffold(
      appBar: _buildAppBar(context, totalAsync),

      // ListView permite rolagem caso a lista de alunos recentes seja grande.
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        children: [
          // Card "Bem-vindo, Professor" — sempre visível, independente do estado.
          const _BoasVindasCard(),

          const SizedBox(height: AppDimensions.paddingL),

          // Conteúdo dinâmico — muda conforme o estado do provider.
          ultimosAsync.when(
            loading: _buildSkeleton,
            error: (_, __) => _buildError(ref),
            data: (alunos) => alunos.isEmpty
                ? _buildEmptyState(context)
                : _SecaoRecentes(
                    alunos: alunos,
                    // Captura context e ref do build() para usar no callback.
                    onTap: (aluno) => _onAlunoTap(context, ref, aluno),
                  ),
          ),
        ],
      ),

      // FAB de ação rápida — atalho direto para o cadastro de aluno.
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/alunos/novo'),
        tooltip: AppStrings.novoAluno,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context, AsyncValue<int> totalAsync) {
    final theme = Theme.of(context);

    // maybeWhen: retorna o valor quando o estado é `data`, null nos demais.
    // Isso evita mostrar "null alunos ativos" durante o loading.
    final total = totalAsync.maybeWhen(data: (t) => t, orElse: () => null);

    return AppBar(
      // Title com ícone + nome do app + subtitle condicional.
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha principal: ícone de pessoas + nome do app.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, size: AppDimensions.iconM),
              const SizedBox(width: AppDimensions.paddingXS),
              const Text(AppStrings.dashboardTitulo),
            ],
          ),

          // Subtitle: só aparece quando o dado do total chegou.
          if (total != null)
            Text(
              AppStrings.dashboardContagemAtivos(total),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),

      actions: [
        // context.go() substitui a pilha (não cria botão voltar no topo de /alunos).
        TextButton(
          onPressed: () => context.go('/alunos'),
          child: const Text(AppStrings.dashboardVerTodos),
        ),
      ],
    );
  }

  // ── Builders de estado ───────────────────────────────────────────────────

  /// Estado LOADING — exibe 3 retângulos cinzas imitando AlunoCards.
  ///
  /// 3 itens são suficientes para preencher visualmente a tela sem
  /// ocupar a área do FAB na parte inferior.
  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.cardGap),
          child: Container(
            height: AppDimensions.listItemHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
        ),
      ),
    );
  }

  /// Estado EMPTY — nenhum aluno cadastrado ainda.
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.people_outline,
            size: AppDimensions.iconXL,
            color: AppColors.textSecondary,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          const Text(
            AppStrings.dashboardNenhumAluno,
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.paddingL),

          FilledButton(
            onPressed: () => context.push('/alunos/novo'),
            child: const Text(AppStrings.dashboardCadastrarPrimeiro),
          ),
        ],
      ),
    );
  }

  /// Estado ERROR — falha ao carregar os dados do banco.
  Widget _buildError(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: AppDimensions.iconXL,
            color: AppColors.error,
          ),

          const SizedBox(height: AppDimensions.paddingM),

          const Text(
            AppStrings.erroGenerico,
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.paddingL),

          FilledButton(
            // invalidate() descarta o estado atual e re-executa o provider.
            onPressed: () => ref.invalidate(dashboardUltimosAlunosProvider),
            child: const Text(AppStrings.tentarNovamente),
          ),
        ],
      ),
    );
  }

  // ── Callbacks ────────────────────────────────────────────────────────────

  /// Navega para o perfil do aluno e atualiza o dashboard ao retornar.
  ///
  /// context.push() devolve um Future que completa quando o usuário faz pop
  /// (pressiona voltar). O `await` garante que o invalidate ocorre só depois
  /// do retorno, não durante a navegação.
  Future<void> _onAlunoTap(
    BuildContext context,
    WidgetRef ref,
    Aluno aluno,
  ) async {
    await context.push('/alunos/${aluno.id}');

    // Após retornar do perfil, os providers são invalidados para refletir
    // o novo ultimo_acesso registrado pelo PerfilAlunoScreen.
    ref.invalidate(dashboardUltimosAlunosProvider);
    ref.invalidate(dashboardTotalAtivosProvider);
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS PRIVADOS
// ════════════════════════════════════════════════════════════════════════════
//
// Prefixo _ = privados a este arquivo.
// Separados em classes para manter o build() do DashboardScreen legível.

// ── Card de boas-vindas ──────────────────────────────────────────────────────

/// Card fixo no topo da tela com cumprimento ao professor.
///
/// Stateless porque não tem estado próprio — só exibe texto estático.
class _BoasVindasCard extends StatelessWidget {
  const _BoasVindasCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppDimensions.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            const Icon(
              Icons.waving_hand,
              color: AppColors.primary,
              size: AppDimensions.iconL,
            ),

            const SizedBox(width: AppDimensions.paddingM),

            Text(
              AppStrings.dashboardBoasVindas,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Seção "Alunos Recentes" ───────────────────────────────────────────────────

/// Exibe o título da seção e a lista de até 5 AlunoCards.
///
/// Recebe [alunos] e [onTap] do DashboardScreen — não gerencia estado.
/// Reutiliza AlunoCard da feature de alunos (evita duplicação de widget).
class _SecaoRecentes extends StatelessWidget {
  final List<Aluno> alunos;
  final void Function(Aluno) onTap;

  const _SecaoRecentes({required this.alunos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção em texto secundário para hierarquia visual clara.
        Text(
          AppStrings.dashboardAlunosRecentes,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppDimensions.paddingS),

        // spread operator (...) expande a Iterable de widgets para a Column.
        ...alunos.map(
          (aluno) => AlunoCard(
            aluno: aluno,
            onTap: () => onTap(aluno),
          ),
        ),
      ],
    );
  }
}
