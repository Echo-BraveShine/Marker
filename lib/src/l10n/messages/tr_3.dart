part of '../message_catalog.dart';

const _tr3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Geçerli içerik kaydedilecek. Varlık klasörü ve bu belgedeki görsel başvuruları da yeniden adlandırılacak. Diğer belgelerden gelen başvuruların ayrıca güncellenmesi gerekir.",
  AppMessage.rename2: "Yeniden adlandır",
  AppMessage.renamingDocument: "Belge yeniden adlandırılıyor",
  AppMessage.packageDocumentAndImages2: "Belgeyi ve görselleri paketle",
  AppMessage.packagingDocument: "Belge paketleniyor",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Paket, hâlâ onarılması gereken başvurularla oluşturuldu.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Geçerli belge ve görseller paketlendi.",
  AppMessage.dropToImportImages: "Görselleri içe aktarmak için bırakın",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Belge varlıklarına kopyala. Özgünler korunur.",
  AppMessage.saveTheDocumentFirst: "Önce belgeyi kaydedin",
  AppMessage.saveBeforeImportImages:
      "Görsellerin taşınabilir göreli yollarla belgenin yanında saklanabilmesi için önce kaydedin.",
  AppMessage.saveAndContinue: "Kaydet ve devam et",
  AppMessage.allowFolderAccess2: "Klasör erişimine izin ver",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "İçeren klasörü veya üst klasörlerinden birini seçin.",
  AppMessage.folderAccessGranted: "Klasör erişimi verildi.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Belge değişti. Görselleri yeniden içe aktarın.",
  AppMessage.importingImages: "Görseller içe aktarılıyor",
  AppMessage.noTextOrImageToPaste: "Yapıştırılacak metin veya görsel yok.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Pano görselleri bu ortamda kullanılamıyor.",
  AppMessage.dropAccessDenied:
      "Sistem, bırakılan dosyalara erişim izni veremedi. Bunları seçmek için Görselleri içe aktar'ı kullanın.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "PNG, JPEG, GIF, WebP veya BMP görselleri bırakın.",
  AppMessage.insertWebImage2: "Web görseli ekle",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Geçerli bir HTTP veya HTTPS görsel URL'si girin.",
  AppMessage.imageDescription: "Görsel açıklaması",
  AppMessage.unsupportedImageAddress: "Desteklenmeyen görsel adresi",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Belgeyi başka bir klasöre taşımak için Farklı Kaydet'i kullanın.",
  AppMessage.aFileWithThisNameAlreadyExists: "Bu adda bir dosya zaten mevcut.",
  AppMessage.theSourceDocumentIsUnavailable: "Kaynak belge kullanılamıyor.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Yeni adla bir varlık klasörü zaten mevcut. Hiçbir şey yeniden adlandırılmadı.",
  AppMessage.resolveImagesBeforeExport:
      "Kullanılamayan görselleri çözümleyin veya özgün başvurularını açıkça koruyun.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Bu görsel belgede referanslanmıyor.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Görsel yüklenemiyor. Yeniden deneyin veya ağ ve dosya erişimini kontrol edin.",
  AppMessage.more: "Daha fazla",
  AppMessage.cannotOverwriteASymbolicLink:
      "Sembolik bağlantının üzerine yazılamıyor.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "Kaynak dizini normal bir dizin değil.",
  AppMessage.noAvailableResourceDirectoryName:
      "Kullanılabilir kaynak dizini adı yok.",
  AppMessage.tooManyImageNameConflicts: "Çok fazla görsel adı çakışması var.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Geçersiz görsel; PNG, JPEG, GIF, WebP veya BMP kullanın.",
  AppMessage.imageExceeds50MB: "Görsel 50 MB'ı aşıyor.",
  AppMessage.imageExceeds50MB2: "Görsel 50 MB'ı aşıyor.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Sembolik bağlantının üzerine yazılamıyor.",
  AppMessage.unsupportedImageURL: "Desteklenmeyen görsel URL'si.",
  AppMessage.downloadFailedHTTPValue: "İndirme başarısız: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Çok fazla görsel yönlendirmesi.",
  AppMessage.continueText: "Devam et",
  AppMessage.someImagesNeedAttention: "Bazı görseller ilgi gerektiriyor",
  AppMessage.partialResourceCopyWarning:
      "Bu başvurular tamamen kopyalanamıyor. Önce onarın veya özgün adreslerini koruyarak devam edin.",
  AppMessage.customSyntax: "Özel sözdizimi",
  AppMessage.continueWithOriginalAddresses: "Özgün adreslerle devam et",
  AppMessage.resourceInventorySummary:
      "{p0} yerel görsel ({p1} yönetilen), {p2} web görseli.\nKopyalanacak {p3} görsel; {p4} MB yerel görsel.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Web görsellerini de indir",
  AppMessage.copyLocalImages: "Yerel görselleri kopyala",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Klasör erişimi gerekli. Bu konuma erişime izin verin ve yeniden deneyin.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Dosya veya klasör eksik, taşınmış ya da yerel olarak indirilmemiş.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Disk dolu. Biraz yer açıp yeniden deneyin.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Bu konum salt okunur. Yazılabilir bir klasör seçin.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Dosya işlemi başarısız. Aşağıdaki konumu ve sistem ayrıntılarını kontrol edin.",
  AppMessage.location: "Konum",
  AppMessage.unknown: "bilinmiyor",
  AppMessage.error: "hata",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Görsel işlenemiyor. Biçimini veya bağlantıyı kontrol edip yeniden deneyin.",
  AppMessage.someImagesCouldNotBeCopied: "Bazı görseller kopyalanamadı",
  AppMessage.originalImagesUnchanged:
      "Özgün dosyalar değişmedi. Bu görselleri onarın veya adreslerini koruyup devam edin.",
  AppMessage.keepAddressesAndContinue: "Adresleri koru ve devam et",
  AppMessage.operationResult: "İşlem sonucu",
  AppMessage.imageDimensionsAreTooLarge: "Görsel boyutları çok büyük.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Zaten bir kaynak işlemi çalışıyor.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Yalnızca Marker içindeki dosyalar silinebilir.",
  AppMessage.trashFailedFileKept:
      "Çöp Kutusuna taşınamıyor. Özgün dosya korundu. Klasör erişimini veya geri dönüşüm kutusunu kontrol edin.",
  AppMessage.allowFolderAccess3: "Klasör erişimine izin ver",
  AppMessage.allowFolderAccess4: "Klasör erişimine izin ver",
  AppMessage.folderAccessPurpose:
      "Marker'ın görselleri okumak veya belgenizin yanında varlık oluşturmak için bu klasöre ihtiyacı var. Devam etmek için erişime izin verin ya da bu işlemi durdurmak için iptal edin.\n{p0}",
  AppMessage.classic: "Klasik",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Dışa aktarma zaman aşımına uğradı. Görsel veya diyagram sayısını azaltmayı deneyin.",
  AppMessage.exportFileAccessFailed:
      "Bir görsele veya hedefe erişilemiyor. Dosyanın var olduğunu, klasör izinlerini ve boş alanı kontrol edin.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Uzak görsel indirilemedi. Bağlantınızı kontrol edin veya yerel bir görsel kullanın.",
  AppMessage.exportIncomplete:
      "Dışa aktarma tamamlanmadı. Hiçbir çıktı yazılmadı. Görselleri, denklemleri ve Mermaid sözdizimini kontrol edin. Uzun belgeler için PDF seçin.\n{p0}",
  AppMessage.splitImagesZIP: "Görselleri böl (ZIP)",
  AppMessage.saveToFiles: "Dosyalar'a kaydet",
  AppMessage.unsupportedExportFormat: "Desteklenmeyen dışa aktarma biçimi",
  AppMessage.pleaseSelectAnExportPath: "Lütfen bir dışa aktarma yolu seçin",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Lütfen dizin yerine bir dosya seçin",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Markdown dosyaları dışa aktarma hedefi olarak kullanılamaz",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Dışa aktarma yolu kaynak dosyayla aynı olamaz",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "Hedef bir dizin. Başka bir dosya adı seçin.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "Çıktı zaten mevcut. Kaydetme iletişim kutusunda doğrudan {p0} öğesini seçin.",
  AppMessage.exportDataCannotBeEmpty: "Dışa aktarma verileri boş olamaz",
  AppMessage.indentEditor: "Girintiyi artır (düzenleyici)",
  AppMessage.outdentEditor: "Girintiyi azalt (düzenleyici)",
  AppMessage.newDocument2: "Yeni belge",
  AppMessage.openDocument2: "Belge aç",
  AppMessage.closeDocument2: "Belgeyi kapat",
  AppMessage.find: "Bul",
  AppMessage.findAndReplace2: "Bul ve değiştir",
  AppMessage.nextMatch: "Sonraki eşleşme",
  AppMessage.previousMatch: "Önceki eşleşme",
  AppMessage.bold: "Kalın",
  AppMessage.italic: "İtalik",
  AppMessage.inlineCode: "Satır içi kod",
  AppMessage.strikethrough: "Üstü çizili",
  AppMessage.editorMode: "Düzenleyici modu",
  AppMessage.splitMode: "Bölünmüş mod",
  AppMessage.previewMode: "Önizleme modu",
  AppMessage.allSyntax: "Tüm sözdizimi",
  AppMessage.quitApp: "Uygulamadan çık",
  AppMessage.cut: "Kes",
  AppMessage.copy: "Kopyala",
  AppMessage.paste: "Yapıştır",
  AppMessage.selectAll: "Tümünü seç",
  AppMessage.shortcutFooter:
      "Esc, aramayı veya sözdizimi panelini kapatır. Metin alanları yerel pano ve geri alma kısayollarını korur.",
};
