// aluno.dart
//
// Entity do domínio que representa um aluno cadastrado pelo professor.
//
// REGRAS IMPORTANTES:
// - Este arquivo não importa sqflite, flutter, riverpod nem qualquer framework
// - É a fonte da verdade sobre o que um Aluno é no sistema
// - Todas as outras camadas (data, presentation) dependem daqui, nunca o contrário
//
// FREEZED:
// Este arquivo usa geração de código. Sempre que alterar os campos, rode:
//   flutter pub run build_runner build --delete-conflicting-outputs
// O arquivo gerado `aluno.freezed.dart` NÃO deve ser editado manualmente.

import 'package:freezed_annotation/freezed_annotation.dart';

// Diz ao Dart que o código gerado estará em aluno.freezed.dart
part 'aluno.freezed.dart';

@freezed

/// Representa um aluno cadastrado no app.
///
/// Imutável: uma vez criado, os campos não mudam. Para "modificar" um aluno,
/// crie uma cópia com [copyWith]:
///
/// ```dart
/// final alunoAtualizado = aluno.copyWith(nome: 'Novo Nome');
/// ```
class Aluno with _$Aluno {
  const factory Aluno({
    // ── Identificação ──────────────────────────────────────────────────────

    /// Chave primária gerada pelo banco (AUTOINCREMENT).
    ///
    /// Nullable porque o aluno ainda não tem id antes de ser salvo no banco.
    /// Após salvar e buscar do banco, sempre será não-nulo.
    int? id,

    // ── Campos obrigatórios ────────────────────────────────────────────────

    /// Nome completo do aluno.
    ///
    /// Único campo obrigatório no cadastro.
    /// Validações: mínimo 2, máximo 60 caracteres (doc1).
    required String nome,

    // ── Campos opcionais — perfil ──────────────────────────────────────────

    /// Caminho absoluto da foto no dispositivo.
    ///
    /// Null quando o aluno não tem foto cadastrada.
    /// Exemplo: /data/user/0/com.gymcoach/files/fotos/aluno_42.jpg
    String? fotoPath,

    /// Idade em anos inteiros.
    ///
    /// Range permitido: 10 a 99 (doc1).
    int? idade,

    /// Peso em quilogramas.
    ///
    /// Range permitido: 30.0 a 250.0 (doc1).
    /// Armazenado como REAL no banco — viabiliza cálculo de IMC no futuro.
    double? peso,

    /// Altura em centímetros.
    ///
    /// Range permitido: 100.0 a 250.0 (doc1).
    double? altura,

    /// Objetivo do aluno (hipertrofia, emagrecimento, condicionamento...).
    ///
    /// Texto livre — sem lista fechada no MVP.
    String? objetivo,

    /// Observações gerais sobre o aluno.
    ///
    /// Campo livre para o professor anotar o que quiser.
    String? observacoes,

    // ── Datas ─────────────────────────────────────────────────────────────

    /// Data em que o aluno foi cadastrado.
    ///
    /// Setada automaticamente pelo banco no INSERT (DEFAULT date('now')).
    /// Não é editável pelo professor.
    required DateTime dataInicio,

    /// Data da última avaliação física realizada com o aluno.
    ///
    /// Null quando nunca foi avaliado.
    DateTime? dataUltimaAvaliacao,

    /// Timestamp do último acesso ao perfil deste aluno.
    ///
    /// Atualizado pelo use case AtualizarUltimoAcesso sempre que o professor
    /// abre o perfil. Usado no dashboard para mostrar os 5 últimos acessados.
    required DateTime ultimoAcesso,

    // ── Status ────────────────────────────────────────────────────────────

    /// Indica se o aluno está ativo.
    ///
    /// `true` = ativo (aparece na lista).
    /// `false` = desativado (preservado no histórico, oculto na UI).
    ///
    /// Diferente de [deletadoEm]: um aluno pode ser desativado sem ser
    /// deletado — o histórico é mantido.
    required bool ativo,

    // ── Metadados de auditoria ────────────────────────────────────────────

    /// Timestamp de criação do registro no banco.
    required DateTime createdAt,

    /// Timestamp da última atualização do registro no banco.
    required DateTime updatedAt,

    /// Timestamp de quando o aluno foi deletado (soft delete).
    ///
    /// Null = aluno ativo (não deletado).
    /// Não-null = aluno deletado — some da UI mas permanece no banco.
    ///
    /// A deleção é permanente no MVP: uma vez deletado, não há tela de
    /// recuperação. O campo existe para auditoria e para o cascade do banco
    /// funcionar de forma rastreável.
    DateTime? deletadoEm,
  }) = _Aluno;
}
