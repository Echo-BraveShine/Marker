part of '../message_catalog.dart';

const _it3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Il contenuto attuale verrà salvato. Anche la cartella delle risorse e i riferimenti alle immagini in questo documento verranno rinominati. I riferimenti da altri documenti devono essere aggiornati separatamente.",
  AppMessage.rename2: "Rinomina",
  AppMessage.renamingDocument: "Rinomina del documento",
  AppMessage.packageDocumentAndImages2: "Pacchetta documento e immagini",
  AppMessage.packagingDocument: "Creazione del pacchetto",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Pacchetto creato con riferimenti che richiedono ancora riparazione.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Documento attuale e immagini pacchettizzati.",
  AppMessage.dropToImportImages: "Trascina qui per importare immagini",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Copia nelle risorse del documento. Gli originali sono conservati.",
  AppMessage.saveTheDocumentFirst: "Salva prima il documento",
  AppMessage.saveBeforeImportImages:
      "Salva prima, così le immagini possono essere archiviate accanto al documento con percorsi relativi portatili.",
  AppMessage.saveAndContinue: "Salva e continua",
  AppMessage.allowFolderAccess2: "Consenti accesso alla cartella",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Scegli la cartella che lo contiene o una delle sue cartelle superiori.",
  AppMessage.folderAccessGranted: "Accesso alla cartella concesso.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Il documento è cambiato. Importa di nuovo le immagini.",
  AppMessage.importingImages: "Importazione delle immagini",
  AppMessage.noTextOrImageToPaste: "Nessun testo o immagine da incollare.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Le immagini degli appunti non sono disponibili in questo ambiente.",
  AppMessage.dropAccessDenied:
      "Il sistema non ha potuto concedere l'accesso ai file trascinati. Usa Importa immagini per selezionarli.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Trascina immagini PNG, JPEG, GIF, WebP o BMP.",
  AppMessage.insertWebImage2: "Inserisci immagine web",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Inserisci un URL immagine HTTP o HTTPS valido.",
  AppMessage.imageDescription: "Descrizione immagine",
  AppMessage.unsupportedImageAddress: "Indirizzo immagine non supportato",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Usa Salva come per spostare il documento in un'altra cartella.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "Esiste già un file con questo nome.",
  AppMessage.theSourceDocumentIsUnavailable:
      "Il documento di origine non è disponibile.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Esiste già una cartella di risorse con il nuovo nome. Nessuna operazione di rinomina è stata eseguita.",
  AppMessage.resolveImagesBeforeExport:
      "Risolvi le immagini non disponibili o mantieni esplicitamente i loro riferimenti originali.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Questa immagine non è referenziata nel documento.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Impossibile caricare l'immagine. Riprova o controlla la rete e l'accesso ai file.",
  AppMessage.more: "Altro",
  AppMessage.cannotOverwriteASymbolicLink:
      "Impossibile sovrascrivere un link simbolico.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "La directory delle risorse non è una directory normale.",
  AppMessage.noAvailableResourceDirectoryName:
      "Nessun nome disponibile per la directory delle risorse.",
  AppMessage.tooManyImageNameConflicts: "Troppi conflitti di nomi di immagine.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Immagine non valida; usa PNG, JPEG, GIF, WebP o BMP.",
  AppMessage.imageExceeds50MB: "L'immagine supera i 50 MB.",
  AppMessage.imageExceeds50MB2: "L'immagine supera i 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Impossibile sovrascrivere un link simbolico.",
  AppMessage.unsupportedImageURL: "URL immagine non supportato.",
  AppMessage.downloadFailedHTTPValue: "Download non riuscito: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Troppi reindirizzamenti di immagine.",
  AppMessage.continueText: "Continua",
  AppMessage.someImagesNeedAttention: "Alcune immagini richiedono attenzione",
  AppMessage.partialResourceCopyWarning:
      "Questi riferimenti non possono essere copiati completamente. Riparali prima oppure continua mantenendo i loro indirizzi originali.",
  AppMessage.customSyntax: "Sintassi personalizzata",
  AppMessage.continueWithOriginalAddresses:
      "Continua con gli indirizzi originali",
  AppMessage.resourceInventorySummary:
      "{p0} immagini locali ({p1} gestite), {p2} immagini web.\n{p3} immagini da copiare; {p4} MB di immagini locali.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Scarica anche le immagini web",
  AppMessage.copyLocalImages: "Copia le immagini locali",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "L'accesso alla cartella è necessario. Consenti l'accesso a questa posizione e riprova.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Il file o la cartella è mancante, spostato o non scaricato localmente.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Il disco è pieno. Libera spazio e riprova.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Questa posizione è di sola lettura. Scegli una cartella scrivibile.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Operazione file non riuscita. Controlla la posizione e i dettagli di sistema qui sotto.",
  AppMessage.location: "Posizione",
  AppMessage.unknown: "sconosciuto",
  AppMessage.error: "errore",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Impossibile elaborare l'immagine. Controlla il formato o la connessione e riprova.",
  AppMessage.someImagesCouldNotBeCopied:
      "Alcune immagini non sono state copiate",
  AppMessage.originalImagesUnchanged:
      "I file originali sono invariati. Ripara queste immagini oppure mantieni i loro indirizzi e continua.",
  AppMessage.keepAddressesAndContinue: "Mantieni gli indirizzi e continua",
  AppMessage.operationResult: "Risultato dell'operazione",
  AppMessage.imageDimensionsAreTooLarge:
      "Le dimensioni dell'immagine sono troppo grandi.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "È già in corso un'operazione sulle risorse.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "È possibile eliminare solo i file all'interno di Marker.",
  AppMessage.trashFailedFileKept:
      "Impossibile spostare nel Cestino. Il file originale è stato conservato. Controlla l'accesso alla cartella o il cestino.",
  AppMessage.allowFolderAccess3: "Consenti accesso alla cartella",
  AppMessage.allowFolderAccess4: "Consenti accesso alla cartella",
  AppMessage.folderAccessPurpose:
      "Marker necessita di questa cartella per leggere le immagini o creare risorse accanto al documento. Consenti l'accesso per continuare, oppure annulla per interrompere questa operazione.\n{p0}",
  AppMessage.classic: "Classico",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Esportazione scaduta. Prova a ridurre il numero di immagini o diagrammi.",
  AppMessage.exportFileAccessFailed:
      "Impossibile accedere a un'immagine o alla destinazione. Controlla che il file esista, i permessi della cartella e lo spazio disponibile.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Impossibile scaricare un'immagine remota. Controlla la connessione o usa un'immagine locale.",
  AppMessage.exportIncomplete:
      "Esportazione non completata. Nessun output scritto. Controlla immagini, equazioni e sintassi Mermaid. Per documenti lunghi, scegli PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Dividi immagini (ZIP)",
  AppMessage.saveToFiles: "Salva su File",
  AppMessage.unsupportedExportFormat: "Formato di esportazione non supportato",
  AppMessage.pleaseSelectAnExportPath: "Seleziona un percorso di esportazione",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Seleziona un file invece di una directory",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "I file Markdown non possono essere usati come destinazione di esportazione",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Il percorso di esportazione non può coincidere con il file di origine",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "La destinazione è una directory. Scegli un altro nome file.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "L'output esiste già. Seleziona {p0} direttamente nella finestra di salvataggio.",
  AppMessage.exportDataCannotBeEmpty:
      "I dati di esportazione non possono essere vuoti",
  AppMessage.indentEditor: "Aumenta rientro (editor)",
  AppMessage.outdentEditor: "Riduci rientro (editor)",
  AppMessage.newDocument2: "Nuovo documento",
  AppMessage.openDocument2: "Apri documento",
  AppMessage.closeDocument2: "Chiudi documento",
  AppMessage.find: "Trova",
  AppMessage.findAndReplace2: "Trova e sostituisci",
  AppMessage.nextMatch: "Corrispondenza successiva",
  AppMessage.previousMatch: "Corrispondenza precedente",
  AppMessage.bold: "Grassetto",
  AppMessage.italic: "Corsivo",
  AppMessage.inlineCode: "Codice in linea",
  AppMessage.strikethrough: "Barrato",
  AppMessage.editorMode: "Modalità editor",
  AppMessage.splitMode: "Modalità dividi",
  AppMessage.previewMode: "Modalità anteprima",
  AppMessage.allSyntax: "Tutta la sintassi",
  AppMessage.quitApp: "Esci dall'app",
  AppMessage.cut: "Taglia",
  AppMessage.copy: "Copia",
  AppMessage.paste: "Incolla",
  AppMessage.selectAll: "Seleziona tutto",
  AppMessage.shortcutFooter:
      "Esc chiude la ricerca o il pannello della sintassi. I campi di testo mantengono le scorciatoie native per appunti e annulla.",
};
