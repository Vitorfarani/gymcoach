// treino_providers.dart
//
// Providers Riverpod da feature de treinos e exercícios.
//
// HIERARQUIA DE DEPENDÊNCIAS (de baixo para cima):
//
//   DatabaseHelper (singleton SQLite)
//        ↓  await
//     TreinoDao(db)                      (SQL puro — tabelas treinos + exercícios)
//        ↓  injeção
//   TreinoRepositoryImpl(dao)            (implementação do contrato)
//        ↓  injeção
//   CriarTreino / AtualizarTreino / ...  (use cases de ação)
//   ListarTreinosDoAluno / Listar...     (use cases de leitura — family providers)
//        ↓  watch/read
//     Tela Flutter
//
// DOIS TIPOS DE PROVIDERS AQUI:
//
//   1. USE CASE PROVIDERS (ação):
//      Retornam a instância do use case — a tela chama imperiativamente.
//      Exemplo: `await ref.read(criarTreinoProvider.future)` → objeto CriarTreino
//               `await uc(alunoId: 1, nome: 'Treino A');`
//
//   2. DATA PROVIDERS (leitura — family):
//      Retornam os dados diretamente, parametrizados por id.
//      Exemplo: `ref.watch(listarTreinosDoAlunoProvider(alunoId))`
//               → AsyncValue<List<Treino>>
//
//      `FutureProvider.family` na prática: ao adicionar um parâmetro extra
//      na função anotada com @riverpod, o build_runner gera automaticamente
//      um provider family. A tela chama o provider passando o id como argumento.
//
// CICLO DE VIDA:
//   - @Riverpod(keepAlive: true): DAO e Repository vivem enquanto o app roda.
//     Custo: banco aberto uma vez, instâncias mantidas em memória.
//   - @riverpod (padrão = autoDispose): use cases e data providers são
//     descartados quando nenhum widget os assiste. Sem cache desatualizado.

import 'package:riverpod_annotation/riverpod_annotation.dart';

// ── core ──────────────────────────────────────────────────────────────────────
import '../../../../core/database/database_helper.dart';

// ── data ──────────────────────────────────────────────────────────────────────
import '../../data/datasources/treino_dao.dart';
import '../../data/repositories/treino_repository_impl.dart';

// ── domain ────────────────────────────────────────────────────────────────────
import '../../domain/entities/treino.dart';
import '../../domain/entities/treino_exercicio.dart';
import '../../domain/repositories/treino_repository.dart';
import '../../domain/usecases/criar_treino.dart';
import '../../domain/usecases/atualizar_treino.dart';
import '../../domain/usecases/deletar_treino.dart';
import '../../domain/usecases/buscar_treino_por_id.dart';
import '../../domain/usecases/listar_treinos_do_aluno.dart';
import '../../domain/usecases/listar_exercicios.dart';
import '../../domain/usecases/adicionar_exercicio.dart';
import '../../domain/usecases/atualizar_exercicio.dart';
import '../../domain/usecases/deletar_exercicio.dart';
import '../../domain/usecases/reordenar_exercicios.dart';

// O `part` conecta este arquivo ao código gerado automaticamente pelo
// build_runner com base nas anotações @riverpod/@Riverpod abaixo.
// Para (re)gerar: flutter pub run build_runner build --delete-conflicting-outputs
part 'treino_providers.g.dart';

// ════════════════════════════════════════════════════════════════════════════
// 1. DAO PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// Cria e mantém viva a instância do TreinoDao.
///
/// `keepAlive: true` — o DAO encapsula a conexão com o banco. Criá-lo a cada
/// navegação seria caro; mantê-lo vivo é o comportamento correto para um app
/// com dados locais.
///
/// O treinoRepositoryProvider depende deste provider via watch.
@Riverpod(keepAlive: true)
Future<TreinoDao> treinoDao(TreinoDaoRef ref) async {
  // DatabaseHelper.instance.database: abre o banco SQLite na primeira chamada
  // e retorna a mesma conexão nas subsequentes (singleton interno).
  final db = await DatabaseHelper.instance.database;
  return TreinoDao(db);
}

// ════════════════════════════════════════════════════════════════════════════
// 2. REPOSITORY PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// Cria e mantém viva a instância do TreinoRepositoryImpl.
///
/// Todos os use case providers dependem deste provider.
/// O tipo de retorno é TreinoRepository (contrato abstrato de domain/) —
/// não TreinoRepositoryImpl — para que a presentation não dependa da camada data.
@Riverpod(keepAlive: true)
Future<TreinoRepository> treinoRepository(TreinoRepositoryRef ref) async {
  // watch garante que, se o DAO for reinicializado (raro), o repositório
  // acompanha automaticamente — sem stale reference.
  final dao = await ref.watch(treinoDaoProvider.future);
  return TreinoRepositoryImpl(dao);
}

// ════════════════════════════════════════════════════════════════════════════
// 3. USE CASE PROVIDERS — ações sobre treinos
// ════════════════════════════════════════════════════════════════════════════
//
// Cada provider retorna a instância do use case (não o resultado).
// A tela obtém o use case e o executa com os parâmetros necessários.
//
// PADRÃO DE USO NA TELA:
//   final uc = await ref.read(criarTreinoProvider.future);
//   final treino = await uc(alunoId: 1, nome: 'Treino A');
//   ref.invalidate(listarTreinosDoAlunoProvider(1)); // força recarregar a lista

/// Persiste um novo treino no banco com validações.
///
/// Lança [NomeObrigatorioException] se nome estiver vazio.
/// Lança [DatabaseException] em falha de persistência.
@riverpod
Future<CriarTreino> criarTreino(CriarTreinoRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return CriarTreino(repo);
}

/// Atualiza nome e/ou descrição de um treino existente.
///
/// A tela deve chamar: `await uc(treino.copyWith(nome: 'Novo Nome'))`.
/// Lança [TreinoNaoEncontradoException] se o treino não existir.
@riverpod
Future<AtualizarTreino> atualizarTreino(AtualizarTreinoRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return AtualizarTreino(repo);
}

/// Faz soft delete de um treino (preenche deletado_em, não apaga do banco).
///
/// Lança [TreinoNaoEncontradoException] se o treino não existir.
@riverpod
Future<DeletarTreino> deletarTreino(DeletarTreinoRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return DeletarTreino(repo);
}

/// Busca um treino específico pelo id — usado ao abrir a tela de detalhes.
///
/// Lança [TreinoNaoEncontradoException] se o id não existir.
@riverpod
Future<BuscarTreinoPorId> buscarTreinoPorId(BuscarTreinoPorIdRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return BuscarTreinoPorId(repo);
}

// ════════════════════════════════════════════════════════════════════════════
// 4. USE CASE PROVIDERS — ações sobre exercícios
// ════════════════════════════════════════════════════════════════════════════

/// Adiciona um exercício ao final da lista de um treino.
///
/// A ordem é calculada internamente pelo use case (count dos existentes).
/// Lança [NomeObrigatorioException] e [SeriesObrigatorioException] se campos
/// obrigatórios estiverem vazios.
@riverpod
Future<AdicionarExercicio> adicionarExercicio(AdicionarExercicioRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return AdicionarExercicio(repo);
}

/// Atualiza os dados de um exercício existente (nome, séries, carga, etc.).
///
/// A ordem NÃO é alterada aqui — use [reordenarExerciciosProvider] para isso.
/// Lança [ExercicioNaoEncontradoException] se o exercício não existir.
@riverpod
Future<AtualizarExercicio> atualizarExercicio(AtualizarExercicioRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return AtualizarExercicio(repo);
}

/// Faz soft delete de um exercício (preenche deletado_em).
///
/// Os índices dos demais exercícios ficam com "buracos" — aceitável no MVP.
/// Lança [ExercicioNaoEncontradoException] se o exercício não existir.
@riverpod
Future<DeletarExercicio> deletarExercicio(DeletarExercicioRef ref) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return DeletarExercicio(repo);
}

/// Move um exercício para cima ou para baixo na lista do treino.
///
/// Recebe a lista completa de exercícios com as novas ordens já calculadas.
/// O batch UPDATE é atômico: ou todos os UPDATEs são aplicados, ou nenhum.
@riverpod
Future<ReordenarExercicios> reordenarExercicios(
  ReordenarExerciciosRef ref,
) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  return ReordenarExercicios(repo);
}

// ════════════════════════════════════════════════════════════════════════════
// 5. DATA PROVIDERS (family) — listas assistidas pela UI
// ════════════════════════════════════════════════════════════════════════════
//
// Estes providers retornam os dados DIRETAMENTE (não o use case).
// São FAMILY providers: cada valor de parâmetro gera uma instância separada.
//
// POR QUE FAMILY AQUI (e não nas ações)?
//   Os providers de ação (criar, deletar...) são chamados UMA VEZ pela tela
//   e descartados — não há estado para "assistir".
//   Os providers de lista são ASSISTIDOS continuamente: a tela reconstrói
//   automaticamente quando os dados mudam (após invalidate).
//
// CICLO DE USO TÍPICO NA TELA:
//   // Assiste — reconstrói quando a lista mudar
//   final asyncLista = ref.watch(listarTreinosDoAlunoProvider(alunoId));
//
//   // Após criar/deletar um treino:
//   ref.invalidate(listarTreinosDoAlunoProvider(alunoId)); // recarrega

/// Retorna a lista de treinos ativos do aluno com [alunoId].
///
/// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
/// separado é criado para cada alunoId distinto pelo Riverpod.
///
/// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
/// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
///
/// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
@riverpod
Future<List<Treino>> listarTreinosDoAluno(
  ListarTreinosDoAlunoRef ref,
  // Este parâmetro extra é o que transforma o provider em family.
  // O build_runner gera: listarTreinosDoAlunoProvider(alunoId)
  int alunoId,
) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  final uc = ListarTreinosDoAluno(repo);
  return uc(alunoId);
}

/// Retorna a lista de exercícios ativos do treino com [treinoId].
///
/// Provider family: `listarExerciciosProvider(treinoId)`.
///
/// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
/// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
///
/// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
@riverpod
Future<List<TreinoExercicio>> listarExercicios(
  ListarExerciciosRef ref,
  // Parâmetro → provider family. Riverpod mantém um cache por treinoId.
  int treinoId,
) async {
  final repo = await ref.watch(treinoRepositoryProvider.future);
  final uc = ListarExercicios(repo);
  return uc(treinoId);
}
