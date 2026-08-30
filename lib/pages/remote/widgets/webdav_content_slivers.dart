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
  final void Function(WebDavFile) onOpenFolder;

  const WebDavSubfoldersSliver({
    super.key,
    required this.folders,
    required this.viewMode,
    required this.server,
    required this.password,
    required this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid =
        viewMode == FolderViewMode.hybrid || viewMode == FolderViewMode.grid;

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
                  return HoverableCard(
                    child: FolderGridCard(
                      folder: MusicFolder(path: folder.path, name: folder.name),
                      subtitle: 'Folder',
                      enableHero: false,
                      onTap: () => onOpenFolder(folder),
                      onSecondaryTapDown: (details) {
                        showWebDavFolderContextMenu(
                          context: context,
                          globalPosition: details.globalPosition,
                          ref: ref,
                          server: server,
                          password: password,
                          folder: folder,
                          onOpen: () => onOpenFolder(folder),
                        );
                      },
                      onLongPress: () {
                        // handled on long press
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
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final folder = folders[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 8 : 16,
                  vertical: 4,
                ),
                child: FolderListTile(
                  folder: MusicFolder(path: folder.path, name: folder.name),
                  subtitle: 'Folder',
                  enableHero: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
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
                              showWebDavFolderContextMenu(
                                context: context,
                                globalPosition: pos,
                                ref: ref,
                                server: server,
                                password: password,
                                folder: folder,
                                onOpen: () => onOpenFolder(folder),
                              );
                            },
                          );
                        },
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                  onTap: () => onOpenFolder(folder),
                  onSecondaryTapDown: (details) {
                    showWebDavFolderContextMenu(
                      context: context,
                      globalPosition: details.globalPosition,
                      ref: ref,
                      server: server,
                      password: password,
                      folder: folder,
                      onOpen: () => onOpenFolder(folder),
                    );
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
  final void Function(WebDavFile) onDownloadSingle;
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
    required this.onDownloadSingle,
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

                  return HoverableCard(
                    child: WebDavSongGridCard(
                      file: file,
                      server: server,
                      password: password,
                      metadata: meta,
                      currentMusicPath: currentMusicPath,
                      isAudioPlaying: isAudioPlaying,
                      allAudioFiles: allAudioFiles,
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
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final file = files[index];
              final uri = RemoteMediaResolver.buildWebDavUri(server.id, file.path);
              final meta = metadataMap[uri] ??
                  ref.watch(scannerServiceProvider.select((s) => s.metadataMap[uri]));

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 8 : 16,
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
                  onDownload: () => onDownloadSingle(file),
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

  const WebDavSongGridCard({
    super.key,
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
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

    void showContextMenu(Offset pos) {
      showWebDavFileContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        file: file,
        currentAudioFiles: allAudioFiles,
        onPlay: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        enableFeedback: false,
        onTap: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
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

/// Rich List Tile widget for a WebDAV Song / Audio File, aligned with SongTile design.
class WebDavSongListTile extends ConsumerWidget {
  final WebDavFile file;
  final RemoteServer server;
  final String password;
  final SongMetadata? metadata;
  final String? currentMusicPath;
  final bool isAudioPlaying;
  final List<MusicFile> allAudioFiles;
  final VoidCallback onDownload;

  const WebDavSongListTile({
    super.key,
    required this.file,
    required this.server,
    required this.password,
    required this.metadata,
    required this.currentMusicPath,
    required this.isAudioPlaying,
    required this.allAudioFiles,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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

    void showContextMenu(Offset pos) {
      showWebDavFileContextMenu(
        context: context,
        globalPosition: pos,
        ref: ref,
        server: server,
        password: password,
        file: file,
        currentAudioFiles: allAudioFiles,
        onPlay: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      );
    }

    Widget leadingWidget;
    if (isAudio) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SongThumbnail(
                path: remoteUri,
                thumbnailPath: metadata?.thumbnailPath,
                size: 52.0,
              ),
              if (isCurrent)
                Container(
                  color: Colors.black45,
                  child: Center(
                    child: PlayingEqualizerIcon(
                      color: Colors.white,
                      size: 18,
                      isPlaying: isAudioPlaying,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      leadingWidget = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.insert_drive_file_outlined,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          size: 26,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) => showContextMenu(details.globalPosition),
      onLongPressStart: (details) => showContextMenu(details.globalPosition),
      child: ListTile(
        leading: leadingWidget,
        title: Text(
          titleText,
          style: TextStyle(
            color: isCurrent
                ? theme.colorScheme.primary
                : (isAudio
                    ? null
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: isAudio
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (artistAlbumStr != null) ...[
                    Text(
                      artistAlbumStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.85)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                  ],
                  Text(
                    techInfoStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isCurrent
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Text(
                sizeStr,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAudio)
              IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  size: 22,
                  color: isCurrent ? theme.colorScheme.primary : null,
                ),
                tooltip: 'Download',
                onPressed: onDownload,
              ),
            Builder(
              builder: (btnContext) {
                return IconButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: isCurrent ? theme.colorScheme.primary : null,
                  ),
                  tooltip: 'More',
                  onPressed: () {
                    final box = btnContext.findRenderObject() as RenderBox?;
                    final pos = box != null
                        ? box.localToGlobal(
                            Offset(box.size.width / 2, box.size.height / 2))
                        : Offset.zero;
                    showContextMenu(pos);
                  },
                );
              },
            ),
          ],
        ),
        onTap: isAudio
            ? () async {
                final target = RemoteMediaResolver.buildMusicFileFromWebDav(
                  file,
                  server,
                  metadata: metadata,
                );
                final initialIndex =
                    allAudioFiles.indexWhere((s) => s.path == target.path);
                final audioService = ref.read(audioServiceProvider);
                await audioService.playPlaylist(
                  allAudioFiles.isNotEmpty ? allAudioFiles : [target],
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                );
              }
            : null,
      ),
    );
  }
}
