part of '../message_catalog.dart';

const _id3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "Konten saat ini akan disimpan. Folder aset dan referensi gambar dalam dokumen ini juga akan diganti namanya. Referensi dari dokumen lain perlu diperbarui secara terpisah.",
  AppMessage.rename2: "Ganti nama",
  AppMessage.renamingDocument: "Mengganti nama dokumen",
  AppMessage.packageDocumentAndImages2: "Paketkan dokumen dan gambar",
  AppMessage.packagingDocument: "Memaketkan dokumen",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Paket dibuat dengan referensi yang masih perlu diperbaiki.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Dokumen saat ini dan gambar telah dipaketkan.",
  AppMessage.dropToImportImages: "Lepaskan untuk mengimpor gambar",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Salin ke aset dokumen. Asli tetap disimpan.",
  AppMessage.saveTheDocumentFirst: "Simpan dokumen terlebih dahulu",
  AppMessage.saveBeforeImportImages:
      "Simpan terlebih dahulu agar gambar dapat disimpan di samping dokumen dengan jalur relatif yang portabel.",
  AppMessage.saveAndContinue: "Simpan dan lanjutkan",
  AppMessage.allowFolderAccess2: "Izinkan akses folder",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Pilih folder yang memuatnya atau salah satu folder induknya.",
  AppMessage.folderAccessGranted: "Akses folder diberikan.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "Dokumen berubah. Impor gambar lagi.",
  AppMessage.importingImages: "Mengimpor gambar",
  AppMessage.noTextOrImageToPaste: "Tidak ada teks atau gambar untuk ditempel.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Gambar papan klip tidak tersedia di lingkungan ini.",
  AppMessage.dropAccessDenied:
      "Sistem tidak dapat memberikan akses ke berkas yang dilepaskan. Gunakan Impor gambar untuk memilihnya.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Lepaskan gambar PNG, JPEG, GIF, WebP, atau BMP.",
  AppMessage.insertWebImage2: "Sisipkan gambar web",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Masukkan URL gambar HTTP atau HTTPS yang valid.",
  AppMessage.imageDescription: "Deskripsi gambar",
  AppMessage.unsupportedImageAddress: "Alamat gambar tidak didukung",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Gunakan Simpan sebagai untuk memindahkan dokumen ke folder lain.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "Berkas dengan nama ini sudah ada.",
  AppMessage.theSourceDocumentIsUnavailable: "Dokumen sumber tidak tersedia.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "Folder aset dengan nama baru sudah ada. Tidak ada yang diganti namanya.",
  AppMessage.resolveImagesBeforeExport:
      "Selesaikan gambar yang tidak tersedia atau secara eksplisit pertahankan referensi aslinya.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "Gambar ini tidak direferensikan dalam dokumen.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Tidak dapat memuat gambar. Coba lagi atau periksa jaringan dan akses berkas.",
  AppMessage.more: "Lainnya",
  AppMessage.cannotOverwriteASymbolicLink:
      "Tidak dapat menimpa tautan simbolik.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "Direktori sumber daya bukan direktori biasa.",
  AppMessage.noAvailableResourceDirectoryName:
      "Tidak ada nama direktori sumber daya yang tersedia.",
  AppMessage.tooManyImageNameConflicts: "Terlalu banyak konflik nama gambar.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Gambar tidak valid; gunakan PNG, JPEG, GIF, WebP, atau BMP.",
  AppMessage.imageExceeds50MB: "Gambar melebihi 50 MB.",
  AppMessage.imageExceeds50MB2: "Gambar melebihi 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2:
      "Tidak dapat menimpa tautan simbolik.",
  AppMessage.unsupportedImageURL: "URL gambar tidak didukung.",
  AppMessage.downloadFailedHTTPValue: "Unduhan gagal: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Terlalu banyak pengalihan gambar.",
  AppMessage.continueText: "Lanjutkan",
  AppMessage.someImagesNeedAttention: "Beberapa gambar perlu perhatian",
  AppMessage.partialResourceCopyWarning:
      "Referensi ini tidak dapat disalin sepenuhnya. Perbaiki dulu, atau lanjutkan dengan mempertahankan alamat aslinya.",
  AppMessage.customSyntax: "Sintaks kustom",
  AppMessage.continueWithOriginalAddresses: "Lanjutkan dengan alamat asli",
  AppMessage.resourceInventorySummary:
      "{p0} gambar lokal ({p1} terkelola), {p2} gambar web.\n{p3} gambar untuk disalin; {p4} MB gambar lokal.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Unduh juga gambar web",
  AppMessage.copyLocalImages: "Salin gambar lokal",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Akses folder diperlukan. Izinkan akses ke lokasi ini dan coba lagi.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "Berkas atau folder hilang, dipindahkan, atau tidak diunduh secara lokal.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "Disk penuh. Kosongkan sebagian ruang dan coba lagi.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "Lokasi ini hanya-baca. Pilih folder yang dapat ditulis.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "Operasi berkas gagal. Periksa lokasi dan detail sistem di bawah ini.",
  AppMessage.location: "Lokasi",
  AppMessage.unknown: "tidak diketahui",
  AppMessage.error: "kesalahan",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Tidak dapat memproses gambar. Periksa format atau koneksinya lalu coba lagi.",
  AppMessage.someImagesCouldNotBeCopied: "Beberapa gambar tidak dapat disalin",
  AppMessage.originalImagesUnchanged:
      "Berkas asli tidak berubah. Perbaiki gambar ini, atau pertahankan alamatnya dan lanjutkan.",
  AppMessage.keepAddressesAndContinue: "Pertahankan alamat dan lanjutkan",
  AppMessage.operationResult: "Hasil operasi",
  AppMessage.imageDimensionsAreTooLarge: "Dimensi gambar terlalu besar.",
  AppMessage.aResourceOperationIsAlreadyRunning:
      "Operasi sumber daya sedang berjalan.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted:
      "Hanya berkas di dalam Marker yang dapat dihapus.",
  AppMessage.trashFailedFileKept:
      "Tidak dapat memindahkan ke Sampah. Berkas asli tetap disimpan. Periksa akses folder atau tempat sampah.",
  AppMessage.allowFolderAccess3: "Izinkan akses folder",
  AppMessage.allowFolderAccess4: "Izinkan akses folder",
  AppMessage.folderAccessPurpose:
      "Marker memerlukan folder ini untuk membaca gambar atau membuat aset di samping dokumen Anda. Izinkan akses untuk melanjutkan, atau batalkan untuk menghentikan operasi ini.\n{p0}",
  AppMessage.classic: "Klasik",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "Ekspor kehabisan waktu. Coba kurangi jumlah gambar atau diagram.",
  AppMessage.exportFileAccessFailed:
      "Tidak dapat mengakses gambar atau tujuan. Periksa apakah berkas ada, izin folder, dan ruang kosong.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "Tidak dapat mengunduh gambar jarak jauh. Periksa koneksi Anda atau gunakan gambar lokal.",
  AppMessage.exportIncomplete:
      "Ekspor tidak selesai. Tidak ada output yang ditulis. Periksa gambar, persamaan, dan sintaks Mermaid. Untuk dokumen panjang, pilih PDF.\n{p0}",
  AppMessage.splitImagesZIP: "Pisahkan gambar (ZIP)",
  AppMessage.saveToFiles: "Simpan ke Files",
  AppMessage.unsupportedExportFormat: "Format ekspor tidak didukung",
  AppMessage.pleaseSelectAnExportPath: "Silakan pilih jalur ekspor",
  AppMessage.pleaseSelectAFileInsteadOfADirectory:
      "Silakan pilih berkas, bukan direktori",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Berkas Markdown tidak dapat digunakan sebagai tujuan ekspor",
  AppMessage.exportPathCannotBeTheSameAsSourceFile:
      "Jalur ekspor tidak boleh sama dengan berkas sumber",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "Tujuan adalah direktori. Pilih nama berkas lain.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "Output sudah ada. Pilih {p0} langsung di dialog simpan.",
  AppMessage.exportDataCannotBeEmpty: "Data ekspor tidak boleh kosong",
  AppMessage.indentEditor: "Inden (editor)",
  AppMessage.outdentEditor: "Kurangi inden (editor)",
  AppMessage.newDocument2: "Dokumen baru",
  AppMessage.openDocument2: "Buka dokumen",
  AppMessage.closeDocument2: "Tutup dokumen",
  AppMessage.find: "Cari",
  AppMessage.findAndReplace2: "Cari dan ganti",
  AppMessage.nextMatch: "Kecocokan berikutnya",
  AppMessage.previousMatch: "Kecocokan sebelumnya",
  AppMessage.bold: "Tebal",
  AppMessage.italic: "Miring",
  AppMessage.inlineCode: "Kode sebaris",
  AppMessage.strikethrough: "Coret",
  AppMessage.editorMode: "Mode editor",
  AppMessage.splitMode: "Mode terbagi",
  AppMessage.previewMode: "Mode pratinjau",
  AppMessage.allSyntax: "Semua sintaks",
  AppMessage.quitApp: "Keluar dari aplikasi",
  AppMessage.cut: "Potong",
  AppMessage.copy: "Salin",
  AppMessage.paste: "Tempel",
  AppMessage.selectAll: "Pilih semua",
  AppMessage.shortcutFooter:
      "Esc menutup pencarian atau panel sintaks. Kolom teks mempertahankan pintasan papan klip dan urungkan bawaan.",
};
