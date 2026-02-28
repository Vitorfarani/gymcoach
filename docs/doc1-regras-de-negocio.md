# Doc 1 — Regras de Negócio e Validações

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## Alunos

- **Campo obrigatório:** apenas `nome`
- **Campos opcionais:** `foto_path`, `idade`, `peso`, `altura`, `objetivo`, `observacoes`, `data_ultima_avaliacao`
- **Validações:**
  - Nome: mínimo 2, máximo 60 caracteres
  - Idade: 10 a 99
  - Peso: 30 a 250 kg
  - Altura: 100 a 250 cm
- **Nomes duplicados:** permitido — dois alunos podem ter o mesmo nome
- **Soft delete:** campo `deletado_em` com timestamp. Deletado some permanentemente — sem tela de inativos no MVP
- **Delete permanente:** deleta aluno + treinos + exercícios + sessões + registros em cascade

---

## Foto do Aluno

- Fonte: câmera ou galeria (os dois)
- Limite de seleção: 5MB
- Processamento antes de salvar: redimensionada para 800x800px, comprimida
- Delete: remove referência no banco **e** arquivo físico no dispositivo — sempre juntos, nunca separados

---

## Treinos

- **Campo obrigatório:** `nome`
- **Campo opcional:** `descricao`
- **Quantidade por aluno:** ilimitado
- **Nome:** livre — professor digita o que quiser
- **Nomes duplicados no mesmo aluno:** permitido
- **Delete:** cascade — deleta exercícios junto. Sessões vinculadas preservam o histórico (`treino_id` vira NULL)

---

## Exercícios

- **Campos obrigatórios:** `nome_exercicio`, `series`
- **Campos opcionais:** `repeticoes`, `carga`, `observacao`
- **Tipo de `repeticoes`:** TEXT — suporta "até a falha", "30 segundos", "10-12"
- **Tipo de `carga`:** TEXT — suporta "peso corporal", "elástico médio", "20kg"
- **Reordenação:** botões subir/descer. Drag and drop vai para v2
- **Quantidade por treino:** ilimitado

---

## Sessões

- Sempre vinculada a um treino — sessão avulsa não existe
- Data = momento do registro ("agora"). Sem data manual no MVP
- Pode deletar, não pode editar — se errou, deleta e recria
- Pode ter mais de uma sessão no mesmo dia para o mesmo aluno
- Delete: cascade — apaga registros de execução junto

---

## Registros de Execução

- Professor pode registrar só alguns exercícios — nenhum campo é obrigatório além da vinculação à sessão
- Não pode editar depois de salvo — deleta e refaz
- **Persistência parcial:** o que foi salvo durante a sessão é preservado se o professor sair. Nunca descarta silenciosamente
- Ao reabrir uma sessão em andamento, mostra o que já foi registrado

---

## Dashboard

- Total de alunos ativos (número em destaque)
- Lista dos últimos 5 alunos acessados (`ORDER BY ultimo_acesso DESC LIMIT 5`)
- Botão flutuante "Novo Aluno"
