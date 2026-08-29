import 'package:flutter/material.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/scanner/scanner_service.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'folder_grid_card.dart';
import 'folder_list_tile.dart';
import 'song_grid_card.dart';
import 'song_tile.dart';
import 'folder_layout_utils.dart';

/// Renders an empty search results placeholder sliver.
class FolderEmptySearchResultsSliver extends StatelessWidget {
  final String message;
  final bool isSearching;

  const FolderEmptySearchResultsSliver({
    super.key,
    required this.message,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSearching)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a section header divider sliver for songs count.
class FolderSectionHeaderSliver extends StatelessWidget {
  final String title;

  const FolderSectionHeaderSliver({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders subfolders in grid or list view.
class FolderSubfoldersSliver extends StatelessWidget {
  final List<MusicFolder> folders;
  final FolderViewMode viewMode;
  final ScannerService scanner;
  final bool isSelectionMode;
  final Set<String> selectedFolderPaths;
  final bool isRoot;
  final bool showSystemMedia;
  final bool hasPermission;
  final String? systemMediaTitle;
  final String? systemMediaSubtitle;
  final void Function(MusicFolder) onNavigateTo;
  final void Function(String path)? onToggleFolderSelection;
  final VoidCallback? onToggleSelectionMode;
  final void Function(MusicFolder, {required bool isRoot})? onShowFolderBottomSheet;
  final double? bottomPadding;

  const FolderSubfoldersSliver({
    super.key,
    required this.folders,
    required this.viewMode,
    required this.scanner,
    this.isSelectionMode = false,
    this.selectedFolderPaths = const {},
    this.isRoot = false,
    this.showSystemMedia = false,
    this.hasPermission = true,
    this.systemMediaTitle,
    this.systemMediaSubtitle,
    required this.onNavigateTo,
    this.onToggleFolderSelection,
    this.onToggleSelectionMode,
    this.onShowFolderBottomSheet,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid =
        viewMode == FolderViewMode.hybrid || viewMode == FolderViewMode.grid;

    if (isGrid) {
      final totalItemCount = folders.length + (showSystemMedia ? 1 : 0);
      if (totalItemCount == 0) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = getFolderGridCrossAxisCount(width);
          final childAspectRatio = calculateFolderGridChildAspectRatio(
            context,
            width,
            crossAxisCount,
          );

          final paddingBottom = bottomPadding ?? (isRoot ? 160.0 : 0.0);

          return SliverPadding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: paddingBottom,
              left: 16,
              right: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (showSystemMedia && index == 0) {
                    final systemFolder = scanner.systemMediaFolder ??
                        MusicFolder(
                          path: 'system',
                          name: systemMediaTitle ?? '',
                        );
                    final songsCount =
                        scanner.getSongCountForFolder(systemFolder);
                    final representativeSong =
                        scanner.getRepresentativeSongForFolder(systemFolder);

                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: HoverableCard(
                        child: FolderGridCard(
                          folder: systemFolder,
                          songsCount: songsCount,
                          representativeSong: representativeSong,
                          subtitle: hasPermission ? null : systemMediaSubtitle,
                          onTap: () async {
                            if (!hasPermission) {
                              await scanner.checkAndRequestPermissions();
                            }
                            if (context.mounted) {
                              onNavigateTo(systemFolder);
                            }
                          },
                        ),
                      ),
                    );
                  }

                  final folderIndex = showSystemMedia ? index - 1 : index;
                  final folder = folders[folderIndex];
                  final isAvailable =
                      isRoot ? scanner.isRootPathAvailable(folder.path) : true;
                  final isSelected = selectedFolderPaths.contains(folder.path);
                  final representativeSong =
                      scanner.getRepresentativeSongForFolder(folder);
                  final songsCount = isRoot
                      ? scanner.getSongCountForFolder(folder)
                      : folder.allSongs.length;

                  return AnimatedOpacity(
                    opacity: isAvailable ? 1.0 : 0.45,
                    duration: const Duration(milliseconds: 180),
                    child: HoverableCard(
                      child: FolderGridCard(
                        folder: folder,
                        songsCount: songsCount,
                        representativeSong: representativeSong,
                        isSelected: isSelected,
                        isSelectionMode: isSelectionMode,
                        onTap: isSelectionMode
                            ? () => onToggleFolderSelection?.call(folder.path)
                            : (isAvailable ? () => onNavigateTo(folder) : null),
                        onLongPress: () {
                          if (isRoot) {
                            onShowFolderBottomSheet?.call(folder, isRoot: true);
                          } else {
                            if (!isSelectionMode) {
                              onToggleSelectionMode?.call();
                              onToggleFolderSelection?.call(folder.path);
                            } else {
                              onToggleFolderSelection?.call(folder.path);
                            }
                          }
                        },
                        onSecondaryTapDown: (details) {
                          onShowFolderBottomSheet?.call(folder, isRoot: isRoot);
                        },
                      ),
                    ),
                  );
                },
                childCount: totalItemCount,
              ),
            ),
          );
        },
      );
    } else {
      final totalItemCount = folders.length + (showSystemMedia ? 1 : 0);
      if (totalItemCount == 0) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      final paddingBottom = bottomPadding ?? (isRoot ? 160.0 : 0.0);

      return SliverPadding(
        padding: EdgeInsets.only(top: isRoot ? 0 : 8, bottom: paddingBottom),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (showSystemMedia && index == 0) {
                final systemFolder = scanner.systemMediaFolder ??
                    MusicFolder(
                      path: 'system',
                      name: systemMediaTitle ?? '',
                    );
                final songsCount =
                    scanner.getSongCountForFolder(systemFolder);
                final representativeSong =
                    scanner.getRepresentativeSongForFolder(systemFolder);
                final isPortrait =
                    MediaQuery.of(context).orientation == Orientation.portrait;

                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPortrait ? 8 : 16,
                      vertical: 4,
                    ),
                    child: FolderListTile(
                      folder: systemFolder,
                      songsCount: songsCount,
                      representativeSong: representativeSong,
                      subtitle: hasPermission ? null : systemMediaSubtitle,
                      onTap: () async {
                        if (!hasPermission) {
                          await scanner.checkAndRequestPermissions();
                        }
                        if (context.mounted) {
                          onNavigateTo(systemFolder);
                        }
                      },
                    ),
                  ),
                );
              }

              final folderIndex = showSystemMedia ? index - 1 : index;
              final folder = folders[folderIndex];
              final isAvailable =
                  isRoot ? scanner.isRootPathAvailable(folder.path) : true;
              final isSelected = selectedFolderPaths.contains(folder.path);
              final representativeSong =
                  scanner.getRepresentativeSongForFolder(folder);
              final songsCount = isRoot
                  ? scanner.getSongCountForFolder(folder)
                  : folder.allSongs.length;

              final isPortrait =
                  MediaQuery.of(context).orientation == Orientation.portrait;

              return AnimatedOpacity(
                opacity: isAvailable ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 180),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPortrait ? 8 : 16,
                    vertical: 4,
                  ),
                  child: FolderListTile(
                    folder: folder,
                    songsCount: songsCount,
                    representativeSong: representativeSong,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    onTap: isSelectionMode
                        ? () => onToggleFolderSelection?.call(folder.path)
                        : (isAvailable ? () => onNavigateTo(folder) : null),
                    onLongPress: () {
                      if (isRoot) {
                        onShowFolderBottomSheet?.call(folder, isRoot: true);
                      } else {
                        if (!isSelectionMode) {
                          onToggleSelectionMode?.call();
                          onToggleFolderSelection?.call(folder.path);
                        } else {
                          onToggleFolderSelection?.call(folder.path);
                        }
                      }
                    },
                    onSecondaryTapDown: (details) {
                      onShowFolderBottomSheet?.call(folder, isRoot: isRoot);
                    },
                  ),
                ),
              );
            },
            childCount: totalItemCount,
          ),
        ),
      );
    }
  }
}

/// Renders songs in grid or list view.
class FolderSongsSliver extends StatelessWidget {
  final List<MusicFile> songs;
  final FolderViewMode viewMode;
  final String? currentSongPath;
  final bool isPlaying;
  final bool isSelectionMode;
  final Set<String> selectedSongPaths;
  final String? highlightedSongPath;
  final void Function(MusicFile song, int index) onSongTap;
  final void Function(MusicFile song)? onSongLongPress;
  final void Function(MusicFile song, TapDownDetails details) onSongSecondaryTapDown;
  final void Function(MusicFile song, BuildContext context)? onSongMorePressed;
  final double topPadding;
  final double bottomPadding;

  const FolderSongsSliver({
    super.key,
    required this.songs,
    required this.viewMode,
    this.currentSongPath,
    this.isPlaying = false,
    this.isSelectionMode = false,
    this.selectedSongPaths = const {},
    this.highlightedSongPath,
    required this.onSongTap,
    this.onSongLongPress,
    required this.onSongSecondaryTapDown,
    this.onSongMorePressed,
    this.topPadding = 8.0,
    this.bottomPadding = 160.0,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isSongGrid = viewMode == FolderViewMode.grid;

    if (isSongGrid) {
      return SliverLayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.crossAxisExtent;
          final crossAxisCount = getFolderGridCrossAxisCount(width);
          final childAspectRatio = calculateFolderGridChildAspectRatio(
            context,
            width,
            crossAxisCount,
          );

          return SliverPadding(
            padding: EdgeInsets.only(
              top: topPadding,
              bottom: bottomPadding,
              left: 16,
              right: 16,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, fileIndex) {
                  final file = songs[fileIndex];
                  final isCurrent = currentSongPath == file.path;
                  final isSelected = selectedSongPaths.contains(file.path);

                  return HoverableCard(
                    child: SongGridCard(
                      song: file,
                      isCurrent: isCurrent,
                      isPlaying: isPlaying,
                      isSelected: isSelected,
                      isSelectionMode: isSelectionMode,
                      isHighlighted: highlightedSongPath == file.path,
                      onTap: () => onSongTap(file, fileIndex),
                      onLongPress: () => onSongLongPress?.call(file),
                      onSecondaryTapDown: (details) {
                        onSongSecondaryTapDown(file, details);
                      },
                    ),
                  );
                },
                childCount: songs.length,
              ),
            ),
          );
        },
      );
    } else {
      final isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;

      return SliverPadding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, fileIndex) {
              final file = songs[fileIndex];
              final isCurrent = currentSongPath == file.path;
              final isSelected = selectedSongPaths.contains(file.path);

              return GestureDetector(
                key: ValueKey(file.path),
                behavior: HitTestBehavior.opaque,
                onSecondaryTapDown: (details) {
                  onSongSecondaryTapDown(file, details);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPortrait ? 8 : 16,
                    vertical: 4,
                  ),
                  child: SongTile(
                    song: file,
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    isHighlighted: highlightedSongPath == file.path,
                    onTap: () => onSongTap(file, fileIndex),
                    onLongPress: () => onSongLongPress?.call(file),
                    onSecondaryTapDown: (details) {
                      onSongSecondaryTapDown(file, details);
                    },
                    onMorePressed: onSongMorePressed != null
                        ? (buttonContext) =>
                            onSongMorePressed!(file, buttonContext)
                        : null,
                  ),
                ),
              );
            },
            childCount: songs.length,
          ),
        ),
      );
    }
  }
}
