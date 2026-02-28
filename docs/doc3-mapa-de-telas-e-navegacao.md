# Doc 3 — Mapa de Telas e Navegação

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## Visão geral das telas

| # | Tela | Rota |
|---|------|------|
| 1 | Dashboard | `/` |
| 2 | Lista de Alunos | `/alunos` |
| 3 | Cadastro de Aluno | `/alunos/novo` |
| 4 | Edição de Aluno | `/alunos/:alunoId/editar` |
| 5 | Perfil do Aluno | `/alunos/:alunoId` |
| 6 | Lista de Treinos | `/alunos/:alunoId/treinos` |
| 7 | Cadastro de Treino | `/alunos/:alunoId/treinos/novo` |
| 8 | Detalhe do Treino | `/alunos/:alunoId/treinos/:treinoId` |
| 9 | Cadastro de Exercício | `/alunos/:alunoId/treinos/:treinoId/exercicios/novo` |
| 10 | Iniciar Sessão | `/alunos/:alunoId/sessoes/nova/:treinoId` |
| 11 | Histórico de Sessões | `/alunos/:alunoId/sessoes` |

---

## Tela a tela

---

### 1. Dashboard — `/`

**O que mostra:**
- Total de alunos ativos (número grande, destaque)
- Lista dos últimos 5 alunos acessados (`ORDER BY ultimo_acesso DESC LIMIT 5`)
- Botão flutuante "Novo Aluno"

**Estados:**
- `loading` — skeleton dos cards
- `data` — número + lista
- `empty` — "Nenhum aluno cadastrado ainda" + botão "Cadastrar primeiro aluno"
- `error` — mensagem de erro + botão "Tentar novamente"

**Navegação:**
- Card de aluno → `/alunos/:alunoId`
- FAB "Novo Aluno" → `/alunos/novo`

---

### 2. Lista de Alunos — `/alunos`

**O que mostra:**
- Campo de busca por nome
- Lista de todos os alunos ativos (`WHERE deletado_em IS NULL`)
- Card por aluno: nome, foto, objetivo (se tiver)
- Botão flutuante "Novo Aluno"

**Estados:**
- `loading` — skeleton da lista
- `data` — lista completa
- `empty_search` — "Nenhum aluno encontrado para '[termo]'"
- `empty` — "Nenhum aluno cadastrado" + botão de ação
- `error` — mensagem + retry

**Navegação:**
- Card de aluno → `/alunos/:alunoId` + atualiza `ultimo_acesso`
- FAB → `/alunos/novo`
- Botão voltar → `/`

---

### 3. Cadastro de Aluno — `/alunos/novo`

**O que mostra:**
- Foto (opcional): câmera ou galeria
- Campo nome (obrigatório)
- Campos opcionais: idade, peso, altura, objetivo, observações
- Botão "Salvar"

**Estados:**
- `idle` — formulário vazio
- `saving` — loading no botão, campos desabilitados
- `validation_error` — mensagem inline em cada campo com erro
- `error` — snackbar de erro ao salvar
- `success` — navega para o perfil do aluno recém-criado

**Navegação:**
- Salvar com sucesso → `/alunos/:alunoId` (substitui na pilha — não volta pro formulário)
- Botão voltar → `/alunos` com confirmação se tiver dado digitado

---

### 4. Edição de Aluno — `/alunos/:alunoId/editar`

**O que mostra:**
- Mesmo formulário do cadastro, pré-preenchido
- Opção de trocar ou remover foto
- Botão "Salvar"
- Botão "Deletar Aluno" (destrutivo, destacado visualmente)

**Estados:**
- `loading` — carregando dados do aluno
- `data` — formulário preenchido
- `saving` — loading no botão
- `validation_error` — inline
- `deleting` — dialog de confirmação em dois passos ("Tem certeza?" → "Isso é irreversível. Confirmar?")
- `success_save` — volta para `/alunos/:alunoId`
- `success_delete` — volta para `/alunos` (remove da pilha)

**Navegação:**
- Salvar → `/alunos/:alunoId`
- Deletar com confirmação → `/alunos`
- Botão voltar → `/alunos/:alunoId` com confirmação se tiver alteração não salva

---

### 5. Perfil do Aluno — `/alunos/:alunoId`

**O que mostra:**
- Foto, nome, dados físicos (apenas os que estiverem preenchidos)
- Cards de atalho: "Treinos", "Histórico de Sessões"
- Botão editar (ícone no AppBar)

**Estados:**
- `loading` — skeleton
- `data` — perfil completo
- `error` — mensagem + retry

**Navegação:**
- Editar → `/alunos/:alunoId/editar`
- Card "Treinos" → `/alunos/:alunoId/treinos`
- Card "Histórico de Sessões" → `/alunos/:alunoId/sessoes`
- Botão voltar → tela anterior (Dashboard ou Lista de Alunos)

---

### 6. Lista de Treinos — `/alunos/:alunoId/treinos`

**O que mostra:**
- Nome do aluno no AppBar
- Lista de treinos ativos do aluno
- Card por treino: nome, descrição (se tiver), quantidade de exercícios
- Botão flutuante "Novo Treino"

**Estados:**
- `loading` — skeleton
- `data` — lista
- `empty` — "Nenhum treino cadastrado" + botão de ação
- `error` — mensagem + retry

**Navegação:**
- Card de treino → `/alunos/:alunoId/treinos/:treinoId`
- FAB → `/alunos/:alunoId/treinos/novo`
- Botão voltar → `/alunos/:alunoId`

---

### 7. Cadastro de Treino — `/alunos/:alunoId/treinos/novo`

**O que mostra:**
- Campo nome (obrigatório)
- Campo descrição (opcional)
- Botão "Salvar"

**Estados:**
- `idle` — formulário vazio
- `saving` — loading
- `validation_error` — inline
- `success` — navega para o detalhe do treino recém-criado

**Navegação:**
- Salvar → `/alunos/:alunoId/treinos/:treinoId` (substitui na pilha)
- Botão voltar → `/alunos/:alunoId/treinos` com confirmação

---

### 8. Detalhe do Treino — `/alunos/:alunoId/treinos/:treinoId`

**O que mostra:**
- Nome e descrição do treino
- Lista de exercícios em ordem (`ORDER BY ordem ASC`)
- Card por exercício: nome, séries, repetições, carga
- Botões subir/descer em cada exercício
- Swipe para deletar exercício (com confirmação)
- Botão flutuante "Adicionar Exercício"
- Botão "Iniciar Sessão" (ação principal da tela, destaque visual)
- Menu: editar treino, deletar treino

**Estados:**
- `loading` — skeleton
- `data` — lista de exercícios
- `empty` — "Nenhum exercício cadastrado" + botão de ação
- `reordering` — feedback visual nos botões subir/descer
- `error` — mensagem + retry

**Navegação:**
- FAB → `/alunos/:alunoId/treinos/:treinoId/exercicios/novo`
- "Iniciar Sessão" → `/alunos/:alunoId/sessoes/nova/:treinoId`
- Editar treino → bottom sheet inline
- Deletar treino → dialog de confirmação → `/alunos/:alunoId/treinos`
- Botão voltar → `/alunos/:alunoId/treinos`

---

### 9. Cadastro de Exercício — `/alunos/:alunoId/treinos/:treinoId/exercicios/novo`

**O que mostra:**
- Campo nome do exercício (obrigatório)
- Campo séries (obrigatório)
- Campo repetições (opcional)
- Campo carga (opcional)
- Campo observação (opcional)
- Botão "Salvar"

**Decisão de UX:** ordem definida automaticamente como o último da lista. Professor reordena depois no detalhe do treino.

**Estados:**
- `idle` — formulário vazio
- `saving` — loading
- `validation_error` — inline
- `success` — volta para o detalhe do treino com exercício já na lista

**Navegação:**
- Salvar → `/alunos/:alunoId/treinos/:treinoId` (pop)
- Botão voltar → `/alunos/:alunoId/treinos/:treinoId` com confirmação

---

### 10. Iniciar Sessão — `/alunos/:alunoId/sessoes/nova/:treinoId`

**O que mostra:**
- Nome do treino e do aluno no AppBar
- Lista dos exercícios do treino
- Para cada exercício: campos de carga realizada, repetições realizadas, observação
- O que já foi salvo aparece preenchido (persistência parcial)
- Botão "Finalizar Sessão"
- Botão "Cancelar Sessão" (deleta tudo que foi registrado)

**Decisão técnica:** cada exercício é salvo individualmente no `onEditingComplete` — sem botão "salvar" por exercício. O botão "Finalizar Sessão" apenas fecha a sessão como concluída.

**Estados:**
- `loading` — carregando exercícios e registros parciais existentes
- `in_progress` — formulário com campos parcialmente preenchidos
- `saving_record` — feedback por exercício individual (não bloqueia a tela)
- `finishing` — loading no botão "Finalizar"
- `canceling` — dialog de confirmação
- `success` — volta para o perfil do aluno

**Navegação:**
- Finalizar → `/alunos/:alunoId` (pop até o perfil)
- Cancelar com confirmação → `/alunos/:alunoId/treinos/:treinoId`
- Botão voltar → comportamento igual ao cancelar (com confirmação)

---

### 11. Histórico de Sessões — `/alunos/:alunoId/sessoes`

**O que mostra:**
- Lista de sessões do aluno ordenadas por data decrescente
- Card por sessão: data, nome do treino (ou "Treino removido" se `treino_id` for NULL), observação
- Swipe para deletar (com confirmação)

**Estados:**
- `loading` — skeleton
- `data` — lista
- `empty` — "Nenhuma sessão registrada ainda"
- `error` — mensagem + retry

**Navegação:**
- Botão voltar → `/alunos/:alunoId`

---

## Fluxo completo

```
Dashboard
├── → Novo Aluno → Cadastro → Perfil
├── → Card Aluno → Perfil
│                   ├── → Editar → Edição → Perfil
│                   │                └── → Deletar → Lista de Alunos
│                   ├── → Treinos → Lista de Treinos
│                   │              ├── → Novo Treino → Detalhe do Treino
│                   │              └── → Card Treino → Detalhe do Treino
│                   │                                  ├── → Add Exercício → Detalhe
│                   │                                  ├── → Iniciar Sessão → Sessão → Perfil
│                   │                                  └── → Deletar Treino → Lista de Treinos
│                   └── → Histórico → Lista de Sessões
└── → Lista de Alunos → (mesmo fluxo do Card Aluno)
```

---

## Regras de navegação

- **Confirmação antes de voltar** em toda tela com formulário que tenha dado digitado não salvo
- **Substituição na pilha** ao criar um recurso — não volta pro formulário vazio com o botão voltar
- **Pop até o perfil** ao finalizar uma sessão — não acumula telas na pilha
- **`ultimo_acesso` atualiza** sempre que o perfil do aluno é aberto
- **Dialog em dois passos** para ações destrutivas irreversíveis (deletar aluno)
- **Swipe to delete** com confirmação para listas (exercícios, sessões)
