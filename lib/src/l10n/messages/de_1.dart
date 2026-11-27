part of '../message_catalog.dart';

const _de1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Verwendet den aktuellen Editorinhalt; das Originaldokument bleibt unverändert.",
  AppMessage.organizeSavesCurrentContent:
      "Beim Organisieren wird der aktuelle Editorinhalt gespeichert; alle Originalbilder bleiben erhalten.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nNicht verfügbare Bilder behalten ihre ursprünglichen Verweise.",
  AppMessage.embeddedImagesTooLarge:
      "Eingebettete Bilder überschreiten 128 MB.",
  AppMessage.imageExceedsSizeLimit: "Bild überschreitet 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "Bild überschreitet 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Speichere das Dokument, um das Bild aufzulösen: {p0}",
  AppMessage.splitImagesTooLarge: "Geteilte Bilder überschreiten 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Ungültige Bildabmessungen oder Dokument zu lang.",
  AppMessage.documentTooLargeForSinglePng:
      "Dokument zu groß für eine PNG-Datei. Aktiviere „Bilder aufteilen (ZIP)“.",
  AppMessage.cannotOpenLink: "Link kann nicht geöffnet werden.",
  AppMessage.cannotReadOriginalImage: "Originalbild kann nicht gelesen werden",
  AppMessage.cannotWriteImageAssets:
      "Bildressourcen können nicht geschrieben werden",
  AppMessage.cannotProcessImageRetry:
      "Dieses Bild kann nicht verarbeitet werden. Prüfe es und versuche es erneut.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Import abgebrochen. Die Originalbilder bleiben unverändert.",
  AppMessage.importStoppedImagesInserted:
      "Import gestoppt. {p0} Bilder eingefügt.",
  AppMessage.originalLocationReferencesInserted:
      "Verweise auf den Originalort eingefügt. Werden die Originalbilder verschoben, können sie brechen.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} Bilder eingefügt. Originale bleiben erhalten.",
  AppMessage.unsupportedSyntaxKept:
      "Benutzerdefinierte Syntax bleibt unverändert.",
  AppMessage.cannotReadOrCopyImage:
      "Bild kann nicht gelesen oder kopiert werden. Prüfe Berechtigungen und verfügbaren Speicherplatz.",
  AppMessage.headings: "Überschriften",
  AppMessage.listsAndBlocks: "Listen und Blöcke",
  AppMessage.linksAndExtensions: "Links und Erweiterungen",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc:
      "Wiederhergestellte nicht gespeicherte Dokumente",
  AppMessage.file: "Datei",
  AppMessage.openFile: "Datei öffnen",
  AppMessage.save: "Speichern",
  AppMessage.export: "Exportieren",
  AppMessage.exportHtml: "HTML exportieren",
  AppMessage.exportPdf: "PDF exportieren",
  AppMessage.settings: "Einstellungen",
  AppMessage.theme: "Design",
  AppMessage.themeLight: "Hell",
  AppMessage.themeDark: "Dunkel",
  AppMessage.themeSystem: "System",
  AppMessage.fontSize: "Zeichen",
  AppMessage.language: "Sprache",
  AppMessage.languageZh: "Chinesisch",
  AppMessage.languageEn: "Englisch",
  AppMessage.edit: "Bearbeiten",
  AppMessage.preview: "Vorschau",
  AppMessage.split: "Geteilt",
  AppMessage.statusLine: "Zeile 1, Spalte 1",
  AppMessage.closeDocument: "Dokument schließen",
  AppMessage.rename: "Umbenennen…",
  AppMessage.moveToTrash: "In den Papierkorb…",
  AppMessage.moveToTrashPrompt: "Dokument in den Papierkorb verschieben?",
  AppMessage.moveToTrashContent:
      "Das Dokument wird in den Papierkorb verschoben; zugehörige Bilder bleiben erhalten. Nicht gespeicherte Änderungen werden geschlossen.",
  AppMessage.saveAs: "Speichern unter",
  AppMessage.saveChanges: "Änderungen speichern?",
  AppMessage.discard: "Verwerfen",
  AppMessage.pathConflict:
      "Ein anderes geöffnetes Dokument verwendet diesen Pfad. Wähle einen anderen Pfad.",
  AppMessage.saveCancelled:
      "Speichern abgebrochen. Dein Dokumentinhalt bleibt erhalten.",
  AppMessage.fileOperationFailed: "Dateivorgang fehlgeschlagen",
  AppMessage.unableToExport: "Dokument kann nicht exportiert werden",
  AppMessage.importImages: "Bilder importieren",
  AppMessage.stopRemainingWork: "Restliche Arbeit stoppen",
  AppMessage.cannotReadImages:
      "Bilder können nicht gelesen werden. Prüfe den Ordnerzugriff.",
  AppMessage.importOrPasteImages:
      "Importiere Bilder oder füge einen Screenshot ein.\nOriginale bleiben erhalten; der Ressourcenordner wird bei Bedarf erstellt.",
  AppMessage.customSyntaxUnchanged:
      "Einige benutzerdefinierte Syntax bleibt unverändert",
  AppMessage.localImages: "Lokale Bilder",
  AppMessage.webImages: "Web-Bilder",
  AppMessage.needsAttention: "Erfordert Aufmerksamkeit",
  AppMessage.managed: "Verwaltet",
  AppMessage.linkedUrl: "Verknüpfte URL",
  AppMessage.clickToRepair: "Zum Reparieren klicken",
  AppMessage.exportFormat: "Format",
  AppMessage.exportA4Info:
      "A4-Seiten mit auswählbarem, kopierbarem Text, einschließlich Formeln, Mermaid und Bildern.",
  AppMessage.useAppAppearance: "Erscheinungsbild der App verwenden",
  AppMessage.imageWidth: "Bildbreite (px)",
  AppMessage.selfContainedHtml:
      "Eigenständiges HTML mit eingebetteten Bildern und Diagrammen, offline verfügbar.",
  AppMessage.version: "Version",
  AppMessage.loadingVersion: "Version wird geladen…",
  AppMessage.unsavedDoc: "Diese Datei ist bereits geöffnet",
  AppMessage.unsupportedLinkType: "Nicht unterstützter Linktyp",
  AppMessage.webImageLoadFailed: "Web-Bild konnte nicht geladen werden",
  AppMessage.cannotAccessImage:
      "Kein Zugriff auf das Bild; erlaube den Ordnerzugriff",
  AppMessage.imageNotFound: "Bild nicht gefunden",
  AppMessage.locateImage: "Bild suchen",
  AppMessage.allowImageFolderAndRetry:
      "Bildordner erlauben und erneut versuchen",
  AppMessage.reloadImage: "Bild neu laden",
  AppMessage.saveToResolveImages:
      "Speichere das Dokument, um relative Bilder aufzulösen",
  AppMessage.stop: "Stoppen",
  AppMessage.toggleSidebar: "Seitenleiste umschalten",
  AppMessage.resources: "Ressourcen",
  AppMessage.files: "Dateien",
  AppMessage.documents: "Dokumente",
  AppMessage.documentResources: "Dokumentressourcen",
  AppMessage.newDocument: "Neu",
  AppMessage.openDocument: "Öffnen",
  AppMessage.undo: "Rückgängig",
  AppMessage.redo: "Wiederholen",
  AppMessage.findAndReplace: "Suchen und ersetzen",
  AppMessage.textColor: "Textfarbe",
  AppMessage.equationTemplates: "Formelvorlagen",
  AppMessage.mermaidTemplates: "Mermaid-Vorlagen",
  AppMessage.allMarkdownSyntax: "Gesamte Markdown-Syntax",
  AppMessage.serifFont: "Serifenschrift",
  AppMessage.startWriting: "Schreib los…",
  AppMessage.auto: "Auto",
  AppMessage.general: "Allgemein",
  AppMessage.editorAndPreview: "Editor & Vorschau",
  AppMessage.keyboardShortcuts: "Tastenkürzel",
  AppMessage.about: "Über",
  AppMessage.appearance: "Erscheinungsbild",
  AppMessage.interfaceLanguage: "Sprache",
  AppMessage.versionUnavailable: "Version nicht verfügbar",
  AppMessage.focusedMarkdown:
      "Fokussiertes Markdown-Schreiben mit Live-Vorschau.",
  AppMessage.checkForUpdates: "Nach Updates suchen",
};
