// app_dimensions.dart
//
// Constantes de espaçamento, tamanho e layout do GymCoach.
//
// POR QUE EXISTEM: elimina magic numbers espalhados pelo código.
// Em vez de `EdgeInsets.all(16)` em 30 arquivos diferentes, usamos
// `EdgeInsets.all(AppDimensions.paddingM)` — um nome com significado.
//
// ESCALA BASE: múltiplos de 4dp (padrão Material Design).
//   XS=4, S=8, M=16, L=24, XL=32, XXL=48

class AppDimensions {
  // Impede instanciação — apenas namespace de constantes.
  AppDimensions._();

  // ===========================================================================
  // PADDING E MARGIN
  // ===========================================================================

  /// 4dp — espaço mínimo, ícone + label, gap interno pequeno.
  static const paddingXS = 4.0;

  /// 8dp — espaço pequeno, gap entre elementos relacionados.
  static const paddingS = 8.0;

  /// 16dp — espaço padrão, padding interno de cards e telas.
  static const paddingM = 16.0;

  /// 24dp — espaço médio-grande, separação de seções.
  static const paddingL = 24.0;

  /// 32dp — espaço grande, margens externas e seções principais.
  static const paddingXL = 32.0;

  /// 48dp — espaço extra grande, topo de telas de destaque.
  static const paddingXXL = 48.0;

  // ===========================================================================
  // BORDER RADIUS
  // ===========================================================================

  /// 4dp — arredondamento sutil, chips pequenos.
  static const radiusS = 4.0;

  /// 8dp — arredondamento padrão, cards e campos.
  static const radiusM = 8.0;

  /// 12dp — arredondamento médio, bottom sheets.
  static const radiusL = 12.0;

  /// 16dp — arredondamento generoso, cards de destaque.
  static const radiusXL = 16.0;

  /// 100dp — arredondamento total, avatares e FAB.
  static const radiusCircle = 100.0;

  // ===========================================================================
  // ÍCONES
  // ===========================================================================

  /// 16dp — ícone pequeno, dentro de chips ou badges.
  static const iconS = 16.0;

  /// 24dp — ícone padrão, AppBar e botões.
  static const iconM = 24.0;

  /// 32dp — ícone grande, estados vazios (empty state).
  static const iconL = 32.0;

  /// 64dp — ícone de destaque, ilustrações de empty state.
  static const iconXL = 64.0;

  // ===========================================================================
  // FOTO DO ALUNO
  // ===========================================================================

  /// Tamanho do avatar nos cards de lista.
  static const avatarS = 44.0;

  /// Tamanho do avatar médio, usado em cards maiores.
  static const avatarM = 60.0;

  /// Tamanho do avatar na tela de perfil.
  static const avatarL = 100.0;

  /// Dimensão máxima para processamento de imagem (800x800px).
  /// Definido no doc1: fotos são redimensionadas antes de salvar.
  static const fotoMaxPixels = 800.0;

  // ===========================================================================
  // CARDS
  // ===========================================================================

  /// Elevação dos cards (zero = flat, sem sombra — estilo dark theme).
  static const cardElevation = 0.0;

  /// Espaço entre cards numa lista.
  static const cardGap = 8.0;

  // ===========================================================================
  // APPBAR
  // ===========================================================================

  static const appBarHeight = 56.0;

  // ===========================================================================
  // BOTÕES
  // ===========================================================================

  /// Altura mínima de botões primários e secundários.
  /// 52dp garante área de toque segura com mãos suadas em academia
  /// — recomendação Material Design para ambientes físicos.
  static const buttonHeight = 52.0;

  /// Border radius dos botões.
  static const buttonRadius = 8.0;

  // ===========================================================================
  // CAMPOS DE TEXTO (TextField / TextFormField)
  // ===========================================================================

  /// Border radius dos campos de input.
  static const inputRadius = 8.0;

  // ===========================================================================
  // DASHBOARD
  // ===========================================================================

  /// Tamanho da fonte do contador de alunos ativos (número grande em destaque).
  static const dashboardContadorFontSize = 64.0;

  // ===========================================================================
  // LISTA
  // ===========================================================================

  /// Altura mínima de um item de lista.
  static const listItemHeight = 72.0;

  // ===========================================================================
  // TIPOGRAFIA — tamanhos de fonte
  // ===========================================================================

  // Usados diretamente em TextStyle quando a escala padrão do tema
  // não for suficiente (ex: o número grande do dashboard).

  static const fontXS  = 11.0;
  static const fontS   = 13.0;
  static const fontM   = 15.0;
  static const fontL   = 17.0;
  static const fontXL  = 20.0;
  static const fontXXL = 28.0;
}
