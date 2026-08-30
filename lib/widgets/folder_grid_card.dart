import 'package:flutter/material.dart';
import '../models/music_file.dart';
import '../models/music_folder.dart';
import '../l10n/app_localizations.dart';
import '../widgets/song_thumbnail.dart';

class FolderGridCard extends StatelessWidget {
  const FolderGridCard({
    super.key,
    required this.folder,
    this.songsCount = 0,
    this.representativeSong,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
    this.subtitle,
    this.customTitle,
    this.enableHero = true,
  });

  final MusicFolder folder;
  final int songsCount;
  final MusicFile? representativeSong;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final String? subtitle;
  final String? customTitle;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

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
        size: 200,
        width: double.infinity,
        height: double.infinity,
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
                    Colors.purple.shade700,
                    Colors.deepPurple.shade900,
                  ]
                : [startColor, endColor],
          ),
        ),
        child: Center(
          child: Icon(
            isSystem ? Icons.library_music_rounded : Icons.folder_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      );
    }

    final cardCover = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          coverWidget,
          if (isSelectionMode)
            Container(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                  : Colors.black26,
            ),
          if (isSelectionMode)
            Positioned(
              top: 8,
              left: 8,
              child: Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? theme.colorScheme.primary : Colors.white70,
                size: 24,
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTapDown,
      onLongPress: onLongPress,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        enableFeedback: false,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: enableHero
                      ? Hero(
                          tag: 'folder-cover-${folder.path}',
                          child: cardCover,
                        )
                      : cardCover,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          customTitle ?? folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle ?? l10n.songsCountFormat(songsCount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HoverableCard extends StatefulWidget {
  const HoverableCard({super.key, required this.child});
  final Widget child;

  @override
  State<HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
