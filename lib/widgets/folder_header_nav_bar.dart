import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/l10n/app_localizations.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/song_locator_helper.dart';
import 'folder_nav_bar_scaffold.dart';

class FolderHeaderNavBar extends ConsumerWidget {
  const FolderHeaderNavBar({
    super.key,
    required this.isOverlay,
    required this.scrollProgress,
    this.currentFolder,
    this.navigationHistory = const [],
    this.onGoBack,
    this.onLocateCurrentSong,
    required this.onSortPressed,
    this.isSortActive = false,
    this.onClearAllSelection,
    this.scrollController,
  });

  final bool isOverlay;
  final ValueListenable<double> scrollProgress;
  final MusicFolder? currentFolder;
  final List<MusicFolder> navigationHistory;
  final VoidCallback? onGoBack;
  final VoidCallback? onLocateCurrentSong;
  final VoidCallback onSortPressed;
  final bool isSortActive;
  final VoidCallback? onClearAllSelection;
  final ScrollController? scrollController;

  void _handleLocate(WidgetRef ref, BuildContext context) {
    if (onLocateCurrentSong != null) {
      onLocateCurrentSong!();
    } else {
      SongLocatorHelper.locateCurrentPlayingSong(ref, context);
    }
  }

  List<Widget> _buildBreadcrumbItems(
    BuildContext context,
    WidgetRef ref,
    FolderNavBarStyle style,
    AppLocalizations l10n,
  ) {
    final List<Widget> items = [];

    // Home icon button
    items.add(
      Material(
        color: Colors.transparent,
        child: InkResponse(
          radius: 18,
          highlightShape: BoxShape.circle,
          onTap: () {
            final scanner = ref.read(scannerServiceProvider);
            scanner.setNavigationState(null, []);
            onClearAllSelection?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.home_rounded,
              size: 20,
              color: style.iconColor,
              shadows: style.shadows,
            ),
          ),
        ),
      ),
    );

    if (currentFolder == null) {
      // Root View breadcrumb
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: style.chevronColor,
            shadows: style.shadows,
          ),
        ),
      );
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Text(
            l10n.scanDirectory,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: style.folderTextColor,
              shadows: style.shadows,
            ),
          ),
        ),
      );
    } else {
      // Subfolder View breadcrumbs
      for (int i = 0; i < navigationHistory.length; i++) {
        final folder = navigationHistory[i];
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: style.chevronColor,
              shadows: style.shadows,
            ),
          ),
        );
        items.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                final scanner = ref.read(scannerServiceProvider);
                scanner.setNavigationState(
                  folder,
                  navigationHistory.take(i).toList(),
                );
                onClearAllSelection?.call();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                child: Text(
                  folder.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: style.folderTextColor,
                    shadows: style.shadows,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: style.chevronColor,
            shadows: style.shadows,
          ),
        ),
      );
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Text(
            currentFolder!.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: style.folderTextColor,
              shadows: style.shadows,
            ),
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    FolderNavBarStyle style,
    AppLocalizations l10n,
  ) {
    final currentMusic = ref.watch(audioCurrentMusicProvider);
    final settings = ref.watch(settingsServiceProvider);

    if (style.isPortrait) {
      return PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: style.iconColor,
          shadows: style.shadows,
        ),
        onSelected: (value) {
          if (value == 'locate') {
            _handleLocate(ref, context);
          } else if (value == 'sort') {
            onSortPressed();
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
                  isSortActive ? Icons.check_rounded : Icons.sort,
                  size: 20,
                  color: isSortActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.sort,
                  style: isSortActive
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )
                      : null,
                ),
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
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentMusic != null) ...[
            IconButton(
              tooltip: l10n.locateCurrentSong,
              icon: Icon(
                Icons.my_location_rounded,
                size: 20,
                color: style.iconColor,
                shadows: style.shadows,
              ),
              onPressed: () => _handleLocate(ref, context),
            ),
          ],
          IconButton(
            tooltip: switch (settings.folderViewMode) {
              FolderViewMode.list => l10n.hybridView,
              FolderViewMode.hybrid => l10n.gridView,
              FolderViewMode.grid => l10n.listView,
            },
            icon: Icon(
              switch (settings.folderViewMode) {
                FolderViewMode.list => Icons.grid_view_rounded,
                FolderViewMode.hybrid => Icons.view_module_rounded,
                FolderViewMode.grid => Icons.view_list_rounded,
              },
              size: 20,
              color: style.iconColor,
              shadows: style.shadows,
            ),
            onPressed: () {
              settings.folderViewMode = switch (settings.folderViewMode) {
                FolderViewMode.list => FolderViewMode.hybrid,
                FolderViewMode.hybrid => FolderViewMode.grid,
                FolderViewMode.grid => FolderViewMode.list,
              };
            },
          ),
          IconButton(
            tooltip: l10n.sort,
            style: isSortActive
                ? IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  )
                : null,
            icon: Icon(
              isSortActive ? Icons.check_rounded : Icons.sort,
              size: 20,
              color: isSortActive
                  ? Theme.of(context).colorScheme.primary
                  : style.iconColor,
              shadows: isSortActive ? null : style.shadows,
            ),
            onPressed: onSortPressed,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return FolderNavBarScaffold(
      isOverlay: isOverlay,
      scrollProgress: scrollProgress,
      onGoBack: onGoBack,
      scrollController: scrollController,
      breadcrumbItemsBuilder: (context, style) =>
          _buildBreadcrumbItems(context, ref, style, l10n),
      actionsBuilder: (context, style) =>
          _buildActions(context, ref, style, l10n),
    );
  }
}
