// aluno_providers.dart
//
// Providers Riverpod da feature de alunos.
//
// RESPONSABILIDADE:
//   - Criar e distribuir as dependências (DAO → Repository → use cases)
//   - Expor o estado da lista de alunos via AlunosNotifier
//   - Permitir que as telas disparem ações sem conhecer a camada de dados
//
// HIERARQUIA DE DEPENDÊNCIAS:
//   DatabaseHelper (singleton SQLite)
//        ↓  await
//     AlunoDao(db)                  (SQL puro)
//        ↓  injeção
//   AlunoRepositoryImpl(dao)        (implementação do contrato)
//        ↓  injeção
//   CriarAluno(repo) / ListarAlunos(repo) / ...
//        ↓  watch/read
//     Tela Flutter
//
// COMO AS TELAS USAM ESTES PROVIDERS:
//   Ler a lista:   ref.watch(alunosProvider)
//   Buscar:        ref.read(alunosProvider.notifier).buscar('João')
//   Criar aluno:   final uc = await ref.read(criarAlunoProvider.future);
//                  await uc(nome: 'Ana', ...);
//                  ref.invalidate(alunosProvider); // recarrega a lista

import 'package:riverpod_annotation/riverpod_annotation.dart';

// ── core ──────────────────────────────────────────────────────────────────────
import '../../../../core/database/database_helper.dart';

// ── data ──────────────────────────────────────────────────────────────────────
import '../../data/datasources/aluno_dao.dart';
import '../../data/repositories/aluno_repository_impl.dart';

// ── domain ────────────────────────────────────────────────────────────────────
import '../../domain/entities/aluno.dart';
import '../../domain/repositories/aluno_repository.dart';
import '../../domain/usecases/criar_aluno.dart';
import '../../domain/usecases/editar_aluno.dart';
import '../../domain/usecases/deletar_aluno.dart';
import '../../domain/usecases/buscar_aluno_por_id.dart';
import '../../domain/usecases/listar_alunos.dart';
import '../../domain/usecases/listar_ultimos_alunos_acessados.dart';
import '../../domain/usecases/contar_alunos_ativos.dart';
import '../../domain/usecases/atualizar_ultimo_acesso.dart';
import '../../domain/usecases/salvar_foto_aluno.dart';
import '../../domain/usecases/remover_foto_aluno.dart';

// O `part` liga este arquivo ao código gerado pelo riverpod_generator.
// O build_runner cria aluno_providers.g.dart automaticamente com base nas
// anotações @riverpod abaixo.
part 'aluno_providers.g.dart';

// ════════════════════════════════════════════════════════════════════════════
// REPOSITORY PROVIDER
// ════════════════════════════════════════════════════════════════════════════

/// Cria e mantém viva a instância do repositório de alunos.
///
/// `keepAlive: true` porque o repositório encapsula a conexão com o banco —
/// criá-lo e descartá-lo a cada navegação seria caro e desnecessário.
/// Os use case providers dependem deste provider via `watch`.
@Riverpod(keepAlive: true)
Future<AlunoRepository> alunoRepository(AlunoRepositoryRef ref) async {
  // DatabaseHelper.instance.database abre o banco na primeira chamada e
  // retorna o mesmo objeto nas subsequentes (padrão singleton interno).
  final db = await DatabaseHelper.instance.database;
  return AlunoRepositoryImpl(AlunoDao(db));
}

// ════════════════════════════════════════════════════════════════════════════
// USE CASE PROVIDERS
// ════════════════════════════════════════════════════════════════════════════
//
// Cada use case é um provider separado. Todos são `autoDispose` (padrão do
// @riverpod sem keepAlive) — quando nenhuma tela os escuta, o Riverpod os
// descarta automaticamente para liberar memória.
//
// FLUXO DE USO NA TELA:
//   1. Obter o use case:  final uc = await ref.read(criarAlunoProvider.future);
//   2. Executar:          final aluno = await uc(nome: 'João', ...);
//   3. Atualizar lista:   ref.invalidate(alunosProvider);

/// Cria um novo aluno e o persiste no banco (com validações).
@riverpod
Future<CriarAluno> criarAluno(CriarAlunoRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return CriarAluno(repo);
}

/// Edita os dados de um aluno existente.
/// A tela passa aluno.copyWith(...) com os novos valores.
@riverpod
Future<EditarAluno> editarAluno(EditarAlunoRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return EditarAluno(repo);
}

/// Faz soft delete de um aluno (marca deletado_em, não apaga o registro).
@riverpod
Future<DeletarAluno> deletarAluno(DeletarAlunoRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return DeletarAluno(repo);
}

/// Busca um único aluno pelo id — usado ao abrir o perfil ou antes de editar.
@riverpod
Future<BuscarAlunoPorId> buscarAlunoPorId(BuscarAlunoPorIdRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return BuscarAlunoPorId(repo);
}

/// Lista os alunos ativos, com busca opcional por nome.
/// Exposto como provider próprio para que o AlunosNotifier possa usá-lo via
/// watch sem criar dependência circular.
@riverpod
Future<ListarAlunos> listarAlunos(ListarAlunosRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return ListarAlunos(repo);
}

/// Retorna os 5 alunos acessados mais recentemente — usado no dashboard.
@riverpod
Future<ListarUltimosAlunosAcessados> listarUltimosAlunosAcessados(
  ListarUltimosAlunosAcessadosRef ref,
) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return ListarUltimosAlunosAcessados(repo);
}

/// Conta quantos alunos estão ativos — usado no dashboard.
@riverpod
Future<ContarAlunosAtivos> contarAlunosAtivos(ContarAlunosAtivosRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return ContarAlunosAtivos(repo);
}

/// Registra o último acesso a um aluno — deve ser chamado ao abrir o perfil.
@riverpod
Future<AtualizarUltimoAcesso> atualizarUltimoAcesso(
  AtualizarUltimoAcessoRef ref,
) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return AtualizarUltimoAcesso(repo);
}

/// Processa (redimensiona, comprime) e salva a foto de um aluno no dispositivo.
@riverpod
Future<SalvarFotoAluno> salvarFotoAluno(SalvarFotoAlunoRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return SalvarFotoAluno(repo);
}

/// Remove a foto de um aluno (arquivo físico do dispositivo + campo no banco).
@riverpod
Future<RemoverFotoAluno> removerFotoAluno(RemoverFotoAlunoRef ref) async {
  final repo = await ref.watch(alunoRepositoryProvider.future);
  return RemoverFotoAluno(repo);
}

// ════════════════════════════════════════════════════════════════════════════
// ALUNOS NOTIFIER — estado da lista com filtro de busca
// ════════════════════════════════════════════════════════════════════════════

/// Gerencia o estado da lista de alunos exibida na tela principal.
///
/// Responsabilidades:
///   - [build()] carrega a lista do banco (aplicando [_query] se definido)
///   - [buscar()] filtra a lista por nome disparando um rebuild via invalidateSelf
///
/// Mutações (criar, editar, deletar) são feitas pelas telas diretamente via
/// os use case providers acima. Após a mutação, a tela deve chamar:
///   ref.invalidate(alunosProvider)
/// para forçar este notifier a recarregar a lista.
@riverpod
class Alunos extends _$Alunos {
  // Filtro de busca atual. null = sem filtro = todos os alunos ativos.
  String? _query;

  /// Carrega a lista de alunos, respeitando o filtro [_query].
  ///
  /// É chamado automaticamente:
  ///   1. Na primeira vez que uma tela assiste a [alunosProvider].
  ///   2. Sempre que [buscar()] é chamado (via invalidateSelf).
  ///   3. Sempre que [alunosProvider] é invalidado externamente
  ///      (ex: após criar/editar/deletar um aluno).
  @override
  Future<List<Aluno>> build() async {
    // Obtém o use case via watch — garante que o notifier é reconstruído
    // caso o repositório seja reinicializado (raro, mas correto).
    final uc = await ref.watch(listarAlunosProvider.future);
    return uc(query: _query);
  }

  /// Filtra a lista de alunos pelo nome.
  ///
  /// Salva a query internamente e dispara [build()] novamente via
  /// [ref.invalidateSelf()]. A tela é reconstruída automaticamente.
  ///
  /// Passar null ou string vazia remove o filtro e exibe todos os alunos.
  void buscar(String? query) {
    _query = query;
    // invalidateSelf() descarta o estado atual e re-executa build().
    // Durante o rebuild, o estado fica em AsyncLoading; o widget pode
    // usar `skipLoadingOnReload: true` para manter o conteúdo anterior
    // visível enquanto a nova consulta chega.
    ref.invalidateSelf();
  }
}
