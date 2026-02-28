# Doc 2 — Schema do Banco de Dados

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## DDL Completo

```sql
PRAGMA foreign_keys = ON;
PRAGMA user_version = 1;

-- ────────────────────────────────────────
-- TABELA: alunos
-- ────────────────────────────────────────
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
  deletado_em           TEXT    -- NULL = ativo, timestamp = deletado
);

CREATE INDEX idx_alunos_ativo ON alunos(ativo);
CREATE INDEX idx_alunos_deletado_em ON alunos(deletado_em);
CREATE INDEX idx_alunos_ultimo_acesso ON alunos(ultimo_acesso DESC);

-- ────────────────────────────────────────
-- TABELA: treinos
-- ────────────────────────────────────────
CREATE TABLE treinos (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  aluno_id     INTEGER NOT NULL,
  nome         TEXT    NOT NULL,
  descricao    TEXT,
  created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  deletado_em  TEXT,

  FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE
);

CREATE INDEX idx_treinos_aluno_id ON treinos(aluno_id);

-- ────────────────────────────────────────
-- TABELA: treino_exercicios
-- ────────────────────────────────────────
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
);

CREATE INDEX idx_exercicios_treino_ordem ON treino_exercicios(treino_id, ordem);

-- ────────────────────────────────────────
-- TABELA: sessoes
-- ────────────────────────────────────────
CREATE TABLE sessoes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  aluno_id   INTEGER NOT NULL,
  treino_id  INTEGER,
  data       TEXT    NOT NULL,
  observacao TEXT,
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),

  FOREIGN KEY (aluno_id)  REFERENCES alunos(id)  ON DELETE CASCADE,
  FOREIGN KEY (treino_id) REFERENCES treinos(id) ON DELETE SET NULL
);

CREATE INDEX idx_sessoes_aluno_id ON sessoes(aluno_id);
CREATE INDEX idx_sessoes_data ON sessoes(data DESC);

-- ────────────────────────────────────────
-- TABELA: registros_execucao
-- ────────────────────────────────────────
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
  -- Garante upsert correto: um registro por exercício por sessão
  UNIQUE(sessao_id, treino_exercicio_id)
);

CREATE INDEX idx_execucao_sessao_id ON registros_execucao(sessao_id);
```

---

## Decisões técnicas documentadas

**`deletado_em` como TEXT timestamp**
Melhor que boolean porque registra *quando* foi deletado. Soft delete: `WHERE deletado_em IS NULL`. Delete permanente: `DELETE` real no banco.

**`ativo` vs `deletado_em`**
Existem os dois por propósito diferente. `ativo = 0` significa aluno desativado (preservado no histórico). `deletado_em` significa deleção permanente escolhida pelo professor.

**`peso` e `altura` como `REAL` e não `TEXT`**
Viabiliza cálculo de IMC e evolução de peso no futuro sem migração de banco. Custo zero agora, potencial alto depois.

**Datas como `TEXT` no formato ISO 8601**
SQLite não tem tipo nativo de data. Padrão é `YYYY-MM-DD` ou `YYYY-MM-DDTHH:MM:SS`. O Dart converte de/para `DateTime` sem custo.

**`series` como `TEXT` e não `INTEGER`**
Consistência com `repeticoes` e `carga`. Suporta "4" e "4 séries" sem perda de dado.

**`ON DELETE SET NULL` em `sessoes.treino_id`**
Se o treino for deletado, a sessão histórica é preservada — ela existiu. Só perde a referência ao treino.

**`ON DELETE CASCADE` em `registros_execucao`**
Sem sessão, não faz sentido guardar os registros. Cascade correto aqui.

**`sessoes.treino_id` é nullable**
Consequência do `ON DELETE SET NULL` — quando o treino é deletado depois da sessão já existir.

**`PRAGMA user_version = 1`**
Controle de versão do banco. Essencial para migrations futuras sem perder dados do usuário.

**Índices definidos explicitamente**
Sem índice em `treinos.aluno_id`, queries ficam lentas com 100+ alunos. Todos os campos usados em `WHERE` e `ORDER BY` têm índice.
