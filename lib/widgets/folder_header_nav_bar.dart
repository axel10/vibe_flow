import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';

class FolderHeaderNavBar extends ConsumerStatefulWidget {
  const FolderHeaderNavBar({
    super.key,
    required this.isOverlay,
    this.currentFolder,
    this.navigationHistory = const [],
    this.onGoBack,
    required this.onLocateCurrentSong,
    required this.onSortPressed,
    this.isSortActive = false,
    this.onClearAllSelection,
    this.scrollController,
  });

  final bool isOverlay;
  final MusicFolder? currentFolder;
  final List<MusicFolder> navigationHistory;
  final VoidCallback? onGoBack;
  final VoidCallback onLocateCurrentSong;
  final VoidCallback onSortPressed;
  final bool isSortActive;
  final VoidCallback? onClearAllSelection;
  final ScrollController? scrollController;

  @override
  ConsumerState<FolderHeaderNavBar> createState() => _FolderHeaderNavBarState();
}

class _FolderHeaderNavBarState extends ConsumerState<FolderHeaderNavBar> {
  ScrollController? _internalScrollController;

  ScrollController get _activeScrollController =>
      widget.scrollController ?? (_internalScrollController ??= ScrollController());

  @override
  void dispose() {
    _internalScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final useWhiteText = widget.isOverlay && isDark;
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final settings = ref.watch(settingsServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    final iconColor = useWhiteText
        ? Colors.white
        : theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final chevronColor = useWhiteText
        ? Colors.white.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface.withValues(alpha: 0.4);
    final folderTextColor = useWhiteText
        ? Colors.white.withValues(alpha: 0.9)
        : theme.colorScheme.onSurface.withValues(alpha: 0.85);
    final shadows = useWhiteText
        ? const [Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87)]
        : null;

    final isFirstItemBack = widget.onGoBack != null;

    final backButton = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onGoBack,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 4, top: 6, bottom: 6),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: iconColor,
            shadows: shadows,
          ),
        ),
      ),
    );

    final backChevron = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: chevronColor,
        shadows: shadows,
      ),
    );

    final List<Widget> breadcrumbItems = [];

    // Home icon button
    breadcrumbItems.add(
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            final scanner = ref.read(scannerServiceProvider);
            scanner.setNavigationState(null, []);
            widget.onClearAllSelection?.call();
          },
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirstItemBack ? 4 : 0,
              right: 6,
              top: 6,
              bottom: 6,
            ),
            child: Icon(
              Icons.home_rounded,
              size: 20,
              color: iconColor,
              shadows: shadows,
            ),
          ),
        ),
      ),
    );

    if (widget.currentFolder == null) {
      // Root View breadcrumb
      breadcrumbItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: chevronColor,
            shadows: shadows,
          ),
        ),
      );
      breadcrumbItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Text(
            l10n.scanDirectory,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: folderTextColor,
              shadows: shadows,
            ),
          ),
        ),
      );
    } else {
      // Subfolder View breadcrumbs
      for (int i = 0; i < widget.navigationHistory.length; i++) {
        final folder = widget.navigationHistory[i];
        breadcrumbItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: chevronColor,
              shadows: shadows,
            ),
          ),
        );
        breadcrumbItems.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                final scanner = ref.read(scannerServiceProvider);
                scanner.setNavigationState(
                  folder,
                  widget.navigationHistory.take(i).toList(),
                );
                widget.onClearAllSelection?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: Text(
                  folder.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: folderTextColor,
                    shadows: shadows,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      breadcrumbItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: chevronColor,
            shadows: shadows,
          ),
        ),
      );
      breadcrumbItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Text(
            widget.currentFolder!.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: folderTextColor,
              shadows: shadows,
            ),
          ),
        ),
      );
    }

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final topPadding = statusBarHeight > 0 ? statusBarHeight + 8 : (isDesktop ? 32.0 : 8.0);

    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: 8,
        left: widget.isOverlay ? 0 : 16,
        right: widget.isOverlay ? 0 : 16,
      ),
      decoration: BoxDecoration(
        color: widget.isOverlay ? Colors.transparent : theme.scaffoldBackgroundColor,
        border: widget.isOverlay
            ? null
            : Border(
                bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
              ),
      ),
      child: Row(
        children: [
          if (widget.onGoBack != null) ...[
            backButton,
            backChevron,
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _activeScrollController,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: breadcrumbItems),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          if (isPortrait)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.only(left: 6, right: 0, top: 6, bottom: 6),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: iconColor,
                  shadows: shadows,
                ),
              ),
              onSelected: (value) {
                if (value == 'locate') {
                  widget.onLocateCurrentSong();
                } else if (value == 'sort') {
                  widget.onSortPressed();
                } else if (value == 'view_mode') {
                  settings.folderViewMode = switch (settings.folderViewMode) {
                    FolderViewMode.list => FolderViewMode.hybrid,
                    FolderViewMode.hybrid => FolderViewMode.grid,
                    FolderViewMode.grid => FolderViewMode.list,
                  };
                }
              },
              itemBuilder: (context) => [
                if (currentMusic != null)
                  PopupMenuItem(
                    value: 'locate',
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_rounded, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.locateCurrentSong),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'sort',
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 20,
                        color: widget.isSortActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.sort),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'view_mode',
                  child: Row(
                    children: [
                      Icon(
                        switch (settings.folderViewMode) {
                          FolderViewMode.list => Icons.grid_view_rounded,
                          FolderViewMode.hybrid => Icons.view_module_rounded,
                          FolderViewMode.grid => Icons.view_list_rounded,
                        },
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        switch (settings.folderViewMode) {
                          FolderViewMode.list => l10n.hybridView,
                          FolderViewMode.hybrid => l10n.gridView,
                          FolderViewMode.grid => l10n.listView,
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            if (currentMusic != null) ...[
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: widget.onLocateCurrentSong,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    child: Icon(
                      Icons.my_location_rounded,
                      size: 20,
                      color: iconColor,
                      shadows: shadows,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  settings.folderViewMode = switch (settings.folderViewMode) {
                    FolderViewMode.list => FolderViewMode.hybrid,
                    FolderViewMode.hybrid => FolderViewMode.grid,
                    FolderViewMode.grid => FolderViewMode.list,
                  };
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Icon(
                    switch (settings.folderViewMode) {
                      FolderViewMode.list => Icons.grid_view_rounded,
                      FolderViewMode.hybrid => Icons.view_module_rounded,
                      FolderViewMode.grid => Icons.view_list_rounded,
                    },
                    size: 20,
                    color: iconColor,
                    shadows: shadows,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: widget.onSortPressed,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 0, top: 6, bottom: 6),
                  child: Icon(
                    Icons.sort,
                    size: 20,
                    color: widget.isSortActive
                        ? Theme.of(context).colorScheme.primary
                        : iconColor,
                    shadows: widget.isSortActive ? null : shadows,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
