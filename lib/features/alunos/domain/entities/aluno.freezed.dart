// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aluno.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Aluno {
  // ── Identificação ──────────────────────────────────────────────────────
  /// Chave primária gerada pelo banco (AUTOINCREMENT).
  ///
  /// Nullable porque o aluno ainda não tem id antes de ser salvo no banco.
  /// Após salvar e buscar do banco, sempre será não-nulo.
  int? get id =>
      throw _privateConstructorUsedError; // ── Campos obrigatórios ────────────────────────────────────────────────
  /// Nome completo do aluno.
  ///
  /// Único campo obrigatório no cadastro.
  /// Validações: mínimo 2, máximo 60 caracteres (doc1).
  String get nome =>
      throw _privateConstructorUsedError; // ── Campos opcionais — perfil ──────────────────────────────────────────
  /// Caminho absoluto da foto no dispositivo.
  ///
  /// Null quando o aluno não tem foto cadastrada.
  /// Exemplo: /data/user/0/com.gymcoach/files/fotos/aluno_42.jpg
  String? get fotoPath => throw _privateConstructorUsedError;

  /// Idade em anos inteiros.
  ///
  /// Range permitido: 10 a 99 (doc1).
  int? get idade => throw _privateConstructorUsedError;

  /// Peso em quilogramas.
  ///
  /// Range permitido: 30.0 a 250.0 (doc1).
  /// Armazenado como REAL no banco — viabiliza cálculo de IMC no futuro.
  double? get peso => throw _privateConstructorUsedError;

  /// Altura em centímetros.
  ///
  /// Range permitido: 100.0 a 250.0 (doc1).
  double? get altura => throw _privateConstructorUsedError;

  /// Objetivo do aluno (hipertrofia, emagrecimento, condicionamento...).
  ///
  /// Texto livre — sem lista fechada no MVP.
  String? get objetivo => throw _privateConstructorUsedError;

  /// Observações gerais sobre o aluno.
  ///
  /// Campo livre para o professor anotar o que quiser.
  String? get observacoes =>
      throw _privateConstructorUsedError; // ── Datas ─────────────────────────────────────────────────────────────
  /// Data em que o aluno foi cadastrado.
  ///
  /// Setada automaticamente pelo banco no INSERT (DEFAULT date('now')).
  /// Não é editável pelo professor.
  DateTime get dataInicio => throw _privateConstructorUsedError;

  /// Data da última avaliação física realizada com o aluno.
  ///
  /// Null quando nunca foi avaliado.
  DateTime? get dataUltimaAvaliacao => throw _privateConstructorUsedError;

  /// Timestamp do último acesso ao perfil deste aluno.
  ///
  /// Atualizado pelo use case AtualizarUltimoAcesso sempre que o professor
  /// abre o perfil. Usado no dashboard para mostrar os 5 últimos acessados.
  DateTime get ultimoAcesso =>
      throw _privateConstructorUsedError; // ── Status ────────────────────────────────────────────────────────────
  /// Indica se o aluno está ativo.
  ///
  /// `true` = ativo (aparece na lista).
  /// `false` = desativado (preservado no histórico, oculto na UI).
  ///
  /// Diferente de [deletadoEm]: um aluno pode ser desativado sem ser
  /// deletado — o histórico é mantido.
  bool get ativo =>
      throw _privateConstructorUsedError; // ── Metadados de auditoria ────────────────────────────────────────────
  /// Timestamp de criação do registro no banco.
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Timestamp da última atualização do registro no banco.
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Timestamp de quando o aluno foi deletado (soft delete).
  ///
  /// Null = aluno ativo (não deletado).
  /// Não-null = aluno deletado — some da UI mas permanece no banco.
  ///
  /// A deleção é permanente no MVP: uma vez deletado, não há tela de
  /// recuperação. O campo existe para auditoria e para o cascade do banco
  /// funcionar de forma rastreável.
  DateTime? get deletadoEm => throw _privateConstructorUsedError;

  /// Create a copy of Aluno
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlunoCopyWith<Aluno> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlunoCopyWith<$Res> {
  factory $AlunoCopyWith(Aluno value, $Res Function(Aluno) then) =
      _$AlunoCopyWithImpl<$Res, Aluno>;
  @useResult
  $Res call({
    int? id,
    String nome,
    String? fotoPath,
    int? idade,
    double? peso,
    double? altura,
    String? objetivo,
    String? observacoes,
    DateTime dataInicio,
    DateTime? dataUltimaAvaliacao,
    DateTime ultimoAcesso,
    bool ativo,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletadoEm,
  });
}

/// @nodoc
class _$AlunoCopyWithImpl<$Res, $Val extends Aluno>
    implements $AlunoCopyWith<$Res> {
  _$AlunoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Aluno
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nome = null,
    Object? fotoPath = freezed,
    Object? idade = freezed,
    Object? peso = freezed,
    Object? altura = freezed,
    Object? objetivo = freezed,
    Object? observacoes = freezed,
    Object? dataInicio = null,
    Object? dataUltimaAvaliacao = freezed,
    Object? ultimoAcesso = null,
    Object? ativo = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletadoEm = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            nome: null == nome
                ? _value.nome
                : nome // ignore: cast_nullable_to_non_nullable
                      as String,
            fotoPath: freezed == fotoPath
                ? _value.fotoPath
                : fotoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            idade: freezed == idade
                ? _value.idade
                : idade // ignore: cast_nullable_to_non_nullable
                      as int?,
            peso: freezed == peso
                ? _value.peso
                : peso // ignore: cast_nullable_to_non_nullable
                      as double?,
            altura: freezed == altura
                ? _value.altura
                : altura // ignore: cast_nullable_to_non_nullable
                      as double?,
            objetivo: freezed == objetivo
                ? _value.objetivo
                : objetivo // ignore: cast_nullable_to_non_nullable
                      as String?,
            observacoes: freezed == observacoes
                ? _value.observacoes
                : observacoes // ignore: cast_nullable_to_non_nullable
                      as String?,
            dataInicio: null == dataInicio
                ? _value.dataInicio
                : dataInicio // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dataUltimaAvaliacao: freezed == dataUltimaAvaliacao
                ? _value.dataUltimaAvaliacao
                : dataUltimaAvaliacao // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            ultimoAcesso: null == ultimoAcesso
                ? _value.ultimoAcesso
                : ultimoAcesso // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ativo: null == ativo
                ? _value.ativo
                : ativo // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            deletadoEm: freezed == deletadoEm
                ? _value.deletadoEm
                : deletadoEm // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlunoImplCopyWith<$Res> implements $AlunoCopyWith<$Res> {
  factory _$$AlunoImplCopyWith(
    _$AlunoImpl value,
    $Res Function(_$AlunoImpl) then,
  ) = __$$AlunoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String nome,
    String? fotoPath,
    int? idade,
    double? peso,
    double? altura,
    String? objetivo,
    String? observacoes,
    DateTime dataInicio,
    DateTime? dataUltimaAvaliacao,
    DateTime ultimoAcesso,
    bool ativo,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? deletadoEm,
  });
}

/// @nodoc
class __$$AlunoImplCopyWithImpl<$Res>
    extends _$AlunoCopyWithImpl<$Res, _$AlunoImpl>
    implements _$$AlunoImplCopyWith<$Res> {
  __$$AlunoImplCopyWithImpl(
    _$AlunoImpl _value,
    $Res Function(_$AlunoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Aluno
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nome = null,
    Object? fotoPath = freezed,
    Object? idade = freezed,
    Object? peso = freezed,
    Object? altura = freezed,
    Object? objetivo = freezed,
    Object? observacoes = freezed,
    Object? dataInicio = null,
    Object? dataUltimaAvaliacao = freezed,
    Object? ultimoAcesso = null,
    Object? ativo = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletadoEm = freezed,
  }) {
    return _then(
      _$AlunoImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        nome: null == nome
            ? _value.nome
            : nome // ignore: cast_nullable_to_non_nullable
                  as String,
        fotoPath: freezed == fotoPath
            ? _value.fotoPath
            : fotoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        idade: freezed == idade
            ? _value.idade
            : idade // ignore: cast_nullable_to_non_nullable
                  as int?,
        peso: freezed == peso
            ? _value.peso
            : peso // ignore: cast_nullable_to_non_nullable
                  as double?,
        altura: freezed == altura
            ? _value.altura
            : altura // ignore: cast_nullable_to_non_nullable
                  as double?,
        objetivo: freezed == objetivo
            ? _value.objetivo
            : objetivo // ignore: cast_nullable_to_non_nullable
                  as String?,
        observacoes: freezed == observacoes
            ? _value.observacoes
            : observacoes // ignore: cast_nullable_to_non_nullable
                  as String?,
        dataInicio: null == dataInicio
            ? _value.dataInicio
            : dataInicio // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dataUltimaAvaliacao: freezed == dataUltimaAvaliacao
            ? _value.dataUltimaAvaliacao
            : dataUltimaAvaliacao // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        ultimoAcesso: null == ultimoAcesso
            ? _value.ultimoAcesso
            : ultimoAcesso // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ativo: null == ativo
            ? _value.ativo
            : ativo // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        deletadoEm: freezed == deletadoEm
            ? _value.deletadoEm
            : deletadoEm // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$AlunoImpl implements _Aluno {
  const _$AlunoImpl({
    this.id,
    required this.nome,
    this.fotoPath,
    this.idade,
    this.peso,
    this.altura,
    this.objetivo,
    this.observacoes,
    required this.dataInicio,
    this.dataUltimaAvaliacao,
    required this.ultimoAcesso,
    required this.ativo,
    required this.createdAt,
    required this.updatedAt,
    this.deletadoEm,
  });

  // ── Identificação ──────────────────────────────────────────────────────
  /// Chave primária gerada pelo banco (AUTOINCREMENT).
  ///
  /// Nullable porque o aluno ainda não tem id antes de ser salvo no banco.
  /// Após salvar e buscar do banco, sempre será não-nulo.
  @override
  final int? id;
  // ── Campos obrigatórios ────────────────────────────────────────────────
  /// Nome completo do aluno.
  ///
  /// Único campo obrigatório no cadastro.
  /// Validações: mínimo 2, máximo 60 caracteres (doc1).
  @override
  final String nome;
  // ── Campos opcionais — perfil ──────────────────────────────────────────
  /// Caminho absoluto da foto no dispositivo.
  ///
  /// Null quando o aluno não tem foto cadastrada.
  /// Exemplo: /data/user/0/com.gymcoach/files/fotos/aluno_42.jpg
  @override
  final String? fotoPath;

  /// Idade em anos inteiros.
  ///
  /// Range permitido: 10 a 99 (doc1).
  @override
  final int? idade;

  /// Peso em quilogramas.
  ///
  /// Range permitido: 30.0 a 250.0 (doc1).
  /// Armazenado como REAL no banco — viabiliza cálculo de IMC no futuro.
  @override
  final double? peso;

  /// Altura em centímetros.
  ///
  /// Range permitido: 100.0 a 250.0 (doc1).
  @override
  final double? altura;

  /// Objetivo do aluno (hipertrofia, emagrecimento, condicionamento...).
  ///
  /// Texto livre — sem lista fechada no MVP.
  @override
  final String? objetivo;

  /// Observações gerais sobre o aluno.
  ///
  /// Campo livre para o professor anotar o que quiser.
  @override
  final String? observacoes;
  // ── Datas ─────────────────────────────────────────────────────────────
  /// Data em que o aluno foi cadastrado.
  ///
  /// Setada automaticamente pelo banco no INSERT (DEFAULT date('now')).
  /// Não é editável pelo professor.
  @override
  final DateTime dataInicio;

  /// Data da última avaliação física realizada com o aluno.
  ///
  /// Null quando nunca foi avaliado.
  @override
  final DateTime? dataUltimaAvaliacao;

  /// Timestamp do último acesso ao perfil deste aluno.
  ///
  /// Atualizado pelo use case AtualizarUltimoAcesso sempre que o professor
  /// abre o perfil. Usado no dashboard para mostrar os 5 últimos acessados.
  @override
  final DateTime ultimoAcesso;
  // ── Status ────────────────────────────────────────────────────────────
  /// Indica se o aluno está ativo.
  ///
  /// `true` = ativo (aparece na lista).
  /// `false` = desativado (preservado no histórico, oculto na UI).
  ///
  /// Diferente de [deletadoEm]: um aluno pode ser desativado sem ser
  /// deletado — o histórico é mantido.
  @override
  final bool ativo;
  // ── Metadados de auditoria ────────────────────────────────────────────
  /// Timestamp de criação do registro no banco.
  @override
  final DateTime createdAt;

  /// Timestamp da última atualização do registro no banco.
  @override
  final DateTime updatedAt;

  /// Timestamp de quando o aluno foi deletado (soft delete).
  ///
  /// Null = aluno ativo (não deletado).
  /// Não-null = aluno deletado — some da UI mas permanece no banco.
  ///
  /// A deleção é permanente no MVP: uma vez deletado, não há tela de
  /// recuperação. O campo existe para auditoria e para o cascade do banco
  /// funcionar de forma rastreável.
  @override
  final DateTime? deletadoEm;

  @override
  String toString() {
    return 'Aluno(id: $id, nome: $nome, fotoPath: $fotoPath, idade: $idade, peso: $peso, altura: $altura, objetivo: $objetivo, observacoes: $observacoes, dataInicio: $dataInicio, dataUltimaAvaliacao: $dataUltimaAvaliacao, ultimoAcesso: $ultimoAcesso, ativo: $ativo, createdAt: $createdAt, updatedAt: $updatedAt, deletadoEm: $deletadoEm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlunoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nome, nome) || other.nome == nome) &&
            (identical(other.fotoPath, fotoPath) ||
                other.fotoPath == fotoPath) &&
            (identical(other.idade, idade) || other.idade == idade) &&
            (identical(other.peso, peso) || other.peso == peso) &&
            (identical(other.altura, altura) || other.altura == altura) &&
            (identical(other.objetivo, objetivo) ||
                other.objetivo == objetivo) &&
            (identical(other.observacoes, observacoes) ||
                other.observacoes == observacoes) &&
            (identical(other.dataInicio, dataInicio) ||
                other.dataInicio == dataInicio) &&
            (identical(other.dataUltimaAvaliacao, dataUltimaAvaliacao) ||
                other.dataUltimaAvaliacao == dataUltimaAvaliacao) &&
            (identical(other.ultimoAcesso, ultimoAcesso) ||
                other.ultimoAcesso == ultimoAcesso) &&
            (identical(other.ativo, ativo) || other.ativo == ativo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletadoEm, deletadoEm) ||
                other.deletadoEm == deletadoEm));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nome,
    fotoPath,
    idade,
    peso,
    altura,
    objetivo,
    observacoes,
    dataInicio,
    dataUltimaAvaliacao,
    ultimoAcesso,
    ativo,
    createdAt,
    updatedAt,
    deletadoEm,
  );

  /// Create a copy of Aluno
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlunoImplCopyWith<_$AlunoImpl> get copyWith =>
      __$$AlunoImplCopyWithImpl<_$AlunoImpl>(this, _$identity);
}

abstract class _Aluno implements Aluno {
  const factory _Aluno({
    final int? id,
    required final String nome,
    final String? fotoPath,
    final int? idade,
    final double? peso,
    final double? altura,
    final String? objetivo,
    final String? observacoes,
    required final DateTime dataInicio,
    final DateTime? dataUltimaAvaliacao,
    required final DateTime ultimoAcesso,
    required final bool ativo,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? deletadoEm,
  }) = _$AlunoImpl;

  // ── Identificação ──────────────────────────────────────────────────────
  /// Chave primária gerada pelo banco (AUTOINCREMENT).
  ///
  /// Nullable porque o aluno ainda não tem id antes de ser salvo no banco.
  /// Após salvar e buscar do banco, sempre será não-nulo.
  @override
  int? get id; // ── Campos obrigatórios ────────────────────────────────────────────────
  /// Nome completo do aluno.
  ///
  /// Único campo obrigatório no cadastro.
  /// Validações: mínimo 2, máximo 60 caracteres (doc1).
  @override
  String get nome; // ── Campos opcionais — perfil ──────────────────────────────────────────
  /// Caminho absoluto da foto no dispositivo.
  ///
  /// Null quando o aluno não tem foto cadastrada.
  /// Exemplo: /data/user/0/com.gymcoach/files/fotos/aluno_42.jpg
  @override
  String? get fotoPath;

  /// Idade em anos inteiros.
  ///
  /// Range permitido: 10 a 99 (doc1).
  @override
  int? get idade;

  /// Peso em quilogramas.
  ///
  /// Range permitido: 30.0 a 250.0 (doc1).
  /// Armazenado como REAL no banco — viabiliza cálculo de IMC no futuro.
  @override
  double? get peso;

  /// Altura em centímetros.
  ///
  /// Range permitido: 100.0 a 250.0 (doc1).
  @override
  double? get altura;

  /// Objetivo do aluno (hipertrofia, emagrecimento, condicionamento...).
  ///
  /// Texto livre — sem lista fechada no MVP.
  @override
  String? get objetivo;

  /// Observações gerais sobre o aluno.
  ///
  /// Campo livre para o professor anotar o que quiser.
  @override
  String? get observacoes; // ── Datas ─────────────────────────────────────────────────────────────
  /// Data em que o aluno foi cadastrado.
  ///
  /// Setada automaticamente pelo banco no INSERT (DEFAULT date('now')).
  /// Não é editável pelo professor.
  @override
  DateTime get dataInicio;

  /// Data da última avaliação física realizada com o aluno.
  ///
  /// Null quando nunca foi avaliado.
  @override
  DateTime? get dataUltimaAvaliacao;

  /// Timestamp do último acesso ao perfil deste aluno.
  ///
  /// Atualizado pelo use case AtualizarUltimoAcesso sempre que o professor
  /// abre o perfil. Usado no dashboard para mostrar os 5 últimos acessados.
  @override
  DateTime get ultimoAcesso; // ── Status ────────────────────────────────────────────────────────────
  /// Indica se o aluno está ativo.
  ///
  /// `true` = ativo (aparece na lista).
  /// `false` = desativado (preservado no histórico, oculto na UI).
  ///
  /// Diferente de [deletadoEm]: um aluno pode ser desativado sem ser
  /// deletado — o histórico é mantido.
  @override
  bool get ativo; // ── Metadados de auditoria ────────────────────────────────────────────
  /// Timestamp de criação do registro no banco.
  @override
  DateTime get createdAt;

  /// Timestamp da última atualização do registro no banco.
  @override
  DateTime get updatedAt;

  /// Timestamp de quando o aluno foi deletado (soft delete).
  ///
  /// Null = aluno ativo (não deletado).
  /// Não-null = aluno deletado — some da UI mas permanece no banco.
  ///
  /// A deleção é permanente no MVP: uma vez deletado, não há tela de
  /// recuperação. O campo existe para auditoria e para o cascade do banco
  /// funcionar de forma rastreável.
  @override
  DateTime? get deletadoEm;

  /// Create a copy of Aluno
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlunoImplCopyWith<_$AlunoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
