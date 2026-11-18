import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marker/src/theme/marker_colors.dart';
import 'package:marker/src/l10n/app_localizations.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return Container(
      width: 240,
      color: colors.bgSidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarHeader(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SidebarItem(CupertinoIcons.star, 'Recent'),
                SidebarItem(CupertinoIcons.folder, 'Open'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      color: colors.bgToolbar,
      child: Row(
        children: [
          Icon(CupertinoIcons.doc, size: 20, color: colors.textSecondary),
          const SizedBox(width: 8),
          Text(
            l10n.file,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const SidebarItem(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<MarkerColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
