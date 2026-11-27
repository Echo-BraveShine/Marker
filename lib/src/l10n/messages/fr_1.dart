part of '../message_catalog.dart';

const _fr1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Utilise le contenu actuel de l’éditeur ; le document d’origine reste inchangé.",
  AppMessage.organizeSavesCurrentContent:
      "L’organisation enregistre le contenu actuel de l’éditeur ; toutes les images d’origine sont conservées.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nLes images indisponibles conservent leurs références d’origine.",
  AppMessage.embeddedImagesTooLarge: "Les images intégrées dépassent 128 Mo.",
  AppMessage.imageExceedsSizeLimit: "L’image dépasse 25 Mo.",
  AppMessage.imageExceedsSizeLimitAt: "L’image dépasse 25 Mo : {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Enregistrez le document pour résoudre l’image : {p0}",
  AppMessage.splitImagesTooLarge: "Les images fractionnées dépassent 64 Mo.",
  AppMessage.invalidImageExportDimensions:
      "Dimensions d’image non valides ou document trop long.",
  AppMessage.documentTooLargeForSinglePng:
      "Document trop volumineux pour un seul PNG. Activez Fractionner les images (ZIP).",
  AppMessage.cannotOpenLink: "Impossible d’ouvrir le lien.",
  AppMessage.cannotReadOriginalImage: "Impossible de lire l’image d’origine",
  AppMessage.cannotWriteImageAssets:
      "Impossible d’écrire les ressources d’image",
  AppMessage.cannotProcessImageRetry:
      "Impossible de traiter cette image. Vérifiez-la et réessayez.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Importation annulée. Les images d’origine sont inchangées.",
  AppMessage.importStoppedImagesInserted:
      "Importation arrêtée. {p0} images insérées.",
  AppMessage.originalLocationReferencesInserted:
      "Références à l’emplacement d’origine insérées. Déplacer les images d’origine peut les rendre invalides.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} images insérées. Originaux conservés.",
  AppMessage.unsupportedSyntaxKept: "La syntaxe personnalisée reste inchangée.",
  AppMessage.cannotReadOrCopyImage:
      "Impossible de lire ou de copier l’image. Vérifiez les autorisations et l’espace disponible.",
  AppMessage.headings: "Titres",
  AppMessage.listsAndBlocks: "Listes et blocs",
  AppMessage.linksAndExtensions: "Liens et extensions",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Documents non enregistrés récupérés",
  AppMessage.file: "Fichier",
  AppMessage.openFile: "Ouvrir un fichier",
  AppMessage.save: "Enregistrer",
  AppMessage.export: "Exporter",
  AppMessage.exportHtml: "Exporter en HTML",
  AppMessage.exportPdf: "Exporter en PDF",
  AppMessage.settings: "Réglages",
  AppMessage.theme: "Thème",
  AppMessage.themeLight: "Clair",
  AppMessage.themeDark: "Sombre",
  AppMessage.themeSystem: "Système",
  AppMessage.fontSize: "caractères",
  AppMessage.language: "Langue",
  AppMessage.languageZh: "Chinois",
  AppMessage.languageEn: "Anglais",
  AppMessage.edit: "Modifier",
  AppMessage.preview: "Aperçu",
  AppMessage.split: "Fractionné",
  AppMessage.statusLine: "Ligne 1, Colonne 1",
  AppMessage.closeDocument: "Fermer le document",
  AppMessage.rename: "Renommer…",
  AppMessage.moveToTrash: "Mettre à la corbeille…",
  AppMessage.moveToTrashPrompt: "Mettre le document à la corbeille ?",
  AppMessage.moveToTrashContent:
      "Le document va à la corbeille ; les images associées sont conservées. Les modifications non enregistrées seront fermées.",
  AppMessage.saveAs: "Enregistrer sous",
  AppMessage.saveChanges: "Enregistrer les modifications ?",
  AppMessage.discard: "Ignorer",
  AppMessage.pathConflict:
      "Un autre document ouvert utilise ce chemin. Choisissez un autre chemin.",
  AppMessage.saveCancelled:
      "Enregistrement annulé. Le contenu de votre document est conservé.",
  AppMessage.fileOperationFailed: "Échec de l’opération sur le fichier",
  AppMessage.unableToExport: "Impossible d’exporter le document",
  AppMessage.importImages: "Importer des images",
  AppMessage.stopRemainingWork: "Arrêter le travail restant",
  AppMessage.cannotReadImages:
      "Impossible de lire les images. Vérifiez l’accès au dossier.",
  AppMessage.importOrPasteImages:
      "Importez des images ou collez une capture d’écran.\nLes originaux sont conservés ; le dossier de ressources est créé si nécessaire.",
  AppMessage.customSyntaxUnchanged:
      "Une partie de la syntaxe personnalisée reste inchangée",
  AppMessage.localImages: "Images locales",
  AppMessage.webImages: "Images web",
  AppMessage.needsAttention: "Nécessite une attention",
  AppMessage.managed: "Gérées",
  AppMessage.linkedUrl: "URL liée",
  AppMessage.clickToRepair: "Cliquez pour réparer",
  AppMessage.exportFormat: "Format",
  AppMessage.exportA4Info:
      "Pages A4 avec texte sélectionnable et copiable, y compris les équations, Mermaid et les images.",
  AppMessage.useAppAppearance: "Utiliser l’apparence de l’app",
  AppMessage.imageWidth: "Largeur de l’image (px)",
  AppMessage.selfContainedHtml:
      "HTML autonome avec images et diagrammes intégrés, disponible hors ligne.",
  AppMessage.version: "Version",
  AppMessage.loadingVersion: "Chargement de la version…",
  AppMessage.unsavedDoc: "Ce fichier est déjà ouvert",
  AppMessage.unsupportedLinkType: "Type de lien non pris en charge",
  AppMessage.webImageLoadFailed: "Impossible de charger l’image web",
  AppMessage.cannotAccessImage:
      "Impossible d’accéder à l’image ; autorisez l’accès au dossier",
  AppMessage.imageNotFound: "Image introuvable",
  AppMessage.locateImage: "Localiser l’image",
  AppMessage.allowImageFolderAndRetry:
      "Autoriser le dossier d’images et réessayer",
  AppMessage.reloadImage: "Recharger l’image",
  AppMessage.saveToResolveImages:
      "Enregistrez le document pour résoudre les images relatives",
  AppMessage.stop: "Arrêter",
  AppMessage.toggleSidebar: "Afficher/masquer la barre latérale",
  AppMessage.resources: "Ressources",
  AppMessage.files: "Fichiers",
  AppMessage.documents: "Documents",
  AppMessage.documentResources: "Ressources du document",
  AppMessage.newDocument: "Nouveau",
  AppMessage.openDocument: "Ouvrir",
  AppMessage.undo: "Annuler",
  AppMessage.redo: "Rétablir",
  AppMessage.findAndReplace: "Rechercher et remplacer",
  AppMessage.textColor: "Couleur du texte",
  AppMessage.equationTemplates: "Modèles d’équation",
  AppMessage.mermaidTemplates: "Modèles Mermaid",
  AppMessage.allMarkdownSyntax: "Toute la syntaxe Markdown",
  AppMessage.serifFont: "Police à empattements",
  AppMessage.startWriting: "Commencez à écrire…",
  AppMessage.auto: "Auto",
  AppMessage.general: "Général",
  AppMessage.editorAndPreview: "Éditeur et aperçu",
  AppMessage.keyboardShortcuts: "Raccourcis clavier",
  AppMessage.about: "À propos",
  AppMessage.appearance: "Apparence",
  AppMessage.interfaceLanguage: "Langue",
  AppMessage.versionUnavailable: "Version indisponible",
  AppMessage.focusedMarkdown:
      "Écriture Markdown concentrée et aperçu en direct.",
  AppMessage.checkForUpdates: "Rechercher des mises à jour",
};
