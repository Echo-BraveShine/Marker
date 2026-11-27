part of '../message_catalog.dart';

const _fr3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Le contenu actuel sera enregistré. Le dossier de ressources et les références d’images de ce document seront également renommés. Les références provenant d’autres documents doivent être mises à jour séparément.",
  AppMessage.rename2: "Renommer",
  AppMessage.renamingDocument: "Renommage du document",
  AppMessage.packageDocumentAndImages2: "Empaqueter le document et les images",
  AppMessage.packagingDocument: "Empaquetage du document",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Paquet créé avec des références qui doivent encore être réparées.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Document actuel et images empaquetés.",
  AppMessage.dropToImportImages: "Déposez pour importer des images",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Copier dans les ressources du document. Les originaux sont conservés.",
  AppMessage.saveTheDocumentFirst: "Enregistrez d’abord le document",
  AppMessage.saveBeforeImportImages:
      "Enregistrez d’abord pour que les images soient stockées à côté du document via des chemins relatifs portables.",
  AppMessage.saveAndContinue: "Enregistrer et continuer",
  AppMessage.allowFolderAccess2: "Autoriser l’accès au dossier",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Choisissez le dossier contenant ou l’un de ses dossiers parents.",
  AppMessage.folderAccessGranted: "Accès au dossier autorisé.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Le document a changé. Importez à nouveau les images.",
  AppMessage.importingImages: "Importation des images",
  AppMessage.noTextOrImageToPaste: "Aucun texte ou image à coller.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Les images du presse-papiers ne sont pas disponibles dans cet environnement.",
  AppMessage.dropAccessDenied:
      "Le système n’a pas pu autoriser l’accès aux fichiers déposés. Utilisez Importer des images pour les sélectionner.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Déposez des images PNG, JPEG, GIF, WebP ou BMP.",
  AppMessage.insertWebImage2: "Insérer une image web",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Saisissez une URL d’image HTTP ou HTTPS valide.",
  AppMessage.imageDescription: "Description de l’image",
  AppMessage.unsupportedImageAddress: "Adresse d’image non prise en charge",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Utilisez Enregistrer sous pour déplacer le document vers un autre dossier.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "Un fichier portant ce nom existe déjà.",
  AppMessage.theSourceDocumentIsUnavailable:
      "Le document source est indisponible.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Un dossier de ressources portant le nouveau nom existe déjà. Rien n’a été renommé.",
  AppMessage.resolveImagesBeforeExport:
      "Résolvez les images indisponibles ou conservez explicitement leurs références d’origine.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Cette image n’est pas référencée dans le document.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Impossible de charger l’image. Réessayez ou vérifiez le réseau et l’accès aux fichiers.",
  AppMessage.more: "Plus",
  AppMessage.cannotOverwriteASymbolicLink:
      "Impossible d’écraser un lien symbolique.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "Le répertoire de ressources n’est pas un dossier standard.",
  AppMessage.noAvailableResourceDirectoryName:
      "Aucun nom de répertoire de ressources disponible.",
  AppMessage.tooManyImageNameConflicts: "Trop de conflits de noms d’images.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Image non valide ; utilisez PNG, JPEG, GIF, WebP ou BMP.",
  AppMessage.imageExceeds50MB: "L’image dépasse 50 Mo.",
  AppMessage.imageExceeds50MB2: "L’image dépasse 50 Mo.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Impossible d’écraser un lien symbolique.",
  AppMessage.unsupportedImageURL: "URL d’image non prise en charge.",
  AppMessage.downloadFailedHTTPValue: "Échec du téléchargement : HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Trop de redirections d’image.",
  AppMessage.continueText: "Continuer",
  AppMessage.someImagesNeedAttention:
      "Certaines images nécessitent une attention",
  AppMessage.partialResourceCopyWarning:
      "Ces références ne peuvent pas être entièrement copiées. Réparez-les d’abord ou continuez en conservant leurs adresses d’origine.",
  AppMessage.customSyntax: "Syntaxe personnalisée",
  AppMessage.continueWithOriginalAddresses:
      "Continuer avec les adresses d’origine",
  AppMessage.resourceInventorySummary:
      "{p0} images locales ({p1} gérées), {p2} images web.\n{p3} images à copier ; {p4} Mo d’images locales.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Télécharger aussi les images web",
  AppMessage.copyLocalImages: "Copier les images locales",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "L’accès au dossier est requis. Autorisez l’accès à cet emplacement et réessayez.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Le fichier ou le dossier est manquant, a été déplacé ou n’est pas téléchargé localement.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Le disque est plein. Libérez de l’espace et réessayez.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Cet emplacement est en lecture seule. Choisissez un dossier accessible en écriture.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Échec de l’opération sur le fichier. Vérifiez l’emplacement et les détails du système ci-dessous.",
  AppMessage.location: "Emplacement",
  AppMessage.unknown: "inconnu",
  AppMessage.error: "erreur",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Impossible de traiter l’image. Vérifiez son format ou la connexion et réessayez.",
  AppMessage.someImagesCouldNotBeCopied:
      "Certaines images n’ont pas pu être copiées",
  AppMessage.originalImagesUnchanged:
      "Les fichiers d’origine sont inchangés. Réparez ces images ou conservez leurs adresses et continuez.",
  AppMessage.keepAddressesAndContinue: "Conserver les adresses et continuer",
  AppMessage.operationResult: "Résultat de l’opération",
  AppMessage.imageDimensionsAreTooLarge:
      "Les dimensions de l’image sont trop grandes.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Une opération sur les ressources est déjà en cours.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Seuls les fichiers dans Marker peuvent être supprimés.",
  AppMessage.trashFailedFileKept:
      "Impossible de mettre à la corbeille. Le fichier d’origine a été conservé. Vérifiez l’accès au dossier ou la corbeille.",
  AppMessage.allowFolderAccess3: "Autoriser l’accès au dossier",
  AppMessage.allowFolderAccess4: "Autoriser l’accès au dossier",
  AppMessage.folderAccessPurpose:
      "Marker a besoin de ce dossier pour lire des images ou créer des ressources à côté de votre document. Autorisez l’accès pour continuer ou annulez pour arrêter cette opération.\n{p0}",
  AppMessage.classic: "Classique",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "L’exportation a expiré. Essayez de réduire le nombre d’images ou de diagrammes.",
  AppMessage.exportFileAccessFailed:
      "Impossible d’accéder à une image ou à la destination. Vérifiez que le fichier existe, les autorisations du dossier et l’espace libre.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Impossible de télécharger une image distante. Vérifiez votre connexion ou utilisez une image locale.",
  AppMessage.exportIncomplete:
      "L’exportation ne s’est pas terminée. Aucun résultat n’a été écrit. Vérifiez les images, les équations et la syntaxe Mermaid. Pour les longs documents, choisissez PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Fractionner les images (ZIP)",
  AppMessage.saveToFiles: "Enregistrer dans Fichiers",
  AppMessage.unsupportedExportFormat: "Format d’exportation non pris en charge",
  AppMessage.pleaseSelectAnExportPath:
      "Veuillez sélectionner un chemin d’exportation",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Veuillez sélectionner un fichier plutôt qu’un dossier",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Les fichiers Markdown ne peuvent pas servir de destination d’exportation",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Le chemin d’exportation ne peut pas être identique au fichier source",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "La destination est un dossier. Choisissez un autre nom de fichier.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "Le résultat existe déjà. Sélectionnez directement {p0} dans la boîte de dialogue d’enregistrement.",
  AppMessage.exportDataCannotBeEmpty:
      "Les données d’exportation ne peuvent pas être vides",
  AppMessage.indentEditor: "Augmenter le retrait (éditeur)",
  AppMessage.outdentEditor: "Réduire le retrait (éditeur)",
  AppMessage.newDocument2: "Nouveau document",
  AppMessage.openDocument2: "Ouvrir un document",
  AppMessage.closeDocument2: "Fermer le document",
  AppMessage.find: "Rechercher",
  AppMessage.findAndReplace2: "Rechercher et remplacer",
  AppMessage.nextMatch: "Occurrence suivante",
  AppMessage.previousMatch: "Occurrence précédente",
  AppMessage.bold: "Gras",
  AppMessage.italic: "Italique",
  AppMessage.inlineCode: "Code en ligne",
  AppMessage.strikethrough: "Barré",
  AppMessage.editorMode: "Mode éditeur",
  AppMessage.splitMode: "Mode fractionné",
  AppMessage.previewMode: "Mode aperçu",
  AppMessage.allSyntax: "Toute la syntaxe",
  AppMessage.quitApp: "Quitter l’application",
  AppMessage.cut: "Couper",
  AppMessage.copy: "Copier",
  AppMessage.paste: "Coller",
  AppMessage.selectAll: "Tout sélectionner",
  AppMessage.shortcutFooter:
      "Échap ferme la recherche ou le panneau de syntaxe. Les champs de texte conservent les raccourcis natifs du presse-papiers et d’annulation.",
};
