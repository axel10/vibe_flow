import 'package:flutter/material.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/widgets/song_thumbnail.dart';

class FolderListTile extends StatelessWidget {
  const FolderListTile({
    super.key,
    required this.folder,
    required this.songsCount,
    this.representativeSong,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
    this.trailing,
    this.subtitle,
  });

  final MusicFolder folder;
  final int songsCount;
  final MusicFile? representativeSong;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final trailingWidget = trailing;

    final int hash = folder.path.hashCode;
    final double hue = (hash.abs() % 360).toDouble();
    final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
    final Color endColor = HSLColor.fromAHSL(1.0, (hue + 40) % 360, 0.75, 0.35).toColor();

    Widget coverWidget;
    if (representativeSong != null) {
      coverWidget = SongThumbnail(
        path: representativeSong!.path,
        id: representativeSong!.id,
        thumbnailPath: representativeSong!.thumbnailPath,
        size: 56.0,
        borderRadius: BorderRadius.zero,
      );
    } else {
      final isSystem = folder.path == 'system';
      coverWidget = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSystem
                ? [
                    const Color(0xFF39C5BB),
                    const Color(0xFF2596BE),
                  ]
                : [startColor, endColor],
          ),
        ),
        child: Center(
          child: Icon(
            isSystem ? Icons.library_music_rounded : Icons.folder_rounded,
            size: 24,
            color: Colors.white70,
          ),
        ),
      );
    }

    final leadingWidget = SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'folder-cover-${folder.path}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: isSelectionMode
                    ? (isSelected ? 0.5 : 0.7)
                    : 1.0,
                child: coverWidget,
              ),
            ),
          ),
          if (isSelectionMode)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap?.call(),
                    fillColor: WidgetStateProperty.all(Colors.white),
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown != null
          ? (details) => onSecondaryTapDown!(details)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelectionMode && isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            onLongPress: onLongPress,
            hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 16,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leadingWidget,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          folder.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle ?? l10n.songsCountFormat(songsCount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailingWidget != null) ...[
                    const SizedBox(width: 16),
                    trailingWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
