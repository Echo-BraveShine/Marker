part of '../message_catalog.dart';

const _id1 = <AppMessage, String>{
  AppMessage.copyUsesCurrentContent:
      "Menggunakan konten editor saat ini; dokumen asli tidak berubah.",
  AppMessage.organizeSavesCurrentContent:
      "Penataan menyimpan konten editor saat ini; semua gambar asli tetap disimpan.",
  AppMessage.unavailableImagesKeepOriginalReferences:
      "\nGambar yang tidak tersedia tetap memakai referensi aslinya.",
  AppMessage.embeddedImagesTooLarge: "Gambar tersemat melebihi 128 MB.",
  AppMessage.imageExceedsSizeLimit: "Gambar melebihi 25 MB.",
  AppMessage.imageExceedsSizeLimitAt: "Gambar melebihi 25 MB: {p0}",
  AppMessage.saveDocumentToResolveImagePath:
      "Simpan dokumen untuk menyelesaikan gambar: {p0}",
  AppMessage.splitImagesTooLarge: "Gambar hasil pemisahan melebihi 64 MB.",
  AppMessage.invalidImageExportDimensions:
      "Dimensi gambar tidak valid atau dokumen terlalu panjang.",
  AppMessage.documentTooLargeForSinglePng:
      "Dokumen terlalu besar untuk satu PNG. Aktifkan Pisahkan gambar (ZIP).",
  AppMessage.cannotOpenLink: "Tidak dapat membuka tautan.",
  AppMessage.cannotReadOriginalImage: "Tidak dapat membaca gambar asli",
  AppMessage.cannotWriteImageAssets: "Tidak dapat menulis aset gambar",
  AppMessage.cannotProcessImageRetry:
      "Tidak dapat memproses gambar ini. Periksa lalu coba lagi.",
  AppMessage.importCancelledOriginalImagesUnchanged:
      "Impor dibatalkan. Gambar asli tidak berubah.",
  AppMessage.importStoppedImagesInserted:
      "Impor dihentikan. {p0} gambar disisipkan.",
  AppMessage.originalLocationReferencesInserted:
      "Referensi lokasi asli disisipkan. Memindahkan gambar asli dapat merusaknya.",
  AppMessage.imagesInsertedOriginalsKept:
      "{p0} gambar disisipkan. Asli tetap disimpan.",
  AppMessage.unsupportedSyntaxKept: "Sintaks kustom dibiarkan tidak berubah.",
  AppMessage.cannotReadOrCopyImage:
      "Tidak dapat membaca atau menyalin gambar. Periksa izin dan ruang yang tersedia.",
  AppMessage.headings: "Judul",
  AppMessage.listsAndBlocks: "Daftar dan blok",
  AppMessage.linksAndExtensions: "Tautan dan ekstensi",
  AppMessage.title: "Marker",
  AppMessage.recoveredUnsavedDoc: "Dokumen belum tersimpan yang dipulihkan",
  AppMessage.file: "Berkas",
  AppMessage.openFile: "Buka Berkas",
  AppMessage.save: "Simpan",
  AppMessage.export: "Ekspor",
  AppMessage.exportHtml: "Ekspor HTML",
  AppMessage.exportPdf: "Ekspor PDF",
  AppMessage.settings: "Pengaturan",
  AppMessage.theme: "Tema",
  AppMessage.themeLight: "Terang",
  AppMessage.themeDark: "Gelap",
  AppMessage.themeSystem: "Sistem",
  AppMessage.fontSize: "karakter",
  AppMessage.language: "Bahasa",
  AppMessage.languageZh: "Tionghoa",
  AppMessage.languageEn: "Inggris",
  AppMessage.edit: "Edit",
  AppMessage.preview: "Pratinjau",
  AppMessage.split: "Terbagi",
  AppMessage.statusLine: "Baris 1, Kolom 1",
  AppMessage.closeDocument: "Tutup dokumen",
  AppMessage.rename: "Ganti nama…",
  AppMessage.moveToTrash: "Pindahkan ke Sampah…",
  AppMessage.moveToTrashPrompt: "Pindahkan dokumen ke Sampah?",
  AppMessage.moveToTrashContent:
      "Dokumen dipindahkan ke Sampah; gambar terkait tetap disimpan. Perubahan yang belum disimpan akan ditutup.",
  AppMessage.saveAs: "Simpan sebagai",
  AppMessage.saveChanges: "Simpan perubahan?",
  AppMessage.discard: "Buang",
  AppMessage.pathConflict:
      "Dokumen lain yang terbuka menggunakan jalur ini. Pilih jalur lain.",
  AppMessage.saveCancelled:
      "Penyimpanan dibatalkan. Konten dokumen Anda tetap tersimpan.",
  AppMessage.fileOperationFailed: "Operasi berkas gagal",
  AppMessage.unableToExport: "Tidak dapat mengekspor dokumen",
  AppMessage.importImages: "Impor gambar",
  AppMessage.stopRemainingWork: "Hentikan pekerjaan yang tersisa",
  AppMessage.cannotReadImages:
      "Tidak dapat membaca gambar. Periksa akses folder.",
  AppMessage.importOrPasteImages:
      "Impor gambar atau tempel tangkapan layar.\nAsli tetap disimpan; folder aset dibuat sesuai kebutuhan.",
  AppMessage.customSyntaxUnchanged:
      "Beberapa sintaks kustom dibiarkan tidak berubah",
  AppMessage.localImages: "Gambar lokal",
  AppMessage.webImages: "Gambar web",
  AppMessage.needsAttention: "Perlu perhatian",
  AppMessage.managed: "Terkelola",
  AppMessage.linkedUrl: "URL tertaut",
  AppMessage.clickToRepair: "Klik untuk memperbaiki",
  AppMessage.exportFormat: "Format",
  AppMessage.exportA4Info:
      "Halaman A4 dengan teks yang dapat dipilih dan disalin, termasuk persamaan, Mermaid, dan gambar.",
  AppMessage.useAppAppearance: "Gunakan tampilan aplikasi",
  AppMessage.imageWidth: "Lebar gambar (px)",
  AppMessage.selfContainedHtml:
      "HTML mandiri dengan gambar dan diagram tersemat, tersedia offline.",
  AppMessage.version: "Versi",
  AppMessage.loadingVersion: "Memuat versi…",
  AppMessage.unsavedDoc: "Berkas ini sudah terbuka",
  AppMessage.unsupportedLinkType: "Jenis tautan tidak didukung",
  AppMessage.webImageLoadFailed: "Gambar web tidak dapat dimuat",
  AppMessage.cannotAccessImage:
      "Tidak dapat mengakses gambar; izinkan akses folder",
  AppMessage.imageNotFound: "Gambar tidak ditemukan",
  AppMessage.locateImage: "Cari gambar",
  AppMessage.allowImageFolderAndRetry: "Izinkan folder gambar dan coba lagi",
  AppMessage.reloadImage: "Muat ulang gambar",
  AppMessage.saveToResolveImages:
      "Simpan dokumen untuk menyelesaikan gambar relatif",
  AppMessage.stop: "Hentikan",
  AppMessage.toggleSidebar: "Tampilkan/sembunyikan bilah sisi",
  AppMessage.resources: "Sumber Daya",
  AppMessage.files: "Berkas",
  AppMessage.documents: "Dokumen",
  AppMessage.documentResources: "Sumber daya dokumen",
  AppMessage.newDocument: "Baru",
  AppMessage.openDocument: "Buka",
  AppMessage.undo: "Urungkan",
  AppMessage.redo: "Ulangi",
  AppMessage.findAndReplace: "Cari dan ganti",
  AppMessage.textColor: "Warna teks",
  AppMessage.equationTemplates: "Templat persamaan",
  AppMessage.mermaidTemplates: "Templat Mermaid",
  AppMessage.allMarkdownSyntax: "Semua sintaks Markdown",
  AppMessage.serifFont: "Font serif",
  AppMessage.startWriting: "Mulai menulis…",
  AppMessage.auto: "Otomatis",
  AppMessage.general: "Umum",
  AppMessage.editorAndPreview: "Editor & pratinjau",
  AppMessage.keyboardShortcuts: "Pintasan papan ketik",
  AppMessage.about: "Tentang",
  AppMessage.appearance: "Tampilan",
  AppMessage.interfaceLanguage: "Bahasa",
  AppMessage.versionUnavailable: "Versi tidak tersedia",
  AppMessage.focusedMarkdown:
      "Penulisan Markdown yang fokus dengan pratinjau langsung.",
  AppMessage.checkForUpdates: "Periksa pembaruan",
};
