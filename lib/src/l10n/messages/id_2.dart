part of '../message_catalog.dart';

const _id2 = <AppMessage, String>{
  AppMessage.versionAvailable: "tersedia",
  AppMessage.requestLimited: "Permintaan dibatasi. Coba lagi nanti.",
  AppMessage.cannotConnect:
      "Tidak dapat terhubung. Periksa koneksi Anda dan coba lagi.",
  AppMessage.cannotReadVersion:
      "Tidak dapat membaca versi yang terpasang. Silakan coba lagi.",
  AppMessage.invalidReleaseInfo:
      "Informasi rilis tidak valid. Coba lagi nanti.",
  AppMessage.checkFailed:
      "Pemeriksaan gagal. Coba lagi atau kunjungi halaman rilis.",
  AppMessage.viewAndDownload: "Lihat dan unduh",
  AppMessage.releases: "Rilis",
  AppMessage.saveFailed: "Penyimpanan gagal",
  AppMessage.retry: "Coba lagi",
  AppMessage.yourEditsAreKeptAsADraftCheckFolderAccessAndFreeSpace:
      "Perubahan Anda disimpan sebagai draf. Periksa akses folder dan ruang kosong.",
  AppMessage.exportComplete: "Ekspor selesai.",
  AppMessage.exportedToValue: "Diekspor ke {p0}",
  AppMessage.remainingWorkStopped: "Pekerjaan tersisa dihentikan",
  AppMessage.thisFileIsAlreadyOpen: "Berkas ini sudah terbuka",
  AppMessage.openedTheExistingFileWithoutOverwritingIt:
      "Membuka berkas yang ada tanpa menimpanya.",
  AppMessage.lnValueColValue: "Baris {p0}, Kolom {p1}",
  AppMessage.characters: "karakter",
  AppMessage.unsavedDraftsRestored: "Draf yang belum tersimpan dipulihkan.",
  AppMessage.draftNotSavedToFile: "Draf · Belum disimpan ke berkas",
  AppMessage.saving: "Menyimpan…",
  AppMessage.saveFailedRetry: "Penyimpanan gagal · Coba lagi",
  AppMessage.fileChangedResolve: "Berkas berubah · Selesaikan",
  AppMessage.fileDeleted: "Berkas dihapus",
  AppMessage.pendingSave: "Menunggu penyimpanan…",
  AppMessage.saved: "Tersimpan",
  AppMessage.fileChangedOnDisk: "Berkas berubah di disk",
  AppMessage.loadDiskVersion: "Muat versi disk",
  AppMessage.overwriteWithMyVersion: "Timpa dengan versi saya",
  AppMessage.autosavePausedYourEditsArePreservedAsADraft:
      "Simpan otomatis dijeda. Perubahan Anda disimpan sebagai draf.",
  AppMessage.sentToTheSelectedApp: "Dikirim ke aplikasi yang dipilih.",
  AppMessage.images: "Gambar",
  AppMessage.addImage: "Tambah gambar",
  AppMessage.takePhoto: "Ambil foto",
  AppMessage.chooseFromPhotos: "Pilih dari Foto",
  AppMessage.allowMarkerToAccessCameraOrPhotosInSystemSettings:
      "Izinkan Marker mengakses Kamera atau Foto di pengaturan sistem.",
  AppMessage.saveInMarker: "Simpan di Marker",
  AppMessage.fileName: "Nama berkas",
  AppMessage.enterAFileNameWithoutSlashes:
      "Masukkan nama berkas tanpa garis miring.",
  AppMessage.fileAlreadyExists: "Berkas sudah ada",
  AppMessage.replaceExistingFile: "Ganti berkas yang ada",
  AppMessage.cannotImportFileValue: "Tidak dapat mengimpor berkas: {p0}",
  AppMessage.valueFileSCouldNotBeImportedTheOtherDocumentsAreOpen:
      "{p0} berkas tidak dapat diimpor. Dokumen lain sedang terbuka.",
  AppMessage.openedDocumentMissingImages:
      "Dokumen dibuka dengan gambar yang hilang. Impor ZIP yang berisi dokumen dan gambar.",
  AppMessage.openedTheExistingCopyInMarker:
      "Membuka salinan yang ada di Marker.",
  AppMessage.importedACopyEditsWillNotChangeTheOriginalFile:
      "Salinan diimpor. Perubahan tidak akan mengubah berkas asli.",
  AppMessage.chooseATemplateToInsertSelectedTextReplacesTheSample:
      "Pilih templat untuk disisipkan. Teks yang dipilih menggantikan contoh.",
  AppMessage.syntaxHighlighting: "Penyorotan sintaks",
  AppMessage.editor: "Editor",
  AppMessage.cannotDecodeImageCheckItsFormatOrIntegrity:
      "Tidak dapat mendekode gambar; periksa format atau integritasnya",
  AppMessage.saveTheDocumentToResolveRelativeImages:
      "Simpan dokumen untuk menyelesaikan gambar relatif",
  AppMessage.diskChangesSyncedUnsavedEditsWerePreserved:
      "Perubahan disk disinkronkan. Perubahan yang belum disimpan telah dipertahankan.",
  AppMessage.saveNow: "Simpan sekarang",
  AppMessage.deleteDocument: "Hapus dokumen",
  AppMessage.deleteDocument2: "Hapus dokumen?",
  AppMessage.deleteDocumentConfirmation:
      "Hapus dokumen ini secara permanen dari Marker. Gambar tetap disimpan. Perubahan yang belum disimpan juga akan ditutup.",
  AppMessage.delete: "Hapus",
  AppMessage.fileOperationFailedValue: "Operasi berkas gagal: {p0}",
  AppMessage.valueHasUnsavedChanges:
      "{p0} memiliki perubahan yang belum disimpan.",
  AppMessage.exportDocument: "Ekspor dokumen",
  AppMessage.exportingDocument: "Mengekspor dokumen…",
  AppMessage.checkTheLatestPublicReleaseOnGitHub:
      "Periksa rilis publik terbaru di GitHub.",
  AppMessage.checkingForUpdates: "Memeriksa pembaruan…",
  AppMessage.noPublicReleaseWasFound: "Tidak ditemukan rilis publik.",
  AppMessage.youAreUpToDate: "Anda sudah menggunakan versi terbaru.",
  AppMessage.valueHasUnsavedChanges2:
      "{p0} memiliki perubahan yang belum disimpan.",
  AppMessage.versionValueIsAvailable: "Versi {p0} tersedia",
  AppMessage.importImagesCopyOriginals: "Impor gambar (salin asli)",
  AppMessage.linkOriginalLocation: "Tautkan lokasi asli…",
  AppMessage.pasteImage: "Tempel gambar",
  AppMessage.insertWebImage: "Sisipkan gambar web…",
  AppMessage.organizeDocumentImages: "Tata gambar dokumen…",
  AppMessage.cleanUnusedResources: "Bersihkan sumber daya yang tidak terpakai…",
  AppMessage.allowFolderAccess: "Izinkan akses folder…",
  AppMessage.newDocumentFolder: "Folder dokumen baru…",
  AppMessage.renameDocument: "Ganti nama dokumen…",
  AppMessage.packageDocumentAndImages: "Paketkan dokumen dan gambar…",
  AppMessage.organizeDocumentImages2: "Tata gambar dokumen",
  AppMessage.organizingImages: "Menata gambar",
  AppMessage.imagesOrganizedOriginalFilesKept:
      "Gambar telah ditata. Berkas asli tetap disimpan.",
  AppMessage.imagesOrganizedInTheEditorSaveTheDocument:
      "Gambar ditata di editor. Simpan dokumen.",
  AppMessage.image: "Gambar",
  AppMessage.locateInEditor: "Temukan di editor",
  AppMessage.insertAtCursor: "Sisipkan di kursor",
  AppMessage.viewImage: "Lihat gambar",
  AppMessage.openImage: "Buka gambar",
  AppMessage.showInFileManager: "Tampilkan di pengelola berkas",
  AppMessage.copyReferencePath: "Salin jalur referensi",
  AppMessage.locateImage2: "Cari gambar…",
  AppMessage.replaceWithImportedImage: "Ganti dengan gambar yang diimpor…",
  AppMessage.downloadToDocumentAssets: "Unduh ke aset dokumen",
  AppMessage.reload: "Muat ulang",
  AppMessage.referenceCopied: "Referensi disalin",
  AppMessage.updatingImage: "Memperbarui gambar",
  AppMessage.downloadingImage: "Mengunduh gambar",
  AppMessage.noSafeCleanupCandidatesSavedAndSharedReferencesAreProtected:
      "Tidak ada kandidat pembersihan yang aman. Referensi tersimpan dan yang dibagikan dilindungi.",
  AppMessage.moveToTrash2: "Pindahkan ke Sampah?",
  AppMessage.unreferencedImagesDescription:
      "Gambar impor ini tidak direferensikan oleh konten saat ini, versi tersimpan, atau dokumen yang diketahui. Pastikan alat lain tidak lagi memakainya.",
  AppMessage.moveToTrash3: "Pindahkan ke Sampah",
  AppMessage.cleaningResources: "Membersihkan sumber daya",
  AppMessage.valueImagesMovedToTrashReferencedOrModifiedResourcesAreKept:
      "{p0} gambar dipindahkan ke Sampah. Sumber daya yang direferensikan atau diubah tetap disimpan.",
  AppMessage.chooseLocation: "Pilih lokasi",
  AppMessage.newDocumentFolder2: "Folder dokumen baru",
  AppMessage.folderName: "Nama folder",
  AppMessage.enterAValidFolderName: "Masukkan nama folder yang valid.",
  AppMessage.theFolderAlreadyExistsChooseAnotherName:
      "Folder sudah ada. Pilih nama lain.",
  AppMessage.renameDocument2: "Ganti nama dokumen",
  AppMessage.documentName: "Nama dokumen",
  AppMessage.invalidDocumentName: "Nama dokumen tidak valid.",
  AppMessage.saveAndRename: "Simpan dan ganti nama?",
};
