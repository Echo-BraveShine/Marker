part of '../../main.dart';

// Dialog and choice handling for resource operations
extension _ResourceChoiceActions on _MarkerHomeState {
  Future<String?> _resourceChoice(
    String title,
    List<(String, String, IconData)> entries, {
    String? description,
  }) => showMarkerDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (context) => MarkerDialog(
      width: 460,
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null) ...[
            Text(
              description,
              style: const TextStyle(fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 12),
          ],
          for (final entry in entries)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              alignment: Alignment.centerLeft,
              onPressed: () => Navigator.pop(context, entry.$1),
              child: Row(
                children: [
                  Icon(
                    entry.$3,
                    size: 17,
                    color: Theme.of(
                      context,
                    ).extension<MarkerColors>()!.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.$2,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).extension<MarkerColors>()!.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );

  Future<String?> _resourceText(
    String title,
    String placeholder, {
    String initial = '',
  }) => showMarkerDialog<String>(
    context: context,
    builder: (context) => ResourceTextDialog(
      title: title,
      placeholder: placeholder,
      initial: initial,
      confirm: _l10n.message(AppMessage.continueText),
    ),
  );

  Future<bool> _confirmResourceIssues(ResourceInventory inventory) async {
    if (inventory.unresolved.isEmpty && inventory.unsupported.isEmpty) {
      return true;
    }
    if (!mounted) return false;
    return await showMarkerDialog<bool>(
          context: context,
          builder: (context) => MarkerDialog(
            width: 520,
            title: Text(_l10n.message(AppMessage.someImagesNeedAttention)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_l10n.message(AppMessage.partialResourceCopyWarning)),
                const SizedBox(height: 12),
                for (final item in inventory.unresolved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      item.source,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                for (final item in inventory.unsupported)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${_l10n.message(AppMessage.customSyntax)}: $item',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              MarkerDialogButton(
                primary: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  _l10n.message(AppMessage.continueWithOriginalAddresses),
                ),
              ),
            ],
          ),
        ) ==
        true;
  }

  Future<bool?> _resourceCollectionChoice(
    String title,
    ResourceInventory inventory, {
    bool standalone = false,
  }) async {
    final local = inventory.items
        .where((i) => i.availability == ResourceAvailability.local)
        .length;
    final remote = inventory.items
        .where((i) => i.availability == ResourceAvailability.remote)
        .length;
    final managed = inventory.items.where((i) => i.managed).length;
    final copying = standalone ? local : local - managed;
    final size = (inventory.totalBytes / 1024 / 1024).toStringAsFixed(1);
    return showMarkerDialog<bool>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 480,
        title: Text(title),
        content: Text(
          _l10n.message(AppMessage.resourceInventorySummary, {
            "p0": local,
            "p1": managed,
            "p2": remote,
            "p3": copying,
            "p4": size,
            "p5": _l10n.message(
              standalone
                  ? AppMessage.copyUsesCurrentContent
                  : AppMessage.organizeSavesCurrentContent,
            ),
            "p6": inventory.unresolved.isNotEmpty
                ? _l10n.message(
                    AppMessage.unavailableImagesKeepOriginalReferences,
                  )
                : '',
          }),
        ),
        actions: [
          if (remote > 0)
            MarkerDialogButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(_l10n.message(AppMessage.alsoDownloadWebImages)),
            ),
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(_l10n.message(AppMessage.copyLocalImages)),
          ),
        ],
      ),
    );
  }
}

// Message formatting and retry helpers
extension _ResourceMessagePart on _MarkerHomeState {
  String _resourceMessage(Object error) {
    if (error is LocalizedMessageError) {
      return error.localize(_languageTag);
    }
    if (error is ResourceFailure) {
      return error.localize(_languageTag);
    }
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      final windows = Platform.isWindows;
      final reason = (windows ? code == 5 : code == 1 || code == 13)
          ? _l10n.message(
              AppMessage
                  .folderAccessIsRequiredAllowAccessToThisLocationAndRetry,
            )
          : (windows ? code == 2 || code == 3 : code == 2)
          ? _l10n.message(
              AppMessage.theFileOrFolderIsMissingMovedOrNotDownloadedLocally,
            )
          : (windows ? code == 112 : code == 28)
          ? _l10n.message(AppMessage.theDiskIsFullFreeSomeSpaceAndRetry)
          : (windows ? code == 19 : code == 30)
          ? _l10n.message(
              AppMessage.thisLocationIsReadOnlyChooseAWritableFolder,
            )
          : _l10n.message(
              AppMessage
                  .fileOperationFailedCheckTheLocationAndSystemDetailsBelow,
            );
      return '$reason\n${_l10n.message(AppMessage.location)}：${error.path ?? _l10n.message(AppMessage.unknown)}\n${error.osError?.message ?? error.message}${code == null ? '' : ' (${_l10n.message(AppMessage.error)} $code)'}';
    }
    return _l10n.message(
      AppMessage.unableToProcessTheImageCheckItsFormatOrConnectionAndRetry,
    );
  }

  String _resourceIssueText(ResourceIssue issue) =>
      '${issue.source}\n${issue.localize(_languageTag)}';

  Future<T> _retryIncomplete<T>(
    Future<T> Function(bool allow) operation, {
    bool allowIncomplete = false,
  }) async {
    try {
      return await operation(allowIncomplete);
    } on ResourceIncomplete catch (error) {
      if (allowIncomplete || !mounted) rethrow;
      final proceed = await showMarkerDialog<bool>(
        context: context,
        builder: (context) => MarkerDialog(
          title: Text(_l10n.message(AppMessage.someImagesCouldNotBeCopied)),
          content: Text(
            '${_l10n.message(AppMessage.originalImagesUnchanged)}\n\n${error.issues.map(_resourceIssueText).join('\n\n')}',
          ),
          actions: [
            MarkerDialogButton(
              primary: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(_l10n.message(AppMessage.keepAddressesAndContinue)),
            ),
          ],
        ),
      );
      if (proceed != true) throw ResourceCancelled();
      return operation(true);
    }
  }

  Future<void> _showResourceIssues(List<String> issues) async {
    if (!mounted) return;
    await showMarkerDialog<void>(
      context: context,
      builder: (context) => MarkerDialog(
        width: 540,
        title: Text(_l10n.message(AppMessage.operationResult)),
        content: Text(
          issues.join('\n\n'),
          style: const TextStyle(fontSize: 12, height: 1.6),
        ),
      ),
    );
  }
}
