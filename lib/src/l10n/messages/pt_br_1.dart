part of '../message_catalog.dart';

const _ptBR1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Usa o conteúdo atual do editor; o documento original não é alterado.",
  AppMessage.organizeSavesCurrentContent:
      "Organizar salva o conteúdo atual do editor; todas as imagens originais são mantidas.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nImagens indisponíveis mantêm suas referências originais.",
  AppMessage.embeddedImagesTooLarge: "As imagens incorporadas excedem 128 MB.",
  AppMessage.imageExceedsSizeLimit: "A imagem excede 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "A imagem excede 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Salve o documento para resolver a imagem: {p0}",
  AppMessage.splitImagesTooLarge: "As imagens divididas excedem 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Dimensões de imagem inválidas ou documento muito longo.",
  AppMessage.documentTooLargeForSinglePng:
      "Documento muito grande para um único PNG. Ative Dividir imagens (ZIP).",
  AppMessage.cannotOpenLink: "Não é possível abrir o link.",
  AppMessage.cannotReadOriginalImage: "Não é possível ler a imagem original",
  AppMessage.cannotWriteImageAssets:
      "Não é possível gravar os recursos de imagem",
  AppMessage.cannotProcessImageRetry:
      "Não é possível processar esta imagem. Verifique-a e tente novamente.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Importação cancelada. As imagens originais não foram alteradas.",
  AppMessage.importStoppedImagesInserted:
      "Importação interrompida. {p0} imagens inseridas.",
  AppMessage.originalLocationReferencesInserted:
      "Referências ao local original inseridas. Mover as imagens originais pode quebrá-las.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} imagens inseridas. Originais mantidas.",
  AppMessage.unsupportedSyntaxKept:
      "Sintaxe personalizada mantida sem alterações.",
  AppMessage.cannotReadOrCopyImage:
      "Não é possível ler ou copiar a imagem. Verifique as permissões e o espaço disponível.",
  AppMessage.headings: "Títulos",
  AppMessage.listsAndBlocks: "Listas e blocos",
  AppMessage.linksAndExtensions: "Links e extensões",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Documentos não salvos recuperados",
  AppMessage.file: "Arquivo",
  AppMessage.openFile: "Abrir arquivo",
  AppMessage.save: "Salvar",
  AppMessage.export: "Exportar",
  AppMessage.exportHtml: "Exportar HTML",
  AppMessage.exportPdf: "Exportar PDF",
  AppMessage.settings: "Configurações",
  AppMessage.theme: "Tema",
  AppMessage.themeLight: "Claro",
  AppMessage.themeDark: "Escuro",
  AppMessage.themeSystem: "Sistema",
  AppMessage.fontSize: "caracteres",
  AppMessage.language: "Idioma",
  AppMessage.languageZh: "Chinês",
  AppMessage.languageEn: "Inglês",
  AppMessage.edit: "Editar",
  AppMessage.preview: "Visualizar",
  AppMessage.split: "Dividir",
  AppMessage.statusLine: "Linha 1, Coluna 1",
  AppMessage.closeDocument: "Fechar documento",
  AppMessage.rename: "Renomear…",
  AppMessage.moveToTrash: "Mover para a Lixeira…",
  AppMessage.moveToTrashPrompt: "Mover documento para a Lixeira?",
  AppMessage.moveToTrashContent:
      "O documento vai para a Lixeira; as imagens associadas são mantidas. As edições não salvas serão fechadas.",
  AppMessage.saveAs: "Salvar como",
  AppMessage.saveChanges: "Salvar alterações?",
  AppMessage.discard: "Descartar",
  AppMessage.pathConflict:
      "Outro documento aberto usa este caminho. Escolha um caminho diferente.",
  AppMessage.saveCancelled:
      "Salvamento cancelado. O conteúdo do seu documento foi preservado.",
  AppMessage.fileOperationFailed: "Falha na operação de arquivo",
  AppMessage.unableToExport: "Não foi possível exportar o documento",
  AppMessage.importImages: "Importar imagens",
  AppMessage.stopRemainingWork: "Interromper o trabalho restante",
  AppMessage.cannotReadImages:
      "Não é possível ler as imagens. Verifique o acesso à pasta.",
  AppMessage.importOrPasteImages:
      "Importe imagens ou cole uma captura de tela.\nOs originais são mantidos; a pasta de recursos é criada conforme necessário.",
  AppMessage.customSyntaxUnchanged:
      "Alguma sintaxe personalizada foi mantida sem alterações",
  AppMessage.localImages: "Imagens locais",
  AppMessage.webImages: "Imagens da web",
  AppMessage.needsAttention: "Requer atenção",
  AppMessage.managed: "Gerenciadas",
  AppMessage.linkedUrl: "URL vinculada",
  AppMessage.clickToRepair: "Clique para reparar",
  AppMessage.exportFormat: "Formato",
  AppMessage.exportA4Info:
      "Páginas A4 com texto selecionável e copiável, incluindo equações, Mermaid e imagens.",
  AppMessage.useAppAppearance: "Usar a aparência do app",
  AppMessage.imageWidth: "Largura da imagem (px)",
  AppMessage.selfContainedHtml:
      "HTML autônomo com imagens e diagramas incorporados, disponível offline.",
  AppMessage.version: "Versão",
  AppMessage.loadingVersion: "Carregando versão…",
  AppMessage.unsavedDoc: "Este arquivo já está aberto",
  AppMessage.unsupportedLinkType: "Tipo de link não suportado",
  AppMessage.webImageLoadFailed: "Não foi possível carregar a imagem da web",
  AppMessage.cannotAccessImage:
      "Não é possível acessar a imagem; permita o acesso à pasta",
  AppMessage.imageNotFound: "Imagem não encontrada",
  AppMessage.locateImage: "Localizar imagem",
  AppMessage.allowImageFolderAndRetry:
      "Permitir a pasta de imagens e tentar novamente",
  AppMessage.reloadImage: "Recarregar imagem",
  AppMessage.saveToResolveImages:
      "Salve o documento para resolver imagens relativas",
  AppMessage.stop: "Parar",
  AppMessage.toggleSidebar: "Mostrar/ocultar barra lateral",
  AppMessage.resources: "Recursos",
  AppMessage.files: "Arquivos",
  AppMessage.documents: "Documentos",
  AppMessage.documentResources: "Recursos do documento",
  AppMessage.newDocument: "Novo",
  AppMessage.openDocument: "Abrir",
  AppMessage.undo: "Desfazer",
  AppMessage.redo: "Refazer",
  AppMessage.findAndReplace: "Localizar e substituir",
  AppMessage.textColor: "Cor do texto",
  AppMessage.equationTemplates: "Modelos de equação",
  AppMessage.mermaidTemplates: "Modelos Mermaid",
  AppMessage.allMarkdownSyntax: "Toda a sintaxe Markdown",
  AppMessage.serifFont: "Fonte serifada",
  AppMessage.startWriting: "Comece a escrever…",
  AppMessage.auto: "Automático",
  AppMessage.general: "Geral",
  AppMessage.editorAndPreview: "Editor e visualização",
  AppMessage.keyboardShortcuts: "Atalhos de teclado",
  AppMessage.about: "Sobre",
  AppMessage.appearance: "Aparência",
  AppMessage.interfaceLanguage: "Idioma",
  AppMessage.versionUnavailable: "Versão indisponível",
  AppMessage.focusedMarkdown: "Escrita Markdown focada e visualização ao vivo.",
  AppMessage.checkForUpdates: "Verificar atualizações",
};
