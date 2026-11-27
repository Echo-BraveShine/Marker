part of '../message_catalog.dart';

const _es2 = <AppMessage, String>{
  AppMessage.versionAvailable: "está disponible",
  AppMessage.requestLimited: "Solicitud limitada. Inténtalo más tarde.",
  AppMessage.cannotConnect:
      "No se puede conectar. Comprueba tu conexión e inténtalo de nuevo.",
  AppMessage.cannotReadVersion:
      "No se puede leer la versión instalada. Inténtalo de nuevo.",
  AppMessage.invalidReleaseInfo:
      "Información de versión no válida. Inténtalo más tarde.",
  AppMessage.checkFailed:
      "La comprobación falló. Reintenta o visita la página de versiones.",
  AppMessage.viewAndDownload: "Ver y descargar",
  AppMessage.releases: "Versiones",
  AppMessage.saveFailed: "Error al guardar",
  AppMessage.retry: "Reintentar",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Tus cambios se conservan como borrador. Comprueba el acceso a la carpeta y el espacio libre.",
  AppMessage.exportComplete: "Exportación completada.",
  AppMessage.exportedToValue: "Exportado a {p0}",
  AppMessage.remainingWorkStopped: "Trabajo restante detenido",
  AppMessage.thisFileIsAlreadyOpen: "Este archivo ya está abierto",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Se abrió el archivo existente sin sobrescribirlo.",
  AppMessage.lnValueColValue: "Lín. {p0}, Col. {p1}",
  AppMessage.characters: "caracteres",
  AppMessage.unsavedDraftsRestored: "Borradores sin guardar restaurados.",
  AppMessage.draftNotSavedToFile: "Borrador · Sin guardar en archivo",
  AppMessage.saving: "Guardando…",
  AppMessage.saveFailedRetry: "Error al guardar · Reintentar",
  AppMessage.fileChangedResolve: "Archivo cambiado · Resolver",
  AppMessage.fileDeleted: "Archivo eliminado",
  AppMessage.pendingSave: "Guardado pendiente…",
  AppMessage.saved: "Guardado",
  AppMessage.fileChangedOnDisk: "El archivo cambió en el disco",
  AppMessage.loadDiskVersion: "Cargar la versión del disco",
  AppMessage.overwriteWithMyVersion: "Sobrescribir con mi versión",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Guardado automático en pausa. Tus cambios se conservan como borrador.",
  AppMessage.sentToTheSelectedApp: "Enviado a la app seleccionada.",
  AppMessage.images: "Imágenes",
  AppMessage.addImage: "Añadir imagen",
  AppMessage.takePhoto: "Hacer una foto",
  AppMessage.chooseFromPhotos: "Elegir de Fotos",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Permite que Marker acceda a Cámara o Fotos en los ajustes del sistema.",
  AppMessage.saveInMarker: "Guardar en Marker",
  AppMessage.fileName: "Nombre del archivo",
  AppMessage.enterAFileNameWithoutSlashes:
      "Introduce un nombre de archivo sin barras.",
  AppMessage.fileAlreadyExists: "El archivo ya existe",
  AppMessage.replaceExistingFile: "Reemplazar el archivo existente",
  AppMessage.cannotImportFileValue: "No se puede importar el archivo: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "No se pudieron importar {p0} archivo(s). Los demás documentos están abiertos.",
  AppMessage.openedDocumentMissingImages:
      "El documento se abrió con imágenes faltantes. Importa un ZIP que contenga el documento y las imágenes.",
  AppMessage.openedTheExistingCopyInMarker:
      "Se abrió la copia existente en Marker.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Se importó una copia. Los cambios no modificarán el archivo original.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Elige una plantilla para insertar. El texto seleccionado reemplaza al ejemplo.",
  AppMessage.syntaxHighlighting: "Resaltado de sintaxis",
  AppMessage.editor: "Editor",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "No se puede decodificar la imagen; comprueba su formato o integridad",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Guarda el documento para resolver las imágenes relativas",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Cambios del disco sincronizados. Los cambios sin guardar se conservaron.",
  AppMessage.saveNow: "Guardar ahora",
  AppMessage.deleteDocument: "Eliminar documento",
  AppMessage.deleteDocument2: "¿Eliminar el documento?",
  AppMessage.deleteDocumentConfirmation:
      "Elimina este documento de Marker de forma permanente. Las imágenes se conservan. Los cambios sin guardar también se cerrarán.",
  AppMessage.delete: "Eliminar",
  AppMessage.fileOperationFailedValue: "Error en la operación de archivo: {p0}",
  AppMessage.valueHasUnsavedChanges: "{p0} tiene cambios sin guardar.",
  AppMessage.exportDocument: "Exportar documento",
  AppMessage.exportingDocument: "Exportando documento…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Consulta la última versión pública en GitHub.",
  AppMessage.checkingForUpdates: "Buscando actualizaciones…",
  AppMessage.noPublicReleaseWasFound: "No se encontró ninguna versión pública.",
  AppMessage.youAreUpToDate: "Estás al día.",
  AppMessage.valueHasUnsavedChanges2: "{p0} tiene cambios sin guardar.",
  AppMessage.versionValueIsAvailable: "La versión {p0} está disponible",
  AppMessage.importImagesCopyOriginals: "Importar imágenes (copiar originales)",
  AppMessage.linkOriginalLocation: "Vincular la ubicación original…",
  AppMessage.pasteImage: "Pegar imagen",
  AppMessage.insertWebImage: "Insertar imagen web…",
  AppMessage.organizeDocumentImages: "Organizar las imágenes del documento…",
  AppMessage.cleanUnusedResources: "Limpiar recursos no usados…",
  AppMessage.allowFolderAccess: "Permitir el acceso a la carpeta…",
  AppMessage.newDocumentFolder: "Nueva carpeta de documentos…",
  AppMessage.renameDocument: "Renombrar documento…",
  AppMessage.packageDocumentAndImages: "Empaquetar documento e imágenes…",
  AppMessage.organizeDocumentImages2: "Organizar las imágenes del documento",
  AppMessage.organizingImages: "Organizando imágenes",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Imágenes organizadas. Se conservaron los archivos originales.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Imágenes organizadas en el editor. Guarda el documento.",
  AppMessage.image: "Imagen",
  AppMessage.locateInEditor: "Localizar en el editor",
  AppMessage.insertAtCursor: "Insertar en el cursor",
  AppMessage.viewImage: "Ver imagen",
  AppMessage.openImage: "Abrir imagen",
  AppMessage.showInFileManager: "Mostrar en el gestor de archivos",
  AppMessage.copyReferencePath: "Copiar la ruta de referencia",
  AppMessage.locateImage2: "Localizar imagen…",
  AppMessage.replaceWithImportedImage: "Reemplazar con una imagen importada…",
  AppMessage.downloadToDocumentAssets: "Descargar a los recursos del documento",
  AppMessage.reload: "Recargar",
  AppMessage.referenceCopied: "Referencia copiada",
  AppMessage.updatingImage: "Actualizando imagen",
  AppMessage.downloadingImage: "Descargando imagen",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "No hay candidatos seguros para limpiar. Las referencias guardadas y compartidas están protegidas.",
  AppMessage.moveToTrash2: "¿Mover a la papelera?",
  AppMessage.unreferencedImagesDescription:
      "El contenido actual, las versiones guardadas y los documentos conocidos no hacen referencia a estas imágenes importadas. Confirma que otras herramientas ya no las usan.",
  AppMessage.moveToTrash3: "Mover a la papelera",
  AppMessage.cleaningResources: "Limpiando recursos",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} imágenes movidas a la papelera. Los recursos referenciados o modificados se conservan.",
  AppMessage.chooseLocation: "Elegir ubicación",
  AppMessage.newDocumentFolder2: "Nueva carpeta de documentos",
  AppMessage.folderName: "Nombre de la carpeta",
  AppMessage.enterAValidFolderName: "Introduce un nombre de carpeta válido.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "La carpeta ya existe. Elige otro nombre.",
  AppMessage.renameDocument2: "Renombrar documento",
  AppMessage.documentName: "Nombre del documento",
  AppMessage.invalidDocumentName: "Nombre de documento no válido.",
  AppMessage.saveAndRename: "¿Guardar y renombrar?",
};
