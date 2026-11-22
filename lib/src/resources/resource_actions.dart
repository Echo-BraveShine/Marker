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
      confirm: t('确定', 'Continue'),
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
            title: Text(t('部分图片需要处理', 'Some images need attention')),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t(
                    '以下引用无法完整复制。可以先修复，或继续并保留其原始地址。',
                    'These references cannot be fully copied. Repair them first, or continue keeping their original addresses.',
                  ),
                ),
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
                      '${t('特殊语法', 'Custom syntax')}: $item',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            actions: [
              MarkerDialogButton(
                primary: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(t('继续并保留原地址', 'Continue with original addresses')),
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
          t(
            '本地图片 $local 张（已托管 $managed 张），网络图片 $remote 张。\n需复制 $copying 张，本地图片总大小 $size MB。\n${standalone ? '副本使用当前编辑内容，原文档保持不变。' : '整理完成后会保存当前编辑内容；所有原图保留。'}${inventory.unresolved.isNotEmpty ? '\n无法读取的图片将保持原引用。' : ''}',
            '$local local images ($managed managed), $remote web images.\n$copying images to copy; $size MB of local images.\n${standalone ? 'Uses current editor content; the original document is unchanged.' : 'Organizing saves current editor content; all original images are kept.'}${inventory.unresolved.isNotEmpty ? '\nUnavailable images keep their original references.' : ''}',
          ),
        ),
        actions: [
          if (remote > 0)
            MarkerDialogButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('同时下载网络图片', 'Also download web images')),
            ),
          MarkerDialogButton(
            primary: true,
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('仅复制本地图片', 'Copy local images')),
          ),
        ],
      ),
    );
  }
}

// Message formatting and retry helpers
extension _ResourceMessagePart on _MarkerHomeState {
  String _resourceMessage(Object error) {
    if (error is ResourceFailure) return t(error.zh, error.en);
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      final windows = Platform.isWindows;
      final reason = (windows ? code == 5 : code == 1 || code == 13)
          ? t(
              '尚未获得此位置的访问权限，请授权对应目录后重试。',
              'Folder access is required. Allow access to this location and retry.',
            )
          : (windows ? code == 2 || code == 3 : code == 2)
          ? t(
              '文件或目录不存在，可能已移动或尚未下载到本地。',
              'The file or folder is missing, moved, or not downloaded locally.',
            )
          : (windows ? code == 112 : code == 28)
          ? t(
              '磁盘剩余空间不足，请释放空间后重试。',
              'The disk is full. Free some space and retry.',
            )
          : (windows ? code == 19 : code == 30)
          ? t(
              '此位置为只读，请选择可写入的保存目录。',
              'This location is read-only. Choose a writable folder.',
            )
          : t(
              '文件操作失败，请查看下方位置和系统信息。',
              'File operation failed. Check the location and system details below.',
            );
      return '$reason\n${t('位置', 'Location')}：${error.path ?? t('未知', 'unknown')}\n${error.osError?.message ?? error.message}${code == null ? '' : ' (${t('错误码', 'error')} $code)'}';
    }
    return t(
      '无法处理图片，请检查格式或网络后重试。',
      'Unable to process the image. Check its format or connection and retry.',
    );
  }

  String _resourceIssueText(ResourceIssue issue) =>
      '${issue.source}\n${_zh ? issue.chinese ?? '无法处理此图片，请检查后重试。' : issue.reason}';

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
          title: Text(t('部分图片未能复制', 'Some images could not be copied')),
          content: Text(
            '${t('原文件未被改动。可以先修复，或保留这些地址继续生成副本。', 'Original files are unchanged. Repair these images, or keep their addresses and continue.')}\n\n${error.issues.map(_resourceIssueText).join('\n\n')}',
          ),
          actions: [
            MarkerDialogButton(
              primary: true,
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('保留原地址并继续', 'Keep addresses and continue')),
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
        title: Text(t('处理结果', 'Operation result')),
        content: Text(
          issues.join('\n\n'),
          style: const TextStyle(fontSize: 12, height: 1.6),
        ),
      ),
    );
  }
}
