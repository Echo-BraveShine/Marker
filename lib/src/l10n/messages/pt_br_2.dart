part of '../message_catalog.dart';

const _ptBR2 = <AppMessage, String>{
  AppMessage.versionAvailable: "está disponível",
  AppMessage.requestLimited:
      "Solicitação limitada. Tente novamente mais tarde.",
  AppMessage.cannotConnect:
      "Não é possível conectar. Verifique sua conexão e tente novamente.",
  AppMessage.cannotReadVersion:
      "Não é possível ler a versão instalada. Tente novamente.",
  AppMessage.invalidReleaseInfo:
      "Informações de versão inválidas. Tente novamente mais tarde.",
  AppMessage.checkFailed:
      "A verificação falhou. Tente novamente ou visite a página de versões.",
  AppMessage.viewAndDownload: "Ver e baixar",
  AppMessage.releases: "Versões",
  AppMessage.saveFailed: "Falha ao salvar",
  AppMessage.retry: "Tentar novamente",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Suas edições são mantidas como rascunho. Verifique o acesso à pasta e o espaço livre.",
  AppMessage.exportComplete: "Exportação concluída.",
  AppMessage.exportedToValue: "Exportado para {p0}",
  AppMessage.remainingWorkStopped: "Trabalho restante interrompido",
  AppMessage.thisFileIsAlreadyOpen: "Este arquivo já está aberto",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "O arquivo existente foi aberto sem sobrescrevê-lo.",
  AppMessage.lnValueColValue: "Lin. {p0}, Col. {p1}",
  AppMessage.characters: "caracteres",
  AppMessage.unsavedDraftsRestored: "Rascunhos não salvos restaurados.",
  AppMessage.draftNotSavedToFile: "Rascunho · Não salvo no arquivo",
  AppMessage.saving: "Salvando…",
  AppMessage.saveFailedRetry: "Falha ao salvar · Tentar novamente",
  AppMessage.fileChangedResolve: "Arquivo alterado · Resolver",
  AppMessage.fileDeleted: "Arquivo excluído",
  AppMessage.pendingSave: "Salvamento pendente…",
  AppMessage.saved: "Salvo",
  AppMessage.fileChangedOnDisk: "Arquivo alterado no disco",
  AppMessage.loadDiskVersion: "Carregar versão do disco",
  AppMessage.overwriteWithMyVersion: "Sobrescrever com minha versão",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Salvamento automático pausado. Suas edições são preservadas como rascunho.",
  AppMessage.sentToTheSelectedApp: "Enviado para o app selecionado.",
  AppMessage.images: "Imagens",
  AppMessage.addImage: "Adicionar imagem",
  AppMessage.takePhoto: "Tirar foto",
  AppMessage.chooseFromPhotos: "Escolher nas Fotos",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Permita que o Marker acesse a Câmera ou as Fotos nas configurações do sistema.",
  AppMessage.saveInMarker: "Salvar no Marker",
  AppMessage.fileName: "Nome do arquivo",
  AppMessage.enterAFileNameWithoutSlashes:
      "Digite um nome de arquivo sem barras.",
  AppMessage.fileAlreadyExists: "O arquivo já existe",
  AppMessage.replaceExistingFile: "Substituir arquivo existente",
  AppMessage.cannotImportFileValue: "Não é possível importar o arquivo: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "{p0} arquivo(s) não puderam ser importados. Os outros documentos estão abertos.",
  AppMessage.openedDocumentMissingImages:
      "Documento aberto com imagens ausentes. Importe um ZIP contendo o documento e as imagens.",
  AppMessage.openedTheExistingCopyInMarker:
      "A cópia existente foi aberta no Marker.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Uma cópia foi importada. As edições não alterarão o arquivo original.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Escolha um modelo para inserir. O texto selecionado substitui o exemplo.",
  AppMessage.syntaxHighlighting: "Realce de sintaxe",
  AppMessage.editor: "Editor",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Não é possível decodificar a imagem; verifique o formato ou a integridade",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Salve o documento para resolver imagens relativas",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Alterações do disco sincronizadas. As edições não salvas foram preservadas.",
  AppMessage.saveNow: "Salvar agora",
  AppMessage.deleteDocument: "Excluir documento",
  AppMessage.deleteDocument2: "Excluir documento?",
  AppMessage.deleteDocumentConfirmation:
      "Excluir permanentemente este documento do Marker. As imagens são mantidas. As edições não salvas também serão fechadas.",
  AppMessage.delete: "Excluir",
  AppMessage.fileOperationFailedValue: "Falha na operação de arquivo: {p0}",
  AppMessage.valueHasUnsavedChanges: "{p0} tem alterações não salvas.",
  AppMessage.exportDocument: "Exportar documento",
  AppMessage.exportingDocument: "Exportando documento…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Verifique a versão pública mais recente no GitHub.",
  AppMessage.checkingForUpdates: "Verificando atualizações…",
  AppMessage.noPublicReleaseWasFound: "Nenhuma versão pública foi encontrada.",
  AppMessage.youAreUpToDate: "Você está atualizado.",
  AppMessage.valueHasUnsavedChanges2: "{p0} tem alterações não salvas.",
  AppMessage.versionValueIsAvailable: "A versão {p0} está disponível",
  AppMessage.importImagesCopyOriginals: "Importar imagens (copiar originais)",
  AppMessage.linkOriginalLocation: "Vincular local original…",
  AppMessage.pasteImage: "Colar imagem",
  AppMessage.insertWebImage: "Inserir imagem da web…",
  AppMessage.organizeDocumentImages: "Organizar imagens do documento…",
  AppMessage.cleanUnusedResources: "Limpar recursos não utilizados…",
  AppMessage.allowFolderAccess: "Permitir acesso à pasta…",
  AppMessage.newDocumentFolder: "Nova pasta de documento…",
  AppMessage.renameDocument: "Renomear documento…",
  AppMessage.packageDocumentAndImages: "Empacotar documento e imagens…",
  AppMessage.organizeDocumentImages2: "Organizar imagens do documento",
  AppMessage.organizingImages: "Organizando imagens",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Imagens organizadas. Os arquivos originais foram mantidos.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Imagens organizadas no editor. Salve o documento.",
  AppMessage.image: "Imagem",
  AppMessage.locateInEditor: "Localizar no editor",
  AppMessage.insertAtCursor: "Inserir no cursor",
  AppMessage.viewImage: "Ver imagem",
  AppMessage.openImage: "Abrir imagem",
  AppMessage.showInFileManager: "Mostrar no gerenciador de arquivos",
  AppMessage.copyReferencePath: "Copiar caminho de referência",
  AppMessage.locateImage2: "Localizar imagem…",
  AppMessage.replaceWithImportedImage: "Substituir por imagem importada…",
  AppMessage.downloadToDocumentAssets: "Baixar para os recursos do documento",
  AppMessage.reload: "Recarregar",
  AppMessage.referenceCopied: "Referência copiada",
  AppMessage.updatingImage: "Atualizando imagem",
  AppMessage.downloadingImage: "Baixando imagem",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Nenhum candidato seguro para limpeza. Referências salvas e compartilhadas são protegidas.",
  AppMessage.moveToTrash2: "Mover para a Lixeira?",
  AppMessage.unreferencedImagesDescription:
      "Estas imagens importadas não são referenciadas pelo conteúdo atual, por versões salvas ou por documentos conhecidos. Confirme que outras ferramentas não as utilizam mais.",
  AppMessage.moveToTrash3: "Mover para a Lixeira",
  AppMessage.cleaningResources: "Limpando recursos",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} imagens movidas para a Lixeira. Recursos referenciados ou modificados são mantidos.",
  AppMessage.chooseLocation: "Escolher local",
  AppMessage.newDocumentFolder2: "Nova pasta de documento",
  AppMessage.folderName: "Nome da pasta",
  AppMessage.enterAValidFolderName: "Digite um nome de pasta válido.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "A pasta já existe. Escolha outro nome.",
  AppMessage.renameDocument2: "Renomear documento",
  AppMessage.documentName: "Nome do documento",
  AppMessage.invalidDocumentName: "Nome de documento inválido.",
  AppMessage.saveAndRename: "Salvar e renomear?",
};
