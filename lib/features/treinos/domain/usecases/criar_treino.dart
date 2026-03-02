// criar_treino.dart
//
// Use case: persiste um novo treino no banco para um aluno.
//
// RESPONSABILIDADE:
//   1. Valida que o nome não está vazio (único campo obrigatório — doc1)
//   2. Monta o objeto Treino com os timestamps iniciais
//   3. Delega a persistência ao repositório
//   4. Retorna o Treino com o id gerado pelo banco
//
// NOME LIVRE (doc1):
//   Treinos não têm restrição de range no nome (diferente de Aluno.nome).
//   A única regra é que não pode ser vazio.

import '../../../../core/errors/exceptions.dart';
import '../entities/treino.dart';
import '../repositories/treino_repository.dart';

class CriarTreino {
  final TreinoRepository _repository;

  CriarTreino(this._repository);

  /// Executa o use case.
  ///
  /// [alunoId] é o aluno dono do treino.
  /// [nome] é obrigatório — não pode ser vazio.
  /// [descricao] é opcional — anotações gerais sobre o treino.
  ///
  /// Retorna o [Treino] criado com o [Treino.id] preenchido pelo banco.
  ///
  /// Lança [NomeObrigatorioException] se o nome estiver vazio.
  /// Lança [AlunoNaoEncontradoException] se o aluno não existir.
  /// Lança [DatabaseException] em falha de persistência.
  Future<Treino> call({
    required int alunoId,
    required String nome,
    String? descricao,
  }) async {
    // ── Validação ─────────────────────────────────────────────────────────────
    // Treino não tem range de nome — apenas obrigatoriedade (doc1).
    if (nome.trim().isEmpty) throw const NomeObrigatorioException();

    // ── Construção do objeto ───────────────────────────────────────────────────
    // Os timestamps são definidos aqui (não no banco) para que o objeto
    // retornado já contenha os valores corretos sem precisar re-buscar.
    final agora = DateTime.now();

    final novoTreino = Treino(
      // id: null — será preenchido pelo banco no INSERT (AUTOINCREMENT)
      alunoId: alunoId,
      nome: nome.trim(),
      descricao: descricao?.trim(),
      dataCriacao: agora,
      dataAtualizacao: agora,
      deletadoEm: null,
    );

    // ── Persistência ──────────────────────────────────────────────────────────
    // repository.criar() insere no banco e retorna o id gerado.
    // Pode lançar AlunoNaoEncontradoException ou DatabaseException.
    final id = await _repository.criar(novoTreino);

    // Devolve o treino com o id agora preenchido — sem precisar buscar de novo.
    return novoTreino.copyWith(id: id);
  }
}
