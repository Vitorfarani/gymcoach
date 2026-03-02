// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treino_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$treinoDaoHash() => r'bef402d2644ec78f6d7323feb1470ec70f1aedb2';

/// Cria e mantém viva a instância do TreinoDao.
///
/// `keepAlive: true` — o DAO encapsula a conexão com o banco. Criá-lo a cada
/// navegação seria caro; mantê-lo vivo é o comportamento correto para um app
/// com dados locais.
///
/// O treinoRepositoryProvider depende deste provider via watch.
///
/// Copied from [treinoDao].
@ProviderFor(treinoDao)
final treinoDaoProvider = FutureProvider<TreinoDao>.internal(
  treinoDao,
  name: r'treinoDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treinoDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TreinoDaoRef = FutureProviderRef<TreinoDao>;
String _$treinoRepositoryHash() => r'156b50bd6e9dd36ea68c3969c5b6ec82bfc74284';

/// Cria e mantém viva a instância do TreinoRepositoryImpl.
///
/// Todos os use case providers dependem deste provider.
/// O tipo de retorno é TreinoRepository (contrato abstrato de domain/) —
/// não TreinoRepositoryImpl — para que a presentation não dependa da camada data.
///
/// Copied from [treinoRepository].
@ProviderFor(treinoRepository)
final treinoRepositoryProvider = FutureProvider<TreinoRepository>.internal(
  treinoRepository,
  name: r'treinoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$treinoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TreinoRepositoryRef = FutureProviderRef<TreinoRepository>;
String _$criarTreinoHash() => r'2631e68f71df8671c05c37ba8c03b81cc5c58712';

/// Persiste um novo treino no banco com validações.
///
/// Lança [NomeObrigatorioException] se nome estiver vazio.
/// Lança [DatabaseException] em falha de persistência.
///
/// Copied from [criarTreino].
@ProviderFor(criarTreino)
final criarTreinoProvider = AutoDisposeFutureProvider<CriarTreino>.internal(
  criarTreino,
  name: r'criarTreinoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$criarTreinoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CriarTreinoRef = AutoDisposeFutureProviderRef<CriarTreino>;
String _$atualizarTreinoHash() => r'f87d85f78748d44d87eabb78ebc0e6508d973753';

/// Atualiza nome e/ou descrição de um treino existente.
///
/// A tela deve chamar: `await uc(treino.copyWith(nome: 'Novo Nome'))`.
/// Lança [TreinoNaoEncontradoException] se o treino não existir.
///
/// Copied from [atualizarTreino].
@ProviderFor(atualizarTreino)
final atualizarTreinoProvider =
    AutoDisposeFutureProvider<AtualizarTreino>.internal(
      atualizarTreino,
      name: r'atualizarTreinoProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$atualizarTreinoHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AtualizarTreinoRef = AutoDisposeFutureProviderRef<AtualizarTreino>;
String _$deletarTreinoHash() => r'845b894c7102eacb99c17d61dc205652776e3efb';

/// Faz soft delete de um treino (preenche deletado_em, não apaga do banco).
///
/// Lança [TreinoNaoEncontradoException] se o treino não existir.
///
/// Copied from [deletarTreino].
@ProviderFor(deletarTreino)
final deletarTreinoProvider = AutoDisposeFutureProvider<DeletarTreino>.internal(
  deletarTreino,
  name: r'deletarTreinoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deletarTreinoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletarTreinoRef = AutoDisposeFutureProviderRef<DeletarTreino>;
String _$buscarTreinoPorIdHash() => r'f460f95cdffc080023f223cc67e0eea44fa542d6';

/// Busca um treino específico pelo id — usado ao abrir a tela de detalhes.
///
/// Lança [TreinoNaoEncontradoException] se o id não existir.
///
/// Copied from [buscarTreinoPorId].
@ProviderFor(buscarTreinoPorId)
final buscarTreinoPorIdProvider =
    AutoDisposeFutureProvider<BuscarTreinoPorId>.internal(
      buscarTreinoPorId,
      name: r'buscarTreinoPorIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$buscarTreinoPorIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BuscarTreinoPorIdRef = AutoDisposeFutureProviderRef<BuscarTreinoPorId>;
String _$adicionarExercicioHash() =>
    r'2f1348359365126a843b905c4764acc9a7155787';

/// Adiciona um exercício ao final da lista de um treino.
///
/// A ordem é calculada internamente pelo use case (count dos existentes).
/// Lança [NomeObrigatorioException] e [SeriesObrigatorioException] se campos
/// obrigatórios estiverem vazios.
///
/// Copied from [adicionarExercicio].
@ProviderFor(adicionarExercicio)
final adicionarExercicioProvider =
    AutoDisposeFutureProvider<AdicionarExercicio>.internal(
      adicionarExercicio,
      name: r'adicionarExercicioProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adicionarExercicioHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdicionarExercicioRef =
    AutoDisposeFutureProviderRef<AdicionarExercicio>;
String _$atualizarExercicioHash() =>
    r'17d9294341a27f273c14b3570f053edd26899655';

/// Atualiza os dados de um exercício existente (nome, séries, carga, etc.).
///
/// A ordem NÃO é alterada aqui — use [reordenarExerciciosProvider] para isso.
/// Lança [ExercicioNaoEncontradoException] se o exercício não existir.
///
/// Copied from [atualizarExercicio].
@ProviderFor(atualizarExercicio)
final atualizarExercicioProvider =
    AutoDisposeFutureProvider<AtualizarExercicio>.internal(
      atualizarExercicio,
      name: r'atualizarExercicioProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$atualizarExercicioHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AtualizarExercicioRef =
    AutoDisposeFutureProviderRef<AtualizarExercicio>;
String _$deletarExercicioHash() => r'208bf92fb22d7d0035da212f72ee4285a703a5a2';

/// Faz soft delete de um exercício (preenche deletado_em).
///
/// Os índices dos demais exercícios ficam com "buracos" — aceitável no MVP.
/// Lança [ExercicioNaoEncontradoException] se o exercício não existir.
///
/// Copied from [deletarExercicio].
@ProviderFor(deletarExercicio)
final deletarExercicioProvider =
    AutoDisposeFutureProvider<DeletarExercicio>.internal(
      deletarExercicio,
      name: r'deletarExercicioProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deletarExercicioHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeletarExercicioRef = AutoDisposeFutureProviderRef<DeletarExercicio>;
String _$reordenarExerciciosHash() =>
    r'5e412eb17a5dcc07025aae152de25685eecd20f3';

/// Move um exercício para cima ou para baixo na lista do treino.
///
/// Recebe a lista completa de exercícios com as novas ordens já calculadas.
/// O batch UPDATE é atômico: ou todos os UPDATEs são aplicados, ou nenhum.
///
/// Copied from [reordenarExercicios].
@ProviderFor(reordenarExercicios)
final reordenarExerciciosProvider =
    AutoDisposeFutureProvider<ReordenarExercicios>.internal(
      reordenarExercicios,
      name: r'reordenarExerciciosProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reordenarExerciciosHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReordenarExerciciosRef =
    AutoDisposeFutureProviderRef<ReordenarExercicios>;
String _$listarTreinosDoAlunoHash() =>
    r'803202745375c53170c1ffe6a1a2ae80eb03747a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Retorna a lista de treinos ativos do aluno com [alunoId].
///
/// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
/// separado é criado para cada alunoId distinto pelo Riverpod.
///
/// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
/// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
///
/// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
///
/// Copied from [listarTreinosDoAluno].
@ProviderFor(listarTreinosDoAluno)
const listarTreinosDoAlunoProvider = ListarTreinosDoAlunoFamily();

/// Retorna a lista de treinos ativos do aluno com [alunoId].
///
/// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
/// separado é criado para cada alunoId distinto pelo Riverpod.
///
/// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
/// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
///
/// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
///
/// Copied from [listarTreinosDoAluno].
class ListarTreinosDoAlunoFamily extends Family<AsyncValue<List<Treino>>> {
  /// Retorna a lista de treinos ativos do aluno com [alunoId].
  ///
  /// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
  /// separado é criado para cada alunoId distinto pelo Riverpod.
  ///
  /// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
  /// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
  ///
  /// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
  ///
  /// Copied from [listarTreinosDoAluno].
  const ListarTreinosDoAlunoFamily();

  /// Retorna a lista de treinos ativos do aluno com [alunoId].
  ///
  /// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
  /// separado é criado para cada alunoId distinto pelo Riverpod.
  ///
  /// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
  /// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
  ///
  /// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
  ///
  /// Copied from [listarTreinosDoAluno].
  ListarTreinosDoAlunoProvider call(int alunoId) {
    return ListarTreinosDoAlunoProvider(alunoId);
  }

  @override
  ListarTreinosDoAlunoProvider getProviderOverride(
    covariant ListarTreinosDoAlunoProvider provider,
  ) {
    return call(provider.alunoId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listarTreinosDoAlunoProvider';
}

/// Retorna a lista de treinos ativos do aluno com [alunoId].
///
/// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
/// separado é criado para cada alunoId distinto pelo Riverpod.
///
/// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
/// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
///
/// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
///
/// Copied from [listarTreinosDoAluno].
class ListarTreinosDoAlunoProvider
    extends AutoDisposeFutureProvider<List<Treino>> {
  /// Retorna a lista de treinos ativos do aluno com [alunoId].
  ///
  /// Provider family: `listarTreinosDoAlunoProvider(alunoId)` — um provider
  /// separado é criado para cada alunoId distinto pelo Riverpod.
  ///
  /// Resultado: `AsyncValue<List<Treino>>` no widget (via ref.watch).
  /// A lista é ordenada por `created_at ASC` (doc4 — ListarTreinosDoAluno).
  ///
  /// Lista vazia é resultado válido (aluno sem treinos) — não lança exceção.
  ///
  /// Copied from [listarTreinosDoAluno].
  ListarTreinosDoAlunoProvider(int alunoId)
    : this._internal(
        (ref) => listarTreinosDoAluno(ref as ListarTreinosDoAlunoRef, alunoId),
        from: listarTreinosDoAlunoProvider,
        name: r'listarTreinosDoAlunoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listarTreinosDoAlunoHash,
        dependencies: ListarTreinosDoAlunoFamily._dependencies,
        allTransitiveDependencies:
            ListarTreinosDoAlunoFamily._allTransitiveDependencies,
        alunoId: alunoId,
      );

  ListarTreinosDoAlunoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.alunoId,
  }) : super.internal();

  final int alunoId;

  @override
  Override overrideWith(
    FutureOr<List<Treino>> Function(ListarTreinosDoAlunoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListarTreinosDoAlunoProvider._internal(
        (ref) => create(ref as ListarTreinosDoAlunoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        alunoId: alunoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Treino>> createElement() {
    return _ListarTreinosDoAlunoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListarTreinosDoAlunoProvider && other.alunoId == alunoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, alunoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListarTreinosDoAlunoRef on AutoDisposeFutureProviderRef<List<Treino>> {
  /// The parameter `alunoId` of this provider.
  int get alunoId;
}

class _ListarTreinosDoAlunoProviderElement
    extends AutoDisposeFutureProviderElement<List<Treino>>
    with ListarTreinosDoAlunoRef {
  _ListarTreinosDoAlunoProviderElement(super.provider);

  @override
  int get alunoId => (origin as ListarTreinosDoAlunoProvider).alunoId;
}

String _$listarExerciciosHash() => r'60bb5f5ed174ed95b6d0d385f0a38f17713b0498';

/// Retorna a lista de exercícios ativos do treino com [treinoId].
///
/// Provider family: `listarExerciciosProvider(treinoId)`.
///
/// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
/// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
///
/// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
///
/// Copied from [listarExercicios].
@ProviderFor(listarExercicios)
const listarExerciciosProvider = ListarExerciciosFamily();

/// Retorna a lista de exercícios ativos do treino com [treinoId].
///
/// Provider family: `listarExerciciosProvider(treinoId)`.
///
/// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
/// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
///
/// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
///
/// Copied from [listarExercicios].
class ListarExerciciosFamily extends Family<AsyncValue<List<TreinoExercicio>>> {
  /// Retorna a lista de exercícios ativos do treino com [treinoId].
  ///
  /// Provider family: `listarExerciciosProvider(treinoId)`.
  ///
  /// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
  /// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
  ///
  /// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
  ///
  /// Copied from [listarExercicios].
  const ListarExerciciosFamily();

  /// Retorna a lista de exercícios ativos do treino com [treinoId].
  ///
  /// Provider family: `listarExerciciosProvider(treinoId)`.
  ///
  /// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
  /// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
  ///
  /// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
  ///
  /// Copied from [listarExercicios].
  ListarExerciciosProvider call(int treinoId) {
    return ListarExerciciosProvider(treinoId);
  }

  @override
  ListarExerciciosProvider getProviderOverride(
    covariant ListarExerciciosProvider provider,
  ) {
    return call(provider.treinoId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listarExerciciosProvider';
}

/// Retorna a lista de exercícios ativos do treino com [treinoId].
///
/// Provider family: `listarExerciciosProvider(treinoId)`.
///
/// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
/// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
///
/// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
///
/// Copied from [listarExercicios].
class ListarExerciciosProvider
    extends AutoDisposeFutureProvider<List<TreinoExercicio>> {
  /// Retorna a lista de exercícios ativos do treino com [treinoId].
  ///
  /// Provider family: `listarExerciciosProvider(treinoId)`.
  ///
  /// Resultado: `AsyncValue<List<TreinoExercicio>>` no widget (via ref.watch).
  /// A lista é ordenada por `ordem ASC` (campo controlado pelo professor).
  ///
  /// Lista vazia é resultado válido (treino sem exercícios) — não lança exceção.
  ///
  /// Copied from [listarExercicios].
  ListarExerciciosProvider(int treinoId)
    : this._internal(
        (ref) => listarExercicios(ref as ListarExerciciosRef, treinoId),
        from: listarExerciciosProvider,
        name: r'listarExerciciosProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listarExerciciosHash,
        dependencies: ListarExerciciosFamily._dependencies,
        allTransitiveDependencies:
            ListarExerciciosFamily._allTransitiveDependencies,
        treinoId: treinoId,
      );

  ListarExerciciosProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.treinoId,
  }) : super.internal();

  final int treinoId;

  @override
  Override overrideWith(
    FutureOr<List<TreinoExercicio>> Function(ListarExerciciosRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListarExerciciosProvider._internal(
        (ref) => create(ref as ListarExerciciosRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        treinoId: treinoId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TreinoExercicio>> createElement() {
    return _ListarExerciciosProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListarExerciciosProvider && other.treinoId == treinoId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, treinoId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListarExerciciosRef
    on AutoDisposeFutureProviderRef<List<TreinoExercicio>> {
  /// The parameter `treinoId` of this provider.
  int get treinoId;
}

class _ListarExerciciosProviderElement
    extends AutoDisposeFutureProviderElement<List<TreinoExercicio>>
    with ListarExerciciosRef {
  _ListarExerciciosProviderElement(super.provider);

  @override
  int get treinoId => (origin as ListarExerciciosProvider).treinoId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
