part of '../message_catalog.dart';

const _es1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Usa el contenido actual del editor; el documento original no cambia.",
  AppMessage.organizeSavesCurrentContent:
      "Organizar guarda el contenido actual del editor; se conservan todas las imágenes originales.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nLas imágenes no disponibles conservan sus referencias originales.",
  AppMessage.embeddedImagesTooLarge:
      "Las imágenes incrustadas superan los 128 MB.",
  AppMessage.imageExceedsSizeLimit: "La imagen supera los 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "La imagen supera los 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Guarda el documento para resolver la imagen: {p0}",
  AppMessage.splitImagesTooLarge: "Las imágenes divididas superan los 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Dimensiones de imagen no válidas o documento demasiado largo.",
  AppMessage.documentTooLargeForSinglePng:
      "El documento es demasiado grande para un solo PNG. Activa Dividir imágenes (ZIP).",
  AppMessage.cannotOpenLink: "No se puede abrir el enlace.",
  AppMessage.cannotReadOriginalImage: "No se puede leer la imagen original",
  AppMessage.cannotWriteImageAssets:
      "No se pueden escribir los recursos de imagen",
  AppMessage.cannotProcessImageRetry:
      "No se puede procesar esta imagen. Compruébala e inténtalo de nuevo.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Importación cancelada. Las imágenes originales no cambian.",
  AppMessage.importStoppedImagesInserted:
      "Importación detenida. {p0} imágenes insertadas.",
  AppMessage.originalLocationReferencesInserted:
      "Se insertaron referencias a la ubicación original. Mover las imágenes originales puede romperlas.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} imágenes insertadas. Originales conservados.",
  AppMessage.unsupportedSyntaxKept:
      "La sintaxis personalizada se mantiene sin cambios.",
  AppMessage.cannotReadOrCopyImage:
      "No se puede leer ni copiar la imagen. Comprueba los permisos y el espacio disponible.",
  AppMessage.headings: "Encabezados",
  AppMessage.listsAndBlocks: "Listas y bloques",
  AppMessage.linksAndExtensions: "Enlaces y extensiones",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Documentos sin guardar recuperados",
  AppMessage.file: "Archivo",
  AppMessage.openFile: "Abrir archivo",
  AppMessage.save: "Guardar",
  AppMessage.export: "Exportar",
  AppMessage.exportHtml: "Exportar HTML",
  AppMessage.exportPdf: "Exportar PDF",
  AppMessage.settings: "Ajustes",
  AppMessage.theme: "Tema",
  AppMessage.themeLight: "Claro",
  AppMessage.themeDark: "Oscuro",
  AppMessage.themeSystem: "Sistema",
  AppMessage.fontSize: "caracteres",
  AppMessage.language: "Idioma",
  AppMessage.languageZh: "Chino",
  AppMessage.languageEn: "Inglés",
  AppMessage.edit: "Editar",
  AppMessage.preview: "Vista previa",
  AppMessage.split: "Dividir",
  AppMessage.statusLine: "Línea 1, Columna 1",
  AppMessage.closeDocument: "Cerrar documento",
  AppMessage.rename: "Renombrar…",
  AppMessage.moveToTrash: "Mover a la papelera…",
  AppMessage.moveToTrashPrompt: "¿Mover el documento a la papelera?",
  AppMessage.moveToTrashContent:
      "El documento se mueve a la papelera; las imágenes asociadas se conservan. Los cambios sin guardar se cerrarán.",
  AppMessage.saveAs: "Guardar como",
  AppMessage.saveChanges: "¿Guardar los cambios?",
  AppMessage.discard: "Descartar",
  AppMessage.pathConflict:
      "Otro documento abierto usa esta ruta. Elige otra ruta.",
  AppMessage.saveCancelled:
      "Guardado cancelado. El contenido del documento se conserva.",
  AppMessage.fileOperationFailed: "Error en la operación de archivo",
  AppMessage.unableToExport: "No se puede exportar el documento",
  AppMessage.importImages: "Importar imágenes",
  AppMessage.stopRemainingWork: "Detener el trabajo restante",
  AppMessage.cannotReadImages:
      "No se pueden leer las imágenes. Comprueba el acceso a la carpeta.",
  AppMessage.importOrPasteImages:
      "Importa imágenes o pega una captura de pantalla.\nLos originales se conservan; la carpeta de recursos se crea si es necesario.",
  AppMessage.customSyntaxUnchanged:
      "Parte de la sintaxis personalizada queda sin cambios",
  AppMessage.localImages: "Imágenes locales",
  AppMessage.webImages: "Imágenes web",
  AppMessage.needsAttention: "Requiere atención",
  AppMessage.managed: "Gestionado",
  AppMessage.linkedUrl: "URL vinculada",
  AppMessage.clickToRepair: "Haz clic para reparar",
  AppMessage.exportFormat: "Formato",
  AppMessage.exportA4Info:
      "Páginas A4 con texto seleccionable y copiable, incluidas ecuaciones, Mermaid e imágenes.",
  AppMessage.useAppAppearance: "Usar la apariencia de la app",
  AppMessage.imageWidth: "Ancho de la imagen (px)",
  AppMessage.selfContainedHtml:
      "HTML autocontenido con imágenes y diagramas incrustados, disponible sin conexión.",
  AppMessage.version: "Versión",
  AppMessage.loadingVersion: "Cargando versión…",
  AppMessage.unsavedDoc: "Este archivo ya está abierto",
  AppMessage.unsupportedLinkType: "Tipo de enlace no compatible",
  AppMessage.webImageLoadFailed: "No se pudo cargar la imagen web",
  AppMessage.cannotAccessImage:
      "No se puede acceder a la imagen; permite el acceso a la carpeta",
  AppMessage.imageNotFound: "Imagen no encontrada",
  AppMessage.locateImage: "Localizar imagen",
  AppMessage.allowImageFolderAndRetry:
      "Permitir la carpeta de imágenes y reintentar",
  AppMessage.reloadImage: "Recargar imagen",
  AppMessage.saveToResolveImages:
      "Guarda el documento para resolver las imágenes relativas",
  AppMessage.stop: "Detener",
  AppMessage.toggleSidebar: "Mostrar u ocultar la barra lateral",
  AppMessage.resources: "Recursos",
  AppMessage.files: "Archivos",
  AppMessage.documents: "Documentos",
  AppMessage.documentResources: "Recursos del documento",
  AppMessage.newDocument: "Nuevo",
  AppMessage.openDocument: "Abrir",
  AppMessage.undo: "Deshacer",
  AppMessage.redo: "Rehacer",
  AppMessage.findAndReplace: "Buscar y reemplazar",
  AppMessage.textColor: "Color del texto",
  AppMessage.equationTemplates: "Plantillas de ecuaciones",
  AppMessage.mermaidTemplates: "Plantillas de Mermaid",
  AppMessage.allMarkdownSyntax: "Toda la sintaxis de Markdown",
  AppMessage.serifFont: "Fuente serif",
  AppMessage.startWriting: "Empieza a escribir…",
  AppMessage.auto: "Automático",
  AppMessage.general: "General",
  AppMessage.editorAndPreview: "Editor y vista previa",
  AppMessage.keyboardShortcuts: "Atajos de teclado",
  AppMessage.about: "Acerca de",
  AppMessage.appearance: "Apariencia",
  AppMessage.interfaceLanguage: "Idioma",
  AppMessage.versionUnavailable: "Versión no disponible",
  AppMessage.focusedMarkdown:
      "Escritura de Markdown centrada y vista previa en vivo.",
  AppMessage.checkForUpdates: "Buscar actualizaciones",
};
