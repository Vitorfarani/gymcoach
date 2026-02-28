// app_strings.dart
//
// Centraliza todos os textos exibidos ao usuário no app GymCoach.
//
// REGRA: nenhuma string visível ao usuário deve existir fora deste arquivo.
// Se precisar de uma string nova, adicione aqui e importe nas telas.
//
// ORGANIZAÇÃO: por seção/feature, seguindo a ordem das telas do doc3.

// ignore_for_file: constant_identifier_names

class AppStrings {
  // Impede instanciação — esta classe é puramente um namespace de constantes.
  AppStrings._();

  // ===========================================================================
  // APP
  // ===========================================================================

  static const appNome = 'GymCoach';

  // ===========================================================================
  // AÇÕES COMUNS — botões e labels reutilizados em múltiplas telas
  // ===========================================================================

  static const salvar          = 'Salvar';
  static const cancelar        = 'Cancelar';
  static const confirmar       = 'Confirmar';
  static const excluir         = 'Excluir';
  static const editar          = 'Editar';
  static const tentarNovamente = 'Tentar novamente';
  static const voltar          = 'Voltar';
  static const sim             = 'Sim';
  static const nao             = 'Não';
  static const sairSemSalvar   = 'Sair sem salvar';
  static const carregando      = 'Carregando...';

  // ===========================================================================
  // DASHBOARD — tela "/"
  // ===========================================================================

  static const dashboardTitulo          = 'GymCoach';
  static const dashboardAlunosAtivos    = 'Alunos ativos';
  static const dashboardUltimosAcessados = 'Últimos acessados';
  static const dashboardNenhumAluno     = 'Nenhum aluno cadastrado ainda.';
  static const dashboardCadastrarPrimeiro = 'Cadastrar primeiro aluno';

  // ===========================================================================
  // ALUNOS
  // ===========================================================================

  static const alunosTitulo          = 'Alunos';
  static const novoAluno             = 'Novo Aluno';
  static const editarAluno           = 'Editar Aluno';
  static const deletarAluno          = 'Deletar Aluno';
  static const nenhumAlunoCadastrado = 'Nenhum aluno cadastrado.';

  // Busca — usado como hint do campo de pesquisa
  static const buscarAlunoHint = 'Buscar aluno por nome...';

  // Resultado vazio na busca — concatenar com o termo buscado:
  // '${AppStrings.nenhumAlunoEncontradoPara} "$termo"'
  static const nenhumAlunoEncontradoPara = 'Nenhum aluno encontrado para';

  // ===========================================================================
  // FORMULÁRIO DE ALUNO — campos (cadastro e edição usam o mesmo form)
  // ===========================================================================

  static const campoNome          = 'Nome';
  static const campoNomeHint      = 'Ex: João Silva';
  static const campoNomeObrig     = 'Nome *'; // asterisco indica obrigatório
  static const campoIdade         = 'Idade (anos)';
  static const campoIdadeHint     = 'Ex: 25';
  static const campoPeso          = 'Peso (kg)';
  static const campoPesoHint      = 'Ex: 80,5';
  static const campoAltura        = 'Altura (cm)';
  static const campoAlturaHint    = 'Ex: 175';
  static const campoObjetivo      = 'Objetivo';
  static const campoObjetivoHint  = 'Ex: Hipertrofia, emagrecimento...';
  static const campoObservacoes   = 'Observações';
  static const campoObservacoesHint = 'Anotações gerais sobre o aluno';

  // ===========================================================================
  // FOTO DO ALUNO
  // ===========================================================================

  static const fotoTirar       = 'Tirar foto';
  static const fotoGaleria     = 'Escolher da galeria';
  static const fotoTrocar      = 'Trocar foto';
  static const fotoRemover     = 'Remover foto';
  static const fotoOpcoes      = 'Foto do aluno';

  // ===========================================================================
  // PERFIL DO ALUNO — tela "/alunos/:alunoId"
  // ===========================================================================

  static const perfilTreinos           = 'Treinos';
  static const perfilHistoricoSessoes  = 'Histórico de Sessões';
  static const perfilSemDados          = 'Não informado';

  // ===========================================================================
  // TREINOS
  // ===========================================================================

  static const treinosTitulo          = 'Treinos';
  static const novoTreino             = 'Novo Treino';
  static const editarTreino           = 'Editar Treino';
  static const deletarTreino          = 'Deletar Treino';
  static const nenhumTreinoCadastrado = 'Nenhum treino cadastrado.';
  static const iniciarSessao          = 'Iniciar Sessão';

  // Campos do treino
  static const campoNomeTreino      = 'Nome do treino *';
  static const campoNomeTreinoHint  = 'Ex: Treino A, Peito e Tríceps...';
  static const campoDescricao       = 'Descrição';
  static const campoDescricaoHint   = 'Descrição opcional do treino';

  // Contagem de exercícios no card — usar com interpolação:
  // '${count} ${AppStrings.exercicioSufixo(count)}'
  static String exercicioSufixo(int count) =>
      count == 1 ? 'exercício' : 'exercícios';

  // ===========================================================================
  // EXERCÍCIOS
  // ===========================================================================

  static const adicionarExercicio      = 'Adicionar Exercício';
  static const nenhumExercicioCadastrado = 'Nenhum exercício cadastrado.';

  // Campos do exercício
  static const campoNomeExercicio      = 'Nome do exercício *';
  static const campoNomeExercicioHint  = 'Ex: Supino Reto, Agachamento...';
  static const campoSeries             = 'Séries *';
  static const campoSeriesHint         = 'Ex: 4';
  static const campoRepeticoes         = 'Repetições';
  static const campoRepeticoesHint     = 'Ex: 10-12, até a falha...';
  static const campoCarga              = 'Carga';
  static const campoCargaHint          = 'Ex: 80kg, peso corporal...';
  static const campoObservacao         = 'Observação';
  static const campoObservacaoHint     = 'Anotações sobre o exercício';

  // Botões de reordenação
  static const subirExercicio  = 'Subir';
  static const descerExercicio = 'Descer';

  // ===========================================================================
  // SESSÕES
  // ===========================================================================

  static const historicoTitulo        = 'Histórico de Sessões';
  static const finalizarSessao        = 'Finalizar Sessão';
  static const cancelarSessao         = 'Cancelar Sessão';
  static const nenhumaSessao          = 'Nenhuma sessão registrada ainda.';
  static const treinoRemovido         = 'Treino removido';

  // Campos de registro de execução
  static const campoCargaRealizada       = 'Carga realizada';
  static const campoCargaRealizadaHint   = 'Ex: 80kg, elástico médio...';
  static const campoRepRealizadas        = 'Repetições realizadas';
  static const campoRepRealizadasHint    = 'Ex: 10, até a falha...';
  static const campoObsSessao            = 'Observação';
  static const campoObsSessaoHint        = 'Como foi esse exercício?';

  // ===========================================================================
  // DIÁLOGOS DE CONFIRMAÇÃO
  // ===========================================================================

  static const confirmacaoTitulo          = 'Tem certeza?';
  static const confirmacaoIrreversivel    = 'Esta ação não pode ser desfeita.';

  static const confirmacaoDeletarAluno    =
      'O aluno e todos os seus dados (treinos, exercícios e sessões) '
      'serão deletados permanentemente.';

  static const confirmacaoDeletarAluno2   =
      'Isso é irreversível. Confirmar exclusão?';

  static const confirmacaoDeletarTreino   =
      'O treino e todos os seus exercícios serão deletados. '
      'O histórico de sessões é preservado.';

  static const confirmacaoDeletarExercicio =
      'O exercício será removido do treino.';

  static const confirmacaoCancelarSessao  =
      'Todos os registros desta sessão serão perdidos.';

  static const confirmacaoDeletarSessao   =
      'Esta sessão e seus registros serão apagados.';

  // ===========================================================================
  // ALTERAÇÕES NÃO SALVAS — dialog ao tentar sair com form preenchido
  // ===========================================================================

  static const alteracoesNaoSalvasTitulo =
      'Alterações não salvas';

  static const alteracoesNaoSalvasMensagem =
      'Você tem alterações não salvas. Deseja sair sem salvar?';

  // ===========================================================================
  // SNACKBARS DE SUCESSO
  // ===========================================================================

  static const alunoSalvo        = 'Aluno salvo com sucesso.';
  static const alunoDeletado     = 'Aluno deletado.';
  static const treinoSalvo       = 'Treino salvo com sucesso.';
  static const treinoDeletado    = 'Treino deletado.';
  static const exercicioSalvo    = 'Exercício salvo com sucesso.';
  static const exercicioDeletado = 'Exercício removido.';
  static const sessaoFinalizada  = 'Sessão finalizada.';
  static const sessaoCancelada   = 'Sessão cancelada.';
  static const sessaoDeletada    = 'Sessão deletada.';
  static const fotoSalva         = 'Foto atualizada.';
  static const fotoRemovida      = 'Foto removida.';

  // ===========================================================================
  // MENSAGENS DE ERRO — apresentadas na UI
  // ===========================================================================

  static const erroGenerico         = 'Erro inesperado. Tente novamente.';
  static const erroBancoDados       = 'Erro ao acessar os dados. Tente novamente.';
  static const erroImagemGrande     = 'A imagem não pode ser maior que 5 MB.';
  static const erroProcessarImagem  = 'Erro ao processar a imagem. Tente outra foto.';
}
