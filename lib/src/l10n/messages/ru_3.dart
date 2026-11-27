part of '../message_catalog.dart';

const _ru3 = <AppMessage, String>{
  AppMessage.managed: "Управляемые",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Файлы Markdown нельзя использовать как место экспорта",
  AppMessage.markdownSyntax: "Синтаксис Markdown",
  AppMessage.matrix: "Матрица",
  AppMessage.mermaidTemplates: "Шаблоны Mermaid",
  AppMessage.mindMap: "Интеллект-карта",
  AppMessage.more: "Ещё",
  AppMessage.moveToTrash: "Переместить в корзину…",
  AppMessage.moveToTrash2: "Переместить в корзину?",
  AppMessage.moveToTrash3: "Переместить в корзину",
  AppMessage.moveToTrashContent:
      "Документ перемещается в корзину; связанные изображения сохраняются. Несохранённые изменения будут закрыты.",
  AppMessage.moveToTrashPrompt: "Переместить документ в корзину?",
  AppMessage.needsAttention: "Требуют внимания",
  AppMessage.nestedBlockquote: "Вложенная цитата",
  AppMessage.nestedList: "Вложенный список",
  AppMessage.newDocument: "Создать",
  AppMessage.newDocument2: "Новый документ",
  AppMessage.newDocumentFolder: "Новая папка документа…",
  AppMessage.newDocumentFolder2: "Новая папка документа",
  AppMessage.next: "Далее",
  AppMessage.nextMatch: "Следующее совпадение",
  AppMessage.noAvailableResourceDirectoryName:
      "Нет доступного имени каталога ресурсов.",
  AppMessage.noPublicReleaseWasFound: "Публичный релиз не найден.",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Нет безопасных кандидатов для очистки. Сохранённые и общие ссылки защищены.",
  AppMessage.noTextOrImageToPaste: "Нет текста или изображения для вставки.",
  AppMessage.noteNoteFootnoteContent: "[^note]\n\n[^note]: Текст сноски",
  AppMessage.numberedList: "Нумерованный список",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Можно удалять только файлы внутри Marker.",
  AppMessage.openDocument: "Открыть",
  AppMessage.openDocument2: "Открыть документ",
  AppMessage.openExample: "Открыть пример",
  AppMessage.openFile: "Открыть файл",
  AppMessage.openImage: "Открыть изображение",
  AppMessage.openedDocumentMissingImages:
      "Документ открыт с отсутствующими изображениями. Импортируйте ZIP, содержащий документ и изображения.",
  AppMessage.openedTheExistingCopyInMarker:
      "Открыта существующая копия в Marker.",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Открыт существующий файл без перезаписи.",
  AppMessage.operationResult: "Результат операции",
  AppMessage.organizeDocumentImages: "Упорядочить изображения документа…",
  AppMessage.organizeDocumentImages2: "Упорядочить изображения документа",
  AppMessage.organizeSavesCurrentContent:
      "При упорядочении сохраняется текущее содержимое редактора; все исходные изображения сохраняются.",
  AppMessage.organizingImages: "Упорядочивание изображений",
  AppMessage.originalImagesUnchanged:
      "Исходные файлы не изменены. Исправьте эти изображения или сохраните их адреса и продолжите.",
  AppMessage.originalLocationReferencesInserted:
      "Вставлены ссылки на исходное расположение. Перемещение исходных изображений может их нарушить.",
  AppMessage.outdentEditor: "Уменьшить отступ (редактор)",
  AppMessage.overwriteWithMyVersion: "Перезаписать моей версией",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Пакет создан, но некоторые ссылки всё ещё требуют исправления.",
  AppMessage.packageDocumentAndImages: "Упаковать документ и изображения…",
  AppMessage.packageDocumentAndImages2: "Упаковать документ и изображения",
  AppMessage.packagingDocument: "Упаковка документа",
  AppMessage.paragraph: "Абзац",
  AppMessage.parentItem: "- Родительский элемент\n  - ",
  AppMessage.partialResourceCopyWarning:
      "Эти ссылки невозможно скопировать полностью. Сначала исправьте их или продолжите, сохранив исходные адреса.",
  AppMessage.paste: "Вставить",
  AppMessage.pasteImage: "Вставить изображение",
  AppMessage.pathConflict:
      "Другой открытый документ использует этот путь. Выберите другой путь.",
  AppMessage.pendingSave: "Ожидание сохранения…",
  AppMessage.piecewiseFunction: "Кусочная функция",
  AppMessage.pieChart: "Круговая диаграмма",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Выберите файл, а не каталог",
  AppMessage.pleaseSelectAnExportPath: "Выберите путь для экспорта",
  AppMessage.preview: "Предпросмотр",
  AppMessage.previewMode: "Режим предпросмотра",
  AppMessage.previous: "Назад",
  AppMessage.previousMatch: "Предыдущее совпадение",
  AppMessage.quitApp: "Выйти из приложения",
  AppMessage.quote: "> Цитата\n>> ",
  AppMessage.recoveredUnsavedDoc: "Восстановленные несохранённые документы",
  AppMessage.redo: "Вернуть",
  AppMessage.referenceCopied: "Ссылка скопирована",
  AppMessage.referenceLink: "Ссылка с определением",
  AppMessage.releases: "Релизы",
  AppMessage.reload: "Обновить",
  AppMessage.reloadImage: "Перезагрузить изображение",
  AppMessage.remainingWorkStopped: "Оставшаяся работа остановлена",
  AppMessage.rename: "Переименовать…",
  AppMessage.rename2: "Переименовать",
  AppMessage.renameDocument: "Переименовать документ…",
  AppMessage.renameDocument2: "Переименовать документ",
  AppMessage.renameDocumentResourcesDescription:
      "Текущее содержимое будет сохранено. Папка ресурсов и ссылки на изображения в этом документе также будут переименованы. Ссылки из других документов нужно обновить отдельно.",
  AppMessage.renamingDocument: "Переименование документа",
  AppMessage.replace: "Заменить",
  AppMessage.replaceAll: "Заменить всё",
  AppMessage.replaceExistingFile: "Заменить существующий файл",
  AppMessage.replaceWith: "Заменить на",
  AppMessage.replaceWithImportedImage: "Заменить импортированным изображением…",
  AppMessage.requestLimited: "Слишком много запросов. Повторите позже.",
  AppMessage.resolveImagesBeforeExport:
      "Определите недоступные изображения или явно сохраните их исходные ссылки.",
  AppMessage.resourceInventorySummary:
      "{p0} локальных изображений ({p1} управляемых), {p2} веб-изображений.\nКопировать изображений: {p3}; локальных изображений: {p4} МБ.\n{p5}{p6}",
  AppMessage.resources: "Ресурсы",
  AppMessage.retry: "Повторить",
  AppMessage.root: "Корень",
  AppMessage.save: "Сохранить",
  AppMessage.saveAndContinue: "Сохранить и продолжить",
  AppMessage.saveAndRename: "Сохранить и переименовать?",
  AppMessage.saveAs: "Сохранить как",
  AppMessage.saveBeforeImportImages:
      "Сначала сохраните, чтобы изображения можно было хранить рядом с документом по переносимым относительным путям.",
  AppMessage.saveCancelled:
      "Сохранение отменено. Содержимое документа сохранено.",
  AppMessage.saveChanges: "Сохранить изменения?",
  AppMessage.saveDocumentToResolveImagePath:
      "Сохраните документ, чтобы определить путь к изображению: {p0}",
  AppMessage.saveFailed: "Не удалось сохранить",
  AppMessage.saveFailedRetry: "Не удалось сохранить · Повторить",
  AppMessage.saveInMarker: "Сохранить в Marker",
  AppMessage.saveNow: "Сохранить сейчас",
  AppMessage.saveTheDocumentFirst: "Сначала сохраните документ",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Сохраните документ, чтобы определить относительные пути к изображениям",
  AppMessage.saveToFiles: "Сохранить в «Файлы»",
  AppMessage.saveToResolveImages:
      "Сохраните документ, чтобы определить относительные пути к изображениям",
  AppMessage.saved: "Сохранено",
  AppMessage.saving: "Сохранение…",
  AppMessage.scriptsGreekLetters: "Индексы и греческие буквы",
};
