// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aluno_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alunoRepositoryHash() => r'87fbf8c20df7197dbbb8af6b2cfba50a4fca369d';

/// Cria e mantém viva a instância do repositório de alunos.
///
/// `keepAlive: true` porque o repositório encapsula a conexão com o banco —
/// criá-lo e descartá-lo a cada navegação seria caro e desnecessário.
/// Os use case providers dependem deste provider via `watch`.
///
/// Copied from [alunoRepository].
@ProviderFor(alunoRepository)
final alunoRepositoryProvider = FutureProvider<AlunoRepository>.internal(
  alunoRepository,
  name: r'alunoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alunoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlunoRepositoryRef = FutureProviderRef<AlunoRepository>;
String _$criarAlunoHash() => r'a1b10e1967903b96cbbca2bde9dbe985c17b7dd8';

/// Cria um novo aluno e o persiste no banco (com validações).
///
/// Copied from [criarAluno].
@ProviderFor(criarAluno)
final criarAlunoProvider = AutoDisposeFutureProvider<CriarAluno>.internal(
  criarAluno,
  name: r'criarAlunoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$criarAlunoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CriarAlunoRef = AutoDisposeFutureProviderRef<CriarAluno>;
String _$editarAlunoHash() => r'8fd8b2c6e5ac67c570c05a05134f7393acfd4b92';

/// Edita os dados de um aluno existente.
/// A tela passa aluno.copyWith(...) com os novos valores.
///
/// Copied from [editarAluno].
@ProviderFor(editarAluno)
final editarAlunoProvider = AutoDisposeFutureProvider<EditarAluno>.internal(
  editarAluno,
  name: r'editarAlunoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$editarAlunoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EditarAlunoRef = AutoDisposeFutureProviderRef<EditarAluno>;
String _$deletarAlunoHash() => r'eba7cd7e569674c14df46320217e1e252c25ce20';

/// Faz soft delete de um aluno (marca deletado_em, não apaga o registro).
///
/// Copied from [deletarAluno].
@ProviderFor(deletarAluno)
final deletarAlunoProvider = AutoDisposeFutureProvider<DeletarAluno>.internal(
  deletarAluno,
  name: r'deletarAlunoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletarAlunoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletarAlunoRef = AutoDisposeFutureProviderRef<DeletarAluno>;
String _$buscarAlunoPorIdHash() => r'51b82ca64faa9e4984a4beeab60b5097b51a2884';

/// Busca um único aluno pelo id — usado ao abrir o perfil ou antes de editar.
///
/// Copied from [buscarAlunoPorId].
@ProviderFor(buscarAlunoPorId)
final buscarAlunoPorIdProvider =
    AutoDisposeFutureProvider<BuscarAlunoPorId>.internal(
      buscarAlunoPorId,
      name: r'buscarAlunoPorIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$buscarAlunoPorIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BuscarAlunoPorIdRef = AutoDisposeFutureProviderRef<BuscarAlunoPorId>;
String _$listarAlunosHash() => r'cabd8bc0b6db00938bafae6fe71bd9fdfccdde0a';

/// Lista os alunos ativos, com busca opcional por nome.
/// Exposto como provider próprio para que o AlunosNotifier possa usá-lo via
/// watch sem criar dependência circular.
///
/// Copied from [listarAlunos].
@ProviderFor(listarAlunos)
final listarAlunosProvider = AutoDisposeFutureProvider<ListarAlunos>.internal(
  listarAlunos,
  name: r'listarAlunosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listarAlunosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListarAlunosRef = AutoDisposeFutureProviderRef<ListarAlunos>;
String _$listarUltimosAlunosAcessadosHash() =>
    r'e9ed27fec81f27bcbaffac873f6156037aa0e820';

/// Retorna os 5 alunos acessados mais recentemente — usado no dashboard.
///
/// Copied from [listarUltimosAlunosAcessados].
@ProviderFor(listarUltimosAlunosAcessados)
final listarUltimosAlunosAcessadosProvider =
    AutoDisposeFutureProvider<ListarUltimosAlunosAcessados>.internal(
      listarUltimosAlunosAcessados,
      name: r'listarUltimosAlunosAcessadosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$listarUltimosAlunosAcessadosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListarUltimosAlunosAcessadosRef =
    AutoDisposeFutureProviderRef<ListarUltimosAlunosAcessados>;
String _$contarAlunosAtivosHash() =>
    r'a93ef90b7fd0f1fba101b472657115318b8cb2a9';

/// Conta quantos alunos estão ativos — usado no dashboard.
///
/// Copied from [contarAlunosAtivos].
@ProviderFor(contarAlunosAtivos)
final contarAlunosAtivosProvider =
    AutoDisposeFutureProvider<ContarAlunosAtivos>.internal(
      contarAlunosAtivos,
      name: r'contarAlunosAtivosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contarAlunosAtivosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContarAlunosAtivosRef =
    AutoDisposeFutureProviderRef<ContarAlunosAtivos>;
String _$atualizarUltimoAcessoHash() =>
    r'e68d7a2159f98f9c6df7362f3335915b7d56e669';

/// Registra o último acesso a um aluno — deve ser chamado ao abrir o perfil.
///
/// Copied from [atualizarUltimoAcesso].
@ProviderFor(atualizarUltimoAcesso)
final atualizarUltimoAcessoProvider =
    AutoDisposeFutureProvider<AtualizarUltimoAcesso>.internal(
      atualizarUltimoAcesso,
      name: r'atualizarUltimoAcessoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$atualizarUltimoAcessoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AtualizarUltimoAcessoRef =
    AutoDisposeFutureProviderRef<AtualizarUltimoAcesso>;
String _$salvarFotoAlunoHash() => r'9618dcda459c3b92fd1621daf849c575533f272d';

/// Processa (redimensiona, comprime) e salva a foto de um aluno no dispositivo.
///
/// Copied from [salvarFotoAluno].
@ProviderFor(salvarFotoAluno)
final salvarFotoAlunoProvider =
    AutoDisposeFutureProvider<SalvarFotoAluno>.internal(
      salvarFotoAluno,
      name: r'salvarFotoAlunoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$salvarFotoAlunoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SalvarFotoAlunoRef = AutoDisposeFutureProviderRef<SalvarFotoAluno>;
String _$removerFotoAlunoHash() => r'7ecc645e547d1c026ab82beec017fd427413ef64';

/// Remove a foto de um aluno (arquivo físico do dispositivo + campo no banco).
///
/// Copied from [removerFotoAluno].
@ProviderFor(removerFotoAluno)
final removerFotoAlunoProvider =
    AutoDisposeFutureProvider<RemoverFotoAluno>.internal(
      removerFotoAluno,
      name: r'removerFotoAlunoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$removerFotoAlunoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RemoverFotoAlunoRef = AutoDisposeFutureProviderRef<RemoverFotoAluno>;
String _$alunosHash() => r'63e274d069a0e9034c20a0483600c1b5b2b9a785';

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
///
/// Copied from [Alunos].
@ProviderFor(Alunos)
final alunosProvider =
    AutoDisposeAsyncNotifierProvider<Alunos, List<Aluno>>.internal(
      Alunos.new,
      name: r'alunosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$alunosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Alunos = AutoDisposeAsyncNotifier<List<Aluno>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
