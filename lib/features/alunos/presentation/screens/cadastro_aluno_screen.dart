// cadastro_aluno_screen.dart
//
// Tela de cadastro de novo aluno — rota: /alunos/novo
//
// RESPONSABILIDADE:
//   Exibir o formulário de cadastro, validar os campos, chamar o use case
//   CriarAluno e navegar para o perfil do aluno recém-criado.
//
// POR QUE ConsumerStatefulWidget?
//   Precisamos de TextEditingControllers (criados em initState, descartados em
//   dispose) e de variáveis de estado local (_isSaving, erros de campo, foto).
//   Tudo isso exige um StatefulWidget. O "Consumer" permite acessar o Riverpod.
//
// FLUXO AO SALVAR:
//   Parseamos os campos numéricos → chamamos CriarAluno → se OK, navegamos
//   para /alunos/:id (pushReplacement substitui esta tela na pilha, então o
//   usuário não volta ao formulário ao pressionar Voltar no perfil).
//
// VALIDAÇÃO:
//   Client-side: campos numéricos com tryParse (erro de formato imediato).
//   Server-side: as exceções do use case mapeiam para erros de campo específicos.
//
// POPSCOPE:
//   Intercepta o botão Voltar. Se há dados preenchidos, pede confirmação.
//   Isso evita que o professor perca dados digitados acidentalmente.

import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../providers/aluno_providers.dart';
import '../widgets/foto_picker_widget.dart';

class CadastroAlunoScreen extends ConsumerStatefulWidget {
  const CadastroAlunoScreen({super.key});

  @override
  ConsumerState<CadastroAlunoScreen> createState() =>
      _CadastroAlunoScreenState();
}

class _CadastroAlunoScreenState extends ConsumerState<CadastroAlunoScreen> {
  // ── Controllers dos campos de texto ─────────────────────────────────────
  // Um controller por campo para ler e limpar o texto digitado.
  final _nomeController       = TextEditingController();
  final _idadeController      = TextEditingController();
  final _pesoController       = TextEditingController();
  final _alturaController     = TextEditingController();
  final _objetivoController   = TextEditingController();
  final _observacoesController = TextEditingController();

  // ── Estado local ─────────────────────────────────────────────────────────
  bool _isSaving = false;

  // Erros por campo — null significa sem erro. Exibidos via InputDecoration.
  String? _nomeError;
  String? _idadeError;
  String? _pesoError;
  String? _alturaError;

  // Erro geral (ex: falha de banco de dados) exibido acima do botão Salvar.
  String? _generalError;

  // Foto selecionada nesta sessão, ainda não salva.
  // É passada para CriarAluno, que a salva junto com o aluno.
  File? _novaFoto;

  @override
  void dispose() {
    // IMPORTANTE: descartar todos os controllers para liberar memória.
    // Sem dispose, os controllers continuam vivos após sair da tela.
    _nomeController.dispose();
    _idadeController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _objetivoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // Detecta se o professor digitou algo (para o dialog de saída).
  bool get _temDadosPreenchidos {
    return _nomeController.text.isNotEmpty ||
        _idadeController.text.isNotEmpty ||
        _pesoController.text.isNotEmpty ||
        _alturaController.text.isNotEmpty ||
        _objetivoController.text.isNotEmpty ||
        _observacoesController.text.isNotEmpty ||
        _novaFoto != null;
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta o botão Voltar do dispositivo.
    // canPop: false → o Flutter não sai automaticamente; chamamos nós mesmos.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // didPop seria true se canPop fosse true e o pop já tivesse acontecido.
        if (didPop) return;
        _confirmarSaida(); // mostra dialog se necessário
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.novoAluno)),
        body: _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Foto ──────────────────────────────────────────────────────────
          Center(
            child: FotoPickerWidget(
              novaFoto: _novaFoto,
              onFotoSelecionada: (file) async {
                // No cadastro, guardamos a foto para salvar junto com o aluno.
                // CriarAluno aceita File? foto e processa internamente.
                setState(() => _novaFoto = file);
              },
              onRemoverFoto: () => setState(() => _novaFoto = null),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingL),

          // ── Campos do formulário ──────────────────────────────────────────
          _buildCampo(
            controller: _nomeController,
            label: AppStrings.campoNomeObrig,
            hint: AppStrings.campoNomeHint,
            error: _nomeError,
            textInputAction: TextInputAction.next,
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

          // ── Erro geral (falha de banco, etc.) ─────────────────────────────
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
            // null desabilita o botão durante o salvamento.
            onPressed: _isSaving ? null : _salvar,
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

          const SizedBox(height: AppDimensions.paddingXL),
        ],
      ),
    );
  }

  // Helper para criar campos com aparência consistente.
  // Evita repetir a mesma estrutura Padding + TextField 6 vezes.
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

  // ── Lógica de salvar ─────────────────────────────────────────────────────

  Future<void> _salvar() async {
    setState(() {
      _isSaving = true;
      _nomeError = null;
      _idadeError = null;
      _pesoError = null;
      _alturaError = null;
      _generalError = null;
    });

    // Parseia campos numéricos com verificação de formato.
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

    // Aceita vírgula como separador decimal (padrão brasileiro).
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
      final uc = await ref.read(criarAlunoProvider.future);
      final aluno = await uc(
        nome: _nomeController.text,
        foto: _novaFoto,
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

      // Força a lista de alunos a recarregar na próxima exibição.
      ref.invalidate(alunosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.alunoSalvo)),
        );
        // pushReplacement substitui /alunos/novo por /alunos/:id na pilha.
        // Assim, ao pressionar Voltar no perfil, volta para /alunos (lista).
        context.pushReplacement('/alunos/${aluno.id}');
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
      final failure = failureFromException(e);
      setState(() => _generalError = failure.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Dialog de saída sem salvar ───────────────────────────────────────────

  Future<void> _confirmarSaida() async {
    // Se não há dados preenchidos, sai direto sem perguntar.
    if (!_temDadosPreenchidos) {
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
