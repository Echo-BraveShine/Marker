part of '../message_catalog.dart';

const _it1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Usa il contenuto attuale dell'editor; il documento originale resta invariato.",
  AppMessage.organizeSavesCurrentContent:
      "L'organizzazione salva il contenuto attuale dell'editor; tutte le immagini originali vengono conservate.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nLe immagini non disponibili mantengono i riferimenti originali.",
  AppMessage.embeddedImagesTooLarge:
      "Le immagini incorporate superano i 128 MB.",
  AppMessage.imageExceedsSizeLimit: "L'immagine supera i 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "L'immagine supera i 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Salva il documento per risolvere l'immagine: {p0}",
  AppMessage.splitImagesTooLarge: "Le immagini divise superano i 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Dimensioni dell'immagine non valide o documento troppo lungo.",
  AppMessage.documentTooLargeForSinglePng:
      "Documento troppo grande per un solo PNG. Attiva Dividi immagini (ZIP).",
  AppMessage.cannotOpenLink: "Impossibile aprire il link.",
  AppMessage.cannotReadOriginalImage:
      "Impossibile leggere l'immagine originale",
  AppMessage.cannotWriteImageAssets: "Impossibile scrivere le risorse immagine",
  AppMessage.cannotProcessImageRetry:
      "Impossibile elaborare questa immagine. Controllala e riprova.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Importazione annullata. Le immagini originali sono invariate.",
  AppMessage.importStoppedImagesInserted:
      "Importazione interrotta. {p0} immagini inserite.",
  AppMessage.originalLocationReferencesInserted:
      "Riferimenti alla posizione originale inseriti. Spostare le immagini originali potrebbe interromperli.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} immagini inserite. Originali conservati.",
  AppMessage.unsupportedSyntaxKept:
      "Sintassi personalizzata mantenuta invariata.",
  AppMessage.cannotReadOrCopyImage:
      "Impossibile leggere o copiare l'immagine. Controlla i permessi e lo spazio disponibile.",
  AppMessage.headings: "Intestazioni",
  AppMessage.listsAndBlocks: "Elenchi e blocchi",
  AppMessage.linksAndExtensions: "Link ed estensioni",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Documenti non salvati recuperati",
  AppMessage.file: "File",
  AppMessage.openFile: "Apri file",
  AppMessage.save: "Salva",
  AppMessage.export: "Esporta",
  AppMessage.exportHtml: "Esporta HTML",
  AppMessage.exportPdf: "Esporta PDF",
  AppMessage.settings: "Impostazioni",
  AppMessage.theme: "Tema",
  AppMessage.themeLight: "Chiaro",
  AppMessage.themeDark: "Scuro",
  AppMessage.themeSystem: "Sistema",
  AppMessage.fontSize: "caratteri",
  AppMessage.language: "Lingua",
  AppMessage.languageZh: "Cinese",
  AppMessage.languageEn: "Inglese",
  AppMessage.edit: "Modifica",
  AppMessage.preview: "Anteprima",
  AppMessage.split: "Dividi",
  AppMessage.statusLine: "Riga 1, Colonna 1",
  AppMessage.closeDocument: "Chiudi documento",
  AppMessage.rename: "Rinomina…",
  AppMessage.moveToTrash: "Sposta nel Cestino…",
  AppMessage.moveToTrashPrompt: "Spostare il documento nel Cestino?",
  AppMessage.moveToTrashContent:
      "Il documento viene spostato nel Cestino; le immagini associate sono conservate. Le modifiche non salvate verranno chiuse.",
  AppMessage.saveAs: "Salva come",
  AppMessage.saveChanges: "Salvare le modifiche?",
  AppMessage.discard: "Ignora",
  AppMessage.pathConflict:
      "Un altro documento aperto usa questo percorso. Scegli un percorso diverso.",
  AppMessage.saveCancelled:
      "Salvataggio annullato. Il contenuto del documento è conservato.",
  AppMessage.fileOperationFailed: "Operazione file non riuscita",
  AppMessage.unableToExport: "Impossibile esportare il documento",
  AppMessage.importImages: "Importa immagini",
  AppMessage.stopRemainingWork: "Interrompi il lavoro rimanente",
  AppMessage.cannotReadImages:
      "Impossibile leggere le immagini. Controlla l'accesso alla cartella.",
  AppMessage.importOrPasteImages:
      "Importa immagini o incolla uno screenshot.\nGli originali sono conservati; la cartella delle risorse viene creata se necessario.",
  AppMessage.customSyntaxUnchanged:
      "Alcune sintassi personalizzate restano invariate",
  AppMessage.localImages: "Immagini locali",
  AppMessage.webImages: "Immagini web",
  AppMessage.needsAttention: "Richiede attenzione",
  AppMessage.managed: "Gestite",
  AppMessage.linkedUrl: "URL collegato",
  AppMessage.clickToRepair: "Fai clic per riparare",
  AppMessage.exportFormat: "Formato",
  AppMessage.exportA4Info:
      "Pagine A4 con testo selezionabile e copiabile, incluse equazioni, Mermaid e immagini.",
  AppMessage.useAppAppearance: "Usa l'aspetto dell'app",
  AppMessage.imageWidth: "Larghezza immagine (px)",
  AppMessage.selfContainedHtml:
      "HTML autonomo con immagini e diagrammi incorporati, disponibile offline.",
  AppMessage.version: "Versione",
  AppMessage.loadingVersion: "Caricamento versione…",
  AppMessage.unsavedDoc: "Questo file è già aperto",
  AppMessage.unsupportedLinkType: "Tipo di link non supportato",
  AppMessage.webImageLoadFailed: "Impossibile caricare l'immagine web",
  AppMessage.cannotAccessImage:
      "Impossibile accedere all'immagine; consenti l'accesso alla cartella",
  AppMessage.imageNotFound: "Immagine non trovata",
  AppMessage.locateImage: "Individua immagine",
  AppMessage.allowImageFolderAndRetry:
      "Consenti la cartella delle immagini e riprova",
  AppMessage.reloadImage: "Ricarica immagine",
  AppMessage.saveToResolveImages:
      "Salva il documento per risolvere le immagini relative",
  AppMessage.stop: "Interrompi",
  AppMessage.toggleSidebar: "Mostra/nascondi barra laterale",
  AppMessage.resources: "Risorse",
  AppMessage.files: "File",
  AppMessage.documents: "Documenti",
  AppMessage.documentResources: "Risorse del documento",
  AppMessage.newDocument: "Nuovo",
  AppMessage.openDocument: "Apri",
  AppMessage.undo: "Annulla",
  AppMessage.redo: "Ripeti",
  AppMessage.findAndReplace: "Trova e sostituisci",
  AppMessage.textColor: "Colore del testo",
  AppMessage.equationTemplates: "Modelli di equazioni",
  AppMessage.mermaidTemplates: "Modelli Mermaid",
  AppMessage.allMarkdownSyntax: "Tutta la sintassi Markdown",
  AppMessage.serifFont: "Carattere serif",
  AppMessage.startWriting: "Inizia a scrivere…",
  AppMessage.auto: "Automatico",
  AppMessage.general: "Generali",
  AppMessage.editorAndPreview: "Editor e anteprima",
  AppMessage.keyboardShortcuts: "Scorciatoie da tastiera",
  AppMessage.about: "Informazioni",
  AppMessage.appearance: "Aspetto",
  AppMessage.interfaceLanguage: "Lingua",
  AppMessage.versionUnavailable: "Versione non disponibile",
  AppMessage.focusedMarkdown:
      "Scrittura Markdown concentrata e anteprima dal vivo.",
  AppMessage.checkForUpdates: "Controlla aggiornamenti",
};
