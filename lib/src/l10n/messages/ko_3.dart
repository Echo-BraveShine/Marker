part of '../message_catalog.dart';

const _ko3 = <AppMessage, String>{
  AppMessage.renameDocumentResourcesDescription:
      "현재 내용이 저장됩니다. 이 문서의 자산 폴더와 이미지 참조도 이름이 바뀝니다. 다른 문서의 참조는 별도로 업데이트해야 합니다.",
  AppMessage.rename2: "이름 바꾸기",
  AppMessage.renamingDocument: "문서 이름 바꾸는 중",
  AppMessage.packageDocumentAndImages2: "문서와 이미지 패키징",
  AppMessage.packagingDocument: "문서 패키징 중",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "패키지를 만들었지만 아직 복구해야 할 참조가 있습니다.",
  AppMessage.currentDocumentAndImagesPackaged: "현재 문서와 이미지를 패키징했습니다.",
  AppMessage.dropToImportImages: "이미지를 가져오려면 여기에 놓으세요",
  AppMessage.copyToDocumentAssetsOriginalsAreKept: "문서 자산에 복사합니다. 원본은 유지됩니다.",
  AppMessage.saveTheDocumentFirst: "먼저 문서를 저장하세요",
  AppMessage.saveBeforeImportImages:
      "휴대 가능한 상대 경로를 사용해 문서 옆에 이미지를 저장하려면 먼저 저장하세요.",
  AppMessage.saveAndContinue: "저장하고 계속",
  AppMessage.allowFolderAccess2: "폴더 접근 허용",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "포함된 폴더 또는 상위 폴더 중 하나를 선택하세요.",
  AppMessage.folderAccessGranted: "폴더 접근이 허용되었습니다.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "문서가 변경되었습니다. 이미지를 다시 가져오세요.",
  AppMessage.importingImages: "이미지 가져오는 중",
  AppMessage.noTextOrImageToPaste: "붙여넣을 텍스트나 이미지가 없습니다.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "이 환경에서는 클립보드 이미지를 사용할 수 없습니다.",
  AppMessage.dropAccessDenied:
      "시스템이 끌어온 파일에 대한 접근을 허용하지 못했습니다. 이미지 가져오기를 사용해 선택하세요.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "PNG, JPEG, GIF, WebP 또는 BMP 이미지를 놓으세요.",
  AppMessage.insertWebImage2: "웹 이미지 삽입",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "올바른 HTTP 또는 HTTPS 이미지 URL을 입력하세요.",
  AppMessage.imageDescription: "이미지 설명",
  AppMessage.unsupportedImageAddress: "지원되지 않는 이미지 주소",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "문서를 다른 폴더로 옮기려면 다른 이름으로 저장을 사용하세요.",
  AppMessage.aFileWithThisNameAlreadyExists: "같은 이름의 파일이 이미 있습니다.",
  AppMessage.theSourceDocumentIsUnavailable: "원본 문서를 사용할 수 없습니다.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "새 이름의 자산 폴더가 이미 있습니다. 아무것도 이름이 바뀌지 않았습니다.",
  AppMessage.resolveImagesBeforeExport:
      "사용할 수 없는 이미지를 확인하거나 원래 참조를 유지하도록 명시하세요.",
  AppMessage.thisImageIsNotReferencedInTheDocument: "이 이미지는 문서에서 참조되지 않습니다.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "이미지를 불러올 수 없습니다. 다시 시도하거나 네트워크와 파일 접근을 확인하세요.",
  AppMessage.more: "더 보기",
  AppMessage.cannotOverwriteASymbolicLink: "심볼릭 링크를 덮어쓸 수 없습니다.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "리소스 디렉터리가 일반 디렉터리가 아닙니다.",
  AppMessage.noAvailableResourceDirectoryName: "사용 가능한 리소스 디렉터리 이름이 없습니다.",
  AppMessage.tooManyImageNameConflicts: "이미지 이름 충돌이 너무 많습니다.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "잘못된 이미지입니다. PNG, JPEG, GIF, WebP 또는 BMP를 사용하세요.",
  AppMessage.imageExceeds50MB: "이미지가 50 MB를 초과합니다.",
  AppMessage.imageExceeds50MB2: "이미지가 50 MB를 초과합니다.",
  AppMessage.cannotOverwriteASymbolicLink2: "심볼릭 링크를 덮어쓸 수 없습니다.",
  AppMessage.unsupportedImageURL: "지원되지 않는 이미지 URL입니다.",
  AppMessage.downloadFailedHTTPValue: "다운로드 실패: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "이미지 리디렉션이 너무 많습니다.",
  AppMessage.continueText: "계속",
  AppMessage.someImagesNeedAttention: "일부 이미지를 확인해야 합니다",
  AppMessage.partialResourceCopyWarning:
      "이 참조는 완전히 복사할 수 없습니다. 먼저 복구하거나 원래 주소를 유지한 채 계속하세요.",
  AppMessage.customSyntax: "사용자 지정 구문",
  AppMessage.continueWithOriginalAddresses: "원래 주소로 계속",
  AppMessage.resourceInventorySummary:
      "{p0}개의 로컬 이미지({p1}개 관리됨), {p2}개의 웹 이미지.\n복사할 이미지 {p3}개, 로컬 이미지 {p4} MB.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "웹 이미지도 다운로드",
  AppMessage.copyLocalImages: "로컬 이미지 복사",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "폴더 접근이 필요합니다. 이 위치에 대한 접근을 허용하고 다시 시도하세요.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "파일이나 폴더가 없거나, 이동되었거나, 로컬에 다운로드되지 않았습니다.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "디스크가 가득 찼습니다. 공간을 확보하고 다시 시도하세요.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "이 위치는 읽기 전용입니다. 쓰기 가능한 폴더를 선택하세요.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "파일 작업에 실패했습니다. 위치와 아래 시스템 세부 정보를 확인하세요.",
  AppMessage.location: "위치",
  AppMessage.unknown: "알 수 없음",
  AppMessage.error: "오류",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "이미지를 처리할 수 없습니다. 형식이나 연결을 확인하고 다시 시도하세요.",
  AppMessage.someImagesCouldNotBeCopied: "일부 이미지를 복사할 수 없습니다",
  AppMessage.originalImagesUnchanged:
      "원본 파일은 변경되지 않았습니다. 이 이미지를 복구하거나 주소를 유지한 채 계속하세요.",
  AppMessage.keepAddressesAndContinue: "주소를 유지하고 계속",
  AppMessage.operationResult: "작업 결과",
  AppMessage.imageDimensionsAreTooLarge: "이미지 크기가 너무 큽니다.",
  AppMessage.aResourceOperationIsAlreadyRunning: "리소스 작업이 이미 실행 중입니다.",
  AppMessage.onlyFilesInsideMarkerCanBeDeleted: "Marker 내부의 파일만 삭제할 수 있습니다.",
  AppMessage.trashFailedFileKept:
      "휴지통으로 이동할 수 없습니다. 원본 파일은 유지되었습니다. 폴더 접근 권한이나 휴지통을 확인하세요.",
  AppMessage.allowFolderAccess3: "폴더 접근 허용",
  AppMessage.allowFolderAccess4: "폴더 접근 허용",
  AppMessage.folderAccessPurpose:
      "Marker가 문서 옆의 이미지를 읽거나 자산을 만들려면 이 폴더가 필요합니다. 계속하려면 접근을 허용하고, 이 작업을 중단하려면 취소하세요.\n{p0}",
  AppMessage.classic: "Classic",
  AppMessage.exportTimedOutTryReducingTheNumberOfImagesOrDiagrams:
      "내보내기 시간이 초과되었습니다. 이미지나 다이어그램 수를 줄여 보세요.",
  AppMessage.exportFileAccessFailed:
      "이미지나 대상에 접근할 수 없습니다. 파일 존재 여부, 폴더 권한, 여유 공간을 확인하세요.\n{p0}",
  AppMessage.exportNetworkImageFailed:
      "원격 이미지를 다운로드할 수 없습니다. 연결을 확인하거나 로컬 이미지를 사용하세요.",
  AppMessage.exportIncomplete:
      "내보내기가 완료되지 않았습니다. 출력이 작성되지 않았습니다. 이미지, 수식, Mermaid 구문을 확인하세요. 긴 문서는 PDF를 선택하세요.\n{p0}",
  AppMessage.splitImagesZIP: "이미지 분할(ZIP)",
  AppMessage.saveToFiles: "파일에 저장",
  AppMessage.unsupportedExportFormat: "지원되지 않는 내보내기 형식",
  AppMessage.pleaseSelectAnExportPath: "내보낼 경로를 선택하세요",
  AppMessage.pleaseSelectAFileInsteadOfADirectory: "디렉터리 대신 파일을 선택하세요",
  AppMessage.markdownFilesCannotBeUsedAsExportDestination:
      "Markdown 파일은 내보내기 대상으로 사용할 수 없습니다",
  AppMessage.exportPathCannotBeTheSameAsSourceFile: "내보내기 경로는 원본 파일과 같을 수 없습니다",
  AppMessage.theDestinationIsADirectoryChooseAnotherFilename:
      "대상이 디렉터리입니다. 다른 파일 이름을 선택하세요.",
  AppMessage.theOutputAlreadyExistsSelectValueDirectlyInTheSaveDialog:
      "출력 파일이 이미 있습니다. 저장 대화상자에서 {p0}을(를) 직접 선택하세요.",
  AppMessage.exportDataCannotBeEmpty: "내보낼 데이터는 비어 있을 수 없습니다",
  AppMessage.indentEditor: "들여쓰기(편집기)",
  AppMessage.outdentEditor: "내어쓰기(편집기)",
  AppMessage.newDocument2: "새 문서",
  AppMessage.openDocument2: "문서 열기",
  AppMessage.closeDocument2: "문서 닫기",
  AppMessage.find: "찾기",
  AppMessage.findAndReplace2: "찾기 및 바꾸기",
  AppMessage.nextMatch: "다음 항목",
  AppMessage.previousMatch: "이전 항목",
  AppMessage.bold: "굵게",
  AppMessage.italic: "기울임",
  AppMessage.inlineCode: "인라인 코드",
  AppMessage.strikethrough: "취소선",
  AppMessage.editorMode: "편집기 모드",
  AppMessage.splitMode: "분할 모드",
  AppMessage.previewMode: "미리보기 모드",
  AppMessage.allSyntax: "모든 구문",
  AppMessage.quitApp: "앱 종료",
  AppMessage.cut: "잘라내기",
  AppMessage.copy: "복사",
  AppMessage.paste: "붙여넣기",
  AppMessage.selectAll: "모두 선택",
  AppMessage.shortcutFooter:
      "Esc는 검색이나 구문 패널을 닫습니다. 텍스트 필드는 기본 클립보드 및 실행 취소 단축키를 유지합니다.",
};
