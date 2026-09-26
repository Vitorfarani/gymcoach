# Changelog

## 2026-09-26 — README translated and reviewed

**Translated**
- Translated the README from Portuguese to English, including headings, tables, badges ("Em desenvolvimento" → "In development") and the table of contents links.
- Added a note explaining that the code uses Portuguese domain names (`aluno` = student, `treino` = workout, `exercicio` = exercise, `historico_carga` = load history).
- Translated the database column descriptions (the column names themselves are unchanged, since they match the code).
- Fixed the clone URL (`seu-usuario` → `Vitorfarani`).

**Updated to match the code**
- Folder structure: the old tree listed use case files with names that don't exist (e.g. `get_alunos.dart`, `save_aluno.dart`). Replaced the per-file listing with a per-folder description, and added `core/utils/image_helper.dart` and the other `core/constants/` files that were missing.
- Dependencies table: added `path_provider`, `image_picker`, `flutter_image_compress` and `sqflite_common_ffi`, which are in `pubspec.yaml` but were missing from the README.
- Tests: the old README showed test folders for `alunos` (domain and data), `treinos/domain` and `core/database`. Today only `test/features/treinos/data/datasources/treino_dao_test.dart` exists (plus the default `widget_test.dart`). The folder tree and the "run tests for one feature" example now point to `test/features/treinos/`.
- TDD principle: changed from "tests written alongside every use case and repository" to "the data access layer is developed test-first against an in-memory SQLite database", which is what exists today.

**Still to do (not removed from the plan)**
- Tests for the `alunos` feature (DAO and use cases), the `treinos` use cases and `core/database`. When they're added, the README test tree and TDD line can go back to the broader description.

No code was changed.
