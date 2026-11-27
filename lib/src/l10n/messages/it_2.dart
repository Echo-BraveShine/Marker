part of '../message_catalog.dart';

const _it2 = <AppMessage, String>{
  AppMessage.versionAvailable: "è disponibile",
  AppMessage.requestLimited: "Richiesta limitata. Riprova più tardi.",
  AppMessage.cannotConnect:
      "Impossibile connettersi. Controlla la connessione e riprova.",
  AppMessage.cannotReadVersion:
      "Impossibile leggere la versione installata. Riprova.",
  AppMessage.invalidReleaseInfo:
      "Informazioni di rilascio non valide. Riprova più tardi.",
  AppMessage.checkFailed:
      "Controllo non riuscito. Riprova o visita la pagina dei rilasci.",
  AppMessage.viewAndDownload: "Visualizza e scarica",
  AppMessage.releases: "Rilasci",
  AppMessage.saveFailed: "Salvataggio non riuscito",
  AppMessage.retry: "Riprova",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Le tue modifiche sono conservate come bozza. Controlla l'accesso alla cartella e lo spazio disponibile.",
  AppMessage.exportComplete: "Esportazione completata.",
  AppMessage.exportedToValue: "Esportato in {p0}",
  AppMessage.remainingWorkStopped: "Lavoro rimanente interrotto",
  AppMessage.thisFileIsAlreadyOpen: "Questo file è già aperto",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "File esistente aperto senza sovrascriverlo.",
  AppMessage.lnValueColValue: "Riga {p0}, Col {p1}",
  AppMessage.characters: "caratteri",
  AppMessage.unsavedDraftsRestored: "Bozze non salvate ripristinate.",
  AppMessage.draftNotSavedToFile: "Bozza · Non salvata su file",
  AppMessage.saving: "Salvataggio…",
  AppMessage.saveFailedRetry: "Salvataggio non riuscito · Riprova",
  AppMessage.fileChangedResolve: "File modificato · Risolvi",
  AppMessage.fileDeleted: "File eliminato",
  AppMessage.pendingSave: "Salvataggio in sospeso…",
  AppMessage.saved: "Salvato",
  AppMessage.fileChangedOnDisk: "File modificato su disco",
  AppMessage.loadDiskVersion: "Carica versione su disco",
  AppMessage.overwriteWithMyVersion: "Sovrascrivi con la mia versione",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Salvataggio automatico in pausa. Le tue modifiche sono conservate come bozza.",
  AppMessage.sentToTheSelectedApp: "Inviato all'app selezionata.",
  AppMessage.images: "Immagini",
  AppMessage.addImage: "Aggiungi immagine",
  AppMessage.takePhoto: "Scatta foto",
  AppMessage.chooseFromPhotos: "Scegli da Foto",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Consenti a Marker di accedere a Fotocamera o Foto nelle impostazioni di sistema.",
  AppMessage.saveInMarker: "Salva in Marker",
  AppMessage.fileName: "Nome file",
  AppMessage.enterAFileNameWithoutSlashes:
      "Inserisci un nome file senza barre.",
  AppMessage.fileAlreadyExists: "Il file esiste già",
  AppMessage.replaceExistingFile: "Sostituisci il file esistente",
  AppMessage.cannotImportFileValue: "Impossibile importare il file: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "Impossibile importare {p0} file. Gli altri documenti sono aperti.",
  AppMessage.openedDocumentMissingImages:
      "Documento aperto con immagini mancanti. Importa uno ZIP contenente il documento e le immagini.",
  AppMessage.openedTheExistingCopyInMarker: "Copia esistente aperta in Marker.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Importata una copia. Le modifiche non cambieranno il file originale.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Scegli un modello da inserire. Il testo selezionato sostituisce l'esempio.",
  AppMessage.syntaxHighlighting: "Evidenziazione della sintassi",
  AppMessage.editor: "Editor",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Impossibile decodificare l'immagine; controlla il formato o l'integrità",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Salva il documento per risolvere le immagini relative",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Modifiche su disco sincronizzate. Le modifiche non salvate sono state conservate.",
  AppMessage.saveNow: "Salva ora",
  AppMessage.deleteDocument: "Elimina documento",
  AppMessage.deleteDocument2: "Eliminare il documento?",
  AppMessage.deleteDocumentConfirmation:
      "Elimina definitivamente questo documento da Marker. Le immagini sono conservate. Anche le modifiche non salvate verranno chiuse.",
  AppMessage.delete: "Elimina",
  AppMessage.fileOperationFailedValue: "Operazione file non riuscita: {p0}",
  AppMessage.valueHasUnsavedChanges: "{p0} contiene modifiche non salvate.",
  AppMessage.exportDocument: "Esporta documento",
  AppMessage.exportingDocument: "Esportazione del documento…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Controlla l'ultima versione pubblica su GitHub.",
  AppMessage.checkingForUpdates: "Controllo aggiornamenti…",
  AppMessage.noPublicReleaseWasFound: "Nessuna versione pubblica trovata.",
  AppMessage.youAreUpToDate: "Hai la versione più recente.",
  AppMessage.valueHasUnsavedChanges2: "{p0} contiene modifiche non salvate.",
  AppMessage.versionValueIsAvailable: "La versione {p0} è disponibile",
  AppMessage.importImagesCopyOriginals:
      "Importa immagini (copia gli originali)",
  AppMessage.linkOriginalLocation: "Collega posizione originale…",
  AppMessage.pasteImage: "Incolla immagine",
  AppMessage.insertWebImage: "Inserisci immagine web…",
  AppMessage.organizeDocumentImages: "Organizza immagini del documento…",
  AppMessage.cleanUnusedResources: "Pulisci risorse non utilizzate…",
  AppMessage.allowFolderAccess: "Consenti accesso alla cartella…",
  AppMessage.newDocumentFolder: "Nuova cartella documenti…",
  AppMessage.renameDocument: "Rinomina documento…",
  AppMessage.packageDocumentAndImages: "Pacchetta documento e immagini…",
  AppMessage.organizeDocumentImages2: "Organizza immagini del documento",
  AppMessage.organizingImages: "Organizzazione delle immagini",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Immagini organizzate. File originali conservati.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Immagini organizzate nell'editor. Salva il documento.",
  AppMessage.image: "Immagine",
  AppMessage.locateInEditor: "Individua nell'editor",
  AppMessage.insertAtCursor: "Inserisci nel cursore",
  AppMessage.viewImage: "Visualizza immagine",
  AppMessage.openImage: "Apri immagine",
  AppMessage.showInFileManager: "Mostra nel gestore file",
  AppMessage.copyReferencePath: "Copia percorso di riferimento",
  AppMessage.locateImage2: "Individua immagine…",
  AppMessage.replaceWithImportedImage: "Sostituisci con immagine importata…",
  AppMessage.downloadToDocumentAssets: "Scarica nelle risorse del documento",
  AppMessage.reload: "Ricarica",
  AppMessage.referenceCopied: "Riferimento copiato",
  AppMessage.updatingImage: "Aggiornamento immagine",
  AppMessage.downloadingImage: "Download immagine",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Nessun elemento sicuro da pulire. I riferimenti salvati e condivisi sono protetti.",
  AppMessage.moveToTrash2: "Spostare nel Cestino?",
  AppMessage.unreferencedImagesDescription:
      "Queste immagini importate non sono referenziate dal contenuto attuale, dalle versioni salvate o dai documenti noti. Verifica che altri strumenti non le utilizzino più.",
  AppMessage.moveToTrash3: "Sposta nel Cestino",
  AppMessage.cleaningResources: "Pulizia delle risorse",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} immagini spostate nel Cestino. Le risorse referenziate o modificate sono conservate.",
  AppMessage.chooseLocation: "Scegli posizione",
  AppMessage.newDocumentFolder2: "Nuova cartella documenti",
  AppMessage.folderName: "Nome cartella",
  AppMessage.enterAValidFolderName: "Inserisci un nome cartella valido.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "La cartella esiste già. Scegli un altro nome.",
  AppMessage.renameDocument2: "Rinomina documento",
  AppMessage.documentName: "Nome documento",
  AppMessage.invalidDocumentName: "Nome documento non valido.",
  AppMessage.saveAndRename: "Salvare e rinominare?",
};
