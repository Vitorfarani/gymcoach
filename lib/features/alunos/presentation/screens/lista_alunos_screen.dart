// lista_alunos_screen.dart
//
// Tela de lista de alunos — rota: /alunos
//
// RESPONSABILIDADE:
//   Exibir todos os alunos ativos com campo de busca por nome.
//   Gerenciar os 4 estados de UI: loading, data, empty, error.
//   Navegar para o perfil ao tocar num card.
//
// POR QUE ConsumerStatefulWidget?
//   Precisamos de um TextEditingController para o campo de busca.
//   Controllers precisam ser criados em initState e destruídos em dispose
//   para não vazar memória — isso requer um StatefulWidget.
//   O "Consumer" vem do Riverpod: dá acesso ao [ref] no State.
//
// FLUXO DE DADOS:
//   ref.watch(alunosProvider)         → AsyncValue<List<Aluno>>
//   ref.read(alunosProvider.notifier) → AlunosNotifier (para buscar())
//   ref.read(atualizarUltimoAcessoProvider.future) → use case para update

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/aluno.dart';
import '../providers/aluno_providers.dart';
import '../widgets/aluno_card.dart';

// ════════════════════════════════════════════════════════════════════════════
// TELA PRINCIPAL
// ════════════════════════════════════════════════════════════════════════════

class ListaAlunosScreen extends ConsumerStatefulWidget {
  const ListaAlunosScreen({super.key});

  @override
  ConsumerState<ListaAlunosScreen> createState() => _ListaAlunosScreenState();
}

class _ListaAlunosScreenState extends ConsumerState<ListaAlunosScreen> {
  // Controller do campo de busca.
  // Deve ser descartado em dispose() para liberar memória.
  final _searchController = TextEditingController();

  @override
  void dispose() {
    // IMPORTANTE: sempre descartar controllers no dispose.
    // Sem isso, o controller continua vivo mesmo após a tela ser removida,
    // causando vazamento de memória.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch: assina o provider — a tela reconstrói automaticamente
    // cada vez que o estado do alunosProvider muda (loading → data → etc.).
    final alunosAsync = ref.watch(alunosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alunosTitulo),
      ),

      body: Column(
        children: [
          // ── Campo de busca ──────────────────────────────────────────────
          _SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
          ),

          // ── Conteúdo principal ─────────────────────────────────────────
          // Expanded: ocupa todo o espaço vertical restante abaixo da busca.
          Expanded(
            child: _buildContent(alunosAsync),
          ),
        ],
      ),

      // ── FAB "Novo Aluno" ─────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/alunos/novo'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.novoAluno),
      ),
    );
  }

  // ── Callbacks ────────────────────────────────────────────────────────────

  /// Chamado a cada letra digitada no campo de busca.
  ///
  /// Repassa a query para o notifier, que invalida o estado e recarrega
  /// a lista filtrada. String vazia remove o filtro (exibe todos).
  void _onSearch(String value) {
    final query = value.trim();
    ref
        .read(alunosProvider.notifier)
        .buscar(query.isEmpty ? null : query);
  }

  /// Chamado ao tocar num card de aluno.
  ///
  /// 1. Navega imediatamente para o perfil (sem await — não trava a UI).
  /// 2. Atualiza último_acesso em background (fire-and-forget).
  void _onAlunoTap(Aluno aluno) async {
    // Navega antes de qualquer async para resposta imediata ao toque.
    context.push('/alunos/${aluno.id}');

    // Atualiza o timestamp de último acesso no banco.
    // Não esperamos o resultado — se falhar, não é crítico para o usuário.
    final uc = await ref.read(atualizarUltimoAcessoProvider.future);
    await uc(aluno.id!);
  }

  // ── Builders de estado ───────────────────────────────────────────────────

  /// Mapeia o AsyncValue para o widget correto de acordo com o estado.
  Widget _buildContent(AsyncValue<List<Aluno>> alunosAsync) {
    // .when() é o método principal do AsyncValue para mapear estados.
    //
    // skipLoadingOnReload: true →  quando o usuário digita na busca,
    // o notifier chama invalidateSelf() e o estado vai para AsyncLoading.
    // Sem este flag, a tela voltaria ao skeleton a cada letra — péssima UX.
    // Com ele, mantém a lista anterior visível enquanto carrega a nova.
    return alunosAsync.when(
      skipLoadingOnReload: true,
      loading: _buildSkeleton,
      error: (_, __) => _buildError(),
      data: _buildData,
    );
  }

  /// Estado LOADING — primeira carga da tela.
  ///
  /// Exibe 8 containers cinzas que imitam o tamanho de um AlunoCard,
  /// dando a percepção de que o conteúdo está prestes a aparecer.
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: 8,
      itemBuilder: (_, __) => const _SkeletonItem(),
    );
  }

  /// Estado DATA — lista com resultados (ou vazia).
  ///
  /// Subdivide em 3 sub-estados:
  /// - Lista não-vazia → mostra os cards
  /// - Vazia com busca ativa → "nenhum resultado para X"
  /// - Vazia sem busca → convite a cadastrar
  Widget _buildData(List<Aluno> alunos) {
    if (alunos.isEmpty) {
      final query = _searchController.text.trim();
      return query.isNotEmpty
          ? _buildEmptySearch(query)
          : _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: alunos.length,
      itemBuilder: (_, index) => AlunoCard(
        aluno: alunos[index],
        onTap: () => _onAlunoTap(alunos[index]),
      ),
    );
  }

  /// Estado EMPTY — nenhum aluno cadastrado (lista global vazia).
  Widget _buildEmptyState() {
    return _EmptyContent(
      icon: Icons.people_outline,
      message: AppStrings.nenhumAlunoCadastrado,
      actionLabel: AppStrings.novoAluno,
      onAction: () => context.push('/alunos/novo'),
    );
  }

  /// Estado EMPTY_SEARCH — busca sem resultados.
  Widget _buildEmptySearch(String query) {
    return _EmptyContent(
      icon: Icons.search_off,
      // Concatena a constante com o termo entre aspas, conforme
      // o comentário no AppStrings: '${nenhumAlunoEncontradoPara} "$termo"'
      message: '${AppStrings.nenhumAlunoEncontradoPara} "$query"',
    );
  }

  /// Estado ERROR — falha ao carregar a lista.
  Widget _buildError() {
    return _EmptyContent(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      message: AppStrings.erroGenerico,
      actionLabel: AppStrings.tentarNovamente,
      // invalidate() descarta o estado atual e re-executa build() do notifier.
      onAction: () => ref.invalidate(alunosProvider),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS PRIVADOS
// ════════════════════════════════════════════════════════════════════════════
//
// Separados em classes para manter o State limpo e os builds legíveis.
// Todos com underscore (_) = privados a este arquivo.

// ── Campo de busca ──────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingM,
        AppDimensions.paddingM,
        AppDimensions.paddingM,
        AppDimensions.paddingS,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        // textInputAction.search mostra a lupa no teclado do celular.
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: AppStrings.buscarAlunoHint,
          prefixIcon: const Icon(Icons.search),
          // Botão X para limpar a busca rapidamente.
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

// ── Skeleton (placeholder de loading) ──────────────────────────────────────

/// Item placeholder exibido enquanto a lista carrega.
///
/// Tem a mesma altura que um AlunoCard para evitar saltos de layout.
class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.cardGap),
      child: Container(
        height: AppDimensions.listItemHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
}

// ── Estado vazio / erro (reutilizável para empty e error) ──────────────────

/// Widget genérico para estados sem conteúdo.
///
/// Usado tanto para empty state quanto para error state.
/// O botão de ação é opcional — quando null, não é renderizado.
class _EmptyContent extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyContent({
    required this.icon,
    this.iconColor,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconXL,
              color: iconColor ?? AppColors.textSecondary,
            ),

            const SizedBox(height: AppDimensions.paddingM),

            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Botão de ação (ex: "Novo Aluno" ou "Tentar novamente")
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.paddingL),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
