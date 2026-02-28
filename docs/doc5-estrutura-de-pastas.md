# Doc 5 — Estrutura de Pastas

> Status: FECHADO  
> Versão: 1.0  
> Projeto: GymCoach MVP

---

## Princípios

- **Feature-first:** cada feature tem sua própria pasta com todas as camadas
- **Clean Architecture:** domain → data → presentation (dependência sempre de fora pra dentro)
- **Um arquivo, uma responsabilidade:** máximo 300 linhas por arquivo, só se for muito necessario, mas sempre evitar
- **Core compartilhado:** tudo que não pertence a uma feature específica fica em `core/`

---

## Estrutura completa

```
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart                  # MaterialApp, tema, roteamento
│   └── router.dart               # GoRouter — todas as rotas
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # paleta de cores
│   │   ├── app_strings.dart      # todos os textos do app
│   │   └── app_dimensions.dart   # espaçamentos, tamanhos
│   │
│   ├── database/
│   │   └── database_helper.dart  # SQLite: criação, migrations, instância
│   │
│   ├── errors/
│   │   ├── exceptions.dart       # exceções de domínio (NomeInvalidoException, etc.)
│   │   └── failures.dart         # failures para o Either (se usar dartz)
│   │
│   ├── theme/
│   │   └── app_theme.dart        # ThemeData dark
│   │
│   └── utils/
│       ├── date_formatter.dart   # formatação de datas
│       └── image_helper.dart     # compressão e redimensionamento de foto
│
├── features/
│   │
│   ├── alunos/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── aluno.dart              # model com Freezed
│   │   │   ├── repositories/
│   │   │   │   └── aluno_repository.dart   # contrato (abstract class)
│   │   │   └── usecases/
│   │   │       ├── criar_aluno.dart
│   │   │       ├── editar_aluno.dart
│   │   │       ├── deletar_aluno.dart
│   │   │       ├── buscar_aluno_por_id.dart
│   │   │       ├── listar_alunos.dart
│   │   │       ├── listar_ultimos_alunos_acessados.dart
│   │   │       ├── contar_alunos_ativos.dart
│   │   │       ├── atualizar_ultimo_acesso.dart
│   │   │       ├── salvar_foto_aluno.dart
│   │   │       └── remover_foto_aluno.dart
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── aluno_dao.dart          # queries SQLite
│   │   │   └── repositories/
│   │   │       └── aluno_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── aluno_providers.dart    # Riverpod providers
│   │       ├── screens/
│   │       │   ├── lista_alunos_screen.dart
│   │       │   ├── cadastro_aluno_screen.dart
│   │       │   ├── edicao_aluno_screen.dart
│   │       │   └── perfil_aluno_screen.dart
│   │       └── widgets/
│   │           ├── aluno_card.dart
│   │           └── foto_picker_widget.dart
│   │
│   ├── treinos/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── treino.dart
│   │   │   ├── repositories/
│   │   │   │   └── treino_repository.dart
│   │   │   └── usecases/
│   │   │       ├── criar_treino.dart
│   │   │       ├── editar_treino.dart
│   │   │       ├── deletar_treino.dart
│   │   │       ├── buscar_treino_por_id.dart
│   │   │       └── listar_treinos_do_aluno.dart
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── treino_dao.dart
│   │   │   └── repositories/
│   │   │       └── treino_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── treino_providers.dart
│   │       ├── screens/
│   │       │   ├── lista_treinos_screen.dart
│   │       │   ├── cadastro_treino_screen.dart
│   │       │   └── detalhe_treino_screen.dart
│   │       └── widgets/
│   │           └── treino_card.dart
│   │
│   ├── exercicios/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── exercicio.dart
│   │   │   ├── repositories/
│   │   │   │   └── exercicio_repository.dart
│   │   │   └── usecases/
│   │   │       ├── criar_exercicio.dart
│   │   │       ├── editar_exercicio.dart
│   │   │       ├── deletar_exercicio.dart
│   │   │       ├── listar_exercicios_do_treino.dart
│   │   │       └── reordenar_exercicio.dart
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── exercicio_dao.dart
│   │   │   └── repositories/
│   │   │       └── exercicio_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── exercicio_providers.dart
│   │       ├── screens/
│   │       │   └── cadastro_exercicio_screen.dart
│   │       └── widgets/
│   │           └── exercicio_card.dart
│   │
│   ├── sessoes/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── sessao.dart
│   │   │   │   └── registro_execucao.dart
│   │   │   ├── repositories/
│   │   │   │   ├── sessao_repository.dart
│   │   │   │   └── registro_execucao_repository.dart
│   │   │   └── usecases/
│   │   │       ├── iniciar_sessao.dart
│   │   │       ├── finalizar_sessao.dart
│   │   │       ├── deletar_sessao.dart
│   │   │       ├── listar_sessoes_do_aluno.dart
│   │   │       ├── buscar_sessao_por_id.dart
│   │   │       ├── salvar_registro_execucao.dart
│   │   │       ├── listar_registros_da_sessao.dart
│   │   │       └── deletar_registro_execucao.dart
│   │   │
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── sessao_dao.dart
│   │   │   │   └── registro_execucao_dao.dart
│   │   │   └── repositories/
│   │   │       ├── sessao_repository_impl.dart
│   │   │       └── registro_execucao_repository_impl.dart
│   │   │
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── sessao_providers.dart
│   │       ├── screens/
│   │       │   ├── iniciar_sessao_screen.dart
│   │       │   └── historico_sessoes_screen.dart
│   │       └── widgets/
│   │           ├── sessao_card.dart
│   │           └── exercicio_execucao_card.dart
│   │
│   └── dashboard/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── dashboard_data.dart
│       │   └── usecases/
│       │       └── carregar_dashboard.dart
│       │
│       ├── data/
│       │   └── datasources/
│       │       └── dashboard_dao.dart
│       │
│       └── presentation/
│           ├── providers/
│           │   └── dashboard_providers.dart
│           └── screens/
│               └── dashboard_screen.dart
│
test/
├── features/
│   ├── alunos/
│   │   └── data/
│   │       └── aluno_dao_test.dart
│   ├── treinos/
│   │   └── data/
│   │       └── treino_dao_test.dart
│   ├── exercicios/
│   │   └── data/
│   │       └── exercicio_dao_test.dart
│   └── sessoes/
│       └── data/
│           ├── sessao_dao_test.dart
│           └── registro_execucao_dao_test.dart
└── core/
    └── database/
        └── database_helper_test.dart
```

---

## Regras de nomenclatura

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Arquivo | `snake_case.dart` | `aluno_dao.dart` |
| Classe | `PascalCase` | `AlunoDao` |
| Provider | `camelCase + Provider` | `alunosProvider` |
| Usecase | `PascalCase` (verbo + substantivo) | `CriarAluno` |
| Screen | `PascalCase + Screen` | `ListaAlunosScreen` |
| Widget | `PascalCase + Widget` | `AlunoCardWidget` |
| DAO | `PascalCase + Dao` | `AlunoDao` |

---

## Regras de dependência

```
presentation  →  domain  (permitido)
data          →  domain  (permitido)
domain        →  nada    (domínio não depende de nada)
presentation  →  data    (PROIBIDO — nunca acessa DAO diretamente)
```

---

## Ordem de criação dos arquivos

Sempre de baixo pra cima — do que não depende de nada para o que depende de tudo:

1. `core/errors/exceptions.dart`
2. `core/errors/failures.dart`
3. `core/constants/` (strings, colors, dimensions)
4. `core/theme/app_theme.dart`
5. `core/database/database_helper.dart`
6. `domain/entities` (models com Freezed) — uma feature por vez
7. `domain/repositories` (contratos)
8. `domain/usecases`
9. `data/datasources` (DAOs)
10. `data/repositories` (implementações)
11. `presentation/providers` (Riverpod)
12. `presentation/screens` e `widgets`
13. `app/router.dart`
14. `app/app.dart`
15. `main.dart`