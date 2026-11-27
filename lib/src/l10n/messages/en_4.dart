part of '../message_catalog.dart';

const _en4 = <AppMessage, String>{
  AppMessage.invalidDocumentName: "Invalid document name.",
  AppMessage.saveAndRename: "Save and rename?",
  AppMessage.renameDocumentResourcesDescription:
      "Current content will be saved. The asset folder and image references in this document will also be renamed. References from other documents need updating separately.",
  AppMessage.rename2: "Rename",
  AppMessage.renamingDocument: "Renaming document",
  AppMessage.packageDocumentAndImages2: "Package document and images",
  AppMessage.packagingDocument: "Packaging document",
  AppMessage.packageCreatedWithReferencesThatStillNeedRepair:
      "Package created with references that still need repair.",
  AppMessage.currentDocumentAndImagesPackaged:
      "Current document and images packaged.",
  AppMessage.dropToImportImages: "Drop to import images",
  AppMessage.copyToDocumentAssetsOriginalsAreKept:
      "Copy to document assets. Originals are kept.",
  AppMessage.saveTheDocumentFirst: "Save the document first",
  AppMessage.saveBeforeImportImages:
      "Save first so images can be stored beside the document using portable relative paths.",
  AppMessage.saveAndContinue: "Save and continue",
  AppMessage.allowFolderAccess2: "Allow folder access",
  AppMessage.chooseTheContainingFolderOrOneOfItsParentFolders:
      "Choose the containing folder or one of its parent folders.",
  AppMessage.folderAccessGranted: "Folder access granted.",
  AppMessage.theDocumentChangedImportTheImagesAgain:
      "The document changed. Import the images again.",
  AppMessage.importingImages: "Importing images",
  AppMessage.noTextOrImageToPaste: "No text or image to paste.",
  AppMessage.clipboardImagesAreUnavailableInThisEnvironment:
      "Clipboard images are unavailable in this environment.",
  AppMessage.dropAccessDenied:
      "The system could not grant access to the dropped files. Use Import images to select them.",
  AppMessage.dropPNGJPEGGIFWebPOrBMPImages:
      "Drop PNG, JPEG, GIF, WebP or BMP images.",
  AppMessage.insertWebImage2: "Insert web image",
  AppMessage.enterAValidHTTPOrHTTPSImageURL:
      "Enter a valid HTTP or HTTPS image URL.",
  AppMessage.imageDescription: "Image description",
  AppMessage.unsupportedImageAddress: "Unsupported image address",
  AppMessage.useSaveAsToMoveTheDocumentToAnotherFolder:
      "Use Save As to move the document to another folder.",
  AppMessage.aFileWithThisNameAlreadyExists:
      "A file with this name already exists.",
  AppMessage.theSourceDocumentIsUnavailable:
      "The source document is unavailable.",
  AppMessage.anAssetFolderWithTheNewNameAlreadyExistsNothingWasRenamed:
      "An asset folder with the new name already exists. Nothing was renamed.",
  AppMessage.resolveImagesBeforeExport:
      "Resolve unavailable images or explicitly keep their original references.",
  AppMessage.thisImageIsNotReferencedInTheDocument:
      "This image is not referenced in the document.",
  AppMessage.cannotLoadImageRetryOrCheckNetworkAndFileAccess:
      "Cannot load image. Retry or check network and file access.",
  AppMessage.more: "More",
  AppMessage.cannotOverwriteASymbolicLink: "Cannot overwrite a symbolic link.",
  AppMessage.theResourceDirectoryIsNotARegularDirectory:
      "The resource directory is not a regular directory.",
  AppMessage.noAvailableResourceDirectoryName:
      "No available resource directory name.",
  AppMessage.tooManyImageNameConflicts: "Too many image name conflicts.",
  AppMessage.invalidImageUsePNGJPEGGIFWebPOrBMP:
      "Invalid image; use PNG, JPEG, GIF, WebP or BMP.",
  AppMessage.imageExceeds50MB: "Image exceeds 50 MB.",
  AppMessage.imageExceeds50MB2: "Image exceeds 50 MB.",
  AppMessage.cannotOverwriteASymbolicLink2: "Cannot overwrite a symbolic link.",
  AppMessage.unsupportedImageURL: "Unsupported image URL.",
  AppMessage.downloadFailedHTTPValue: "Download failed: HTTP {p0}",
  AppMessage.tooManyImageRedirects: "Too many image redirects.",
  AppMessage.continueText: "Continue",
  AppMessage.someImagesNeedAttention: "Some images need attention",
  AppMessage.partialResourceCopyWarning:
      "These references cannot be fully copied. Repair them first, or continue keeping their original addresses.",
  AppMessage.customSyntax: "Custom syntax",
  AppMessage.continueWithOriginalAddresses: "Continue with original addresses",
  AppMessage.resourceInventorySummary:
      "{p0} local images ({p1} managed), {p2} web images.\n{p3} images to copy; {p4} MB of local images.\n{p5}{p6}",
  AppMessage.alsoDownloadWebImages: "Also download web images",
  AppMessage.copyLocalImages: "Copy local images",
  AppMessage.folderAccessIsRequiredAllowAccessToThisLocationAndRetry:
      "Folder access is required. Allow access to this location and retry.",
  AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally:
      "The file or folder is missing, moved, or not downloaded locally.",
  AppMessage.theDiskIsFullFreeSomeSpaceAndRetry:
      "The disk is full. Free some space and retry.",
  AppMessage.thisLocationIsReadOnlyChooseAWritableFolder:
      "This location is read-only. Choose a writable folder.",
  AppMessage.fileOperationFailedCheckTheLocationAndSystemDetailsBelow:
      "File operation failed. Check the location and system details below.",
  AppMessage.location: "Location",
  AppMessage.unknown: "unknown",
  AppMessage.error: "error",
  AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry:
      "Unable to process the image. Check its format or connection and retry.",
  AppMessage.someImagesCouldNotBeCopied: "Some images could not be copied",
  AppMessage.originalImagesUnchanged:
      "Original files are unchanged. Repair these images, or keep their addresses and continue.",
};
