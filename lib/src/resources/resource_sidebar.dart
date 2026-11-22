import 'dart:io';
import 'package:flutter/cupertino.dart';
export 'resource_text_dialog.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/marker_colors.dart';
import '../l10n/app_localizations.dart';
import 'resource_provider.dart';
import 'resource_service.dart';

class ResourceSidebar extends ConsumerWidget {
  const ResourceSidebar({
    super.key,
    required this.text,
    required this.path,
    required this.zh,
    required this.onImport,
    required this.onMenu,
    required this.onItem,
  });
  final String text;
  final String? path;
  final bool zh;
  final VoidCallback onImport, onMenu;
  final void Function(ResourceItem) onItem;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = Theme.of(context).extension<MarkerColors>()!;
    final work = ref.watch(resourceUiProvider);
    final data = ref.watch(
      resourceInventoryProvider((
        text: text,
        path: path,
        revision: work.revision,
      )),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  key: const Key('resource-import'),
                  minimumSize: const Size(0, 30),
                  padding: EdgeInsets.zero,
                  onPressed: work.busy ? null : onImport,
                  child: Text(
                    l10n.importImages,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              CupertinoButton(
                key: const Key('resource-menu'),
                minimumSize: const Size(30, 30),
                padding: EdgeInsets.zero,
                onPressed: work.busy ? null : onMenu,
                child: Icon(
                  CupertinoIcons.ellipsis,
                  color: c.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        if (work.busy)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${work.operation}${work.total > 0 ? ' ${work.done}/${work.total}' : ''}',
                  style: TextStyle(fontSize: 11, color: c.textSecondary),
                ),
                CupertinoButton(
                  minimumSize: const Size(0, 28),
                  padding: EdgeInsets.zero,
                  onPressed: ref.read(resourceUiProvider.notifier).cancel,
                  child: Text(
                    l10n.stopRemainingWork,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: data.when(
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (_, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.cannotReadImages,
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ),
            ),
            data: (inventory) {
              if (inventory.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.importOrPasteImages,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 12),
                children: [
                  if (inventory.unsupported.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.customSyntaxUnchanged,
                        style: TextStyle(fontSize: 11, color: c.textSecondary),
                      ),
                    ),
                  for (final status in [
                    ResourceAvailability.local,
                    ResourceAvailability.remote,
                    ResourceAvailability.missing,
                    ResourceAvailability.denied,
                    ResourceAvailability.unsupported,
                  ])
                    if (inventory.items.any(
                      (item) => item.availability == status,
                    )) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 5),
                        child: Text(
                          switch (status) {
                            ResourceAvailability.local => l10n.localImages,
                            ResourceAvailability.remote => l10n.webImages,
                            _ => l10n.needsAttention,
                          },
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                      for (final item in inventory.items.where(
                        (i) => i.availability == status,
                      ))
                        CupertinoButton(
                          key: ValueKey('resource-${item.source}'),
                          padding: const EdgeInsets.all(7),
                          onPressed: work.busy ? null : () => onItem(item),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child:
                                      item.availability ==
                                          ResourceAvailability.local
                                      ? Image.file(
                                          File(item.path!),
                                          key: ValueKey((
                                            item.path,
                                            work.revision,
                                          )),
                                          fit: BoxFit.cover,
                                          cacheWidth: 96,
                                          errorBuilder: (_, _, _) => Icon(
                                            CupertinoIcons.photo,
                                            color: c.textTertiary,
                                            size: 22,
                                          ),
                                        )
                                      : Icon(
                                          status == ResourceAvailability.remote
                                              ? CupertinoIcons.link
                                              : CupertinoIcons
                                                    .exclamationmark_triangle,
                                          color: c.textSecondary,
                                          size: 21,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.alt.isEmpty
                                          ? Uri.tryParse(
                                                  item.source,
                                                )?.pathSegments.lastOrNull ??
                                                item.source
                                          : item.alt,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      item.availability ==
                                              ResourceAvailability.local
                                          ? '${(item.size / 1024).ceil()} KB${item.managed ? ' · ${l10n.managed}' : ''}'
                                          : item.availability ==
                                                ResourceAvailability.remote
                                          ? l10n.linkedUrl
                                          : l10n.clickToRepair,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
