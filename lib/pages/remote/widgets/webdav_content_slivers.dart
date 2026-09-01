import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:vynody/models/music_file.dart';
import 'package:vynody/models/music_folder.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/player/remote/clients/webdav_client.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/settings/settings_service.dart';
import 'package:vynody/utils/folder_helpers.dart';
import 'package:vynody/utils/remote_context_menu_utils.dart';
import 'package:vynody/widgets/folder_grid_card.dart';
import 'package:vynody/widgets/folder_layout_utils.dart';
import 'package:vynody/widgets/folder_list_tile.dart';
import 'package:vynody/widgets/playing_equalizer_icon.dart';
import 'package:vynody/widgets/song_thumbnail.dart';

/// Renders WebDAV subfolders in grid or list view using unified FolderGridCard and FolderListTile.
class WebDavSubfoldersSliver extends ConsumerWidget {
  final List<WebDavFile> folders;
  final FolderViewMode viewMode;
  final RemoteServer server;
  final String password;
  final bool isSelectionMode;
  final Set<String> selectedFolderPaths;
  final void Function(WebDavFile) onOpenFolder;
  final void Function(WebDavFile folder, int index)? onFolderTap;
  final void Function(WebDavFile folder, int index)? onFolderLongPress;
  final void Function(String folderPath)? onToggleFolderSelection;
  final VoidCallback? onToggleSelectionMode;
  final void Function(WebDavFile folder)? onShowFolderBottomSheet;

  const WebDavSubfoldersSliver({
    super.key,
    required this.folders,
    required this.viewMode,
    required this.server,
    required this.password,
    this.isSelectionMode = false,
    this.selectedFolderPaths = const {},
    required this.onOpenFolder,
    this.onFolderTap,
    this.onFolderLongPress,
    this.onToggleFolderSelection,
    this.onToggleSelectionMode,
    this.onShowFolderBottomSheet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid =
        viewMode == FolderViewMode.hybrid || viewMode == FolderViewMode.grid;

    void openContextMenu(WebDavFile folder, Offset globalPosition) {
      showWebDavFolderContextMenu(
        context: context,
        globalPosition: globalPosition,
        ref: ref,
        server: server,
        password: password,
        folder: folder,
        onOpen: () => onOpenFolder(folder),
        onMultiSelect: (path) {
          if (!isSelectionMode) onToggleSelectionMode?.call();
          onToggleFolderSelection?.call(path);
        },
      );
    }

    if (isGrid) {
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
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
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
                  final folder = folders[index];
                  final isSelected = selectedFolderPaths.contains(folder.path);

                  return HoverableCard(
                    child: FolderGridCard(
                      folder: MusicFolder(path: folder.path, name: folder.name),
                      subtitle: 'Folder',
                      enableHero: false,
                      isSelected: isSelected,
                      isSelectionMode: isSelectionMode,
                      onTap: onFolderTap != null
                          ? () => onFolderTap?.call(folder, index)
                          : (isSelectionMode
                              ? () => onToggleFolderSelection?.call(folder.path)
                              : () => onOpenFolder(folder)),
                      onSecondaryTapDown: (details) {
                        openContextMenu(folder, details.globalPosition);
                      },
                      onLongPress: onFolderLongPress != null
                          ? () => onFolderLongPress?.call(folder, index)
                          : () {
                              if (!isSelectionMode) {
                                onToggleSelectionMode?.call();
                                onToggleFolderSelection?.call(folder.path);
                              } else {
                                onToggleFolderSelection?.call(folder.path);
                              }
                            },
                    ),
                  );
                },
                childCount: folders.length,
              ),
            ),
          );
        },
      );
    } else {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return SliverPadding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isPortrait ? 4 : 8,
          right: isPortrait ? 4 : 8,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final folder = folders[index];
              final isSelected = selectedFolderPaths.contains(folder.path);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: FolderListTile(
                  folder: MusicFolder(path: folder.path, name: folder.name),
                  subtitle: 'Folder',
                  enableHero: false,
                  isSelected: isSelected,
                  isSelectionMode: isSelectionMode,
                  trailing: Builder(
                    builder: (btnContext) {
                      return IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        tooltip: 'More',
                        onPressed: () {
                          final box = btnContext.findRenderObject() as RenderBox?;
                          final pos = box != null
                              ? box.localToGlobal(
                                  Offset(box.size.width / 2, box.size.height / 2))
                              : Offset.zero;
                          openContextMenu(folder, pos);
                        },
                      );
                    },
                  ),
                  onTap: onFolderTap != null
                      ? () => onFolderTap?.call(folder, index)
                      : (isSelectionMode
                          ? () => onToggleFolderSelection?.call(folder.path)
                          : () => onOpenFolder(folder)),
                  onLongPress: onFolderLongPress != null
                      ? () => onFolderLongPress?.call(folder, index)
                      : () {
                          if (!isSelectionMode) {
                            onToggleSelectionMode?.call();
                            onToggleFolderSelection?.call(folder.path);
                          } else {
                            onToggleFolderSelection?.call(folder.path);
                          }
                        },
                  onSecondaryTapDown: (details) {
                    openContextMenu(folder, details.globalPosition);
                  },
                ),
              );
            },
            childCount: folders.length,
          ),
        ),
      );
    }
  }
}

/// Renders songs & files in grid or list mode for WebDAV.
class WebDavSongsSliver extends ConsumerWidget {
  final List<WebDavFile> files;
  final FolderViewMode viewMode;
  final RemoteServer server;
  final String password;
  final Map<String, SongMetadata> metadataMap;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final bool isSelectionMode;
  final Set<String> selectedSongPaths;
  final void Function(WebDavFile, int) onSongTap;
  final void Function(WebDavFile)? onSongLongPress;
  final void Function(WebDavFile, TapDownDetails)? onSongSecondaryTapDown;
  final void Function(WebDavFile, BuildContext)? onSongMorePressed;
  final double bottomPadding;

  const WebDavSongsSliver({
    super.key,
    required this.files,
    required this.viewMode,
    required this.server,
    required this.password,
    required this.metadataMap,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    this.isSelectionMode = false,
    this.selectedSongPaths = const {},
    required this.onSongTap,
    this.onSongLongPress,
    this.onSongSecondaryTapDown,
    this.onSongMorePressed,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
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
                  final file = files[index];
                  final uri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
                  final meta = metadataMap[uri] ??
                      ref.watch(scannerServiceProvider.select((s) => s.metadataMap[uri]));
                  final isSelected = selectedSongPaths.contains(uri);

                  return HoverableCard(
                    child: WebDavSongGridCard(
                      file: file,
                      server: server,
                      password: password,
                      metadata: meta,
                      currentMusicPath: currentMusicPath,
                      isAudioPlaying: isAudioPlaying,
                      allAudioFiles: allAudioFiles,
                      isSelected: isSelected,
                      isSelectionMode: isSelectionMode,
                      onTap: () => onSongTap(file, index),
                      onLongPress: () => onSongLongPress?.call(file),
                      onSecondaryTapDown: (details) =>
                          onSongSecondaryTapDown?.call(file, details),
                    ),
                  );
                },
                childCount: files.length,
              ),
            ),
          );
        },
      );
    } else {
      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      return SliverPadding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: isPortrait ? 4 : 8,
          right: isPortrait ? 4 : 8,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final file = files[index];
              final uri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
              final meta = metadataMap[uri] ??
                  ref.watch(scannerServiceProvider.select((s) => s.metadataMap[uri]));
              final isSelected = selectedSongPaths.contains(uri);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ),
                child: WebDavSongListTile(
                  file: file,
                  server: server,
                  password: password,
                  metadata: meta,
                  currentMusicPath: currentMusicPath,
                  isAudioPlaying: isAudioPlaying,
                  allAudioFiles: allAudioFiles,
                  isSelected: isSelected,
                  isSelectionMode: isSelectionMode,
                  onTap: () => onSongTap(file, index),
                  onLongPress: () => onSongLongPress?.call(file),
                  onSecondaryTapDown: (details) =>
                      onSongSecondaryTapDown?.call(file, details),
                  onMorePressed: (ctx) => onSongMorePressed?.call(file, ctx),
                ),
              );
            },
            childCount: files.length,
          ),
        ),
      );
    }
  }
}

/// Rich Grid Card widget for a WebDAV Song / Audio File, aligned with SongGridCard design.
class WebDavSongGridCard extends ConsumerWidget {
  final WebDavFile file;
  final RemoteServer server;
  final String password;
  final SongMetadata? metadata;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails)? onSecondaryTapDown;

  const WebDavSongGridCard({
    super.key,
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isDark = theme.brightness == Brightness.dark;
    final isAudio = file.isAudio;
    final remoteUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
    final isCurrent = currentMusicPath == remoteUri;

    final titleText = (metadata != null && metadata!.title.isNotEmpty)
        ? metadata!.title
        : file.name;

    final hasArtist = metadata != null &&
        metadata!.artist.isNotEmpty &&
        metadata!.artist != 'Unknown';
    final hasAlbum = metadata != null &&
        metadata!.album.isNotEmpty &&
        metadata!.album != 'Unknown';
    String artistAlbumStr = 'WebDAV File';
    if (hasArtist && hasAlbum) {
      artistAlbumStr = '${metadata!.artist} - ${metadata!.album}';
    } else if (hasArtist) {
      artistAlbumStr = metadata!.artist;
    } else if (hasAlbum) {
      artistAlbumStr = metadata!.album;
    }

    final durationStr = metadata?.duration != null
        ? formatDurationMs(metadata!.duration!)
        : null;
    final ext = p.extension(file.name).replaceAll('.', '').toUpperCase();

    final capsuleBgColor = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.75);
    final capsuleTextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.9);

    final titleColor = isCurrent
        ? theme.colorScheme.primary
        : (isAudio
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7));

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTapDown,
      onLongPress: onLongPress,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        enableFeedback: false,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
            border: Border.all(
              color: isCurrent
                  ? theme.colorScheme.primary.withValues(alpha: 0.8)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
              width: isCurrent ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(11)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isAudio)
                          SongThumbnail(
                            path: remoteUri,
                            thumbnailPath: metadata?.thumbnailPath,
                            size: 200,
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: BorderRadius.zero,
                          )
                        else
                          Container(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            child: Center(
                              child: Icon(
                                Icons.insert_drive_file_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        if (isAudio && (durationStr != null || ext.isNotEmpty))
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: capsuleBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${ext.isNotEmpty ? ext : "AUDIO"}${durationStr != null ? " • $durationStr" : ""}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: capsuleTextColor,
                                ),
                              ),
                            ),
                          ),
                        if (isCurrent)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child: PlayingEqualizerIcon(
                                color: Colors.white,
                                size: 22,
                                isPlaying: isAudioPlaying,
                              ),
                            ),
                          ),
                        if (isSelectionMode)
                          Container(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.4)
                                : Colors.black26,
                          ),
                        if (isSelectionMode)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.white70,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            if (isCurrent) ...[
                              PlayingEqualizerIcon(
                                color: theme.colorScheme.primary,
                                size: 14,
                                isPlaying: isAudioPlaying,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                titleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: (isPortrait
                                        ? theme.textTheme.titleSmall
                                        : theme.textTheme.titleMedium)
                                    ?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAudio
                              ? artistAlbumStr
                              : formatFileSize(file.contentLength),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (isPortrait
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
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

/// Rich List Tile widget for a WebDAV Song / Audio File, aligned with SongTile & FolderListTile design.
class WebDavSongListTile extends ConsumerWidget {
  final WebDavFile file;
  final RemoteServer server;
  final String password;
  final SongMetadata? metadata;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final void Function(TapDownDetails)? onSecondaryTapDown;
  final void Function(BuildContext)? onMorePressed;

  const WebDavSongListTile({
    super.key,
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTapDown,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isAudio = file.isAudio;
    final remoteUri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
    final isCurrent = currentMusicPath == remoteUri;

    final titleText = (metadata != null && metadata!.title.isNotEmpty)
        ? metadata!.title
        : file.name;

    final hasArtist = metadata != null &&
        metadata!.artist.isNotEmpty &&
        metadata!.artist != 'Unknown';
    final hasAlbum = metadata != null &&
        metadata!.album.isNotEmpty &&
        metadata!.album != 'Unknown';
    String? artistAlbumStr;
    if (hasArtist && hasAlbum) {
      artistAlbumStr = '${metadata!.artist} - ${metadata!.album}';
    } else if (hasArtist) {
      artistAlbumStr = metadata!.artist;
    } else if (hasAlbum) {
      artistAlbumStr = metadata!.album;
    }

    final durationStr = metadata?.duration != null
        ? formatDurationMs(metadata!.duration!)
        : null;
    final ext = p.extension(file.name).replaceAll('.', '').toUpperCase();
    final sizeStr = formatFileSize(file.contentLength);

    final List<String> techParts = [];
    if (durationStr != null) techParts.add(durationStr);
    if (ext.isNotEmpty) techParts.add(ext);
    if (sizeStr.isNotEmpty) techParts.add(sizeStr);
    final techInfoStr = techParts.join(' | ');

    Widget leadingContent;
    if (isAudio) {
      leadingContent = SongThumbnail(
        path: remoteUri,
        thumbnailPath: metadata?.thumbnailPath,
        size: 56.0,
        borderRadius: BorderRadius.zero,
      );
    } else {
      leadingContent = Container(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        child: Center(
          child: Icon(
            Icons.insert_drive_file_outlined,
            size: 26,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Opacity(
              opacity: isSelectionMode ? (isSelected ? 0.5 : 0.7) : 1.0,
              child: leadingContent,
            ),
          ),
          if (isCurrent)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: PlayingEqualizerIcon(
                    color: Colors.white,
                    size: 18,
                    isPlaying: isAudioPlaying,
                  ),
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

    final trailingWidget = Builder(
      builder: (btnContext) {
        return IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: isCurrent ? theme.colorScheme.primary : null,
          ),
          tooltip: 'More',
          onPressed: () {
            onMorePressed?.call(btnContext);
          },
        );
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: onSecondaryTapDown,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelectionMode && isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            enableFeedback: false,
            onTap: onTap,
            onLongPress: onLongPress,
            hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isPortrait ? 12 : 16,
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
                        Row(
                          children: [
                            if (isCurrent) ...[
                              PlayingEqualizerIcon(
                                color: theme.colorScheme.primary,
                                size: 14,
                                isPlaying: isAudioPlaying,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                titleText,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isCurrent
                                      ? theme.colorScheme.primary
                                      : (isAudio
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.6)),
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (isAudio) ...[
                          if (artistAlbumStr != null) ...[
                            Text(
                              artistAlbumStr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: isCurrent
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.85)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                          ],
                          Text(
                            techInfoStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.7)
                                  : theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.75),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else ...[
                          Text(
                            sizeStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  trailingWidget,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
