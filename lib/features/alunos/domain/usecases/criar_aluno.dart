// criar_aluno.dart
//
// Use case: persiste um novo aluno no banco.
//
// RESPONSABILIDADE:
//   1. Valida os campos fornecidos pelo professor
//   2. Constrói o objeto Aluno com os timestamps iniciais
//   3. Delega a persistência ao repositório
//   4. Retorna o Aluno com o id gerado pelo banco
//
// VALIDAÇÕES (doc1):
//   - nome: obrigatório, 2–60 caracteres
//   - idade: 10–99 (se informada)
//   - peso: 30–250 kg (se informado)
//   - altura: 100–250 cm (se informada)

import 'dart:io' show File;

import '../../../../core/errors/exceptions.dart';
import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class CriarAluno {
  final AlunoRepository _repository;

  // O repositório é injetado pelo construtor — o use case não sabe se é
  // SQLite, mock de teste ou qualquer outra implementação.
  CriarAluno(this._repository);

  /// Executa o use case.
  ///
  /// Parâmetros refletem exatamente o que o professor preenche no formulário.
  /// Os campos de auditoria (dataInicio, createdAt, etc.) são gerados aqui.
  Future<Aluno> call({
    required String nome,
    String? fotoPath,
    int? idade,
    double? peso,
    double? altura,
    String? objetivo,
    String? observacoes,
    File? foto, // se foto for passada, salvarFoto será chamado após criar
  }) async {
    // ── Validação ────────────────────────────────────────────────────────────
    _validarNome(nome);
    _validarIdade(idade);
    _validarPeso(peso);
    _validarAltura(altura);

    // ── Construção do objeto ──────────────────────────────────────────────────
    // Campos que o banco teria como DEFAULT são definidos aqui para que
    // o objeto retornado já tenha os valores corretos sem precisar re-buscar.
    final agora = DateTime.now();

    final novoAluno = Aluno(
      // id: null — será preenchido pelo banco no INSERT
      nome: nome.trim(),
      fotoPath: fotoPath,
      idade: idade,
      peso: peso,
      altura: altura,
      objetivo: objetivo?.trim(),
      observacoes: observacoes?.trim(),
      dataInicio: agora,
      dataUltimaAvaliacao: null,
      ultimoAcesso: agora,
      ativo: true,
      createdAt: agora,
      updatedAt: agora,
      deletadoEm: null,
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    // O repository.criar() insere no banco e devolve o aluno com id preenchido.
    // Pode lançar DatabaseException — deixamos propagar para o provider tratar.
    final alunoCriado = await _repository.criar(novoAluno);

    // ── Foto (opcional) ───────────────────────────────────────────────────────
    // Se uma foto foi selecionada junto com o cadastro, salva após criar.
    if (foto != null) {
      return _repository.salvarFoto(alunoCriado.id!, foto).then(
            (path) => alunoCriado.copyWith(fotoPath: path),
          );
    }

    return alunoCriado;
  }

  // ── Validações privadas ───────────────────────────────────────────────────
  // Separadas em métodos para evitar repetição no EditarAluno.

  static void _validarNome(String nome) {
    if (nome.trim().isEmpty) throw const NomeObrigatorioException();
    final tamanho = nome.trim().length;
    if (tamanho < 2 || tamanho > 60) throw const NomeInvalidoException();
  }

  static void _validarIdade(int? idade) {
    if (idade != null && (idade < 10 || idade > 99)) {
      throw const IdadeInvalidaException();
    }
  }

  static void _validarPeso(double? peso) {
    if (peso != null && (peso < 30 || peso > 250)) {
      throw const PesoInvalidoException();
    }
  }

  static void _validarAltura(double? altura) {
    if (altura != null && (altura < 100 || altura > 250)) {
      throw const AlturaInvalidaException();
    }
  }
}
