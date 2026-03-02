// treino_dao_test.dart
//
// Testes unitários do TreinoDao.
//
// COMO FUNCIONA:
//   Usa `sqflite_common_ffi` para abrir um banco SQLite em memória (RAM).
//   Não precisa de emulador Android — roda direto no Windows/desktop.
//   Cada teste recebe um banco limpo, criado em `setUp` e fechado em `tearDown`.
//
// ESTRUTURA DOS TESTES:
//   - Grupo "treinos": CRUD e soft delete da tabela `treinos`.
//   - Grupo "exercícios": CRUD, soft delete e reordenação de `treino_exercicios`.
//
// DADOS DE FIXTURE:
//   Um aluno (id=1) é inserido na tabela `alunos` antes de cada teste.
//   Necessário porque `treinos.aluno_id` tem FK para `alunos(id)`.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:gymcoach/features/treinos/data/datasources/treino_dao.dart';
import 'package:gymcoach/features/treinos/domain/entities/treino.dart';
import 'package:gymcoach/features/treinos/domain/entities/treino_exercicio.dart';

// ── Helpers de fixture ──────────────────────────────────────────────────────

/// Cria um Treino de teste com valores válidos.
///
/// [alunoId] e [nome] são os únicos campos que variam nos testes.
Treino _makeTreino({int alunoId = 1, String nome = 'Treino A'}) {
  final agora = DateTime.now();
  return Treino(
    alunoId: alunoId,
    nome: nome,
    descricao: 'Descrição de teste',
    dataCriacao: agora,
    dataAtualizacao: agora,
  );
}

/// Cria um TreinoExercicio de teste com valores válidos.
TreinoExercicio _makeExercicio({
  required int treinoId,
  String nome = 'Supino Reto',
  int ordem = 0,
}) {
  final agora = DateTime.now();
  return TreinoExercicio(
    treinoId: treinoId,
    nomeExercicio: nome,
    series: '4',
    repeticoes: '10-12',
    carga: '20kg',
    observacao: null,
    ordem: ordem,
    dataCriacao: agora,
    dataAtualizacao: agora,
  );
}

// ── Setup do banco em memória ──────────────────────────────────────────────

/// DDL das tabelas necessárias para os testes do TreinoDao.
///
/// Cria `alunos` (por causa do FK), `treinos` e `treino_exercicios`.
Future<void> _criarSchema(Database db) async {
  await db.execute('PRAGMA foreign_keys = ON');

  await db.execute('''
    CREATE TABLE alunos (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      nome        TEXT    NOT NULL,
      data_inicio TEXT    NOT NULL DEFAULT (date('now')),
      ultimo_acesso TEXT  NOT NULL DEFAULT (datetime('now')),
      ativo       INTEGER NOT NULL DEFAULT 1,
      created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      updated_at  TEXT    NOT NULL DEFAULT (datetime('now')),
      deletado_em TEXT
    )
  ''');

  await db.execute('''
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
  ''');

  await db.execute('''
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
  ''');
}

/// Insere um aluno mínimo para satisfazer o FK de treinos.
Future<void> _inserirAlunoFixture(Database db, {int id = 1}) async {
  await db.insert('alunos', {
    'id': id,
    'nome': 'Aluno Teste',
    'data_inicio': DateTime.now().toIso8601String(),
    'ultimo_acesso': DateTime.now().toIso8601String(),
    'ativo': 1,
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  });
}

// ── Main ───────────────────────────────────────────────────────────────────

void main() {
  // Inicializa o sqflite para rodar no desktop (Windows/Linux/macOS).
  // Sem isso, sqflite só funciona em emulador/dispositivo Android.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late TreinoDao dao;

  // Cada teste começa com um banco limpo em memória.
  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, _) => _criarSchema(db),
    );
    await _inserirAlunoFixture(db);
    dao = TreinoDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ══════════════════════════════════════════════════════════════════════════
  // TREINOS
  // ══════════════════════════════════════════════════════════════════════════

  group('treinos', () {
    test('inserirTreino: retorna id > 0 após inserção', () async {
      final treino = _makeTreino();
      final id = await dao.inserirTreino(treino);
      expect(id, greaterThan(0));
    });

    test('buscarTreinoPorId: retorna treino existente', () async {
      final id = await dao.inserirTreino(_makeTreino(nome: 'Treino B'));
      final encontrado = await dao.buscarTreinoPorId(id);
      expect(encontrado, isNotNull);
      expect(encontrado!.nome, equals('Treino B'));
    });

    test('buscarTreinoPorId: retorna null para id inexistente', () async {
      final resultado = await dao.buscarTreinoPorId(9999);
      expect(resultado, isNull);
    });

    test('listarTreinosPorAluno: retorna apenas treinos do aluno informado',
        () async {
      // Cria segundo aluno para garantir isolamento
      await _inserirAlunoFixture(db, id: 2);

      await dao.inserirTreino(_makeTreino(alunoId: 1, nome: 'Treino A'));
      await dao.inserirTreino(_makeTreino(alunoId: 1, nome: 'Treino B'));
      await dao.inserirTreino(_makeTreino(alunoId: 2, nome: 'Treino C'));

      final lista = await dao.listarTreinosPorAluno(1);
      expect(lista.length, equals(2));
      expect(lista.map((t) => t.nome), containsAll(['Treino A', 'Treino B']));
    });

    test('listarTreinosPorAluno: retorna lista vazia para aluno sem treinos',
        () async {
      await _inserirAlunoFixture(db, id: 2);
      final lista = await dao.listarTreinosPorAluno(2);
      expect(lista, isEmpty);
    });

    test('atualizarTreino: persiste o novo nome', () async {
      final id = await dao.inserirTreino(_makeTreino(nome: 'Nome Original'));
      final inserido = (await dao.buscarTreinoPorId(id))!;

      await dao.atualizarTreino(inserido.copyWith(nome: 'Nome Atualizado'));

      final atualizado = await dao.buscarTreinoPorId(id);
      expect(atualizado!.nome, equals('Nome Atualizado'));
    });

    test('softDeleteTreino: retorna 1 e oculta treino de queries', () async {
      final id = await dao.inserirTreino(_makeTreino());

      final afetadas = await dao.softDeleteTreino(id);
      expect(afetadas, equals(1));

      // Após soft delete, busca e listagem não devem mais retornar o treino
      final buscado = await dao.buscarTreinoPorId(id);
      expect(buscado, isNull);
    });

    test('softDeleteTreino: retorna 0 para id inexistente', () async {
      final afetadas = await dao.softDeleteTreino(9999);
      expect(afetadas, equals(0));
    });

    test('softDeleteTreino: retorna 0 ao tentar deletar treino já deletado',
        () async {
      final id = await dao.inserirTreino(_makeTreino());
      await dao.softDeleteTreino(id);
      // Segunda chamada com o mesmo id deve retornar 0
      final afetadas = await dao.softDeleteTreino(id);
      expect(afetadas, equals(0));
    });

    test('listarTreinosPorAluno: não inclui treinos soft-deletados', () async {
      final id = await dao.inserirTreino(_makeTreino());
      await dao.softDeleteTreino(id);

      final lista = await dao.listarTreinosPorAluno(1);
      expect(lista, isEmpty);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // EXERCÍCIOS
  // ══════════════════════════════════════════════════════════════════════════

  group('exercícios', () {
    // id do treino compartilhado entre os testes deste grupo
    late int treinoId;

    setUp(() async {
      treinoId = await dao.inserirTreino(_makeTreino());
    });

    test('inserirExercicio: retorna id > 0 após inserção', () async {
      final id = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId),
      );
      expect(id, greaterThan(0));
    });

    test('buscarExercicioPorId: retorna exercício existente', () async {
      final id = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'Rosca Direta'),
      );
      final encontrado = await dao.buscarExercicioPorId(id);
      expect(encontrado, isNotNull);
      expect(encontrado!.nomeExercicio, equals('Rosca Direta'));
    });

    test('buscarExercicioPorId: retorna null para id inexistente', () async {
      final resultado = await dao.buscarExercicioPorId(9999);
      expect(resultado, isNull);
    });

    test('listarExercicios: retorna lista ordenada por ordem ASC', () async {
      await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'C', ordem: 2),
      );
      await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'A', ordem: 0),
      );
      await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'B', ordem: 1),
      );

      final lista = await dao.listarExercicios(treinoId);
      expect(lista.map((e) => e.nomeExercicio).toList(), equals(['A', 'B', 'C']));
    });

    test('listarExercicios: retorna lista vazia para treino sem exercícios',
        () async {
      final lista = await dao.listarExercicios(treinoId);
      expect(lista, isEmpty);
    });

    test('atualizarExercicio: persiste o novo nome', () async {
      final id = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'Nome Original'),
      );
      final inserido = (await dao.buscarExercicioPorId(id))!;

      await dao.atualizarExercicio(
        inserido.copyWith(nomeExercicio: 'Nome Atualizado'),
      );

      final atualizado = await dao.buscarExercicioPorId(id);
      expect(atualizado!.nomeExercicio, equals('Nome Atualizado'));
    });

    test('softDeleteExercicio: retorna 1 e oculta exercício de queries',
        () async {
      final id = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId),
      );

      final afetadas = await dao.softDeleteExercicio(id);
      expect(afetadas, equals(1));

      final lista = await dao.listarExercicios(treinoId);
      expect(lista, isEmpty);
    });

    test('softDeleteExercicio: retorna 0 para id inexistente', () async {
      final afetadas = await dao.softDeleteExercicio(9999);
      expect(afetadas, equals(0));
    });

    test('atualizarOrdemExercicios: persiste novas ordens em batch', () async {
      final idA = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'A', ordem: 0),
      );
      final idB = await dao.inserirExercicio(
        _makeExercicio(treinoId: treinoId, nome: 'B', ordem: 1),
      );

      // Troca as ordens: A vai para 1, B vai para 0
      final agora = DateTime.now();
      final lista = await dao.listarExercicios(treinoId);
      final exercicioA = lista.firstWhere((e) => e.id == idA);
      final exercicioB = lista.firstWhere((e) => e.id == idB);

      await dao.atualizarOrdemExercicios([
        exercicioA.copyWith(ordem: 1, dataAtualizacao: agora),
        exercicioB.copyWith(ordem: 0, dataAtualizacao: agora),
      ]);

      // Após reordenação, B deve vir primeiro (ordem 0) e A por último (ordem 1)
      final reordenada = await dao.listarExercicios(treinoId);
      expect(reordenada[0].nomeExercicio, equals('B'));
      expect(reordenada[1].nomeExercicio, equals('A'));
    });
  });
}
