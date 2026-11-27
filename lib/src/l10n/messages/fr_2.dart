part of '../message_catalog.dart';

const _fr2 = <AppMessage, String>{
  AppMessage.versionAvailable: "est disponible",
  AppMessage.requestLimited: "Requête limitée. Réessayez plus tard.",
  AppMessage.cannotConnect:
      "Connexion impossible. Vérifiez votre connexion et réessayez.",
  AppMessage.cannotReadVersion:
      "Impossible de lire la version installée. Veuillez réessayer.",
  AppMessage.invalidReleaseInfo:
      "Informations de version non valides. Réessayez plus tard.",
  AppMessage.checkFailed:
      "Échec de la vérification. Réessayez ou consultez la page des versions.",
  AppMessage.viewAndDownload: "Voir et télécharger",
  AppMessage.releases: "Versions",
  AppMessage.saveFailed: "Échec de l’enregistrement",
  AppMessage.retry: "Réessayer",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Vos modifications sont conservées en brouillon. Vérifiez l’accès au dossier et l’espace libre.",
  AppMessage.exportComplete: "Exportation terminée.",
  AppMessage.exportedToValue: "Exporté vers {p0}",
  AppMessage.remainingWorkStopped: "Travail restant arrêté",
  AppMessage.thisFileIsAlreadyOpen: "Ce fichier est déjà ouvert",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Le fichier existant a été ouvert sans être écrasé.",
  AppMessage.lnValueColValue: "Lig. {p0}, Col. {p1}",
  AppMessage.characters: "caractères",
  AppMessage.unsavedDraftsRestored: "Brouillons non enregistrés restaurés.",
  AppMessage.draftNotSavedToFile: "Brouillon · Non enregistré dans un fichier",
  AppMessage.saving: "Enregistrement…",
  AppMessage.saveFailedRetry: "Échec de l’enregistrement · Réessayer",
  AppMessage.fileChangedResolve: "Fichier modifié · Résoudre",
  AppMessage.fileDeleted: "Fichier supprimé",
  AppMessage.pendingSave: "Enregistrement en attente…",
  AppMessage.saved: "Enregistré",
  AppMessage.fileChangedOnDisk: "Fichier modifié sur le disque",
  AppMessage.loadDiskVersion: "Charger la version du disque",
  AppMessage.overwriteWithMyVersion: "Écraser avec ma version",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Enregistrement automatique en pause. Vos modifications sont conservées en brouillon.",
  AppMessage.sentToTheSelectedApp: "Envoyé à l’application sélectionnée.",
  AppMessage.images: "Images",
  AppMessage.addImage: "Ajouter une image",
  AppMessage.takePhoto: "Prendre une photo",
  AppMessage.chooseFromPhotos: "Choisir dans Photos",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Autorisez Marker à accéder à l’appareil photo ou à Photos dans les réglages du système.",
  AppMessage.saveInMarker: "Enregistrer dans Marker",
  AppMessage.fileName: "Nom du fichier",
  AppMessage.enterAFileNameWithoutSlashes:
      "Saisissez un nom de fichier sans barres obliques.",
  AppMessage.fileAlreadyExists: "Le fichier existe déjà",
  AppMessage.replaceExistingFile: "Remplacer le fichier existant",
  AppMessage.cannotImportFileValue: "Impossible d’importer le fichier : {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "{p0} fichier(s) n’ont pas pu être importés. Les autres documents sont ouverts.",
  AppMessage.openedDocumentMissingImages:
      "Document ouvert avec des images manquantes. Importez un ZIP contenant le document et les images.",
  AppMessage.openedTheExistingCopyInMarker:
      "La copie existante a été ouverte dans Marker.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Copie importée. Les modifications ne changeront pas le fichier d’origine.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Choisissez un modèle à insérer. Le texte sélectionné remplace l’exemple.",
  AppMessage.syntaxHighlighting: "Coloration syntaxique",
  AppMessage.editor: "Éditeur",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Impossible de décoder l’image ; vérifiez son format ou son intégrité",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Enregistrez le document pour résoudre les images relatives",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Modifications du disque synchronisées. Les modifications non enregistrées ont été conservées.",
  AppMessage.saveNow: "Enregistrer maintenant",
  AppMessage.deleteDocument: "Supprimer le document",
  AppMessage.deleteDocument2: "Supprimer le document ?",
  AppMessage.deleteDocumentConfirmation:
      "Supprimer définitivement ce document de Marker. Les images sont conservées. Les modifications non enregistrées seront également fermées.",
  AppMessage.delete: "Supprimer",
  AppMessage.fileOperationFailedValue:
      "Échec de l’opération sur le fichier : {p0}",
  AppMessage.valueHasUnsavedChanges:
      "{p0} contient des modifications non enregistrées.",
  AppMessage.exportDocument: "Exporter le document",
  AppMessage.exportingDocument: "Exportation du document…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Consultez la dernière version publique sur GitHub.",
  AppMessage.checkingForUpdates: "Recherche de mises à jour…",
  AppMessage.noPublicReleaseWasFound: "Aucune version publique trouvée.",
  AppMessage.youAreUpToDate: "Vous êtes à jour.",
  AppMessage.valueHasUnsavedChanges2:
      "{p0} contient des modifications non enregistrées.",
  AppMessage.versionValueIsAvailable: "La version {p0} est disponible",
  AppMessage.importImagesCopyOriginals:
      "Importer des images (copier les originaux)",
  AppMessage.linkOriginalLocation: "Lier l’emplacement d’origine…",
  AppMessage.pasteImage: "Coller l’image",
  AppMessage.insertWebImage: "Insérer une image web…",
  AppMessage.organizeDocumentImages: "Organiser les images du document…",
  AppMessage.cleanUnusedResources: "Nettoyer les ressources inutilisées…",
  AppMessage.allowFolderAccess: "Autoriser l’accès au dossier…",
  AppMessage.newDocumentFolder: "Nouveau dossier de documents…",
  AppMessage.renameDocument: "Renommer le document…",
  AppMessage.packageDocumentAndImages: "Empaqueter le document et les images…",
  AppMessage.organizeDocumentImages2: "Organiser les images du document",
  AppMessage.organizingImages: "Organisation des images",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Images organisées. Fichiers d’origine conservés.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Images organisées dans l’éditeur. Enregistrez le document.",
  AppMessage.image: "Image",
  AppMessage.locateInEditor: "Localiser dans l’éditeur",
  AppMessage.insertAtCursor: "Insérer au curseur",
  AppMessage.viewImage: "Afficher l’image",
  AppMessage.openImage: "Ouvrir l’image",
  AppMessage.showInFileManager: "Afficher dans le gestionnaire de fichiers",
  AppMessage.copyReferencePath: "Copier le chemin de référence",
  AppMessage.locateImage2: "Localiser l’image…",
  AppMessage.replaceWithImportedImage: "Remplacer par une image importée…",
  AppMessage.downloadToDocumentAssets:
      "Télécharger dans les ressources du document",
  AppMessage.reload: "Recharger",
  AppMessage.referenceCopied: "Référence copiée",
  AppMessage.updatingImage: "Mise à jour de l’image",
  AppMessage.downloadingImage: "Téléchargement de l’image",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Aucun candidat sûr à nettoyer. Les références enregistrées et partagées sont protégées.",
  AppMessage.moveToTrash2: "Mettre à la corbeille ?",
  AppMessage.unreferencedImagesDescription:
      "Ces images importées ne sont référencées ni par le contenu actuel, ni par les versions enregistrées, ni par les documents connus. Confirmez que d’autres outils ne les utilisent plus.",
  AppMessage.moveToTrash3: "Mettre à la corbeille",
  AppMessage.cleaningResources: "Nettoyage des ressources",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} images déplacées à la corbeille. Les ressources référencées ou modifiées sont conservées.",
  AppMessage.chooseLocation: "Choisir l’emplacement",
  AppMessage.newDocumentFolder2: "Nouveau dossier de documents",
  AppMessage.folderName: "Nom du dossier",
  AppMessage.enterAValidFolderName: "Saisissez un nom de dossier valide.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "Le dossier existe déjà. Choisissez un autre nom.",
  AppMessage.renameDocument2: "Renommer le document",
  AppMessage.documentName: "Nom du document",
  AppMessage.invalidDocumentName: "Nom de document non valide.",
  AppMessage.saveAndRename: "Enregistrer et renommer ?",
};
