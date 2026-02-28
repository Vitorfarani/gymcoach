// database_helper.dart
//
// Responsabilidade única: abrir, versionar e fornecer a instância do banco
// SQLite para todos os DAOs do app.
//
// REGRA: nenhum outro arquivo deve importar 'sqflite' diretamente exceto os
// DAOs — e mesmo eles recebem a instância via DatabaseHelper, não abrem
// o banco sozinhos.
//
// PADRÃO SINGLETON:
// O banco é aberto uma única vez. Cada chamada a `DatabaseHelper.instance`
// retorna o mesmo objeto. Isso evita conexões duplicadas e race conditions.

import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------

  /// Única instância global do helper.
  ///
  /// Uso nos DAOs:
  /// ```dart
  /// final db = await DatabaseHelper.instance.database;
  /// ```
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// Construtor privado — impede que alguém crie `DatabaseHelper()` do lado de fora.
  DatabaseHelper._internal();

  // ---------------------------------------------------------------------------
  // Estado interno
  // ---------------------------------------------------------------------------

  /// Cache da conexão aberta.
  ///
  /// `Database?` com `?` porque começa nulo e só é preenchida na primeira
  /// chamada ao getter [database].
  Database? _database;

  // ---------------------------------------------------------------------------
  // Constantes
  // ---------------------------------------------------------------------------

  /// Nome do arquivo .db salvo no dispositivo.
  static const String _dbName = 'gymcoach.db';

  /// Versão atual do schema. Incrementar aqui + adicionar lógica em
  /// [_onUpgrade] sempre que mudar a estrutura do banco.
  static const int _dbVersion = 1;

  // ---------------------------------------------------------------------------
  // API pública
  // ---------------------------------------------------------------------------

  /// Retorna a conexão com o banco, abrindo-a na primeira chamada.
  ///
  /// `async` porque abrir o banco envolve I/O (disco). O `??=` garante que
  /// [_initDatabase] só é chamado uma vez — nas próximas chamadas o cache
  /// já está preenchido e o await resolve imediatamente.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ---------------------------------------------------------------------------
  // Inicialização
  // ---------------------------------------------------------------------------

  Future<Database> _initDatabase() async {
    // getDatabasesPath() retorna o diretório padrão do sistema para bancos SQLite
    // Ex: /data/user/0/com.example.gymcoach/databases/
    final dbPath = await getDatabasesPath();

    // join() constrói o caminho completo: .../databases/gymcoach.db
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,

      // Roda em TODA abertura, antes de qualquer query.
      // Lugar certo para PRAGMAs de configuração global.
      onConfigure: _onConfigure,

      // Roda apenas quando o arquivo não existia (primeiro uso no dispositivo).
      onCreate: _onCreate,

      // Roda quando _dbVersion > versão gravada no arquivo.
      onUpgrade: _onUpgrade,
    );
  }

  // ---------------------------------------------------------------------------
  // Configuração de conexão
  // ---------------------------------------------------------------------------

  /// Ativa o suporte a chaves estrangeiras.
  ///
  /// No SQLite, `FOREIGN KEY` e `ON DELETE CASCADE` são IGNORADOS por padrão.
  /// Este PRAGMA deve ser chamado em cada abertura de conexão.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ---------------------------------------------------------------------------
  // Criação das tabelas (primeira instalação)
  // ---------------------------------------------------------------------------

  /// Cria todas as tabelas e índices dentro de uma única transação.
  ///
  /// Transação garante atomicidade: ou tudo é criado, ou nada é — sem banco
  /// meio-criado se o app fechar no meio do processo.
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // ── alunos ────────────────────────────────────────────────────────────
      await txn.execute(_sqlCreateAlunos);
      await txn.execute(_sqlIndexAlunosAtivo);
      await txn.execute(_sqlIndexAlunosDeletadoEm);
      await txn.execute(_sqlIndexAlunosUltimoAcesso);

      // ── treinos ───────────────────────────────────────────────────────────
      await txn.execute(_sqlCreateTreinos);
      await txn.execute(_sqlIndexTreinosAlunoId);

      // ── treino_exercicios ─────────────────────────────────────────────────
      await txn.execute(_sqlCreateTreinoExercicios);
      await txn.execute(_sqlIndexExerciciosTreinoOrdem);

      // ── sessoes ───────────────────────────────────────────────────────────
      await txn.execute(_sqlCreateSessoes);
      await txn.execute(_sqlIndexSessoesAlunoId);
      await txn.execute(_sqlIndexSessoesData);

      // ── registros_execucao ────────────────────────────────────────────────
      await txn.execute(_sqlCreateRegistrosExecucao);
      await txn.execute(_sqlIndexExecucaoSessaoId);
    });
  }

  // ---------------------------------------------------------------------------
  // Migrações (versões futuras do schema)
  // ---------------------------------------------------------------------------

  /// Chamado quando [_dbVersion] é maior que a versão gravada no arquivo.
  ///
  /// Exemplo de uso futuro:
  /// ```dart
  /// if (oldVersion < 2) {
  ///   await db.execute('ALTER TABLE alunos ADD COLUMN telefone TEXT');
  /// }
  /// ```
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2, v2 → v3... serão adicionados aqui conforme o app evolui.
    // Nunca usar DROP TABLE aqui — preserve os dados do usuário.
  }

  // ---------------------------------------------------------------------------
  // DDL — tabela: alunos
  // ---------------------------------------------------------------------------

  static const String _sqlCreateAlunos = '''
    CREATE TABLE alunos (
      id                    INTEGER PRIMARY KEY AUTOINCREMENT,
      nome                  TEXT    NOT NULL CHECK(length(nome) >= 2 AND length(nome) <= 60),
      foto_path             TEXT,
      idade                 INTEGER CHECK(idade >= 10 AND idade <= 99),
      peso                  REAL    CHECK(peso >= 30.0 AND peso <= 250.0),
      altura                REAL    CHECK(altura >= 100.0 AND altura <= 250.0),
      objetivo              TEXT,
      observacoes           TEXT,
      data_inicio           TEXT    NOT NULL DEFAULT (date('now')),
      data_ultima_avaliacao TEXT,
      ultimo_acesso         TEXT    NOT NULL DEFAULT (datetime('now')),
      ativo                 INTEGER NOT NULL DEFAULT 1,
      created_at            TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at            TEXT    NOT NULL DEFAULT (datetime('now')),
      deletado_em           TEXT
    )
  ''';

  // `deletado_em IS NULL` é a condição padrão de "aluno ativo".
  // O índice acelera este filtro frequente.
  static const String _sqlIndexAlunosDeletadoEm =
      'CREATE INDEX idx_alunos_deletado_em ON alunos(deletado_em)';

  // `ativo = 1` filtra alunos não-desativados. Índice separado do deletado_em
  // porque têm semânticas diferentes (veja doc2 para detalhes).
  static const String _sqlIndexAlunosAtivo =
      'CREATE INDEX idx_alunos_ativo ON alunos(ativo)';

  // Dashboard usa `ORDER BY ultimo_acesso DESC LIMIT 5`. DESC no índice
  // evita full scan na tabela.
  static const String _sqlIndexAlunosUltimoAcesso =
      'CREATE INDEX idx_alunos_ultimo_acesso ON alunos(ultimo_acesso DESC)';

  // ---------------------------------------------------------------------------
  // DDL — tabela: treinos
  // ---------------------------------------------------------------------------

  static const String _sqlCreateTreinos = '''
    CREATE TABLE treinos (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id    INTEGER NOT NULL,
      nome        TEXT    NOT NULL,
      descricao   TEXT,
      created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      deletado_em TEXT,

      FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE
    )
  ''';

  static const String _sqlIndexTreinosAlunoId =
      'CREATE INDEX idx_treinos_aluno_id ON treinos(aluno_id)';

  // ---------------------------------------------------------------------------
  // DDL — tabela: treino_exercicios
  // ---------------------------------------------------------------------------

  static const String _sqlCreateTreinoExercicios = '''
    CREATE TABLE treino_exercicios (
      id             INTEGER PRIMARY KEY AUTOINCREMENT,
      treino_id      INTEGER NOT NULL,
      nome_exercicio TEXT    NOT NULL,
      series         TEXT    NOT NULL,
      repeticoes     TEXT,
      carga          TEXT,
      observacao     TEXT,
      ordem          INTEGER NOT NULL DEFAULT 0,
      created_at     TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at     TEXT    NOT NULL DEFAULT (datetime('now')),
      deletado_em    TEXT,

      FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE CASCADE
    )
  ''';

  // Composto (treino_id, ordem): busca exercícios de um treino já ordenados.
  static const String _sqlIndexExerciciosTreinoOrdem =
      'CREATE INDEX idx_exercicios_treino_ordem ON treino_exercicios(treino_id, ordem)';

  // ---------------------------------------------------------------------------
  // DDL — tabela: sessoes
  // ---------------------------------------------------------------------------

  static const String _sqlCreateSessoes = '''
    CREATE TABLE sessoes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      aluno_id   INTEGER NOT NULL,
      treino_id  INTEGER,
      data       TEXT    NOT NULL,
      observacao TEXT,
      created_at TEXT    NOT NULL DEFAULT (datetime('now')),

      FOREIGN KEY (aluno_id)  REFERENCES alunos(id)   ON DELETE CASCADE,
      FOREIGN KEY (treino_id) REFERENCES treinos(id)  ON DELETE SET NULL
    )
  ''';

  // `treino_id` é nullable: se o treino for deletado depois da sessão existir,
  // a sessão histórica é preservada mas perde a referência ao treino.
  static const String _sqlIndexSessoesAlunoId =
      'CREATE INDEX idx_sessoes_aluno_id ON sessoes(aluno_id)';

  static const String _sqlIndexSessoesData =
      'CREATE INDEX idx_sessoes_data ON sessoes(data DESC)';

  // ---------------------------------------------------------------------------
  // DDL — tabela: registros_execucao
  // ---------------------------------------------------------------------------

  static const String _sqlCreateRegistrosExecucao = '''
    CREATE TABLE registros_execucao (
      id                    INTEGER PRIMARY KEY AUTOINCREMENT,
      sessao_id             INTEGER NOT NULL,
      treino_exercicio_id   INTEGER NOT NULL,
      carga_realizada       TEXT,
      repeticoes_realizadas TEXT,
      observacao            TEXT,
      created_at            TEXT    NOT NULL DEFAULT (datetime('now')),

      FOREIGN KEY (sessao_id)           REFERENCES sessoes(id)           ON DELETE CASCADE,
      FOREIGN KEY (treino_exercicio_id) REFERENCES treino_exercicios(id) ON DELETE CASCADE,

      UNIQUE(sessao_id, treino_exercicio_id)
    )
  ''';

  // A constraint UNIQUE garante que o INSERT OR REPLACE (upsert) funcione
  // corretamente: um registro por exercício por sessão.
  static const String _sqlIndexExecucaoSessaoId =
      'CREATE INDEX idx_execucao_sessao_id ON registros_execucao(sessao_id)';
}
