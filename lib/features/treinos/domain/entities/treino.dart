// treino.dart
//
// Entidade de domínio que representa um treino cadastrado para um aluno.
//
// REGRAS IMPORTANTES:
// - Este arquivo não importa sqflite, flutter, riverpod nem qualquer framework.
// - É a fonte da verdade sobre o que um Treino é no sistema.
// - Todas as outras camadas (data, presentation) dependem daqui, nunca o contrário.
//
// POR QUE CLASSE SIMPLES (sem Freezed)?
// Freezed gera código automaticamente, mas exige `build_runner` a cada mudança.
// Uma classe simples com `copyWith` manual é equivalente, mais transparente
// e mais fácil de entender para quem está aprendendo.

/// Representa um treino cadastrado para um aluno.
///
/// Um aluno pode ter quantos treinos quiser (A, B, C, ou qualquer nome livre).
/// O nome é definido pelo professor — não há lista fechada no MVP.
///
/// Esta classe é imutável: todos os campos são `final`. Para "modificar" um
/// treino, use [copyWith] para criar uma cópia com os campos alterados:
///
/// ```dart
/// final treinoAtualizado = treino.copyWith(nome: 'Treino B');
/// ```
class Treino {
  // ── Identificação ──────────────────────────────────────────────────────────

  /// Chave primária gerada pelo banco (AUTOINCREMENT).
  ///
  /// Null antes de ser salvo no banco. Após o INSERT, sempre será não-nulo.
  final int? id;

  /// FK para a tabela `alunos` — a qual aluno este treino pertence.
  ///
  /// Sempre obrigatório. O banco tem ON DELETE CASCADE: se o aluno for
  /// deletado, todos os seus treinos são deletados automaticamente junto.
  final int alunoId;

  // ── Campos do treino ───────────────────────────────────────────────────────

  /// Nome do treino, definido livremente pelo professor.
  ///
  /// Exemplos: "Treino A", "Peito e Tríceps", "Full Body Segunda".
  /// Nomes duplicados no mesmo aluno são permitidos (doc1).
  /// Campo obrigatório — não pode ser vazio.
  final String nome;

  /// Descrição opcional do treino.
  ///
  /// Espaço para o professor anotar informações gerais sobre o treino,
  /// como foco muscular, intensidade, etc. Null quando não preenchido.
  final String? descricao;

  // ── Metadados de auditoria ─────────────────────────────────────────────────

  /// Timestamp de criação do registro no banco.
  ///
  /// Setado automaticamente no INSERT (DEFAULT datetime('now') no SQLite).
  /// Armazenado como TEXT ISO 8601 no banco e convertido para DateTime aqui.
  final DateTime dataCriacao;

  /// Timestamp da última atualização do registro no banco.
  ///
  /// Atualizado a cada UPDATE. Igual a [dataCriacao] logo após o INSERT.
  final DateTime dataAtualizacao;

  /// Timestamp de quando o treino foi deletado (soft delete).
  ///
  /// Null = treino ativo e visível na UI.
  /// Não-null = treino deletado. Queries sempre filtram `WHERE deletado_em IS NULL`.
  ///
  /// Ao deletar um treino, os exercícios vinculados são apagados em cascade
  /// pelo banco. Sessões que referenciavam este treino têm `treino_id` setado
  /// para NULL (o histórico de sessões é preservado — doc1).
  final DateTime? deletadoEm;

  // ── Construtor ─────────────────────────────────────────────────────────────

  const Treino({
    this.id,
    required this.alunoId,
    required this.nome,
    this.descricao,
    required this.dataCriacao,
    required this.dataAtualizacao,
    this.deletadoEm,
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  /// Retorna uma cópia deste treino com os campos informados substituídos.
  ///
  /// Campos não informados mantêm o valor original.
  ///
  /// ```dart
  /// final copia = treino.copyWith(nome: 'Treino B');
  /// ```
  ///
  /// LIMITAÇÃO: não é possível setar [descricao] ou [deletadoEm] de volta
  /// para null via copyWith (ambos viriam null por padrão e o ?? manteria
  /// o valor atual). Para esse caso, crie uma nova instância diretamente.
  Treino copyWith({
    int? id,
    int? alunoId,
    String? nome,
    String? descricao,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    DateTime? deletadoEm,
  }) {
    return Treino(
      id: id ?? this.id,
      alunoId: alunoId ?? this.alunoId,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      deletadoEm: deletadoEm ?? this.deletadoEm,
    );
  }

  // ── toString ───────────────────────────────────────────────────────────────

  /// Representação textual do treino — útil para logs e debugging.
  @override
  String toString() {
    return 'Treino('
        'id: $id, '
        'alunoId: $alunoId, '
        'nome: $nome, '
        'descricao: $descricao, '
        'dataCriacao: $dataCriacao, '
        'dataAtualizacao: $dataAtualizacao, '
        'deletadoEm: $deletadoEm'
        ')';
  }
}
