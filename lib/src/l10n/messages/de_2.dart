part of '../message_catalog.dart';

const _de2 = <AppMessage, String>{
  AppMessage.versionAvailable: "ist verfügbar",
  AppMessage.requestLimited: "Anfrage begrenzt. Versuche es später erneut.",
  AppMessage.cannotConnect:
      "Keine Verbindung. Prüfe deine Verbindung und versuche es erneut.",
  AppMessage.cannotReadVersion:
      "Installierte Version kann nicht gelesen werden. Bitte erneut versuchen.",
  AppMessage.invalidReleaseInfo:
      "Ungültige Versionsinformationen. Versuche es später erneut.",
  AppMessage.checkFailed:
      "Prüfung fehlgeschlagen. Versuche es erneut oder besuche die Release-Seite.",
  AppMessage.viewAndDownload: "Ansehen und herunterladen",
  AppMessage.releases: "Releases",
  AppMessage.saveFailed: "Speichern fehlgeschlagen",
  AppMessage.retry: "Erneut versuchen",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Deine Änderungen werden als Entwurf behalten. Prüfe Ordnerzugriff und freien Speicherplatz.",
  AppMessage.exportComplete: "Export abgeschlossen.",
  AppMessage.exportedToValue: "Exportiert nach {p0}",
  AppMessage.remainingWorkStopped: "Restliche Arbeit gestoppt",
  AppMessage.thisFileIsAlreadyOpen: "Diese Datei ist bereits geöffnet",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Vorhandene Datei geöffnet, ohne sie zu überschreiben.",
  AppMessage.lnValueColValue: "Z {p0}, Sp {p1}",
  AppMessage.characters: "Zeichen",
  AppMessage.unsavedDraftsRestored:
      "Nicht gespeicherte Entwürfe wiederhergestellt.",
  AppMessage.draftNotSavedToFile: "Entwurf · Nicht in Datei gespeichert",
  AppMessage.saving: "Speichern…",
  AppMessage.saveFailedRetry: "Speichern fehlgeschlagen · Erneut versuchen",
  AppMessage.fileChangedResolve: "Datei geändert · Klären",
  AppMessage.fileDeleted: "Datei gelöscht",
  AppMessage.pendingSave: "Speichern ausstehend…",
  AppMessage.saved: "Gespeichert",
  AppMessage.fileChangedOnDisk: "Datei auf dem Datenträger geändert",
  AppMessage.loadDiskVersion: "Version vom Datenträger laden",
  AppMessage.overwriteWithMyVersion: "Mit meiner Version überschreiben",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Automatisches Speichern pausiert. Deine Änderungen bleiben als Entwurf erhalten.",
  AppMessage.sentToTheSelectedApp: "An die ausgewählte App gesendet.",
  AppMessage.images: "Bilder",
  AppMessage.addImage: "Bild hinzufügen",
  AppMessage.takePhoto: "Foto aufnehmen",
  AppMessage.chooseFromPhotos: "Aus Fotos auswählen",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Erlaube Marker in den Systemeinstellungen den Zugriff auf Kamera oder Fotos.",
  AppMessage.saveInMarker: "In Marker speichern",
  AppMessage.fileName: "Dateiname",
  AppMessage.enterAFileNameWithoutSlashes:
      "Gib einen Dateinamen ohne Schrägstriche ein.",
  AppMessage.fileAlreadyExists: "Datei existiert bereits",
  AppMessage.replaceExistingFile: "Vorhandene Datei ersetzen",
  AppMessage.cannotImportFileValue: "Datei kann nicht importiert werden: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "{p0} Datei(en) konnten nicht importiert werden. Die anderen Dokumente sind geöffnet.",
  AppMessage.openedDocumentMissingImages:
      "Dokument mit fehlenden Bildern geöffnet. Importiere eine ZIP-Datei mit dem Dokument und den Bildern.",
  AppMessage.openedTheExistingCopyInMarker:
      "Vorhandene Kopie in Marker geöffnet.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Kopie importiert. Änderungen wirken sich nicht auf die Originaldatei aus.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Wähle eine Vorlage zum Einfügen. Der ausgewählte Text ersetzt das Beispiel.",
  AppMessage.syntaxHighlighting: "Syntaxhervorhebung",
  AppMessage.editor: "Editor",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Bild kann nicht dekodiert werden; prüfe Format oder Integrität",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Speichere das Dokument, um relative Bilder aufzulösen",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Änderungen auf dem Datenträger abgeglichen. Nicht gespeicherte Änderungen blieben erhalten.",
  AppMessage.saveNow: "Jetzt speichern",
  AppMessage.deleteDocument: "Dokument löschen",
  AppMessage.deleteDocument2: "Dokument löschen?",
  AppMessage.deleteDocumentConfirmation:
      "Dieses Dokument dauerhaft aus Marker löschen. Bilder bleiben erhalten. Nicht gespeicherte Änderungen werden ebenfalls geschlossen.",
  AppMessage.delete: "Löschen",
  AppMessage.fileOperationFailedValue: "Dateivorgang fehlgeschlagen: {p0}",
  AppMessage.valueHasUnsavedChanges: "{p0} hat nicht gespeicherte Änderungen.",
  AppMessage.exportDocument: "Dokument exportieren",
  AppMessage.exportingDocument: "Dokument wird exportiert…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Prüfe die neueste öffentliche Version auf GitHub.",
  AppMessage.checkingForUpdates: "Suche nach Updates…",
  AppMessage.noPublicReleaseWasFound:
      "Es wurde keine öffentliche Version gefunden.",
  AppMessage.youAreUpToDate: "Du bist auf dem neuesten Stand.",
  AppMessage.valueHasUnsavedChanges2: "{p0} hat nicht gespeicherte Änderungen.",
  AppMessage.versionValueIsAvailable: "Version {p0} ist verfügbar",
  AppMessage.importImagesCopyOriginals:
      "Bilder importieren (Originale kopieren)",
  AppMessage.linkOriginalLocation: "Originalort verknüpfen…",
  AppMessage.pasteImage: "Bild einfügen",
  AppMessage.insertWebImage: "Web-Bild einfügen…",
  AppMessage.organizeDocumentImages: "Dokumentbilder organisieren…",
  AppMessage.cleanUnusedResources: "Ungenutzte Ressourcen bereinigen…",
  AppMessage.allowFolderAccess: "Ordnerzugriff erlauben…",
  AppMessage.newDocumentFolder: "Neuer Dokumentordner…",
  AppMessage.renameDocument: "Dokument umbenennen…",
  AppMessage.packageDocumentAndImages: "Dokument und Bilder paketieren…",
  AppMessage.organizeDocumentImages2: "Dokumentbilder organisieren",
  AppMessage.organizingImages: "Bilder werden organisiert",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Bilder organisiert. Originaldateien bleiben erhalten.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Bilder im Editor organisiert. Speichere das Dokument.",
  AppMessage.image: "Bild",
  AppMessage.locateInEditor: "Im Editor suchen",
  AppMessage.insertAtCursor: "An Cursorposition einfügen",
  AppMessage.viewImage: "Bild anzeigen",
  AppMessage.openImage: "Bild öffnen",
  AppMessage.showInFileManager: "Im Dateimanager anzeigen",
  AppMessage.copyReferencePath: "Verweispfad kopieren",
  AppMessage.locateImage2: "Bild suchen…",
  AppMessage.replaceWithImportedImage: "Durch importiertes Bild ersetzen…",
  AppMessage.downloadToDocumentAssets: "In Dokumentressourcen herunterladen",
  AppMessage.reload: "Neu laden",
  AppMessage.referenceCopied: "Verweis kopiert",
  AppMessage.updatingImage: "Bild wird aktualisiert",
  AppMessage.downloadingImage: "Bild wird heruntergeladen",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Keine sicheren Bereinigungskandidaten. Gespeicherte und geteilte Verweise sind geschützt.",
  AppMessage.moveToTrash2: "In den Papierkorb verschieben?",
  AppMessage.unreferencedImagesDescription:
      "Diese importierten Bilder werden von keinem aktuellen Inhalt, keinen gespeicherten Versionen und keinen bekannten Dokumenten referenziert. Bestätige, dass andere Tools sie nicht mehr verwenden.",
  AppMessage.moveToTrash3: "In den Papierkorb",
  AppMessage.cleaningResources: "Ressourcen werden bereinigt",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} Bilder in den Papierkorb verschoben. Referenzierte oder geänderte Ressourcen bleiben erhalten.",
  AppMessage.chooseLocation: "Ort auswählen",
  AppMessage.newDocumentFolder2: "Neuer Dokumentordner",
  AppMessage.folderName: "Ordnername",
  AppMessage.enterAValidFolderName: "Gib einen gültigen Ordnernamen ein.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "Der Ordner existiert bereits. Wähle einen anderen Namen.",
  AppMessage.renameDocument2: "Dokument umbenennen",
  AppMessage.documentName: "Dokumentname",
  AppMessage.invalidDocumentName: "Ungültiger Dokumentname.",
  AppMessage.saveAndRename: "Speichern und umbenennen?",
};
