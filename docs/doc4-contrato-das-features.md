# Doc 4 — Contrato das Features

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## Como ler este documento

Cada use case segue o formato:

- **Entrada:** o que chega pro use case
- **Saída:** o que ele devolve em caso de sucesso
- **Erros possíveis:** o que pode dar errado e qual exceção lançar

---

## Feature: Alunos

---

### CriarAluno
- **Entrada:** `nome`, `foto_path?`, `idade?`, `peso?`, `altura?`, `objetivo?`, `observacoes?`
- **Saída:** `Aluno` criado com `id` gerado
- **Erros:**
  - `NomeObrigatorioException` — nome vazio ou nulo
  - `NomeInvalidoException` — nome fora do range (< 2 ou > 60 caracteres)
  - `IdadeInvalidaException` — idade fora do range (< 10 ou > 99)
  - `PesoInvalidoException` — peso fora do range (< 30 ou > 250)
  - `AlturaInvalidaException` — altura fora do range (< 100 ou > 250)
  - `DatabaseException` — erro ao persistir no banco

---

### EditarAluno
- **Entrada:** `id`, + qualquer campo editável (`nome`, `foto_path?`, `idade?`, `peso?`, `altura?`, `objetivo?`, `observacoes?`, `data_ultima_avaliacao?`)
- **Saída:** `Aluno` atualizado
- **Erros:**
  - Mesmos de `CriarAluno`
  - `AlunoNaoEncontradoException` — id não existe no banco
  - `DatabaseException`

---

### BuscarAlunoPorId
- **Entrada:** `id`
- **Saída:** `Aluno`
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### ListarAlunos
- **Entrada:** `query?` (texto de busca por nome)
- **Saída:** `List<Aluno>` — apenas ativos (`deletado_em IS NULL`), ordenados por `nome ASC`
- **Erros:**
  - `DatabaseException`

---

### ListarUltimosAlunosAcessados
- **Entrada:** `limite` (fixo: 5)
- **Saída:** `List<Aluno>` — últimos acessados (`ORDER BY ultimo_acesso DESC LIMIT 5`)
- **Erros:**
  - `DatabaseException`

---

### ContarAlunosAtivos
- **Entrada:** nenhuma
- **Saída:** `int`
- **Erros:**
  - `DatabaseException`

---

### AtualizarUltimoAcesso
- **Entrada:** `id`
- **Saída:** void
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### DeletarAluno
- **Entrada:** `id`
- **Saída:** void
- **Comportamento:** soft delete — preenche `deletado_em` com timestamp atual. Cascade no banco garante que treinos, exercícios, sessões e registros são apagados.
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### SalvarFotoAluno
- **Entrada:** `id`, `imagemOriginal` (File)
- **Saída:** `fotoPath` (String — caminho do arquivo salvo)
- **Comportamento:** redimensiona para 800x800px, comprime, salva no diretório do app, atualiza `foto_path` no banco
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `ImagemMuitoGrandeException` — arquivo original > 5MB
  - `ErroAoProcessarImagemException`
  - `DatabaseException`

---

### RemoverFotoAluno
- **Entrada:** `id`
- **Saída:** void
- **Comportamento:** deleta arquivo físico do dispositivo + limpa `foto_path` no banco
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

## Feature: Treinos

---

### CriarTreino
- **Entrada:** `aluno_id`, `nome`, `descricao?`
- **Saída:** `Treino` criado com `id` gerado
- **Erros:**
  - `NomeObrigatorioException`
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### EditarTreino
- **Entrada:** `id`, `nome`, `descricao?`
- **Saída:** `Treino` atualizado
- **Erros:**
  - `NomeObrigatorioException`
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

### ListarTreinosDoAluno
- **Entrada:** `aluno_id`
- **Saída:** `List<Treino>` — apenas ativos (`deletado_em IS NULL`), ordenados por `created_at ASC`
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### BuscarTreinoPorId
- **Entrada:** `id`
- **Saída:** `Treino`
- **Erros:**
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

### DeletarTreino
- **Entrada:** `id`
- **Saída:** void
- **Comportamento:** delete permanente. Cascade no banco apaga exercícios. Sessões vinculadas têm `treino_id` setado para NULL.
- **Erros:**
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

## Feature: Exercícios

---

### CriarExercicio
- **Entrada:** `treino_id`, `nome_exercicio`, `series`, `repeticoes?`, `carga?`, `observacao?`
- **Saída:** `Exercicio` criado, com `ordem` = último da lista + 1
- **Erros:**
  - `NomeObrigatorioException`
  - `SeriesObrigatorioException`
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

### EditarExercicio
- **Entrada:** `id`, `nome_exercicio`, `series`, `repeticoes?`, `carga?`, `observacao?`
- **Saída:** `Exercicio` atualizado
- **Erros:**
  - `NomeObrigatorioException`
  - `SeriesObrigatorioException`
  - `ExercicioNaoEncontradoException`
  - `DatabaseException`

---

### ListarExerciciosDoTreino
- **Entrada:** `treino_id`
- **Saída:** `List<Exercicio>` — ordenados por `ordem ASC`
- **Erros:**
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

### ReordenarExercicio
- **Entrada:** `treino_id`, `exercicio_id`, `direcao` (enum: `subir` | `descer`)
- **Saída:** void
- **Comportamento:** troca o valor de `ordem` entre o exercício e o seu vizinho na direção indicada
- **Erros:**
  - `ExercicioNaoEncontradoException`
  - `ReordenacaoImpossívelException` — exercício já está no topo (subir) ou no final (descer)
  - `DatabaseException`

---

### DeletarExercicio
- **Entrada:** `id`
- **Saída:** void
- **Comportamento:** delete permanente.
- **Erros:**
  - `ExercicioNaoEncontradoException`
  - `DatabaseException`

---

## Feature: Sessões

---

### IniciarSessao
- **Entrada:** `aluno_id`, `treino_id`
- **Saída:** `Sessao` criada com `data` = `datetime('now')`
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `TreinoNaoEncontradoException`
  - `DatabaseException`

---

### FinalizarSessao
- **Entrada:** `sessao_id`
- **Saída:** void
- **Comportamento:** apenas marca a sessão como encerrada — no MVP não há campo de status, a sessão existe e está finalizada por definição
- **Erros:**
  - `SessaoNaoEncontradaException`
  - `DatabaseException`

---

### DeletarSessao
- **Entrada:** `sessao_id`
- **Saída:** void
- **Comportamento:** delete permanente. Cascade apaga registros de execução.
- **Erros:**
  - `SessaoNaoEncontradaException`
  - `DatabaseException`

---

### ListarSessoesDoAluno
- **Entrada:** `aluno_id`
- **Saída:** `List<Sessao>` — ordenadas por `data DESC`
- **Erros:**
  - `AlunoNaoEncontradoException`
  - `DatabaseException`

---

### BuscarSessaoPorId
- **Entrada:** `sessao_id`
- **Saída:** `Sessao`
- **Erros:**
  - `SessaoNaoEncontradaException`
  - `DatabaseException`

---

## Feature: Registros de Execução

---

### SalvarRegistroExecucao
- **Entrada:** `sessao_id`, `treino_exercicio_id`, `carga_realizada?`, `repeticoes_realizadas?`, `observacao?`
- **Saída:** `RegistroExecucao` criado ou atualizado
- **Comportamento:** upsert — se já existe registro para esse `sessao_id` + `treino_exercicio_id`, atualiza. Se não existe, cria. Garante a persistência parcial.
- **Erros:**
  - `SessaoNaoEncontradaException`
  - `ExercicioNaoEncontradoException`
  - `DatabaseException`

---

### ListarRegistrosDaSessao
- **Entrada:** `sessao_id`
- **Saída:** `List<RegistroExecucao>`
- **Erros:**
  - `SessaoNaoEncontradaException`
  - `DatabaseException`

---

### DeletarRegistroExecucao
- **Entrada:** `id`
- **Saída:** void
- **Erros:**
  - `RegistroNaoEncontradoException`
  - `DatabaseException`

---

## Feature: Dashboard

---

### CarregarDashboard
- **Entrada:** nenhuma
- **Saída:** `DashboardData` contendo:
  - `totalAlunosAtivos: int`
  - `ultimosAlunos: List<Aluno>` (máximo 5)
- **Comportamento:** executa as duas queries em paralelo
- **Erros:**
  - `DatabaseException`