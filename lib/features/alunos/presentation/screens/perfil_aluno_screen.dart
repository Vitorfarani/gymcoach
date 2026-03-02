// perfil_aluno_screen.dart
//
// Tela de perfil do aluno — rota: /alunos/:alunoId
//
// RESPONSABILIDADE:
//   Carregar e exibir os dados completos de um aluno, atualizar o último
//   acesso ao banco e oferecer atalhos para Treinos e Histórico de Sessões.
//
// FLUXO DE CARREGAMENTO:
//   initState → _carregarAluno() → BuscarAlunoPorId(alunoId) → setState(_aluno)
//                                                              → _atualizarAcesso()
//
// ESTADOS:
//   _isLoading == true   → skeleton (caixas cinzas espelhando o layout)
//   _errorMessage != null → mensagem de erro + botão "Tentar novamente"
//   senão                → perfil completo
//
// NAVEGAÇÃO:
//   Ícone editar (AppBar)  → push /alunos/:alunoId/editar
//   Card "Treinos"         → push /alunos/:alunoId/treinos
//   Card "Histórico"       → push /alunos/:alunoId/sessoes
//   Botão voltar           → comportamento padrão do GoRouter (tela anterior)

import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/aluno.dart';
import '../providers/aluno_providers.dart';

class PerfilAlunoScreen extends ConsumerStatefulWidget {
  // O alunoId chega via parâmetro de rota configurado no GoRouter.
  final int alunoId;

  const PerfilAlunoScreen({super.key, required this.alunoId});

  @override
  ConsumerState<PerfilAlunoScreen> createState() => _PerfilAlunoScreenState();
}

class _PerfilAlunoScreenState extends ConsumerState<PerfilAlunoScreen> {
  // ── Estado local ──────────────────────────────────────────────────────────
  Aluno? _aluno;          // null enquanto carrega ou se houve erro
  bool _isLoading = true; // controla qual "tela" o build() renderiza
  String? _errorMessage;  // mensagem de erro formatada para o usuário

  @override
  void initState() {
    super.initState();
    // addPostFrameCallback: garante que o primeiro frame já foi pintado
    // antes de chamarmos o ref (boa prática para async em initState).
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarAluno());
  }

  // ── Carregamento do aluno ─────────────────────────────────────────────────

  Future<void> _carregarAluno() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uc = await ref.read(buscarAlunoPorIdProvider.future);
      final aluno = await uc(widget.alunoId);

      if (!mounted) return;
      setState(() {
        _aluno = aluno;
        _isLoading = false;
      });

      // Atualiza o timestamp em segundo plano — não bloqueia a exibição do perfil.
      _atualizarAcesso();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = failureFromException(e).message;
      });
    }
  }

  /// Registra o acesso ao perfil no banco (alimenta o Dashboard).
  ///
  /// Fire-and-forget: erros são silenciosos porque é uma operação secundária.
  /// O perfil continua funcionando mesmo que essa chamada falhe.
  Future<void> _atualizarAcesso() async {
    try {
      final uc = await ref.read(atualizarUltimoAcessoProvider.future);
      await uc(widget.alunoId);
      // Invalida a lista para que o Dashboard reflita a ordem atualizada.
      ref.invalidate(alunosProvider);
    } catch (_) {
      // Silencioso: não afeta a experiência do professor.
    }
  }

  // ── Build principal ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Mostra o nome do aluno quando disponível; "Carregando..." antes disso.
        title: Text(_aluno?.nome ?? AppStrings.carregando),
        actions: [
          // O botão de editar só aparece quando o aluno foi carregado com sucesso.
          if (_aluno != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: AppStrings.editar,
              // push (não go) para que context.pop() na tela de edição retorne aqui.
              onPressed: () =>
                  context.push('/alunos/${widget.alunoId}/editar'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSkeleton();
    if (_errorMessage != null) return _buildErro();
    return _buildPerfil();
  }

  // ── Estado: skeleton (loading) ────────────────────────────────────────────

  /// Caixas cinzas estáticas que espelham o layout do perfil real.
  /// Dão ao professor a sensação de que o conteúdo está chegando logo.
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.paddingL),
          // Círculo → avatar
          Center(
            child: _skeletonBox(
              height: AppDimensions.avatarL,
              width: AppDimensions.avatarL,
              radius: AppDimensions.radiusCircle,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Retângulo central → nome
          Center(
            child: _skeletonBox(height: 24, width: 180),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          // Linhas → dados físicos
          _skeletonBox(height: 16, width: double.infinity),
          const SizedBox(height: AppDimensions.paddingS),
          _skeletonBox(height: 16, width: 220),
          const SizedBox(height: AppDimensions.paddingS),
          _skeletonBox(height: 16, width: 160),
          const SizedBox(height: AppDimensions.paddingL),
          // Retângulos altos → cards de atalho
          _skeletonBox(
              height: 56, width: double.infinity, radius: AppDimensions.radiusL),
          const SizedBox(height: AppDimensions.cardGap),
          _skeletonBox(
              height: 56, width: double.infinity, radius: AppDimensions.radiusL),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    required double height,
    required double width,
    double radius = AppDimensions.radiusM,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Estado: erro ──────────────────────────────────────────────────────────

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            OutlinedButton(
              onPressed: _carregarAluno,
              child: const Text(AppStrings.tentarNovamente),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado: perfil completo ───────────────────────────────────────────────

  Widget _buildPerfil() {
    final aluno = _aluno!; // garantidamente não-nulo aqui (veja _buildBody)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppDimensions.paddingL),

          // ── Foto ─────────────────────────────────────────────────────────
          Center(child: _buildFoto(aluno)),

          const SizedBox(height: AppDimensions.paddingM),

          // ── Nome ─────────────────────────────────────────────────────────
          Text(
            aluno.nome,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // ── Dados físicos — só renderiza se pelo menos um campo tiver valor
          if (_temDadosFisicos(aluno)) ...[
            _buildSecaoTitulo('Dados físicos'),
            const SizedBox(height: AppDimensions.paddingS),
            _buildCardDadosFisicos(aluno),
            const SizedBox(height: AppDimensions.paddingL),
          ],

          // ── Objetivo — só aparece se preenchido ──────────────────────────
          if (aluno.objetivo != null && aluno.objetivo!.isNotEmpty) ...[
            _buildSecaoTitulo(AppStrings.campoObjetivo),
            const SizedBox(height: AppDimensions.paddingS),
            _buildCardTexto(aluno.objetivo!),
            const SizedBox(height: AppDimensions.paddingL),
          ],

          // ── Observações — só aparecem se preenchidas ──────────────────────
          if (aluno.observacoes != null && aluno.observacoes!.isNotEmpty) ...[
            _buildSecaoTitulo(AppStrings.campoObservacoes),
            const SizedBox(height: AppDimensions.paddingS),
            _buildCardTexto(aluno.observacoes!),
            const SizedBox(height: AppDimensions.paddingL),
          ],

          // ── Cards de atalho ───────────────────────────────────────────────
          _buildCardAtalho(
            icone: Icons.fitness_center,
            titulo: AppStrings.perfilTreinos,
            onTap: () => context.push('/alunos/${widget.alunoId}/treinos'),
          ),
          const SizedBox(height: AppDimensions.cardGap),
          _buildCardAtalho(
            icone: Icons.history,
            titulo: AppStrings.perfilHistoricoSessoes,
            onTap: () => context.push('/alunos/${widget.alunoId}/sessoes'),
          ),

          const SizedBox(height: AppDimensions.paddingXL),
        ],
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  bool _temDadosFisicos(Aluno aluno) =>
      aluno.idade != null || aluno.peso != null || aluno.altura != null;

  Widget _buildFoto(Aluno aluno) {
    const double size = AppDimensions.avatarL;
    if (aluno.fotoPath != null) {
      return ClipOval(
        child: Image.file(
          File(aluno.fotoPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Se o arquivo não existir mais no dispositivo, cai no avatar padrão.
          errorBuilder: (_, __, ___) => _buildAvatarPadrao(size),
        ),
      );
    }
    return _buildAvatarPadrao(size);
  }

  Widget _buildAvatarPadrao(double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.surfaceVariant,
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildSecaoTitulo(String titulo) {
    return Text(
      titulo.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
    );
  }

  /// Card com linhas de label + valor para os dados físicos (idade, peso, altura).
  Widget _buildCardDadosFisicos(Aluno aluno) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        child: Column(
          children: [
            if (aluno.idade != null)
              _buildLinhaDado('Idade', '${aluno.idade} anos'),
            if (aluno.peso != null)
              _buildLinhaDado(
                'Peso',
                '${aluno.peso!.toStringAsFixed(1).replaceAll('.', ',')} kg',
              ),
            if (aluno.altura != null)
              _buildLinhaDado('Altura', '${aluno.altura!.toInt()} cm'),
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaDado(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            valor,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  /// Card de texto simples — usado para objetivo e observações.
  Widget _buildCardTexto(String texto) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Text(
          texto,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  /// Card de atalho com ícone, título e seta → navega para a sub-tela.
  Widget _buildCardAtalho({
    required IconData icone,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icone, color: AppColors.primary),
        title: Text(
          titulo,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
