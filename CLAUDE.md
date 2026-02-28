# GymCoach — Contexto do Projeto para Claude Code

## O que é este app

Aplicativo mobile Android para professor de academia gerenciar alunos e treinos.
- Usuário único (o professor), sem login, sem cloud, 100% offline
- Dados salvos localmente com SQLite
- Stack: Flutter + SQLite (sqflite) + Riverpod + GoRouter + Freezed
- Plataforma de desenvolvimento: Windows + VS Code + Emulador Pixel 7 (API 34)

---

## Documentação obrigatória — leia antes de qualquer tarefa

Todos os documentos estão em `docs/`. Leia o relevante antes de implementar qualquer coisa:

- `docs/prd-documento-de-requisitos.md` — escopo do MVP, o que está dentro e fora
- `docs/doc1-regras-de-negocio.md` — regras de negócio e validações
- `docs/doc2-schema-banco-de-dados.md` — DDL completo com tipos, constraints e índices
- `docs/doc3-mapa-de-telas-e-navegacao.md` — rotas, parâmetros e estados de UI
- `docs/doc4-contrato-das-features.md` — use cases: entrada, saída e erros
- `docs/doc5-estrutura-de-pastas.md` — onde cada arquivo deve ser criado

---

## Arquitetura

Clean Architecture + Feature-First:

```
lib/
├── main.dart
├── app/          # router.dart, app.dart
├── core/         # errors, database, theme, constants, utils
└── features/
    ├── alunos/
    ├── treinos/
    ├── exercicios/
    ├── sessoes/
    └── dashboard/
```

Cada feature segue: `domain/` → `data/` → `presentation/`

**Regra de dependência:**
- `presentation` depende de `domain` ✅
- `data` depende de `domain` ✅
- `domain` não depende de nada ✅
- `presentation` nunca acessa `data` diretamente ❌

---

## Regras de código — sem exceção

1. Máximo 300 linhas por arquivo
2. Um arquivo = uma responsabilidade
3. Nomes em português para domínio de negócio, inglês para código técnico
4. Todo use case tem sua própria classe em arquivo próprio
5. Todo DAO tem seu arquivo próprio
6. Providers Riverpod ficam em `presentation/providers/`
7. Nunca acesse o banco diretamente de um provider — sempre via use case → repository → DAO
8. Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`
9. TDD — para cada DAO criado, crie o teste correspondente em test/ antes ou junto do arquivo. Nunca entregue um DAO sem teste.

---

## Comandos úteis

```bash
# Rodar o app no emulador
flutter run

# Gerar código Freezed/Riverpod
flutter pub run build_runner build --delete-conflicting-outputs

# Rodar testes
flutter test

# Verificar erros
flutter analyze
```

---

## Ordem de criação dos arquivos

Sempre de baixo pra cima:

1. `core/errors/exceptions.dart` e `failures.dart`
2. `core/constants/` (strings, colors, dimensions)
3. `core/theme/app_theme.dart`
4. `core/database/database_helper.dart`
5. `domain/entities` (models com Freezed)
6. `domain/repositories` (contratos)
7. `domain/usecases`
8. `data/datasources` (DAOs)
9. `data/repositories` (implementações)
10. `presentation/providers` (Riverpod)
11. `presentation/screens` e `widgets`
12. `app/router.dart`
13. `app/app.dart`
14. `main.dart`

---

## Tema visual

Dark theme:
- Primary: #1E88E5
- Background: #121212
- Surface: #1E1E1E
- SurfaceVariant: #2C2C2C
- Error: #CF6679

---

## Contexto do desenvolvedor

O desenvolvedor é iniciante em Flutter. Sempre que criar ou modificar um arquivo:
1. Explica brevemente o que o arquivo faz e por que está sendo criado assim
2. Comenta as partes não óbvias do código
3. Não pule etapas assumindo conhecimento prévio