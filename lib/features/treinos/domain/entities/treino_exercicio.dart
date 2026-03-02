// treino_exercicio.dart
//
// Entidade de domínio que representa um exercício dentro de um treino.
//
// RELAÇÃO COM Treino:
// Um Treino contém muitos TreinoExercicios (1-para-muitos).
// TreinoExercicio é a "linha filha" — cada instância é um exercício
// na lista de um treino específico.
//
// CAMPOS COMO TEXT (String) NO BANCO:
// `series`, `repeticoes` e `carga` são TEXT no SQLite (não INTEGER/REAL).
// Isso permite valores como "4 séries", "até a falha", "peso corporal",
// "10-12 reps" — sem perda de informação. (doc1 e doc2)
//
// REORDENAÇÃO:
// O campo `ordem` controla a sequência dos exercícios na lista do treino.
// O professor reordena com botões subir/descer (drag-and-drop vai para v2).

/// Representa um exercício dentro de um treino.
///
/// Esta classe é imutável: todos os campos são `final`. Para "modificar",
/// use [copyWith] para criar uma cópia com os campos alterados:
///
/// ```dart
/// final atualizado = exercicio.copyWith(series: '5');
/// ```
class TreinoExercicio {
  // ── Identificação ──────────────────────────────────────────────────────────

  /// Chave primária gerada pelo banco (AUTOINCREMENT).
  ///
  /// Null antes de ser salvo no banco. Após o INSERT, sempre será não-nulo.
  final int? id;

  /// FK para a tabela `treinos` — a qual treino este exercício pertence.
  ///
  /// O banco tem ON DELETE CASCADE: se o treino for deletado, todos os seus
  /// exercícios são deletados automaticamente junto.
  final int treinoId;

  // ── Campos do exercício ────────────────────────────────────────────────────

  /// Nome do exercício (campo obrigatório).
  ///
  /// Texto livre definido pelo professor.
  /// Exemplos: "Supino Reto", "Agachamento Livre", "Rosca Direta".
  final String nomeExercicio;

  /// Número de séries (campo obrigatório).
  ///
  /// Armazenado como TEXT para suportar formatos variados:
  /// "4", "3-4", "4 séries drop-set".
  final String series;

  /// Número de repetições (campo opcional).
  ///
  /// Armazenado como TEXT para suportar: "12", "10-12", "até a falha",
  /// "30 segundos". Null quando o professor não especifica.
  final String? repeticoes;

  /// Carga utilizada no exercício (campo opcional).
  ///
  /// Armazenado como TEXT para suportar: "20kg", "peso corporal",
  /// "elástico médio", "barra + 40kg". Null quando não especificado.
  final String? carga;

  /// Observação ou instrução adicional sobre o exercício (campo opcional).
  ///
  /// Espaço para o professor anotar técnica, variações, cuidados, etc.
  /// Null quando não preenchido.
  final String? observacao;

  // ── Posição na lista ───────────────────────────────────────────────────────

  /// Posição do exercício na lista do treino (começa em 0).
  ///
  /// Controla a ordem de exibição. Quando o professor reordena com os botões
  /// subir/descer, o use case `ReordenarExercicios` atualiza este campo
  /// em todos os exercícios afetados de uma vez (batch UPDATE).
  ///
  /// Índice no banco: `idx_exercicios_treino_ordem(treino_id, ordem)`
  /// garante queries rápidas ao listar exercícios já ordenados.
  final int ordem;

  // ── Metadados de auditoria ─────────────────────────────────────────────────

  /// Timestamp de criação do registro no banco.
  ///
  /// Setado automaticamente no INSERT (DEFAULT datetime('now') no SQLite).
  final DateTime dataCriacao;

  /// Timestamp da última atualização do registro no banco.
  ///
  /// Atualizado a cada UPDATE (nome, séries, carga, ordem, etc.).
  final DateTime dataAtualizacao;

  /// Timestamp de quando o exercício foi deletado (soft delete).
  ///
  /// Null = exercício ativo e visível na lista do treino.
  /// Não-null = exercício deletado. Queries filtram `WHERE deletado_em IS NULL`.
  final DateTime? deletadoEm;

  // ── Construtor ─────────────────────────────────────────────────────────────

  const TreinoExercicio({
    this.id,
    required this.treinoId,
    required this.nomeExercicio,
    required this.series,
    this.repeticoes,
    this.carga,
    this.observacao,
    required this.ordem,
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.deletadoEm,
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  /// Retorna uma cópia deste exercício com os campos informados substituídos.
  ///
  /// ```dart
  /// final atualizado = exercicio.copyWith(series: '5', carga: '25kg');
  /// ```
  ///
  /// LIMITAÇÃO: não é possível setar campos nullable de volta para null
  /// via copyWith. Para esse caso, crie uma nova instância diretamente.
  TreinoExercicio copyWith({
    int? id,
    int? treinoId,
    String? nomeExercicio,
    String? series,
    String? repeticoes,
    String? carga,
    String? observacao,
    int? ordem,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    DateTime? deletadoEm,
  }) {
    return TreinoExercicio(
      id: id ?? this.id,
      treinoId: treinoId ?? this.treinoId,
      nomeExercicio: nomeExercicio ?? this.nomeExercicio,
      series: series ?? this.series,
      repeticoes: repeticoes ?? this.repeticoes,
      carga: carga ?? this.carga,
      observacao: observacao ?? this.observacao,
      ordem: ordem ?? this.ordem,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      deletadoEm: deletadoEm ?? this.deletadoEm,
    );
  }

  // ── toString ───────────────────────────────────────────────────────────────

  /// Representação textual do exercício — útil para logs e debugging.
  @override
  String toString() {
    return 'TreinoExercicio('
        'id: $id, '
        'treinoId: $treinoId, '
        'nomeExercicio: $nomeExercicio, '
        'series: $series, '
        'repeticoes: $repeticoes, '
        'carga: $carga, '
        'observacao: $observacao, '
        'ordem: $ordem, '
        'dataCriacao: $dataCriacao, '
        'dataAtualizacao: $dataAtualizacao, '
        'deletadoEm: $deletadoEm'
        ')';
  }
}
