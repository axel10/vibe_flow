import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/audio/app_playback_mode.dart';
import 'package:vynody/player/sharing/remote_control/remote_playback_model.dart';

void main() {
  group('RemotePlaybackState tests', () {
    test('serialization and deserialization', () {
      const original = RemotePlaybackState(
        title: 'Song Title',
        artist: 'Artist Name',
        album: 'Album Name',
        durationMs: 240000,
        positionMs: 45000,
        isPlaying: true,
        isFavorite: true,
        playbackMode: AppPlaybackMode.singleLoop,
        isRandomMode: true,
        hostDeviceName: 'MacBook Pro',
      );

      final json = original.toJson();
      final restored = RemotePlaybackState.fromJson(json);

      expect(restored.title, 'Song Title');
      expect(restored.artist, 'Artist Name');
      expect(restored.album, 'Album Name');
      expect(restored.durationMs, 240000);
      expect(restored.positionMs, 45000);
      expect(restored.isPlaying, true);
      expect(restored.isFavorite, true);
      expect(restored.playbackMode, AppPlaybackMode.singleLoop);
      expect(restored.isRandomMode, true);
      expect(restored.hostDeviceName, 'MacBook Pro');
    });

    test('copyWith works properly', () {
      const original = RemotePlaybackState(
        title: 'Old Title',
        isPlaying: false,
      );

      final updated = original.copyWith(
        title: 'New Title',
        isPlaying: true,
      );

      expect(updated.title, 'New Title');
      expect(updated.isPlaying, true);
      expect(updated.isFavorite, false);
    });
  });

  group('RemoteCommand tests', () {
    test('factory methods create correct command actions and params', () {
      final playCmd = RemoteCommand.play();
      expect(playCmd.action, 'play');
      expect(playCmd.toJson()['action'], 'play');

      final toggleCmd = RemoteCommand.togglePlay();
      expect(toggleCmd.action, 'togglePlay');

      final seekCmd = RemoteCommand.seek(12345);
      expect(seekCmd.action, 'seek');
      expect(seekCmd.params['positionMs'], 12345);

      final modeCmd = RemoteCommand.setPlaybackMode(AppPlaybackMode.single);
      expect(modeCmd.action, 'setPlaybackMode');
      expect(modeCmd.params['mode'], 'single');

      final favCmd = RemoteCommand.toggleFavorite();
      expect(favCmd.action, 'toggleFavorite');

      final randCmd = RemoteCommand.toggleRandomMode();
      expect(randCmd.action, 'toggleRandomMode');
    });

    test('command roundtrip json parsing', () {
      final original = RemoteCommand.setPlaybackMode(AppPlaybackMode.queueLoop);
      final json = original.toJson();
      final parsed = RemoteCommand.fromJson(json);

      expect(parsed.action, 'setPlaybackMode');
      expect(parsed.params['mode'], 'queueLoop');
    });
  });

  group('TrustedRemoteDevice tests', () {
    test('json serialization and parsing', () {
      final now = DateTime.now();
      final device = TrustedRemoteDevice(
        id: 'dev_123',
        name: 'iPhone 15',
        deviceType: 'ios',
        token: 'auth_token_xyz',
        pairedAt: now,
      );

      final json = device.toJson();
      final restored = TrustedRemoteDevice.fromJson(json);

      expect(restored.id, 'dev_123');
      expect(restored.name, 'iPhone 15');
      expect(restored.deviceType, 'ios');
      expect(restored.token, 'auth_token_xyz');
      expect(restored.pairedAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(restored.certFingerprint, isNull);
    });

    test('json serialization and parsing with certFingerprint', () {
      final now = DateTime.now();
      final device = TrustedRemoteDevice(
        id: 'dev_123',
        name: 'iPhone 15',
        deviceType: 'ios',
        token: 'auth_token_xyz',
        pairedAt: now,
        certFingerprint: 'abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234',
      );

      final json = device.toJson();
      expect(json['certFingerprint'], 'abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234');

      final restored = TrustedRemoteDevice.fromJson(json);
      expect(restored.certFingerprint, 'abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234');
    });
  });
}
