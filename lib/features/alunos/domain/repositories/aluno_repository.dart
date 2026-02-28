// aluno_repository.dart
//
// Contrato (interface) do repositório de alunos.
//
// PAPEL NA ARQUITETURA:
// Este arquivo fica em `domain/` e define O QUÊ o repositório deve fazer,
// sem dizer COMO. A implementação real fica em:
//   data/repositories/aluno_repository_impl.dart
//
// POR QUE ABSTRACT CLASS AQUI?
// - Os use cases dependem desta abstract class, não da implementação
// - Isso permite trocar sqflite por outro banco no futuro sem tocar nos use cases
// - Facilita testes: basta criar um FakeAlunoRepository que implemente este contrato
//
// EXCEÇÕES:
// Os métodos lançam as exceções definidas em core/errors/exceptions.dart.
// Não há retorno de Failure aqui — exceptions são lançadas e capturadas
// pelos providers na camada de apresentação.

import 'dart:io' show File;

import '../entities/aluno.dart';

abstract class AlunoRepository {
  // ── Escrita ───────────────────────────────────────────────────────────────

  /// Persiste um novo aluno no banco e retorna o aluno com o id gerado.
  ///
  /// O [aluno] passado deve ter [Aluno.id] == null.
  /// O aluno retornado terá o [Aluno.id] preenchido pelo banco.
  ///
  /// Lança:
  /// - [NomeObrigatorioException] — nome vazio
  /// - [NomeInvalidoException] — nome fora do range 2–60 chars
  /// - [IdadeInvalidaException] — idade fora do range 10–99
  /// - [PesoInvalidoException] — peso fora do range 30–250
  /// - [AlturaInvalidaException] — altura fora do range 100–250
  /// - [DatabaseException] — erro ao persistir
  Future<Aluno> criar(Aluno aluno);

  /// Atualiza os dados de um aluno existente e retorna o aluno atualizado.
  ///
  /// O [aluno] deve ter [Aluno.id] preenchido.
  ///
  /// Lança:
  /// - Mesmas de [criar]
  /// - [AlunoNaoEncontradoException] — id não existe no banco
  Future<Aluno> editar(Aluno aluno);

  /// Realiza soft delete: preenche `deletado_em` com o timestamp atual.
  ///
  /// O aluno some da UI mas permanece no banco para auditoria.
  /// O cascade do banco apaga treinos, exercícios, sessões e registros.
  ///
  /// Lança:
  /// - [AlunoNaoEncontradoException]
  /// - [DatabaseException]
  Future<void> deletar(int id);

  /// Atualiza o campo `ultimo_acesso` para o timestamp atual.
  ///
  /// Deve ser chamado sempre que o professor abrir o perfil de um aluno.
  /// Alimenta a lista "últimos acessados" do dashboard.
  ///
  /// Lança:
  /// - [AlunoNaoEncontradoException]
  /// - [DatabaseException]
  Future<void> atualizarUltimoAcesso(int id);

  // ── Leitura ───────────────────────────────────────────────────────────────

  /// Busca um aluno pelo id.
  ///
  /// Lança:
  /// - [AlunoNaoEncontradoException] — id não existe ou aluno foi deletado
  /// - [DatabaseException]
  Future<Aluno> buscarPorId(int id);

  /// Lista todos os alunos ativos (`deletado_em IS NULL`), ordenados por nome.
  ///
  /// Se [query] for informado, filtra por nome (busca parcial, case-insensitive).
  /// Retorna lista vazia se não houver alunos — não lança exceção.
  ///
  /// Lança:
  /// - [DatabaseException]
  Future<List<Aluno>> listar({String? query});

  /// Retorna os últimos [limite] alunos acessados, ordenados por
  /// `ultimo_acesso DESC`.
  ///
  /// Usado pelo dashboard. Normalmente [limite] = 5.
  ///
  /// Lança:
  /// - [DatabaseException]
  Future<List<Aluno>> listarUltimosAcessados(int limite);

  /// Retorna o total de alunos ativos (`deletado_em IS NULL AND ativo = 1`).
  ///
  /// Usado pelo dashboard para exibir o contador em destaque.
  ///
  /// Lança:
  /// - [DatabaseException]
  Future<int> contarAtivos();

  // ── Foto ──────────────────────────────────────────────────────────────────

  /// Processa e salva a foto do aluno.
  ///
  /// Comportamento:
  /// 1. Valida que [imagemOriginal] tem menos de 5MB
  /// 2. Redimensiona para 800×800px e comprime
  /// 3. Salva no diretório do app
  /// 4. Atualiza `foto_path` no banco
  ///
  /// Retorna o caminho absoluto do arquivo salvo.
  ///
  /// Lança:
  /// - [AlunoNaoEncontradoException]
  /// - [ImagemMuitoGrandeException] — arquivo > 5MB
  /// - [ErroAoProcessarImagemException] — falha no processamento
  /// - [DatabaseException]
  Future<String> salvarFoto(int id, File imagemOriginal);

  /// Remove a foto do aluno.
  ///
  /// Comportamento:
  /// 1. Deleta o arquivo físico do dispositivo
  /// 2. Limpa `foto_path` no banco (seta para NULL)
  ///
  /// Lança:
  /// - [AlunoNaoEncontradoException]
  /// - [DatabaseException]
  Future<void> removerFoto(int id);
}
