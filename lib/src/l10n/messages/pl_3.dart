part of '../message_catalog.dart';

const _pl3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Bieżąca zawartość zostanie zapisana. Folder zasobów i odwołania do obrazów w tym dokumencie również zostaną zmienione. Odwołania z innych dokumentów wymagają osobnej aktualizacji.",
  AppMessage.rename2: "Zmień nazwę",
  AppMessage.renamingDocument: "Zmienianie nazwy dokumentu",
  AppMessage.packageDocumentAndImages2: "Spakuj dokument i obrazy",
  AppMessage.packagingDocument: "Pakowanie dokumentu",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Utworzono pakiet z odwołaniami, które nadal wymagają naprawy.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Spakowano bieżący dokument i obrazy.",
  AppMessage.dropToImportImages: "Upuść, aby zaimportować obrazy",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Kopiuj do zasobów dokumentu. Oryginały są zachowywane.",
  AppMessage.saveTheDocumentFirst: "Najpierw zapisz dokument",
  AppMessage.saveBeforeImportImages:
      "Najpierw zapisz, aby obrazy mogły być przechowywane obok dokumentu przy użyciu przenośnych ścieżek względnych.",
  AppMessage.saveAndContinue: "Zapisz i kontynuuj",
  AppMessage.allowFolderAccess2: "Zezwól na dostęp do folderu",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Wybierz folder, w którym znajduje się plik, lub jeden z jego folderów nadrzędnych.",
  AppMessage.folderAccessGranted: "Przyznano dostęp do folderu.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Dokument zmienił się. Zaimportuj obrazy ponownie.",
  AppMessage.importingImages: "Importowanie obrazów",
  AppMessage.noTextOrImageToPaste: "Brak tekstu lub obrazu do wklejenia.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Obrazy ze schowka są niedostępne w tym środowisku.",
  AppMessage.dropAccessDenied:
      "System nie mógł przyznać dostępu do upuszczonych plików. Użyj opcji Importuj obrazy, aby je wybrać.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Upuść obrazy PNG, JPEG, GIF, WebP lub BMP.",
  AppMessage.insertWebImage2: "Wstaw obraz z sieci",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Wprowadź prawidłowy adres URL obrazu HTTP lub HTTPS.",
  AppMessage.imageDescription: "Opis obrazu",
  AppMessage.unsupportedImageAddress: "Nieobsługiwany adres obrazu",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Użyj opcji Zapisz jako, aby przenieść dokument do innego folderu.",
  AppMessage.aFileWithThisNameAlreadyExists: "Plik o tej nazwie już istnieje.",
  AppMessage.theSourceDocumentIsUnavailable:
      "Dokument źródłowy jest niedostępny.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Folder zasobów o nowej nazwie już istnieje. Nic nie zmieniono.",
  AppMessage.resolveImagesBeforeExport:
      "Rozwiąż niedostępne obrazy lub wyraźnie zachowaj ich oryginalne odwołania.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Ten obraz nie jest przywoływany w dokumencie.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Nie można załadować obrazu. Ponów lub sprawdź sieć i dostęp do plików.",
  AppMessage.more: "Więcej",
  AppMessage.cannotOverwriteASymbolicLink:
      "Nie można nadpisać dowiązania symbolicznego.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "Katalog zasobów nie jest zwykłym katalogiem.",
  AppMessage.noAvailableResourceDirectoryName:
      "Brak dostępnej nazwy katalogu zasobów.",
  AppMessage.tooManyImageNameConflicts: "Zbyt wiele konfliktów nazw obrazów.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Nieprawidłowy obraz; użyj PNG, JPEG, GIF, WebP lub BMP.",
  AppMessage.imageExceeds50MB: "Obraz przekracza 50 MB.",
  AppMessage.imageExceeds50MB2: "Obraz przekracza 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Nie można nadpisać dowiązania symbolicznego.",
  AppMessage.unsupportedImageURL: "Nieobsługiwany adres URL obrazu.",
  AppMessage.downloadFailedHTTPValue: "Pobieranie nie powiodło się: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Zbyt wiele przekierowań obrazu.",
  AppMessage.continueText: "Kontynuuj",
  AppMessage.someImagesNeedAttention: "Niektóre obrazy wymagają uwagi",
  AppMessage.partialResourceCopyWarning:
      "Tych odwołań nie można w pełni skopiować. Najpierw je napraw lub kontynuuj, zachowując ich oryginalne adresy.",
  AppMessage.customSyntax: "Niestandardowa składnia",
  AppMessage.continueWithOriginalAddresses: "Kontynuuj z oryginalnymi adresami",
  AppMessage.resourceInventorySummary:
      "Obrazy lokalne: {p0} (zarządzane: {p1}), obrazy z sieci: {p2}.\nDo skopiowania: {p3} obrazów; obrazy lokalne: {p4} MB.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Pobierz także obrazy z sieci",
  AppMessage.copyLocalImages: "Kopiuj obrazy lokalne",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Wymagany jest dostęp do folderu. Zezwól na dostęp do tej lokalizacji i spróbuj ponownie.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Plik lub folder nie istnieje, został przeniesiony albo nie został pobrany lokalnie.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Dysk jest pełny. Zwolnij miejsce i spróbuj ponownie.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Ta lokalizacja jest tylko do odczytu. Wybierz folder z prawem zapisu.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Operacja na pliku nie powiodła się. Sprawdź lokalizację i szczegóły systemu poniżej.",
  AppMessage.location: "Lokalizacja",
  AppMessage.unknown: "nieznane",
  AppMessage.error: "błąd",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Nie można przetworzyć obrazu. Sprawdź jego format lub połączenie i spróbuj ponownie.",
  AppMessage.someImagesCouldNotBeCopied:
      "Nie udało się skopiować niektórych obrazów",
  AppMessage.originalImagesUnchanged:
      "Oryginalne pliki pozostają bez zmian. Napraw te obrazy lub zachowaj ich adresy i kontynuuj.",
  AppMessage.keepAddressesAndContinue: "Zachowaj adresy i kontynuuj",
  AppMessage.operationResult: "Wynik operacji",
  AppMessage.imageDimensionsAreTooLarge: "Wymiary obrazu są zbyt duże.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Operacja na zasobach jest już w toku.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Można usuwać tylko pliki wewnątrz Markera.",
  AppMessage.trashFailedFileKept:
      "Nie można przenieść do kosza. Oryginalny plik został zachowany. Sprawdź dostęp do folderu lub kosz.",
  AppMessage.allowFolderAccess3: "Zezwól na dostęp do folderu",
  AppMessage.allowFolderAccess4: "Zezwól na dostęp do folderu",
  AppMessage.folderAccessPurpose:
      "Marker potrzebuje tego folderu, aby odczytywać obrazy lub tworzyć zasoby obok dokumentu. Zezwól na dostęp, aby kontynuować, lub anuluj, aby zatrzymać tę operację.\n{p0}",
  AppMessage.classic: "Classic",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Eksport przekroczył limit czasu. Spróbuj zmniejszyć liczbę obrazów lub diagramów.",
  AppMessage.exportFileAccessFailed:
      "Brak dostępu do obrazu lub miejsca docelowego. Sprawdź, czy plik istnieje, uprawnienia folderu i wolne miejsce.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Nie udało się pobrać zdalnego obrazu. Sprawdź połączenie lub użyj obrazu lokalnego.",
  AppMessage.exportIncomplete:
      "Eksport nie został ukończony. Nic nie zapisano. Sprawdź obrazy, równania i składnię Mermaid. W przypadku długich dokumentów wybierz PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Podziel obrazy (ZIP)",
  AppMessage.saveToFiles: "Zapisz w Plikach",
  AppMessage.unsupportedExportFormat: "Nieobsługiwany format eksportu",
  AppMessage.pleaseSelectAnExportPath: "Wybierz ścieżkę eksportu",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Wybierz plik zamiast katalogu",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Pliki Markdown nie mogą być celem eksportu",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Ścieżka eksportu nie może być taka sama jak plik źródłowy",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "Miejsce docelowe to katalog. Wybierz inną nazwę pliku.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "Plik wynikowy już istnieje. Wybierz {p0} bezpośrednio w oknie zapisu.",
  AppMessage.exportDataCannotBeEmpty: "Dane eksportu nie mogą być puste",
  AppMessage.indentEditor: "Zwiększ wcięcie (edytor)",
  AppMessage.outdentEditor: "Zmniejsz wcięcie (edytor)",
  AppMessage.newDocument2: "Nowy dokument",
  AppMessage.openDocument2: "Otwórz dokument",
  AppMessage.closeDocument2: "Zamknij dokument",
  AppMessage.find: "Znajdź",
  AppMessage.findAndReplace2: "Znajdź i zamień",
  AppMessage.nextMatch: "Następne dopasowanie",
  AppMessage.previousMatch: "Poprzednie dopasowanie",
  AppMessage.bold: "Pogrubienie",
  AppMessage.italic: "Kursywa",
  AppMessage.inlineCode: "Kod w wierszu",
  AppMessage.strikethrough: "Przekreślenie",
  AppMessage.editorMode: "Tryb edytora",
  AppMessage.splitMode: "Tryb podziału",
  AppMessage.previewMode: "Tryb podglądu",
  AppMessage.allSyntax: "Cała składnia",
  AppMessage.quitApp: "Zamknij aplikację",
  AppMessage.cut: "Wytnij",
  AppMessage.copy: "Kopiuj",
  AppMessage.paste: "Wklej",
  AppMessage.selectAll: "Zaznacz wszystko",
  AppMessage.shortcutFooter:
      "Esc zamyka wyszukiwanie lub panel składni. Pola tekstowe zachowują natywne skróty schowka i cofania.",
};
