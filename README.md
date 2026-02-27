# 💪 GymCoach

> Aplicativo mobile offline para professores de academia gerenciarem alunos, treinos e evolução de carga.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)
![SQLite](https://img.shields.io/badge/SQLite-Local-003B57?logo=sqlite)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)
![Status](https://img.shields.io/badge/Status-Em%20desenvolvimento-yellow)

---

## 📋 Índice

- [Sobre o projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Arquitetura](#-arquitetura)
- [Estrutura de pastas](#-estrutura-de-pastas)
- [Banco de dados](#-banco-de-dados)
- [Tecnologias e dependências](#-tecnologias-e-dependências)
- [Pré-requisitos](#-pré-requisitos)
- [Como rodar o projeto](#-como-rodar-o-projeto)
- [Como rodar os testes](#-como-rodar-os-testes)
- [Decisões de arquitetura](#-decisões-de-arquitetura)
- [Roadmap](#-roadmap)
- [Princípios aplicados](#-princípios-aplicados)

---

## 📌 Sobre o projeto

O GymCoach nasceu para resolver um problema real de professores de academia: gerenciar alunos e treinos ainda acontece em cadernos, planilhas e grupos de WhatsApp.

O app permite que o professor cadastre alunos, monte treinos personalizados, acompanhe a evolução de carga de cada exercício e tenha tudo centralizado no celular — funcionando 100% offline, sem depender de internet ou servidores externos.

### Contexto da versão atual (MVP 1.0)
- Usuário único: o professor
- Funciona totalmente offline
- Dados salvos localmente com SQLite
- Sem login, sem sincronização, sem planos

A arquitetura foi desenhada para escalar: quando o produto crescer para múltiplos professores e acesso dos alunos, a camada de dados pode ser trocada por uma API sem tocar nas telas ou regras de negócio.

---

## ✅ Funcionalidades

### MVP 1.0
- [x] Cadastro, edição e listagem de alunos
- [x] Foto de perfil do aluno
- [x] Criação de treinos (nome livre: A, B, C ou qualquer nome)
- [x] Adição e reordenação de exercícios dentro do treino
- [x] Registro de séries, repetições, carga e tempo de descanso
- [x] Histórico de carga por exercício
- [x] Dashboard com resumo geral
- [x] Arquivamento de alunos inativos
- [x] Arquivamento de treinos antigos

### Futuro (pós-MVP)
- [ ] Acesso do aluno ao próprio treino
- [ ] Sincronização na nuvem
- [ ] Suporte a múltiplos professores
- [ ] Notificações e lembretes
- [ ] Exportação de treino em PDF

---

## 🏗 Arquitetura

O projeto segue **Clean Architecture** com separação em 3 camadas por feature:

```
Presentation  →  Domain  →  Data
(Telas/State)    (Regras)    (Banco/API)
```

### Regra de dependência
As camadas externas conhecem as internas, nunca o contrário.
- `Presentation` depende de `Domain`
- `Data` depende de `Domain`
- `Domain` não depende de nada — é Dart puro

Isso garante que trocar o SQLite por uma API no futuro exige criar uma nova implementação em `Data`, sem tocar em nenhuma tela ou regra de negócio.

### Fluxo de dados
```
Tela → Provider (Riverpod) → UseCase → Repository (contrato) → RepositoryImpl → DAO → SQLite
```

---

## 📁 Estrutura de pastas

```
lib/
├── main.dart                        # Ponto de entrada — só inicializa o app
├── app/
│   ├── app.dart                     # MaterialApp + tema + ProviderScope
│   └── router.dart                  # Todas as rotas com GoRouter
│
├── core/                            # Utilitários compartilhados por todo o app
│   ├── constants/
│   │   └── app_strings.dart         # Textos fixos centralizados
│   ├── database/
│   │   └── database_helper.dart     # Singleton de conexão com SQLite
│   ├── errors/
│   │   ├── exceptions.dart          # Exceções da camada de dados
│   │   └── failures.dart            # Falhas da camada de domínio
│   └── theme/
│       └── app_theme.dart           # Cores, fontes e estilos globais
│
├── shared/
│   └── widgets/                     # Widgets reutilizáveis entre features
│       ├── confirm_dialog.dart
│       ├── empty_state_widget.dart
│       ├── error_widget.dart
│       └── loading_widget.dart
│
└── features/
    ├── alunos/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── aluno_dao.dart               # Queries SQL de alunos
    │   │   └── repositories/
    │   │       └── aluno_repository_impl.dart   # Implementação com SQLite
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── aluno.dart                   # Model: o que é um Aluno
    │   │   ├── repositories/
    │   │   │   └── aluno_repository.dart        # Contrato do repositório
    │   │   └── usecases/
    │   │       ├── get_alunos.dart
    │   │       ├── get_aluno_by_id.dart
    │   │       ├── save_aluno.dart
    │   │       └── delete_aluno.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── alunos_provider.dart         # Estado com Riverpod
    │       ├── screens/
    │       │   ├── alunos_screen.dart
    │       │   ├── aluno_form_screen.dart
    │       │   └── aluno_detail_screen.dart
    │       └── widgets/
    │           └── aluno_card.dart
    │
    ├── treinos/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── treino_dao.dart
    │   │   │   ├── treino_exercicio_dao.dart
    │   │   │   └── historico_carga_dao.dart
    │   │   └── repositories/
    │   │       └── treino_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── treino.dart
    │   │   │   ├── treino_exercicio.dart
    │   │   │   └── historico/
    │   │   │       └── historico_carga.dart
    │   │   ├── repositories/
    │   │   │   └── treino_repository.dart
    │   │   └── usecases/
    │   │       ├── get_treinos_by_aluno.dart
    │   │       ├── save_treino.dart
    │   │       ├── delete_treino.dart
    │   │       ├── save_exercicio.dart
    │   │       ├── delete_exercicio.dart
    │   │       ├── save_historico_carga.dart
    │   │       └── get_historico_carga.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── treinos_provider.dart
    │       ├── screens/
    │       │   ├── treinos_screen.dart
    │       │   ├── treino_form_screen.dart
    │       │   └── exercicio_form_screen.dart
    │       └── widgets/
    │           ├── treino_card.dart
    │           └── exercicio_card.dart
    │
    └── dashboard/
        ├── data/
        ├── domain/
        └── presentation/
            ├── providers/
            │   └── dashboard_provider.dart
            ├── screens/
            │   └── dashboard_screen.dart
            └── widgets/
                └── resumo_card.dart

test/
├── features/
│   ├── alunos/
│   │   ├── data/                    # Testes dos DAOs e repositórios
│   │   └── domain/                  # Testes dos usecases
│   └── treinos/
│       ├── data/
│       └── domain/
└── core/
    └── database/                    # Testes do helper de banco
```

---

## 🗄 Banco de dados

### Tabela: `alunos`

| Coluna | Tipo | Obrigatório | Descrição |
|--------|------|-------------|-----------|
| id | INTEGER PK | sim | Auto incremento |
| nome | TEXT | sim | Nome completo |
| idade | INTEGER | não | — |
| peso | REAL | não | Em kg |
| altura | REAL | não | Em metros |
| data_nascimento | TEXT | não | ISO 8601 |
| telefone | TEXT | não | — |
| objetivo | TEXT | não | — |
| observacoes | TEXT | não | — |
| foto_path | TEXT | não | Caminho local da foto |
| data_inicio | TEXT | sim | ISO 8601 |
| ativo | INTEGER | sim | 1 = ativo, 0 = inativo |

### Tabela: `treinos`

| Coluna | Tipo | Obrigatório | Descrição |
|--------|------|-------------|-----------|
| id | INTEGER PK | sim | Auto incremento |
| aluno_id | INTEGER FK | sim | Referência para alunos |
| nome | TEXT | sim | Ex: "Treino A", "Peito" |
| objetivo | TEXT | não | Foco do treino |
| ativo | INTEGER | sim | 1 = ativo, 0 = arquivado |
| data_criacao | TEXT | sim | ISO 8601 |

### Tabela: `treino_exercicios`

| Coluna | Tipo | Obrigatório | Descrição |
|--------|------|-------------|-----------|
| id | INTEGER PK | sim | Auto incremento |
| treino_id | INTEGER FK | sim | Referência para treinos |
| nome_exercicio | TEXT | sim | — |
| series | INTEGER | não | — |
| repeticoes | TEXT | não | TEXT pois pode ser "até a falha" |
| carga | REAL | não | Em kg |
| tempo_descanso | INTEGER | não | Em segundos |
| observacao | TEXT | não | — |
| ordem | INTEGER | sim | Para reordenação |

### Tabela: `historico_carga`

| Coluna | Tipo | Obrigatório | Descrição |
|--------|------|-------------|-----------|
| id | INTEGER PK | sim | Auto incremento |
| exercicio_id | INTEGER FK | sim | Referência para treino_exercicios |
| carga | REAL | sim | Carga registrada |
| repeticoes | TEXT | não | Repetições realizadas |
| data_registro | TEXT | sim | ISO 8601 |
| observacao | TEXT | não | — |

### Relacionamentos
```
alunos ──< treinos ──< treino_exercicios ──< historico_carga
```
Todos com `ON DELETE CASCADE` — deletar um aluno remove todos os dados relacionados.

---

## 📦 Tecnologias e dependências

### Runtime
| Pacote | Versão | Por quê |
|--------|--------|---------|
| flutter_riverpod | ^2.5.1 | Gerenciamento de estado e injeção de dependência |
| riverpod_annotation | ^2.3.4 | Geração de código para providers |
| go_router | ^13.2.0 | Navegação declarativa e escalável |
| sqflite | ^2.3.2 | Banco de dados SQLite local |
| path | ^1.9.0 | Localização do arquivo do banco no dispositivo |
| freezed_annotation | ^2.4.1 | Models imutáveis com copyWith, == e toString |
| json_annotation | ^4.9.0 | Serialização/deserialização de objetos |

### Dev (geração de código e testes)
| Pacote | Versão | Por quê |
|--------|--------|---------|
| build_runner | ^2.4.9 | Executor de geradores de código |
| freezed | ^2.5.2 | Gerador para models imutáveis |
| riverpod_generator | ^2.4.0 | Gerador para providers Riverpod |
| json_serializable | ^6.8.0 | Gerador para serialização JSON |

---

## 🛠 Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10 ou superior
- [Android Studio](https://developer.android.com/studio) com emulador configurado (API 34+)
- [VS Code](https://code.visualstudio.com/) com extensões Flutter e Dart
- Java JDK 17 ou superior

Verifique sua instalação:
```bash
flutter doctor
```
Todos os itens devem estar com ✅ antes de rodar o projeto.

---

## 🚀 Como rodar o projeto

**1. Clone o repositório**
```bash
git clone https://github.com/seu-usuario/gymcoach.git
cd gymcoach
```

**2. Instale as dependências**
```bash
flutter pub get
```

**3. Gere os arquivos de código automático**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**4. Inicie o emulador e rode o app**
```bash
flutter run --no-enable-impeller
```

> `--no-enable-impeller` desliga o renderizador Impeller, que é pesado demais para emuladores. Em dispositivo físico pode rodar sem essa flag.

---

## 🧪 Como rodar os testes

Rodar todos os testes:
```bash
flutter test
```

Rodar testes de uma feature específica:
```bash
flutter test test/features/alunos/
```

Rodar com cobertura:
```bash
flutter test --coverage
```

---

## 🧠 Decisões de arquitetura

### Por que Clean Architecture?
O app começa offline com SQLite, mas foi desenhado para escalar. Com Clean Architecture, trocar a fonte de dados (SQLite → API) exige criar uma nova implementação em `data/repositories/` sem tocar em nenhuma tela ou regra de negócio.

### Por que Riverpod?
É o padrão mais robusto de gerenciamento de estado no Flutter. Resolve injeção de dependência, cache, reatividade e testabilidade sem bibliotecas extras.

### Por que GoRouter?
Navegação declarativa que escala bem. Quando o app crescer para deep links, autenticação e rotas protegidas, o GoRouter suporta tudo sem refatoração.

### Por que SQLite e não Hive/Isar?
O GymCoach tem relacionamentos reais entre entidades (aluno → treinos → exercícios → histórico). SQLite com queries relacionais é a escolha mais sólida para esse modelo de dados.

### Por que Freezed nos models?
Models imutáveis eliminam uma classe inteira de bugs. Com Freezed, você nunca modifica um objeto acidentalmente — sempre cria uma cópia com `copyWith`. Além disso, `==` e `toString` gerados automaticamente facilitam testes e debug.

---

## 🗺 Roadmap

### Versão 1.0 — MVP (atual)
- Gestão completa de alunos e treinos
- Histórico de evolução de carga
- Funciona 100% offline

### Versão 2.0 — Multi-usuário
- Backend na nuvem (API REST)
- Autenticação por professor
- Sincronização offline-first

### Versão 3.0 — Aluno no app
- Acesso do aluno ao próprio treino
- Marcação de exercícios realizados
- Visualização da própria evolução

---

## 📐 Princípios aplicados

| Princípio | Como está aplicado |
|-----------|-------------------|
| **SOLID** | Cada arquivo tem uma responsabilidade. Contratos abstratos permitem trocar implementações. |
| **DRY** | Textos em `app_strings`, cores em `app_theme`, SQL nos DAOs. |
| **KISS** | Solução mais simples que resolve o problema. Sem over-engineering. |
| **YAGNI** | A arquitetura suporta crescimento, mas o código só implementa o que o MVP precisa. |
| **Clean Code** | Nomes descritivos, funções pequenas, comentários explicam o porquê. |
| **TDD** | Testes escritos junto com cada usecase e repositório. |

---

## 👨‍💻 Autor

Feito por **Vitor Farani Barbosa**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?logo=linkedin)](https://www.linkedin.com/in/vitor-farani/)
[![GitHub](https://img.shields.io/badge/GitHub-black?logo=github)](https://github.com/Vitorfarani)