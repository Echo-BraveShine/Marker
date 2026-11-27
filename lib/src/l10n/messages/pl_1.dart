part of '../message_catalog.dart';

const _pl1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Używa bieżącej zawartości edytora; oryginalny dokument pozostaje bez zmian.",
  AppMessage.organizeSavesCurrentContent:
      "Porządkowanie zapisuje bieżącą zawartość edytora; wszystkie oryginalne obrazy są zachowywane.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nNiedostępne obrazy zachowują swoje oryginalne odwołania.",
  AppMessage.embeddedImagesTooLarge: "Osadzone obrazy przekraczają 128 MB.",
  AppMessage.imageExceedsSizeLimit: "Obraz przekracza 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "Obraz przekracza 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Zapisz dokument, aby odnaleźć obraz: {p0}",
  AppMessage.splitImagesTooLarge: "Podzielone obrazy przekraczają 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Nieprawidłowe wymiary obrazu lub dokument jest zbyt długi.",
  AppMessage.documentTooLargeForSinglePng:
      "Dokument jest zbyt duży dla jednego pliku PNG. Włącz Podziel obrazy (ZIP).",
  AppMessage.cannotOpenLink: "Nie można otworzyć linku.",
  AppMessage.cannotReadOriginalImage: "Nie można odczytać oryginalnego obrazu",
  AppMessage.cannotWriteImageAssets: "Nie można zapisać zasobów obrazów",
  AppMessage.cannotProcessImageRetry:
      "Nie można przetworzyć tego obrazu. Sprawdź go i spróbuj ponownie.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Import anulowany. Oryginalne obrazy pozostają bez zmian.",
  AppMessage.importStoppedImagesInserted:
      "Import zatrzymany. Wstawiono obrazy: {p0}.",
  AppMessage.originalLocationReferencesInserted:
      "Wstawiono odwołania do oryginalnych lokalizacji. Przeniesienie oryginalnych obrazów może je zepsuć.",
  AppMessage.imagesInsertedOriginalsKept:
      "Wstawiono obrazy: {p0}. Oryginały zachowane.",
  AppMessage.unsupportedSyntaxKept:
      "Niestandardowa składnia pozostała bez zmian.",
  AppMessage.cannotReadOrCopyImage:
      "Nie można odczytać ani skopiować obrazu. Sprawdź uprawnienia i dostępne miejsce.",
  AppMessage.headings: "Nagłówki",
  AppMessage.listsAndBlocks: "Listy i bloki",
  AppMessage.linksAndExtensions: "Linki i rozszerzenia",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Odzyskane niezapisane dokumenty",
  AppMessage.file: "Plik",
  AppMessage.openFile: "Otwórz plik",
  AppMessage.save: "Zapisz",
  AppMessage.export: "Eksportuj",
  AppMessage.exportHtml: "Eksportuj HTML",
  AppMessage.exportPdf: "Eksportuj PDF",
  AppMessage.settings: "Ustawienia",
  AppMessage.theme: "Motyw",
  AppMessage.themeLight: "Jasny",
  AppMessage.themeDark: "Ciemny",
  AppMessage.themeSystem: "Systemowy",
  AppMessage.fontSize: "znaki",
  AppMessage.language: "Język",
  AppMessage.languageZh: "Chiński",
  AppMessage.languageEn: "Angielski",
  AppMessage.edit: "Edytuj",
  AppMessage.preview: "Podgląd",
  AppMessage.split: "Podział",
  AppMessage.statusLine: "Wiersz 1, kolumna 1",
  AppMessage.closeDocument: "Zamknij dokument",
  AppMessage.rename: "Zmień nazwę…",
  AppMessage.moveToTrash: "Przenieś do kosza…",
  AppMessage.moveToTrashPrompt: "Przenieść dokument do kosza?",
  AppMessage.moveToTrashContent:
      "Dokument zostanie przeniesiony do kosza; powiązane obrazy zostaną zachowane. Niezapisane zmiany zostaną zamknięte.",
  AppMessage.saveAs: "Zapisz jako",
  AppMessage.saveChanges: "Zapisać zmiany?",
  AppMessage.discard: "Odrzuć",
  AppMessage.pathConflict:
      "Inny otwarty dokument używa tej ścieżki. Wybierz inną ścieżkę.",
  AppMessage.saveCancelled:
      "Zapisywanie anulowane. Zawartość dokumentu została zachowana.",
  AppMessage.fileOperationFailed: "Operacja na pliku nie powiodła się",
  AppMessage.unableToExport: "Nie można wyeksportować dokumentu",
  AppMessage.importImages: "Importuj obrazy",
  AppMessage.stopRemainingWork: "Zatrzymaj pozostałą pracę",
  AppMessage.cannotReadImages:
      "Nie można odczytać obrazów. Sprawdź dostęp do folderu.",
  AppMessage.importOrPasteImages:
      "Importuj obrazy lub wklej zrzut ekranu.\nOryginały są zachowywane; folder zasobów jest tworzony w razie potrzeby.",
  AppMessage.customSyntaxUnchanged:
      "Część niestandardowej składni pozostała bez zmian",
  AppMessage.localImages: "Obrazy lokalne",
  AppMessage.webImages: "Obrazy z sieci",
  AppMessage.needsAttention: "Wymaga uwagi",
  AppMessage.managed: "Zarządzane",
  AppMessage.linkedUrl: "Powiązany adres URL",
  AppMessage.clickToRepair: "Kliknij, aby naprawić",
  AppMessage.exportFormat: "Format",
  AppMessage.exportA4Info:
      "Strony A4 z tekstem możliwym do zaznaczenia i skopiowania, w tym równania, Mermaid i obrazy.",
  AppMessage.useAppAppearance: "Użyj wyglądu aplikacji",
  AppMessage.imageWidth: "Szerokość obrazu (px)",
  AppMessage.selfContainedHtml:
      "Samodzielny plik HTML z osadzonymi obrazami i diagramami, dostępny offline.",
  AppMessage.version: "Wersja",
  AppMessage.loadingVersion: "Ładowanie wersji…",
  AppMessage.unsavedDoc: "Ten plik jest już otwarty",
  AppMessage.unsupportedLinkType: "Nieobsługiwany typ linku",
  AppMessage.webImageLoadFailed: "Nie udało się załadować obrazu z sieci",
  AppMessage.cannotAccessImage:
      "Brak dostępu do obrazu; zezwól na dostęp do folderu",
  AppMessage.imageNotFound: "Nie znaleziono obrazu",
  AppMessage.locateImage: "Zlokalizuj obraz",
  AppMessage.allowImageFolderAndRetry:
      "Zezwól na folder obrazów i spróbuj ponownie",
  AppMessage.reloadImage: "Odśwież obraz",
  AppMessage.saveToResolveImages:
      "Zapisz dokument, aby odnaleźć obrazy względne",
  AppMessage.stop: "Zatrzymaj",
  AppMessage.toggleSidebar: "Pokaż/ukryj panel boczny",
  AppMessage.resources: "Zasoby",
  AppMessage.files: "Pliki",
  AppMessage.documents: "Dokumenty",
  AppMessage.documentResources: "Zasoby dokumentu",
  AppMessage.newDocument: "Nowy",
  AppMessage.openDocument: "Otwórz",
  AppMessage.undo: "Cofnij",
  AppMessage.redo: "Ponów",
  AppMessage.findAndReplace: "Znajdź i zamień",
  AppMessage.textColor: "Kolor tekstu",
  AppMessage.equationTemplates: "Szablony równań",
  AppMessage.mermaidTemplates: "Szablony Mermaid",
  AppMessage.allMarkdownSyntax: "Cała składnia Markdown",
  AppMessage.serifFont: "Czcionka szeryfowa",
  AppMessage.startWriting: "Zacznij pisać…",
  AppMessage.auto: "Automatyczny",
  AppMessage.general: "Ogólne",
  AppMessage.editorAndPreview: "Edytor i podgląd",
  AppMessage.keyboardShortcuts: "Skróty klawiszowe",
  AppMessage.about: "O aplikacji",
  AppMessage.appearance: "Wygląd",
  AppMessage.interfaceLanguage: "Język",
  AppMessage.versionUnavailable: "Wersja niedostępna",
  AppMessage.focusedMarkdown:
      "Skupione pisanie w Markdown z podglądem na żywo.",
  AppMessage.checkForUpdates: "Sprawdź aktualizacje",
};
