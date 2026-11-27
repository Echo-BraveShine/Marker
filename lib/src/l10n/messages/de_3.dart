part of '../message_catalog.dart';

const _de3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Der aktuelle Inhalt wird gespeichert. Der Ressourcenordner und die Bildverweise in diesem Dokument werden ebenfalls umbenannt. Verweise aus anderen Dokumenten müssen separat aktualisiert werden.",
  AppMessage.rename2: "Umbenennen",
  AppMessage.renamingDocument: "Dokument wird umbenannt",
  AppMessage.packageDocumentAndImages2: "Dokument und Bilder paketieren",
  AppMessage.packagingDocument: "Dokument wird paketiert",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Paket erstellt, aber einige Verweise müssen noch repariert werden.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Aktuelles Dokument und Bilder paketiert.",
  AppMessage.dropToImportImages: "Zum Importieren von Bildern ablegen",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "In Dokumentressourcen kopieren. Originale bleiben erhalten.",
  AppMessage.saveTheDocumentFirst: "Speichere zuerst das Dokument",
  AppMessage.saveBeforeImportImages:
      "Speichere zuerst, damit Bilder neben dem Dokument mit portablen relativen Pfaden abgelegt werden können.",
  AppMessage.saveAndContinue: "Speichern und fortfahren",
  AppMessage.allowFolderAccess2: "Ordnerzugriff erlauben",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Wähle den übergeordneten Ordner oder einen seiner Elternordner.",
  AppMessage.folderAccessGranted: "Ordnerzugriff gewährt.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Das Dokument wurde geändert. Importiere die Bilder erneut.",
  AppMessage.importingImages: "Bilder werden importiert",
  AppMessage.noTextOrImageToPaste: "Kein Text und kein Bild zum Einfügen.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Zwischenablagebilder sind in dieser Umgebung nicht verfügbar.",
  AppMessage.dropAccessDenied:
      "Das System konnte keinen Zugriff auf die abgelegten Dateien gewähren. Wähle sie über „Bilder importieren“ aus.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "PNG-, JPEG-, GIF-, WebP- oder BMP-Bilder ablegen.",
  AppMessage.insertWebImage2: "Web-Bild einfügen",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Gib eine gültige HTTP- oder HTTPS-Bild-URL ein.",
  AppMessage.imageDescription: "Bildbeschreibung",
  AppMessage.unsupportedImageAddress: "Nicht unterstützte Bildadresse",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Verwende „Speichern unter“, um das Dokument in einen anderen Ordner zu verschieben.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "Eine Datei mit diesem Namen existiert bereits.",
  AppMessage.theSourceDocumentIsUnavailable:
      "Das Quelldokument ist nicht verfügbar.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Ein Ressourcenordner mit dem neuen Namen existiert bereits. Es wurde nichts umbenannt.",
  AppMessage.resolveImagesBeforeExport:
      "Löse nicht verfügbare Bilder auf oder behalte ausdrücklich ihre ursprünglichen Verweise.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Dieses Bild wird im Dokument nicht referenziert.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Bild kann nicht geladen werden. Versuche es erneut oder prüfe Netzwerk und Dateizugriff.",
  AppMessage.more: "Mehr",
  AppMessage.cannotOverwriteASymbolicLink:
      "Ein symbolischer Link kann nicht überschrieben werden.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "Das Ressourcenverzeichnis ist kein reguläres Verzeichnis.",
  AppMessage.noAvailableResourceDirectoryName:
      "Kein verfügbarer Name für das Ressourcenverzeichnis.",
  AppMessage.tooManyImageNameConflicts: "Zu viele Namenskonflikte bei Bildern.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Ungültiges Bild; verwende PNG, JPEG, GIF, WebP oder BMP.",
  AppMessage.imageExceeds50MB: "Bild überschreitet 50 MB.",
  AppMessage.imageExceeds50MB2: "Bild überschreitet 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Ein symbolischer Link kann nicht überschrieben werden.",
  AppMessage.unsupportedImageURL: "Nicht unterstützte Bild-URL.",
  AppMessage.downloadFailedHTTPValue: "Download fehlgeschlagen: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Zu viele Bild-Weiterleitungen.",
  AppMessage.continueText: "Fortfahren",
  AppMessage.someImagesNeedAttention: "Einige Bilder erfordern Aufmerksamkeit",
  AppMessage.partialResourceCopyWarning:
      "Diese Verweise können nicht vollständig kopiert werden. Repariere sie zuerst oder fahre fort und behalte ihre ursprünglichen Adressen.",
  AppMessage.customSyntax: "Benutzerdefinierte Syntax",
  AppMessage.continueWithOriginalAddresses:
      "Mit ursprünglichen Adressen fortfahren",
  AppMessage.resourceInventorySummary:
      "{p0} lokale Bilder ({p1} verwaltet), {p2} Web-Bilder.\n{p3} Bilder zum Kopieren; {p4} MB lokale Bilder.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Web-Bilder ebenfalls herunterladen",
  AppMessage.copyLocalImages: "Lokale Bilder kopieren",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Ordnerzugriff ist erforderlich. Erlaube den Zugriff auf diesen Ort und versuche es erneut.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Die Datei oder der Ordner fehlt, wurde verschoben oder nicht lokal heruntergeladen.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Der Datenträger ist voll. Gib etwas Speicherplatz frei und versuche es erneut.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Dieser Ort ist schreibgeschützt. Wähle einen beschreibbaren Ordner.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Dateivorgang fehlgeschlagen. Prüfe den Ort und die Systemdetails unten.",
  AppMessage.location: "Ort",
  AppMessage.unknown: "unbekannt",
  AppMessage.error: "Fehler",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Das Bild kann nicht verarbeitet werden. Prüfe Format oder Verbindung und versuche es erneut.",
  AppMessage.someImagesCouldNotBeCopied:
      "Einige Bilder konnten nicht kopiert werden",
  AppMessage.originalImagesUnchanged:
      "Die Originaldateien bleiben unverändert. Repariere diese Bilder oder behalte ihre Adressen und fahre fort.",
  AppMessage.keepAddressesAndContinue: "Adressen behalten und fortfahren",
  AppMessage.operationResult: "Vorgangsergebnis",
  AppMessage.imageDimensionsAreTooLarge: "Die Bildabmessungen sind zu groß.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Es läuft bereits ein Ressourcenvorgang.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Nur Dateien innerhalb von Marker können gelöscht werden.",
  AppMessage.trashFailedFileKept:
      "Verschieben in den Papierkorb nicht möglich. Die Originaldatei bleibt erhalten. Prüfe Ordnerzugriff oder Papierkorb.",
  AppMessage.allowFolderAccess3: "Ordnerzugriff erlauben",
  AppMessage.allowFolderAccess4: "Ordnerzugriff erlauben",
  AppMessage.folderAccessPurpose:
      "Marker benötigt diesen Ordner, um Bilder zu lesen oder Ressourcen neben deinem Dokument zu erstellen. Erlaube den Zugriff, um fortzufahren, oder brich ab, um den Vorgang zu beenden.\n{p0}",
  AppMessage.classic: "Classic",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Zeitüberschreitung beim Export. Reduziere die Anzahl der Bilder oder Diagramme.",
  AppMessage.exportFileAccessFailed:
      "Zugriff auf ein Bild oder das Ziel nicht möglich. Prüfe, ob die Datei existiert, die Ordnerberechtigungen und den freien Speicherplatz.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Ein Remote-Bild konnte nicht heruntergeladen werden. Prüfe deine Verbindung oder verwende ein lokales Bild.",
  AppMessage.exportIncomplete:
      "Export nicht abgeschlossen. Es wurde keine Ausgabe geschrieben. Prüfe Bilder, Formeln und Mermaid-Syntax. Wähle für lange Dokumente PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Bilder aufteilen (ZIP)",
  AppMessage.saveToFiles: "In Dateien sichern",
  AppMessage.unsupportedExportFormat: "Nicht unterstütztes Exportformat",
  AppMessage.pleaseSelectAnExportPath: "Bitte wähle einen Exportpfad",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Bitte wähle eine Datei statt eines Verzeichnisses",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Markdown-Dateien können nicht als Exportziel verwendet werden",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Der Exportpfad darf nicht mit der Quelldatei identisch sein",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "Das Ziel ist ein Verzeichnis. Wähle einen anderen Dateinamen.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "Die Ausgabe existiert bereits. Wähle {p0} direkt im Speichern-Dialog aus.",
  AppMessage.exportDataCannotBeEmpty: "Exportdaten dürfen nicht leer sein",
  AppMessage.indentEditor: "Einrücken (Editor)",
  AppMessage.outdentEditor: "Ausrücken (Editor)",
  AppMessage.newDocument2: "Neues Dokument",
  AppMessage.openDocument2: "Dokument öffnen",
  AppMessage.closeDocument2: "Dokument schließen",
  AppMessage.find: "Suchen",
  AppMessage.findAndReplace2: "Suchen und ersetzen",
  AppMessage.nextMatch: "Nächster Treffer",
  AppMessage.previousMatch: "Vorheriger Treffer",
  AppMessage.bold: "Fett",
  AppMessage.italic: "Kursiv",
  AppMessage.inlineCode: "Inline-Code",
  AppMessage.strikethrough: "Durchgestrichen",
  AppMessage.editorMode: "Editor-Modus",
  AppMessage.splitMode: "Geteilter Modus",
  AppMessage.previewMode: "Vorschaumodus",
  AppMessage.allSyntax: "Gesamte Syntax",
  AppMessage.quitApp: "App beenden",
  AppMessage.cut: "Ausschneiden",
  AppMessage.copy: "Kopieren",
  AppMessage.paste: "Einfügen",
  AppMessage.selectAll: "Alles auswählen",
  AppMessage.shortcutFooter:
      "Esc schließt die Suche oder das Syntaxfenster. Textfelder behalten die nativen Tastenkürzel für Zwischenablage und Rückgängig.",
};
