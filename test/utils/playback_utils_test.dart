import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/utils/playback_utils.dart';

void main() {
  group('getVolumeIcon', () {
    test('returns Icons.volume_off when isMuted is true', () {
      expect(getVolumeIcon(100, isMuted: true), Icons.volume_off);
      expect(getVolumeIcon(50, isMuted: true), Icons.volume_off);
      expect(getVolumeIcon(0, isMuted: true), Icons.volume_off);
    });

    test('returns correct volume icons when unmuted', () {
      expect(getVolumeIcon(0, isMuted: false), Icons.volume_mute);
      expect(getVolumeIcon(50, isMuted: false), Icons.volume_down);
      expect(getVolumeIcon(80, isMuted: false), Icons.volume_up);
    });
  });
}
