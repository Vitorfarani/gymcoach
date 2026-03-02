// treino_repository.dart
//
// Contrato (interface) do repositório de treinos e exercícios.
//
// PAPEL NA ARQUITETURA:
// Este arquivo fica em `domain/` e define O QUÊ o repositório deve fazer,
// sem dizer COMO. A implementação real fica em:
//   data/repositories/treino_repository_impl.dart
//
// POR QUE ABSTRACT CLASS AQUI?
// - Os use cases dependem desta abstract class, não da implementação concreta.
// - Isso permite trocar sqflite por outro banco no futuro sem tocar nos use cases.
// - Facilita testes: basta criar um FakeTreinoRepository que implemente este contrato.
//
// POR QUE EXERCÍCIOS AQUI (e não em um repositório separado)?
// Exercícios são inseparáveis dos treinos no MVP:
// - Sempre listados no contexto de um treino (`listarExercicios(treinoId)`)
// - Reordenação é um batch que atualiza todos de uma vez
// - Ciclo de vida idêntico: deletar treino deleta exercícios em cascade
// Manter no mesmo repositório simplifica o MVP sem violação arquitetural.
//
// EXCEÇÕES:
// Os métodos lançam as exceções definidas em core/errors/exceptions.dart.
// Não há retorno de Failure aqui — exceptions são lançadas e capturadas
// pelos providers na camada de apresentação.

import '../entities/treino.dart';
import '../entities/treino_exercicio.dart';

abstract class TreinoRepository {
  // ══════════════════════════════════════════════════════════════════════════
  // TREINOS
  // ══════════════════════════════════════════════════════════════════════════

  // ── Leitura ───────────────────────────────────────────────────────────────

  /// Lista todos os treinos ativos de um aluno, ordenados por data de criação.
  ///
  /// Filtra `WHERE aluno_id = [alunoId] AND deletado_em IS NULL`.
  /// Retorna lista vazia se o aluno não tiver treinos — não lança exceção.
  ///
  /// Lança:
  /// - [DatabaseException] — erro de leitura no banco
  Future<List<Treino>> listarPorAluno(int alunoId);

  /// Busca um treino pelo id.
  ///
  /// Lança:
  /// - [TreinoNaoEncontradoException] — id não existe ou treino foi deletado
  /// - [DatabaseException]
  Future<Treino> buscarPorId(int id);

  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Persiste um novo treino no banco e retorna o id gerado.
  ///
  /// O [treino] passado deve ter [Treino.id] == null.
  /// Retorna o id do registro inserido (gerado pelo AUTOINCREMENT do banco).
  ///
  /// Lança:
  /// - [NomeObrigatorioException] — nome vazio
  /// - [DatabaseException]
  Future<int> criar(Treino treino);

  /// Atualiza os dados de um treino existente.
  ///
  /// O [treino] deve ter [Treino.id] preenchido.
  ///
  /// Lança:
  /// - [TreinoNaoEncontradoException] — id não existe no banco
  /// - [NomeObrigatorioException] — nome vazio
  /// - [DatabaseException]
  Future<void> atualizar(Treino treino);

  /// Realiza soft delete do treino: preenche `deletado_em` com o timestamp atual.
  ///
  /// O banco aplica ON DELETE CASCADE nos exercícios vinculados — todos são
  /// apagados automaticamente. Sessões que referenciavam este treino têm
  /// `treino_id` setado para NULL (preservam o histórico — doc1).
  ///
  /// Lança:
  /// - [TreinoNaoEncontradoException]
  /// - [DatabaseException]
  Future<void> deletar(int id);

  // ══════════════════════════════════════════════════════════════════════════
  // EXERCÍCIOS
  // ══════════════════════════════════════════════════════════════════════════

  // ── Leitura ───────────────────────────────────────────────────────────────

  /// Lista todos os exercícios ativos de um treino, ordenados por [ordem] ASC.
  ///
  /// Filtra `WHERE treino_id = [treinoId] AND deletado_em IS NULL ORDER BY ordem`.
  /// Retorna lista vazia se o treino não tiver exercícios — não lança exceção.
  ///
  /// Usa o índice `idx_exercicios_treino_ordem(treino_id, ordem)` para
  /// performance eficiente mesmo com muitos exercícios.
  ///
  /// Lança:
  /// - [DatabaseException]
  Future<List<TreinoExercicio>> listarExercicios(int treinoId);

  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Adiciona um novo exercício ao treino e retorna o id gerado.
  ///
  /// O [exercicio] passado deve ter [TreinoExercicio.id] == null.
  /// O campo [TreinoExercicio.ordem] deve ser o próximo índice disponível
  /// (geralmente `quantidade_atual`), calculado pelo use case antes de chamar.
  ///
  /// Lança:
  /// - [NomeObrigatorioException] — nomeExercicio vazio
  /// - [DatabaseException]
  Future<int> adicionarExercicio(TreinoExercicio exercicio);

  /// Atualiza os dados de um exercício existente.
  ///
  /// O [exercicio] deve ter [TreinoExercicio.id] preenchido.
  /// Campos atualizáveis: nomeExercicio, series, repeticoes, carga, observacao.
  /// A ordem é atualizada separadamente via [reordenarExercicios].
  ///
  /// Lança:
  /// - [ExercicioNaoEncontradoException] — id não existe no banco
  /// - [NomeObrigatorioException] — nomeExercicio vazio
  /// - [DatabaseException]
  Future<void> atualizarExercicio(TreinoExercicio exercicio);

  /// Remove um exercício do treino (soft delete).
  ///
  /// Preenche `deletado_em` com o timestamp atual.
  /// Os índices dos demais exercícios NÃO são recalculados automaticamente —
  /// o use case deve chamar [reordenarExercicios] logo após para normalizar.
  ///
  /// Lança:
  /// - [ExercicioNaoEncontradoException]
  /// - [DatabaseException]
  Future<void> deletarExercicio(int id);

  /// Persiste a nova ordem de todos os exercícios de um treino em batch.
  ///
  /// Recebe a lista completa de exercícios com os campos [TreinoExercicio.id]
  /// e [TreinoExercicio.ordem] já ajustados pelo use case.
  ///
  /// Por que batch (todos de uma vez)?
  /// Ao mover um exercício, a `ordem` de TODOS os vizinhos muda.
  /// Atualizar um por um seria N queries e poderia deixar o banco em estado
  /// inconsistente se a operação falhar no meio. O batch é atômico.
  ///
  /// Exemplo: lista de 4 exercícios — mover o item de ordem 3 para ordem 0:
  /// [3,0,1,2] → use case recalcula → [0,1,2,3] → repositório salva tudo.
  ///
  /// Lança:
  /// - [DatabaseException]
  Future<void> reordenarExercicios(List<TreinoExercicio> exercicios);
}
