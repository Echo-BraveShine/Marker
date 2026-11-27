part of '../message_catalog.dart';

const _tr2 = <AppMessage, String>{
  AppMessage.versionAvailable: "kullanılabilir",
  AppMessage.requestLimited: "İstek sınırlı. Daha sonra tekrar deneyin.",
  AppMessage.cannotConnect:
      "Bağlanılamıyor. Bağlantınızı kontrol edip yeniden deneyin.",
  AppMessage.cannotReadVersion:
      "Yüklü sürüm okunamıyor. Lütfen yeniden deneyin.",
  AppMessage.invalidReleaseInfo:
      "Geçersiz sürüm bilgisi. Daha sonra tekrar deneyin.",
  AppMessage.checkFailed:
      "Kontrol başarısız. Yeniden deneyin veya sürümler sayfasını ziyaret edin.",
  AppMessage.viewAndDownload: "Görüntüle ve indir",
  AppMessage.releases: "Sürümler",
  AppMessage.saveFailed: "Kaydetme başarısız",
  AppMessage.retry: "Yeniden dene",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Düzenlemeleriniz taslak olarak korunur. Klasör erişimini ve boş alanı kontrol edin.",
  AppMessage.exportComplete: "Dışa aktarma tamamlandı.",
  AppMessage.exportedToValue: "{p0} konumuna aktarıldı",
  AppMessage.remainingWorkStopped: "Kalan iş durduruldu",
  AppMessage.thisFileIsAlreadyOpen: "Bu dosya zaten açık",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Mevcut dosya üzerine yazılmadan açıldı.",
  AppMessage.lnValueColValue: "Sat {p0}, Süt {p1}",
  AppMessage.characters: "karakter",
  AppMessage.unsavedDraftsRestored: "Kaydedilmemiş taslaklar geri yüklendi.",
  AppMessage.draftNotSavedToFile: "Taslak · Dosyaya kaydedilmedi",
  AppMessage.saving: "Kaydediliyor…",
  AppMessage.saveFailedRetry: "Kaydetme başarısız · Yeniden dene",
  AppMessage.fileChangedResolve: "Dosya değişti · Çözümle",
  AppMessage.fileDeleted: "Dosya silindi",
  AppMessage.pendingSave: "Kaydetme bekliyor…",
  AppMessage.saved: "Kaydedildi",
  AppMessage.fileChangedOnDisk: "Dosya diskte değişti",
  AppMessage.loadDiskVersion: "Disk sürümünü yükle",
  AppMessage.overwriteWithMyVersion: "Benim sürümümle üzerine yaz",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Otomatik kaydetme duraklatıldı. Düzenlemeleriniz taslak olarak korunuyor.",
  AppMessage.sentToTheSelectedApp: "Seçili uygulamaya gönderildi.",
  AppMessage.images: "Görseller",
  AppMessage.addImage: "Görsel ekle",
  AppMessage.takePhoto: "Fotoğraf çek",
  AppMessage.chooseFromPhotos: "Fotoğraflardan Seç",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Sistem ayarlarından Marker'ın Kamera veya Fotoğraflar'a erişmesine izin verin.",
  AppMessage.saveInMarker: "Marker'da kaydet",
  AppMessage.fileName: "Dosya adı",
  AppMessage.enterAFileNameWithoutSlashes:
      "Eğik çizgi içermeyen bir dosya adı girin.",
  AppMessage.fileAlreadyExists: "Dosya zaten mevcut",
  AppMessage.replaceExistingFile: "Mevcut dosyayı değiştir",
  AppMessage.cannotImportFileValue: "Dosya içe aktarılamıyor: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "{p0} dosya içe aktarılamadı. Diğer belgeler açık.",
  AppMessage.openedDocumentMissingImages:
      "Belge eksik görsellerle açıldı. Belgeyi ve görselleri içeren bir ZIP içe aktarın.",
  AppMessage.openedTheExistingCopyInMarker: "Mevcut kopya Marker'da açıldı.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Bir kopya içe aktarıldı. Düzenlemeler özgün dosyayı değiştirmez.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Eklenecek bir şablon seçin. Seçili metin örnek içeriğin yerini alır.",
  AppMessage.syntaxHighlighting: "Sözdizimi vurgulama",
  AppMessage.editor: "Düzenleyici",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Görsel çözülemiyor; biçimini veya bütünlüğünü kontrol edin",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Göreli görselleri çözümlemek için belgeyi kaydedin",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Disk değişiklikleri eşitlendi. Kaydedilmemiş düzenlemeler korundu.",
  AppMessage.saveNow: "Şimdi kaydet",
  AppMessage.deleteDocument: "Belgeyi sil",
  AppMessage.deleteDocument2: "Belge silinsin mi?",
  AppMessage.deleteDocumentConfirmation:
      "Bu belgeyi Marker'dan kalıcı olarak silin. Görseller korunur. Kaydedilmemiş düzenlemeler de kapatılır.",
  AppMessage.delete: "Sil",
  AppMessage.fileOperationFailedValue: "Dosya işlemi başarısız: {p0}",
  AppMessage.valueHasUnsavedChanges:
      "{p0} dosyasında kaydedilmemiş değişiklikler var.",
  AppMessage.exportDocument: "Belgeyi dışa aktar",
  AppMessage.exportingDocument: "Belge dışa aktarılıyor…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "GitHub'daki en son herkese açık sürümü kontrol edin.",
  AppMessage.checkingForUpdates: "Güncellemeler kontrol ediliyor…",
  AppMessage.noPublicReleaseWasFound: "Herkese açık sürüm bulunamadı.",
  AppMessage.youAreUpToDate: "Güncelsiniz.",
  AppMessage.valueHasUnsavedChanges2:
      "{p0} dosyasında kaydedilmemiş değişiklikler var.",
  AppMessage.versionValueIsAvailable: "Sürüm {p0} kullanılabilir",
  AppMessage.importImagesCopyOriginals:
      "Görselleri içe aktar (özgünleri kopyala)",
  AppMessage.linkOriginalLocation: "Özgün konumu bağla…",
  AppMessage.pasteImage: "Görsel yapıştır",
  AppMessage.insertWebImage: "Web görseli ekle…",
  AppMessage.organizeDocumentImages: "Belge görsellerini düzenle…",
  AppMessage.cleanUnusedResources: "Kullanılmayan kaynakları temizle…",
  AppMessage.allowFolderAccess: "Klasör erişimine izin ver…",
  AppMessage.newDocumentFolder: "Yeni belge klasörü…",
  AppMessage.renameDocument: "Belgeyi yeniden adlandır…",
  AppMessage.packageDocumentAndImages: "Belgeyi ve görselleri paketle…",
  AppMessage.organizeDocumentImages2: "Belge görsellerini düzenle",
  AppMessage.organizingImages: "Görseller düzenleniyor",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Görseller düzenlendi. Özgün dosyalar korundu.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Görseller düzenleyicide düzenlendi. Belgeyi kaydedin.",
  AppMessage.image: "Görsel",
  AppMessage.locateInEditor: "Düzenleyicide bul",
  AppMessage.insertAtCursor: "İmleç konumuna ekle",
  AppMessage.viewImage: "Görseli görüntüle",
  AppMessage.openImage: "Görseli aç",
  AppMessage.showInFileManager: "Dosya yöneticisinde göster",
  AppMessage.copyReferencePath: "Başvuru yolunu kopyala",
  AppMessage.locateImage2: "Görseli bul…",
  AppMessage.replaceWithImportedImage: "İçe aktarılan görselle değiştir…",
  AppMessage.downloadToDocumentAssets: "Belge varlıklarına indir",
  AppMessage.reload: "Yeniden yükle",
  AppMessage.referenceCopied: "Başvuru kopyalandı",
  AppMessage.updatingImage: "Görsel güncelleniyor",
  AppMessage.downloadingImage: "Görsel indiriliyor",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Güvenli temizleme adayı yok. Kaydedilmiş ve paylaşılan başvurular korunur.",
  AppMessage.moveToTrash2: "Çöp Kutusuna taşınsın mı?",
  AppMessage.unreferencedImagesDescription:
      "Bu içe aktarılan görseller geçerli içerik, kaydedilmiş sürümler veya bilinen belgeler tarafından referanslanmıyor. Diğer araçların artık bunları kullanmadığını onaylayın.",
  AppMessage.moveToTrash3: "Çöp Kutusuna Taşı",
  AppMessage.cleaningResources: "Kaynaklar temizleniyor",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} görsel Çöp Kutusuna taşındı. Başvurulan veya değiştirilen kaynaklar korunur.",
  AppMessage.chooseLocation: "Konum seç",
  AppMessage.newDocumentFolder2: "Yeni belge klasörü",
  AppMessage.folderName: "Klasör adı",
  AppMessage.enterAValidFolderName: "Geçerli bir klasör adı girin.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "Klasör zaten mevcut. Başka bir ad seçin.",
  AppMessage.renameDocument2: "Belgeyi yeniden adlandır",
  AppMessage.documentName: "Belge adı",
  AppMessage.invalidDocumentName: "Geçersiz belge adı.",
  AppMessage.saveAndRename: "Kaydedilsin ve yeniden adlandırılsın mı?",
};
