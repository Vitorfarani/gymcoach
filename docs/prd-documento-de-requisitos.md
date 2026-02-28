# PRD — Documento de Requisitos do Produto

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## Visão do Produto

Aplicativo mobile Android para professor de academia gerenciar seus alunos e treinos de forma offline, rápida e sem burocracia. O professor é o único usuário. Não há login, não há cloud, não há planos.

---

## Problema que resolve

Professores de academia gerenciam alunos e treinos em papel, WhatsApp ou planilhas. Essas ferramentas não foram feitas pra isso: papel se perde, WhatsApp mistura pessoal com profissional, planilha é lenta no celular. O GymCoach resolve isso com uma interface feita especificamente pro contexto de academia — rápida, legível com a tela sob luz intensa, operável com uma mão.

---

## Usuário

Professor de academia. Usa o app durante ou entre atendimentos. Tem pressa. Precisa cadastrar um aluno novo em menos de 30 segundos. Não tem paciência pra tutorial.

---

## Plataforma

- Android
- Offline — 100% dos dados salvos localmente com SQLite
- Sem autenticação, sem backend, sem sincronização

---

## Escopo do MVP — O que está dentro

### Alunos
- Cadastrar aluno (nome obrigatório, demais campos opcionais)
- Editar aluno
- Adicionar / trocar / remover foto do aluno (câmera ou galeria)
- Listar alunos ativos com busca por nome
- Visualizar perfil do aluno
- Deletar aluno (soft delete — dado some da UI, permanece no banco marcado)

### Treinos
- Criar treino vinculado a um aluno (nome livre)
- Editar treino
- Listar treinos de um aluno
- Deletar treino

### Exercícios
- Adicionar exercício a um treino (nome e séries obrigatórios)
- Campos opcionais: repetições, carga, observação — todos TEXT (suporta "até a falha", "peso corporal", etc.)
- Reordenar exercícios com botões subir/descer
- Deletar exercício

### Sessões
- Iniciar sessão vinculada a um treino
- Registrar execução de exercícios (carga real, repetições reais, observação)
- Persistência parcial — se sair no meio, o que foi salvo é preservado
- Finalizar sessão
- Deletar sessão
- Histórico de sessões por aluno

### Dashboard
- Total de alunos ativos
- Últimos 5 alunos acessados (atalho rápido)
- Botão "Novo Aluno"

---

## Escopo do MVP — O que está fora (v2+)

- Login ou autenticação de qualquer tipo
- Sincronização com cloud ou backup automático
- Múltiplos usuários ou perfis
- Tela de alunos inativos
- Drag and drop para reordenar exercícios
- Edição de sessão ou registro de execução (deletar e recriar é o fluxo)
- Data manual em sessões
- Exportação de dados (PDF, Excel, etc.)
- Notificações
- Histórico de peso / evolução do aluno
- Cálculo de IMC na UI
- Modo claro (light theme)
- Tablet / iPad
- iOS

---

## Requisitos não funcionais

- **Performance:** listas devem renderizar em menos de 300ms mesmo com 200+ alunos
- **Armazenamento:** fotos comprimidas para no máximo 800x800px antes de salvar
- **Offline first:** nenhuma funcionalidade depende de internet
- **Tamanho do app:** manter abaixo de 30MB no build final
- **Compatibilidade:** Android 8.0 (API 26) ou superior

---

## Regras de negócio (resumo — detalhes no Doc 1)

- Apenas `nome` é obrigatório no cadastro de aluno
- Nomes duplicados são permitidos em todas as entidades
- Soft delete em alunos — sem tela de recuperação no MVP
- Delete em cascata: aluno → treinos → exercícios → sessões → registros
- Sessão sempre vinculada a um treino
- Registro de execução: upsert por `(sessao_id, treino_exercicio_id)`
- Foto: aceita até 5MB, processada para 800x800px antes de salvar

---

## Critérios de sucesso do MVP

- Professor consegue cadastrar um aluno novo em menos de 30 segundos
- Professor consegue criar um treino completo (3 exercícios) em menos de 2 minutos
- Professor consegue registrar uma sessão completa sem travar ou perder dados
- App não trava, não perde dados, funciona 100% offline