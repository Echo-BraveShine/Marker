part of '../message_catalog.dart';

const _tr1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Geçerli düzenleyici içeriğini kullanır; özgün belge değişmez.",
  AppMessage.organizeSavesCurrentContent:
      "Düzenleme, geçerli düzenleyici içeriğini kaydeder; tüm özgün görseller korunur.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nKullanılamayan görseller özgün başvurularını korur.",
  AppMessage.embeddedImagesTooLarge: "Gömülü görseller 128 MB'ı aşıyor.",
  AppMessage.imageExceedsSizeLimit: "Görsel 25 MB'ı aşıyor.",
  AppMessage.imageExceedsSizeLimitAt: "Görsel 25 MB'ı aşıyor: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Görseli çözümlemek için belgeyi kaydedin: {p0}",
  AppMessage.splitImagesTooLarge: "Bölünmüş görseller 64 MB'ı aşıyor.",
  AppMessage.invalidImageExportDimensions:
      "Geçersiz görsel boyutları veya belge çok uzun.",
  AppMessage.documentTooLargeForSinglePng:
      "Belge tek bir PNG için çok büyük. Görselleri böl (ZIP) seçeneğini etkinleştirin.",
  AppMessage.cannotOpenLink: "Bağlantı açılamıyor.",
  AppMessage.cannotReadOriginalImage: "Özgün görsel okunamıyor",
  AppMessage.cannotWriteImageAssets: "Görsel varlıkları yazılamıyor",
  AppMessage.cannotProcessImageRetry:
      "Bu görsel işlenemiyor. Kontrol edip yeniden deneyin.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "İçe aktarma iptal edildi. Özgün görseller değişmedi.",
  AppMessage.importStoppedImagesInserted:
      "İçe aktarma durduruldu. {p0} görsel eklendi.",
  AppMessage.originalLocationReferencesInserted:
      "Özgün konum başvuruları eklendi. Özgün görsellerin taşınması bunları bozabilir.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} görsel eklendi. Özgünler korundu.",
  AppMessage.unsupportedSyntaxKept: "Özel sözdizimi değiştirilmeden korundu.",
  AppMessage.cannotReadOrCopyImage:
      "Görsel okunamıyor veya kopyalanamıyor. İzinleri ve kullanılabilir alanı kontrol edin.",
  AppMessage.headings: "Başlıklar",
  AppMessage.listsAndBlocks: "Listeler ve bloklar",
  AppMessage.linksAndExtensions: "Bağlantılar ve uzantılar",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Kaydedilmemiş belgeler kurtarıldı",
  AppMessage.file: "Dosya",
  AppMessage.openFile: "Dosya Aç",
  AppMessage.save: "Kaydet",
  AppMessage.export: "Dışa Aktar",
  AppMessage.exportHtml: "HTML Dışa Aktar",
  AppMessage.exportPdf: "PDF Dışa Aktar",
  AppMessage.settings: "Ayarlar",
  AppMessage.theme: "Tema",
  AppMessage.themeLight: "Açık",
  AppMessage.themeDark: "Koyu",
  AppMessage.themeSystem: "Sistem",
  AppMessage.fontSize: "karakter",
  AppMessage.language: "Dil",
  AppMessage.languageZh: "Çince",
  AppMessage.languageEn: "İngilizce",
  AppMessage.edit: "Düzenle",
  AppMessage.preview: "Önizleme",
  AppMessage.split: "Bölünmüş",
  AppMessage.statusLine: "Satır 1, Sütun 1",
  AppMessage.closeDocument: "Belgeyi kapat",
  AppMessage.rename: "Yeniden adlandır…",
  AppMessage.moveToTrash: "Çöp Kutusuna Taşı…",
  AppMessage.moveToTrashPrompt: "Belge Çöp Kutusuna taşınsın mı?",
  AppMessage.moveToTrashContent:
      "Belge Çöp Kutusuna taşınır; ilgili görseller korunur. Kaydedilmemiş düzenlemeler kapatılır.",
  AppMessage.saveAs: "Farklı kaydet",
  AppMessage.saveChanges: "Değişiklikler kaydedilsin mi?",
  AppMessage.discard: "Vazgeç",
  AppMessage.pathConflict:
      "Açık olan başka bir belge bu yolu kullanıyor. Farklı bir yol seçin.",
  AppMessage.saveCancelled:
      "Kaydetme iptal edildi. Belge içeriğiniz korunuyor.",
  AppMessage.fileOperationFailed: "Dosya işlemi başarısız",
  AppMessage.unableToExport: "Belge dışa aktarılamıyor",
  AppMessage.importImages: "Görselleri içe aktar",
  AppMessage.stopRemainingWork: "Kalan işi durdur",
  AppMessage.cannotReadImages:
      "Görseller okunamıyor. Klasör erişimini kontrol edin.",
  AppMessage.importOrPasteImages:
      "Görsel içe aktarın veya bir ekran görüntüsü yapıştırın.\nÖzgünler korunur; varlık klasörü gerektiğinde oluşturulur.",
  AppMessage.customSyntaxUnchanged:
      "Bazı özel sözdizimi değiştirilmeden bırakıldı",
  AppMessage.localImages: "Yerel görseller",
  AppMessage.webImages: "Web görselleri",
  AppMessage.needsAttention: "İlgi gerekiyor",
  AppMessage.managed: "Yönetilen",
  AppMessage.linkedUrl: "Bağlantılı URL",
  AppMessage.clickToRepair: "Onarmak için tıklayın",
  AppMessage.exportFormat: "Biçim",
  AppMessage.exportA4Info:
      "Denklemler, Mermaid ve görseller dahil seçilebilir, kopyalanabilir metin içeren A4 sayfaları.",
  AppMessage.useAppAppearance: "Uygulama görünümünü kullan",
  AppMessage.imageWidth: "Görsel genişliği (px)",
  AppMessage.selfContainedHtml:
      "Gömülü görseller ve diyagramlar içeren, çevrimdışı kullanılabilen bağımsız HTML.",
  AppMessage.version: "Sürüm",
  AppMessage.loadingVersion: "Sürüm yükleniyor…",
  AppMessage.unsavedDoc: "Bu dosya zaten açık",
  AppMessage.unsupportedLinkType: "Desteklenmeyen bağlantı türü",
  AppMessage.webImageLoadFailed: "Web görseli yüklenemedi",
  AppMessage.cannotAccessImage:
      "Görsele erişilemiyor; klasör erişimine izin verin",
  AppMessage.imageNotFound: "Görsel bulunamadı",
  AppMessage.locateImage: "Görseli bul",
  AppMessage.allowImageFolderAndRetry:
      "Görsel klasörüne izin verin ve yeniden deneyin",
  AppMessage.reloadImage: "Görseli yeniden yükle",
  AppMessage.saveToResolveImages:
      "Göreli görselleri çözümlemek için belgeyi kaydedin",
  AppMessage.stop: "Durdur",
  AppMessage.toggleSidebar: "Kenar çubuğunu aç/kapat",
  AppMessage.resources: "Kaynaklar",
  AppMessage.files: "Dosyalar",
  AppMessage.documents: "Belgeler",
  AppMessage.documentResources: "Belge kaynakları",
  AppMessage.newDocument: "Yeni",
  AppMessage.openDocument: "Aç",
  AppMessage.undo: "Geri al",
  AppMessage.redo: "Yinele",
  AppMessage.findAndReplace: "Bul ve değiştir",
  AppMessage.textColor: "Metin rengi",
  AppMessage.equationTemplates: "Denklem şablonları",
  AppMessage.mermaidTemplates: "Mermaid şablonları",
  AppMessage.allMarkdownSyntax: "Tüm Markdown sözdizimi",
  AppMessage.serifFont: "Serif yazı tipi",
  AppMessage.startWriting: "Yazmaya başlayın…",
  AppMessage.auto: "Otomatik",
  AppMessage.general: "Genel",
  AppMessage.editorAndPreview: "Düzenleyici ve önizleme",
  AppMessage.keyboardShortcuts: "Klavye kısayolları",
  AppMessage.about: "Hakkında",
  AppMessage.appearance: "Görünüm",
  AppMessage.interfaceLanguage: "Dil",
  AppMessage.versionUnavailable: "Sürüm kullanılamıyor",
  AppMessage.focusedMarkdown: "Odaklı Markdown yazımı ve canlı önizleme.",
  AppMessage.checkForUpdates: "Güncellemeleri kontrol et",
};
