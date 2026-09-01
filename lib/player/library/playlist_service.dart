import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/metadata/metadata_database.dart';
import 'package:vynody/utils/m3u_utils.dart';

/// 播放列表模型
class Playlist {
  final String id;
  String name;
  final List<MusicFile> songs;
  final DateTime createdAt;
  DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    List<MusicFile>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : songs = songs ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建播放列表
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (s) => MusicFile(
                  path: s['path'] as String,
                  name: s['name'] as String,
                  title: s['title'] as String?,
                  artist: s['artist'] as String?,
                  album: s['album'] as String?,
                  trackNumber: s['trackNumber'] as int?,
                  durationMillis: s['durationMillis'] as int?,
                  id: s['id'] as int?,
                  mediaUri: s['mediaUri'] as String?,
                  thumbnailPath: s['thumbnailPath'] as String?,
                  artworkWidth: s['artworkWidth'] as int?,
                  artworkHeight: s['artworkHeight'] as int?,
                  themeColorsBlob: s['themeColorsBlob'] != null
                      ? base64Decode(s['themeColorsBlob'] as String)
                      : null,
                ),
              )
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songs': songs
          .map(
            (s) => {
              'path': s.path,
              'name': s.name,
              'title': s.title,
              'artist': s.artist,
              'album': s.album,
              'trackNumber': s.trackNumber,
              'durationMillis': s.durationMillis,
              'id': s.id,
              'mediaUri': s.mediaUri,
              'thumbnailPath': s.thumbnailPath,
              'artworkWidth': s.artworkWidth,
              'artworkHeight': s.artworkHeight,
              'themeColorsBlob': s.themeColorsBlob != null
                  ? base64Encode(s.themeColorsBlob!)
                  : null,
            },
          )
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Playlist copyWith({
    String? id,
    String? name,
    List<MusicFile>? songs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songs: songs ?? List.from(this.songs),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 播放列表管理服务
class PlaylistService extends ChangeNotifier {
  final List<Playlist> _playlists = [];
  String? _currentPlaylistId;
  static const String _storageKey = 'playlists';
  static const String _currentPlaylistKey = 'current_playlist_id';
  static const String favoritePlaylistId = 'favorites';

  List<Playlist> get playlists => List.unmodifiable(_playlists);
  Playlist? get currentPlaylist => _currentPlaylistId != null
      ? _playlists.firstWhere(
          (p) => p.id == _currentPlaylistId,
          orElse: () => _playlists.isNotEmpty
              ? _playlists.first
              : Playlist(id: 'default', name: '默认列表'),
        )
      : (_playlists.isNotEmpty ? _playlists.first : null);

  PlaylistService() {
    _init();
  }

  /// 初始化，加载保存的播放列表
  Future<void> _init() async {
    await _loadPlaylists();
    // 确保内置列表始终存在，并保持在普通列表之后。
    final hasDefault = _playlists.any((p) => p.id == 'default');
    final hasFavorites = _playlists.any((p) => p.id == favoritePlaylistId);

    if (!hasDefault) {
      _playlists.insert(0, Playlist(id: 'default', name: '默认列表'));
    }
    if (!hasFavorites) {
      final favoriteIndex = _playlists.indexWhere((p) => p.id == 'default');
      final insertIndex = favoriteIndex == -1
          ? _playlists.length
          : favoriteIndex + 1;
      _playlists.insert(
        insertIndex,
        Playlist(id: favoritePlaylistId, name: '收藏'),
      );
    }

    if (_playlists.isNotEmpty &&
        (_currentPlaylistId == null ||
            !_playlists.any((p) => p.id == _currentPlaylistId))) {
      _currentPlaylistId = _playlists.first.id;
    }
    await _savePlaylists();
    notifyListeners();
  }

  /// 从本地存储加载播放列表
  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      final currentId = prefs.getString(_currentPlaylistKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _playlists.clear();
        _playlists.addAll(
          jsonList.map(
            (json) => Playlist.fromJson(json as Map<String, dynamic>),
          ),
        );
      }

      _currentPlaylistId = currentId;
    } catch (e) {
      debugPrint('Error loading playlists: $e');
    }
  }

  /// 保存播放列表到本地存储
  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(
        _playlists.map((p) => p.toJson()).toList(),
      );
      await prefs.setString(_storageKey, jsonString);
      if (_currentPlaylistId != null) {
        await prefs.setString(_currentPlaylistKey, _currentPlaylistId!);
      }
    } catch (e) {
      debugPrint('Error saving playlists: $e');
    }
  }

  /// 创建新的播放列表
  Future<Playlist> createPlaylist(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(id: id, name: name);
    _playlists.add(playlist);
    _currentPlaylistId = id;
    await _savePlaylists();
    notifyListeners();
    return playlist;
  }

  /// 检查是否存在同名播放列表 (不区分大小写，去除首尾空格)
  bool playlistExists(String name, {String? excludeId}) {
    final searchName = name.trim().toLowerCase();
    if (searchName.isEmpty) return false;
    return _playlists.any((p) {
      if (excludeId != null && p.id == excludeId) return false;
      return p.name.trim().toLowerCase() == searchName;
    });
  }

  /// 生成不重复的播放列表名称
  String generateUniquePlaylistName(String baseName) {
    final trimmed = baseName.trim();
    if (trimmed.isEmpty) return generateUniquePlaylistName('新建歌单');
    if (!playlistExists(trimmed)) return trimmed;

    int counter = 1;
    while (playlistExists('$trimmed ($counter)')) {
      counter++;
    }
    return '$trimmed ($counter)';
  }

  /// 从 M3U 文件导入播放列表
  Future<Playlist> importPlaylistFromM3u(String filePath) async {
    final file = File(filePath);
    String content;
    try {
      content = await file.readAsString(encoding: utf8);
    } catch (_) {
      content = await file.readAsString(encoding: latin1);
    }

    final data = M3uUtils.parse(content, baseDir: p.dirname(filePath));
    final rawName = data.playlistName?.trim().isNotEmpty == true
        ? data.playlistName!.trim()
        : p.basenameWithoutExtension(filePath);
    final playlistName = generateUniquePlaylistName(rawName);

    final songs = await M3uUtils.resolveMusicFiles(data.entries);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(
      id: id,
      name: playlistName,
      songs: songs,
    );

    _playlists.add(playlist);
    _currentPlaylistId = id;
    await _savePlaylists();
    notifyListeners();
    return playlist;
  }

  /// 批量从 M3U 文件导入播放列表
  Future<List<Playlist>> importPlaylistsFromM3u(List<String> filePaths) async {
    final imported = <Playlist>[];
    for (final path in filePaths) {
      try {
        final playlist = await importPlaylistFromM3u(path);
        imported.add(playlist);
      } catch (e) {
        debugPrint('Error importing playlist from $path: $e');
      }
    }
    return imported;
  }

  /// 导出播放列表为 M3U8 字符串
  String exportPlaylistToM3u(Playlist playlist) {
    return M3uUtils.generate(playlist.songs, playlistName: playlist.name);
  }

  /// 删除播放列表
  Future<void> deletePlaylist(String id) async {
    if (id == favoritePlaylistId) {
      return;
    }
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists.removeAt(index);
      if (_currentPlaylistId == id) {
        _currentPlaylistId = _playlists.isNotEmpty ? _playlists.first.id : null;
      }
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// 重命名播放列表
  Future<void> renamePlaylist(String id, String newName) async {
    if (id == favoritePlaylistId) {
      return;
    }
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index].name = newName;
      _playlists[index].updatedAt = DateTime.now();
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// 切换当前播放列表
  void setCurrentPlaylist(String id) {
    if (_playlists.any((p) => p.id == id)) {
      _currentPlaylistId = id;
      _savePlaylists();
      notifyListeners();
    }
  }

  /// 向播放列表添加歌曲
  Future<void> addSongsToPlaylist(
    String playlistId,
    List<MusicFile> songs,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.addAll(songs);
      _playlists[index].updatedAt = DateTime.now();
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// 从播放列表移除歌曲
  Future<void> removeSongsFromPlaylist(
    String playlistId,
    List<int> indices,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      // 按索引降序排序后删除，避免索引错位
      final sortedIndices = List<int>.from(indices)
        ..sort((a, b) => b.compareTo(a));
      for (final idx in sortedIndices) {
        if (idx >= 0 && idx < _playlists[index].songs.length) {
          _playlists[index].songs.removeAt(idx);
        }
      }
      _playlists[index].updatedAt = DateTime.now();
      await _savePlaylists();
      notifyListeners();
    }
  }

  /// 重新排序播放列表中的歌曲
  Future<void> reorderSongsInPlaylist(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final songs = _playlists[index].songs;
      if (oldIndex < songs.length && newIndex < songs.length) {
        final song = songs.removeAt(oldIndex);
        songs.insert(newIndex, song);
        _playlists[index].updatedAt = DateTime.now();
        await _savePlaylists();
        notifyListeners();
      }
    }
  }

  /// 清空播放列表
  Future<void> clearPlaylist(String playlistId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.clear();
      _playlists[index].updatedAt = DateTime.now();
      await _savePlaylists();
      notifyListeners();
    }
  }

  Playlist? get favoritePlaylist {
    try {
      return _playlists.firstWhere((p) => p.id == favoritePlaylistId);
    } catch (_) {
      return null;
    }
  }

  bool isFavoriteSong(MusicFile song) {
    return favoritePlaylist?.songs.any((item) => item.path == song.path) ??
        false;
  }

  Future<bool> toggleFavoriteSong(MusicFile song) async {
    final index = _playlists.indexWhere((p) => p.id == favoritePlaylistId);
    if (index == -1) return false;

    final playlist = _playlists[index];
    final existingIndex = playlist.songs.indexWhere(
      (item) => item.path == song.path,
    );
    final wasAdded = existingIndex == -1;

    if (existingIndex == -1) {
      playlist.songs.add(song);
    } else {
      playlist.songs.removeAt(existingIndex);
    }

    playlist.updatedAt = DateTime.now();
    await _savePlaylists();
    notifyListeners();
    return wasAdded;
  }

  Future<void> addSongToFavorite(MusicFile song) async {
    final index = _playlists.indexWhere((p) => p.id == favoritePlaylistId);
    if (index == -1) return;

    final playlist = _playlists[index];
    final existingIndex = playlist.songs.indexWhere(
      (item) => item.path == song.path,
    );
    if (existingIndex == -1) {
      playlist.songs.add(song);
    } else {
      playlist.songs[existingIndex] = song;
    }
    playlist.updatedAt = DateTime.now();
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> updateSongMetadataByPath(
    SongMetadata metadata, {
    Uint8List? artworkBytes,
  }) async {
    bool changed = false;
    final isArtworkCleared = artworkBytes != null && artworkBytes.isEmpty;

    for (final playlist in _playlists) {
      for (var i = 0; i < playlist.songs.length; i++) {
        final song = playlist.songs[i];
        if (song.path != metadata.path) continue;

        playlist.songs[i] = song.copyWith(
          title: metadata.title,
          artist: metadata.artist,
          albumArtist: metadata.albumArtist,
          album: metadata.album,
          trackNumber: metadata.trackNumber,
          thumbnailPath: isArtworkCleared ? null : (metadata.thumbnailPath ?? song.thumbnailPath),
          artworkPath: isArtworkCleared ? null : (metadata.artworkPath ?? song.artworkPath),
          artworkWidth: isArtworkCleared ? null : (metadata.artworkWidth ?? song.artworkWidth),
          artworkHeight: isArtworkCleared ? null : (metadata.artworkHeight ?? song.artworkHeight),
          themeColorsBlob: isArtworkCleared ? null : (metadata.themeColorsBlob ?? song.themeColorsBlob),
          artworkBytes: isArtworkCleared ? null : (artworkBytes ?? song.artworkBytes),
          lastModifiedTime: metadata.lastModifiedTime,
        );

        playlist.updatedAt = DateTime.now();
        changed = true;
      }
    }

    if (changed) {
      await _savePlaylists();
      notifyListeners();
    }
  }

  void setSongMissingStateByPath(String path, bool isMissing) {
    var changed = false;
    for (final playlist in _playlists) {
      for (var i = 0; i < playlist.songs.length; i++) {
        final song = playlist.songs[i];
        if (song.path != path || song.isMissing == isMissing) continue;

        playlist.songs[i] = song.copyWith(isMissing: isMissing);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }
}
