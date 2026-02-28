// edicao_aluno_screen.dart
//
// Tela de edição de aluno — rota: /alunos/:alunoId/editar
//
// RESPONSABILIDADE:
//   Carregar os dados do aluno, exibir o formulário pré-preenchido,
//   salvar alterações via EditarAluno, gerenciar foto e deletar o aluno.
//
// DIFERENÇAS DO CADASTRO:
//   - Carrega o aluno no initState antes de exibir o formulário.
//   - Foto: alterações são salvas IMEDIATAMENTE (aluno já existe no banco).
//   - Botão deletar com dialog em dois passos (ação irreversível).
//   - _foiModificado rastreia se o professor alterou algum campo.
//
// FLUXO AO SALVAR:
//   aluno.copyWith(...novos valores...) → EditarAluno → context.pop()
//   (volta para o perfil do aluno, que deve recarregar os dados)
//
// FLUXO AO DELETAR:
//   Dialog passo 1 → dialog passo 2 → DeletarAluno → context.go('/alunos')
//   (volta para a lista, removendo o perfil da pilha)

import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/aluno.dart';
import '../providers/aluno_providers.dart';
import '../widgets/foto_picker_widget.dart';

class EdicaoAlunoScreen extends ConsumerStatefulWidget {
  // O alunoId é passado pelo GoRouter ao configurar a rota /alunos/:alunoId/editar.
  final int alunoId;

  const EdicaoAlunoScreen({super.key, required this.alunoId});

  @override
  ConsumerState<EdicaoAlunoScreen> createState() => _EdicaoAlunoScreenState();
}

class _EdicaoAlunoScreenState extends ConsumerState<EdicaoAlunoScreen> {
  // ── Controllers dos campos de texto ─────────────────────────────────────
  final _nomeController        = TextEditingController();
  final _idadeController       = TextEditingController();
  final _pesoController        = TextEditingController();
  final _alturaController      = TextEditingController();
  final _objetivoController    = TextEditingController();
  final _observacoesController = TextEditingController();

  // ── Estado local ─────────────────────────────────────────────────────────
  Aluno? _aluno;       // dados originais do banco (null durante o carregamento)
  bool _isLoading  = true;  // true enquanto busca os dados do aluno
  bool _isSaving   = false; // true durante o salvamento do formulário
  bool _isDeleting = false; // true durante a exclusão

  // Foto nova selecionada nesta sessão (já salva — mas guardamos para exibir).
  File? _novaFoto;
  // Flag para saber que o usuário removeu a foto nesta sessão.
  bool _fotoRemovida = false;
  // Flag de modificação — torna-se true quando qualquer campo é alterado.
  bool _foiModificado = false;

  String? _nomeError;
  String? _idadeError;
  String? _pesoError;
  String? _alturaError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    // addPostFrameCallback: garante que o primeiro frame já foi renderizado
    // antes de chamarmos ref (boa prática para operações assíncronas em initState).
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarAluno());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _idadeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _objetivoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // ── Carregamento do aluno ────────────────────────────────────────────────

  Future<void> _carregarAluno() async {
    setState(() => _isLoading = true);
    try {
      final uc = await ref.read(buscarAlunoPorIdProvider.future);
      final aluno = await uc(widget.alunoId);
      if (!mounted) return;
      setState(() {
        _aluno = aluno;
        _isLoading = false;
      });
      _preencherCampos(); // preenche ANTES de adicionar os listeners
      _adicionarListeners();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureFromException(e).message)),
      );
    }
  }

  void _preencherCampos() {
    // Convertemos os valores para String para preencher os TextFields.
    // Para peso, usamos vírgula como separador decimal (padrão brasileiro).
    _nomeController.text       = _aluno!.nome;
    _idadeController.text      = _aluno!.idade?.toString() ?? '';
    _pesoController.text       = _aluno!.peso != null
        ? _aluno!.peso!.toStringAsFixed(1).replaceAll('.', ',')
        : '';
    _alturaController.text     = _aluno!.altura?.toInt().toString() ?? '';
    _objetivoController.text   = _aluno!.objetivo ?? '';
    _observacoesController.text = _aluno!.observacoes ?? '';
  }

  void _adicionarListeners() {
    // Adicionamos os listeners APÓS preencher os campos para que o preenchimento
    // programático não marque o formulário como modificado.
    for (final c in [
      _nomeController, _idadeController, _pesoController,
      _alturaController, _objetivoController, _observacoesController,
    ]) {
      c.addListener(() {
        if (!_foiModificado && mounted) {
          setState(() => _foiModificado = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmarSaida();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.editarAluno)),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _aluno == null
                ? const Center(child: Text(AppStrings.erroGenerico))
                : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Foto (salva imediatamente no modo edição) ─────────────────────
          Center(
            child: FotoPickerWidget(
              fotoPath: _aluno!.fotoPath,
              novaFoto: _novaFoto,
              fotoRemovida: _fotoRemovida,
              onFotoSelecionada: _onFotoSelecionada,
              onRemoverFoto: _onRemoverFoto,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // ── Campos do formulário (idênticos ao cadastro) ───────────────────
          _buildCampo(
            controller: _nomeController,
            label: AppStrings.campoNomeObrig,
            hint: AppStrings.campoNomeHint,
            error: _nomeError,
          ),
          _buildCampo(
            controller: _idadeController,
            label: AppStrings.campoIdade,
            hint: AppStrings.campoIdadeHint,
            error: _idadeError,
            keyboardType: TextInputType.number,
          ),
          _buildCampo(
            controller: _pesoController,
            label: AppStrings.campoPeso,
            hint: AppStrings.campoPesoHint,
            error: _pesoError,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _buildCampo(
            controller: _alturaController,
            label: AppStrings.campoAltura,
            hint: AppStrings.campoAlturaHint,
            error: _alturaError,
            keyboardType: TextInputType.number,
          ),
          _buildCampo(
            controller: _objetivoController,
            label: AppStrings.campoObjetivo,
            hint: AppStrings.campoObjetivoHint,
            maxLines: 3,
          ),
          _buildCampo(
            controller: _observacoesController,
            label: AppStrings.campoObservacoes,
            hint: AppStrings.campoObservacoesHint,
            maxLines: 5,
            textInputAction: TextInputAction.done,
          ),

          if (_generalError != null) ...[
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              _generalError!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppDimensions.paddingL),

          // ── Botão Salvar ──────────────────────────────────────────────────
          FilledButton(
            onPressed: (_isSaving || _isDeleting) ? null : _salvar,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(AppStrings.salvar),
          ),

          const SizedBox(height: AppDimensions.paddingM),

          // ── Botão Deletar (ação destrutiva — vermelho, ícone de lixo) ─────
          TextButton.icon(
            onPressed: (_isSaving || _isDeleting) ? null : _deletarAluno,
            icon: _isDeleting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: const Text(AppStrings.deletarAluno),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXL),
        ],
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? error,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: error,
        ),
      ),
    );
  }

  // ── Operações de foto ────────────────────────────────────────────────────

  /// Salva a foto imediatamente (o aluno já existe no banco).
  Future<void> _onFotoSelecionada(File foto) async {
    try {
      final uc = await ref.read(salvarFotoAlunoProvider.future);
      final path = await uc(_aluno!.id!, foto);
      if (!mounted) return;
      setState(() {
        _aluno    = _aluno!.copyWith(fotoPath: path);
        _novaFoto = foto;
        _fotoRemovida = false;
        _foiModificado = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fotoSalva)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureFromException(e).message)),
      );
    }
  }

  /// Remove a foto imediatamente.
  Future<void> _onRemoverFoto() async {
    try {
      final uc = await ref.read(removerFotoAlunoProvider.future);
      await uc(_aluno!.id!);
      if (!mounted) return;
      setState(() {
        _aluno        = _aluno!.copyWith(fotoPath: null);
        _novaFoto     = null;
        _fotoRemovida = true;
        _foiModificado = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fotoRemovida)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureFromException(e).message)),
      );
    }
  }

  // ── Salvar alterações ────────────────────────────────────────────────────

  Future<void> _salvar() async {
    setState(() {
      _isSaving    = true;
      _nomeError   = null;
      _idadeError  = null;
      _pesoError   = null;
      _alturaError = null;
      _generalError = null;
    });

    int? idade;
    double? peso;
    double? altura;
    bool temErroFormato = false;

    final idadeText = _idadeController.text.trim();
    if (idadeText.isNotEmpty) {
      idade = int.tryParse(idadeText);
      if (idade == null) {
        setState(() => _idadeError = AppStrings.erroNumeroInvalido);
        temErroFormato = true;
      }
    }

    final pesoText = _pesoController.text.trim().replaceAll(',', '.');
    if (pesoText.isNotEmpty) {
      peso = double.tryParse(pesoText);
      if (peso == null) {
        setState(() => _pesoError = AppStrings.erroNumeroInvalido);
        temErroFormato = true;
      }
    }

    final alturaText = _alturaController.text.trim();
    if (alturaText.isNotEmpty) {
      altura = double.tryParse(alturaText);
      if (altura == null) {
        setState(() => _alturaError = AppStrings.erroNumeroInvalido);
        temErroFormato = true;
      }
    }

    if (temErroFormato) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      final alunoEditado = _aluno!.copyWith(
        nome: _nomeController.text,
        idade: idade,
        peso: peso,
        altura: altura,
        objetivo: _objetivoController.text.trim().isEmpty
            ? null
            : _objetivoController.text.trim(),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );

      final uc = await ref.read(editarAlunoProvider.future);
      await uc(alunoEditado);

      ref.invalidate(alunosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.alunoSalvo)),
        );
        context.pop(); // volta para o perfil do aluno
      }
    } on NomeObrigatorioException {
      setState(() => _nomeError = AppStrings.erroNomeObrigatorio);
    } on NomeInvalidoException {
      setState(() => _nomeError = AppStrings.erroNomeInvalido);
    } on IdadeInvalidaException {
      setState(() => _idadeError = AppStrings.erroIdadeInvalida);
    } on PesoInvalidoException {
      setState(() => _pesoError = AppStrings.erroPesoInvalido);
    } on AlturaInvalidaException {
      setState(() => _alturaError = AppStrings.erroAlturaInvalida);
    } catch (e) {
      setState(() => _generalError = failureFromException(e).message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Deletar aluno (dois passos) ──────────────────────────────────────────

  Future<void> _deletarAluno() async {
    // Passo 1: primeira confirmação
    final passo1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmacaoTitulo),
        content: const Text(AppStrings.confirmacaoDeletarAluno),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.excluir),
          ),
        ],
      ),
    ) ??
        false;

    if (!passo1 || !mounted) return;

    // Passo 2: confirmação final (ação irreversível)
    final passo2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmacaoTitulo),
        content: const Text(AppStrings.confirmacaoDeletarAluno2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.confirmar),
          ),
        ],
      ),
    ) ??
        false;

    if (!passo2 || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final uc = await ref.read(deletarAlunoProvider.future);
      await uc(_aluno!.id!);

      ref.invalidate(alunosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.alunoDeletado)),
        );
        // go() navega para /alunos e limpa toda a pilha de navegação acima.
        // Isso garante que o perfil deletado não apareça mais no histórico.
        context.go('/alunos');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generalError = failureFromException(e).message);
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // ── Dialog de saída sem salvar ───────────────────────────────────────────

  Future<void> _confirmarSaida() async {
    // Se não houve modificação nos campos de texto, sai direto.
    if (!_foiModificado) {
      if (mounted) context.pop();
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.alteracoesNaoSalvasTitulo),
        content: const Text(AppStrings.alteracoesNaoSalvasMensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.sairSemSalvar),
          ),
        ],
      ),
    );

    if ((confirmar ?? false) && mounted) context.pop();
  }
}
