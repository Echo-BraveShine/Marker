part of '../message_catalog.dart';

const _es3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Se guardará el contenido actual. También se renombrarán la carpeta de recursos y las referencias de imagen de este documento. Las referencias de otros documentos deben actualizarse por separado.",
  AppMessage.rename2: "Renombrar",
  AppMessage.renamingDocument: "Renombrando documento",
  AppMessage.packageDocumentAndImages2: "Empaquetar documento e imágenes",
  AppMessage.packagingDocument: "Empaquetando documento",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Paquete creado con referencias que aún necesitan repararse.",
  AppMessage.currentDocumentAndImagesPackaged:
      "El documento actual y las imágenes se empaquetaron.",
  AppMessage.dropToImportImages: "Suelta para importar imágenes",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Copiar a los recursos del documento. Los originales se conservan.",
  AppMessage.saveTheDocumentFirst: "Guarda el documento primero",
  AppMessage.saveBeforeImportImages:
      "Guarda primero para que las imágenes se almacenen junto al documento con rutas relativas portables.",
  AppMessage.saveAndContinue: "Guardar y continuar",
  AppMessage.allowFolderAccess2: "Permitir el acceso a la carpeta",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Elige la carpeta contenedora o una de sus carpetas superiores.",
  AppMessage.folderAccessGranted: "Acceso a la carpeta concedido.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "El documento cambió. Importa las imágenes de nuevo.",
  AppMessage.importingImages: "Importando imágenes",
  AppMessage.noTextOrImageToPaste: "No hay texto ni imagen para pegar.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Las imágenes del portapapeles no están disponibles en este entorno.",
  AppMessage.dropAccessDenied:
      "El sistema no pudo conceder acceso a los archivos soltados. Usa Importar imágenes para seleccionarlos.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Suelta imágenes PNG, JPEG, GIF, WebP o BMP.",
  AppMessage.insertWebImage2: "Insertar imagen web",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Introduce una URL de imagen HTTP o HTTPS válida.",
  AppMessage.imageDescription: "Descripción de la imagen",
  AppMessage.unsupportedImageAddress: "Dirección de imagen no compatible",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Usa Guardar como para mover el documento a otra carpeta.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "Ya existe un archivo con este nombre.",
  AppMessage.theSourceDocumentIsUnavailable:
      "El documento de origen no está disponible.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Ya existe una carpeta de recursos con el nuevo nombre. No se renombró nada.",
  AppMessage.resolveImagesBeforeExport:
      "Resuelve las imágenes no disponibles o conserva explícitamente sus referencias originales.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "El documento no hace referencia a esta imagen.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "No se puede cargar la imagen. Reintenta o comprueba el acceso a la red y a los archivos.",
  AppMessage.more: "Más",
  AppMessage.cannotOverwriteASymbolicLink:
      "No se puede sobrescribir un enlace simbólico.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "El directorio de recursos no es un directorio normal.",
  AppMessage.noAvailableResourceDirectoryName:
      "No hay ningún nombre disponible para el directorio de recursos.",
  AppMessage.tooManyImageNameConflicts:
      "Demasiados conflictos de nombres de imagen.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Imagen no válida; usa PNG, JPEG, GIF, WebP o BMP.",
  AppMessage.imageExceeds50MB: "La imagen supera los 50 MB.",
  AppMessage.imageExceeds50MB2: "La imagen supera los 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "No se puede sobrescribir un enlace simbólico.",
  AppMessage.unsupportedImageURL: "URL de imagen no compatible.",
  AppMessage.downloadFailedHTTPValue: "Error de descarga: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Demasiadas redirecciones de imagen.",
  AppMessage.continueText: "Continuar",
  AppMessage.someImagesNeedAttention: "Algunas imágenes requieren atención",
  AppMessage.partialResourceCopyWarning:
      "Estas referencias no se pueden copiar por completo. Repáralas primero o continúa conservando sus direcciones originales.",
  AppMessage.customSyntax: "Sintaxis personalizada",
  AppMessage.continueWithOriginalAddresses:
      "Continuar con las direcciones originales",
  AppMessage.resourceInventorySummary:
      "{p0} imágenes locales ({p1} gestionadas), {p2} imágenes web.\n{p3} imágenes para copiar; {p4} MB de imágenes locales.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Descargar también las imágenes web",
  AppMessage.copyLocalImages: "Copiar imágenes locales",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Se requiere acceso a la carpeta. Permite el acceso a esta ubicación y reintenta.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "El archivo o la carpeta falta, se movió o no se descargó localmente.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "El disco está lleno. Libera espacio y reintenta.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Esta ubicación es de solo lectura. Elige una carpeta con permisos de escritura.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Error en la operación de archivo. Comprueba la ubicación y los detalles del sistema a continuación.",
  AppMessage.location: "Ubicación",
  AppMessage.unknown: "desconocido",
  AppMessage.error: "error",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "No se puede procesar la imagen. Comprueba su formato o la conexión y reintenta.",
  AppMessage.someImagesCouldNotBeCopied:
      "No se pudieron copiar algunas imágenes",
  AppMessage.originalImagesUnchanged:
      "Los archivos originales no cambian. Repara estas imágenes o conserva sus direcciones y continúa.",
  AppMessage.keepAddressesAndContinue: "Conservar las direcciones y continuar",
  AppMessage.operationResult: "Resultado de la operación",
  AppMessage.imageDimensionsAreTooLarge:
      "Las dimensiones de la imagen son demasiado grandes.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Ya hay una operación de recursos en curso.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Solo se pueden eliminar los archivos dentro de Marker.",
  AppMessage.trashFailedFileKept:
      "No se puede mover a la papelera. El archivo original se conservó. Comprueba el acceso a la carpeta o la papelera de reciclaje.",
  AppMessage.allowFolderAccess3: "Permitir el acceso a la carpeta",
  AppMessage.allowFolderAccess4: "Permitir el acceso a la carpeta",
  AppMessage.folderAccessPurpose:
      "Marker necesita esta carpeta para leer imágenes o crear recursos junto a tu documento. Permite el acceso para continuar o cancela para detener esta operación.\n{p0}",
  AppMessage.classic: "Classic",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Se agotó el tiempo de exportación. Prueba a reducir el número de imágenes o diagramas.",
  AppMessage.exportFileAccessFailed:
      "No se puede acceder a una imagen o al destino. Comprueba que el archivo exista, los permisos de la carpeta y el espacio libre.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "No se pudo descargar una imagen remota. Comprueba tu conexión o usa una imagen local.",
  AppMessage.exportIncomplete:
      "La exportación no se completó. No se escribió ningún resultado. Comprueba las imágenes, las ecuaciones y la sintaxis de Mermaid. Para documentos largos, elige PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Dividir imágenes (ZIP)",
  AppMessage.saveToFiles: "Guardar en Archivos",
  AppMessage.unsupportedExportFormat: "Formato de exportación no compatible",
  AppMessage.pleaseSelectAnExportPath: "Selecciona una ruta de exportación",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Selecciona un archivo en lugar de un directorio",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Los archivos Markdown no pueden usarse como destino de exportación",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "La ruta de exportación no puede ser la misma que la del archivo de origen",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "El destino es un directorio. Elige otro nombre de archivo.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "El archivo de salida ya existe. Selecciona {p0} directamente en el diálogo de guardado.",
  AppMessage.exportDataCannotBeEmpty:
      "Los datos de exportación no pueden estar vacíos",
  AppMessage.indentEditor: "Aumentar sangría (editor)",
  AppMessage.outdentEditor: "Reducir sangría (editor)",
  AppMessage.newDocument2: "Nuevo documento",
  AppMessage.openDocument2: "Abrir documento",
  AppMessage.closeDocument2: "Cerrar documento",
  AppMessage.find: "Buscar",
  AppMessage.findAndReplace2: "Buscar y reemplazar",
  AppMessage.nextMatch: "Siguiente coincidencia",
  AppMessage.previousMatch: "Coincidencia anterior",
  AppMessage.bold: "Negrita",
  AppMessage.italic: "Cursiva",
  AppMessage.inlineCode: "Código en línea",
  AppMessage.strikethrough: "Tachado",
  AppMessage.editorMode: "Modo editor",
  AppMessage.splitMode: "Modo dividido",
  AppMessage.previewMode: "Modo vista previa",
  AppMessage.allSyntax: "Toda la sintaxis",
  AppMessage.quitApp: "Salir de la app",
  AppMessage.cut: "Cortar",
  AppMessage.copy: "Copiar",
  AppMessage.paste: "Pegar",
  AppMessage.selectAll: "Seleccionar todo",
  AppMessage.shortcutFooter:
      "Esc cierra la búsqueda o el panel de sintaxis. Los campos de texto conservan los atajos nativos del portapapeles y de deshacer.",
};
