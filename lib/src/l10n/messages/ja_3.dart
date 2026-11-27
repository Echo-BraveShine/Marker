part of '../message_catalog.dart';

const _ja3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "現在の内容が保存されます。このドキュメントのアセットフォルダと画像参照も名前が変更されます。他のドキュメントからの参照は別途更新が必要です。",
  AppMessage.rename2: "名前を変更",
  AppMessage.renamingDocument: "ドキュメントの名前を変更中",
  AppMessage.packageDocumentAndImages2: "ドキュメントと画像をパッケージ化",
  AppMessage.packagingDocument: "ドキュメントをパッケージ化中",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "パッケージを作成しましたが、修復が必要な参照があります。",
  AppMessage.currentDocumentAndImagesPackaged: "現在のドキュメントと画像をパッケージ化しました。",
  AppMessage.dropToImportImages: "ドロップして画像を読み込む",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "ドキュメントのアセットにコピーします。元のファイルは保持されます。",
  AppMessage.saveTheDocumentFirst: "先にドキュメントを保存してください",
  AppMessage.saveBeforeImportImages:
      "ポータブルな相対パスでドキュメントの隣に画像を保存できるよう、先に保存してください。",
  AppMessage.saveAndContinue: "保存して続行",
  AppMessage.allowFolderAccess2: "フォルダへのアクセスを許可",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "格納先のフォルダまたはその親フォルダのいずれかを選択してください。",
  AppMessage.folderAccessGranted: "フォルダへのアクセスが許可されました。",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "ドキュメントが変更されました。画像を再度読み込んでください。",
  AppMessage.importingImages: "画像を読み込み中",
  AppMessage.noTextOrImageToPaste: "貼り付けるテキストまたは画像がありません。",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "この環境ではクリップボードの画像を使用できません。",
  AppMessage.dropAccessDenied:
      "ドロップされたファイルへのアクセスをシステムが許可できませんでした。「画像を読み込む」で選択してください。",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "PNG、JPEG、GIF、WebP、BMP 画像をドロップしてください。",
  AppMessage.insertWebImage2: "ウェブ画像を挿入",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "有効な HTTP または HTTPS の画像 URL を入力してください。",
  AppMessage.imageDescription: "画像の説明",
  AppMessage.unsupportedImageAddress: "サポートされていない画像アドレス",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "ドキュメントを別のフォルダに移動するには「名前を付けて保存」を使用してください。",
  AppMessage.aFileWithThisNameAlreadyExists: "この名前のファイルは既に存在します。",
  AppMessage.theSourceDocumentIsUnavailable: "元のドキュメントを利用できません。",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "新しい名前のアセットフォルダが既に存在します。名前は変更されていません。",
  AppMessage.resolveImagesBeforeExport: "利用できない画像を解決するか、元の参照のままにすることを明示してください。",
  AppMessage.thisImageIsNotReferencedInTheDocument: "この画像はドキュメント内で参照されていません。",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "画像を読み込めません。再試行するか、ネットワークとファイルへのアクセスを確認してください。",
  AppMessage.more: "その他",
  AppMessage.cannotOverwriteASymbolicLink: "シンボリックリンクは上書きできません。",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "リソースディレクトリが通常のディレクトリではありません。",
  AppMessage.noAvailableResourceDirectoryName: "使用可能なリソースディレクトリ名がありません。",
  AppMessage.tooManyImageNameConflicts: "画像名の競合が多すぎます。",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "無効な画像です。PNG、JPEG、GIF、WebP、BMP のいずれかを使用してください。",
  AppMessage.imageExceeds50MB: "画像が 50 MB を超えています。",
  AppMessage.imageExceeds50MB2: "画像が 50 MB を超えています。",
  AppMessage.cannotOverwriteASymbolicLink2: "シンボリックリンクは上書きできません。",
  AppMessage.unsupportedImageURL: "サポートされていない画像 URL です。",
  AppMessage.downloadFailedHTTPValue: "ダウンロードに失敗しました: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "画像のリダイレクトが多すぎます。",
  AppMessage.continueText: "続行",
  AppMessage.someImagesNeedAttention: "一部の画像に確認が必要です",
  AppMessage.partialResourceCopyWarning:
      "これらの参照は完全にはコピーできません。先に修復するか、元のアドレスのまま続行してください。",
  AppMessage.customSyntax: "カスタム構文",
  AppMessage.continueWithOriginalAddresses: "元のアドレスのまま続行",
  AppMessage.resourceInventorySummary:
      "{p0} 個のローカル画像 ({p1} 個は管理済み)、{p2} 個のウェブ画像。\nコピーする画像: {p3} 個、ローカル画像のサイズ: {p4} MB。\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "ウェブ画像もダウンロード",
  AppMessage.copyLocalImages: "ローカル画像をコピー",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "フォルダへのアクセスが必要です。この場所へのアクセスを許可して再試行してください。",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "ファイルまたはフォルダが見つからないか、移動されたか、ローカルにダウンロードされていません。",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "ディスクがいっぱいです。空き容量を確保して再試行してください。",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "この場所は読み取り専用です。書き込み可能なフォルダを選択してください。",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "ファイル操作に失敗しました。場所と以下のシステムの詳細を確認してください。",
  AppMessage.location: "場所",
  AppMessage.unknown: "不明",
  AppMessage.error: "エラー",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "画像を処理できません。形式または接続を確認して再試行してください。",
  AppMessage.someImagesCouldNotBeCopied: "一部の画像をコピーできませんでした",
  AppMessage.originalImagesUnchanged:
      "元のファイルは変更されていません。これらの画像を修復するか、アドレスを保持したまま続行してください。",
  AppMessage.keepAddressesAndContinue: "アドレスを保持して続行",
  AppMessage.operationResult: "操作結果",
  AppMessage.imageDimensionsAreTooLarge: "画像の寸法が大きすぎます。",
  AppMessage.aResourceOperationIsAlreadyRunning: "リソース操作が既に実行中です。",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted: "Marker 内のファイルのみ削除できます。",
  AppMessage.trashFailedFileKept:
      "ゴミ箱に移動できません。元のファイルは保持されています。フォルダへのアクセスまたはゴミ箱を確認してください。",
  AppMessage.allowFolderAccess3: "フォルダへのアクセスを許可",
  AppMessage.allowFolderAccess4: "フォルダへのアクセスを許可",
  AppMessage.folderAccessPurpose:
      "Marker がドキュメントの隣で画像を読み取ったりアセットを作成したりするには、このフォルダが必要です。続行するにはアクセスを許可するか、キャンセルしてこの操作を中止してください。\n{p0}",
  AppMessage.classic: "Classic",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "書き出しがタイムアウトしました。画像や図の数を減らしてみてください。",
  AppMessage.exportFileAccessFailed:
      "画像または出力先にアクセスできません。ファイルの存在、フォルダの権限、空き容量を確認してください。\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "リモート画像をダウンロードできませんでした。接続を確認するか、ローカル画像を使用してください。",
  AppMessage.exportIncomplete:
      "書き出しが完了しませんでした。出力は書き込まれていません。画像、数式、Mermaid の構文を確認してください。長いドキュメントでは PDF を選択してください。\n{p0}",
  AppMessage.splitImagesZIP: "画像を分割 (ZIP)",
  AppMessage.saveToFiles: "ファイルに保存",
  AppMessage.unsupportedExportFormat: "サポートされていない書き出し形式",
  AppMessage.pleaseSelectAnExportPath: "書き出し先を選択してください",
  AppMessage.pleaseSelectAFileInsteadOfADirectory: "ディレクトリではなくファイルを選択してください",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Markdown ファイルは書き出し先にできません",
  AppMessage.exportPathCannotBeTheSameAsSourceFile: "書き出し先は元のファイルと同じにできません",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "出力先がディレクトリです。別のファイル名を選択してください。",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "出力先は既に存在します。保存ダイアログで {p0} を直接選択してください。",
  AppMessage.exportDataCannotBeEmpty: "書き出すデータを空にできません",
  AppMessage.indentEditor: "インデント (エディター)",
  AppMessage.outdentEditor: "インデント解除 (エディター)",
  AppMessage.newDocument2: "新規ドキュメント",
  AppMessage.openDocument2: "ドキュメントを開く",
  AppMessage.closeDocument2: "ドキュメントを閉じる",
  AppMessage.find: "検索",
  AppMessage.findAndReplace2: "検索と置換",
  AppMessage.nextMatch: "次の一致",
  AppMessage.previousMatch: "前の一致",
  AppMessage.bold: "太字",
  AppMessage.italic: "斜体",
  AppMessage.inlineCode: "インラインコード",
  AppMessage.strikethrough: "取り消し線",
  AppMessage.editorMode: "エディターモード",
  AppMessage.splitMode: "分割モード",
  AppMessage.previewMode: "プレビューモード",
  AppMessage.allSyntax: "すべての構文",
  AppMessage.quitApp: "アプリを終了",
  AppMessage.cut: "切り取り",
  AppMessage.copy: "コピー",
  AppMessage.paste: "貼り付け",
  AppMessage.selectAll: "すべて選択",
  AppMessage.shortcutFooter:
      "Esc で検索または構文パネルを閉じます。テキストフィールドでは標準のクリップボードと元に戻すのショートカットが使えます。",
};
