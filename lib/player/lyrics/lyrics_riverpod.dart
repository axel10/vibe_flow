import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vynody/models/music_file.dart';
import 'package:vynody/player/lyrics/lyrics_controller_dependencies.dart';
import 'package:vynody/player/audio/audio_riverpod.dart';
import 'package:vynody/player/lyrics/lyrics_controller.dart';
import 'package:vynody/player/lyrics/lyrics_controller_state.dart';
import 'package:vynody/player/lyrics/lyrics_ai_service.dart';
import 'package:vynody/player/lyrics/lyrics_service.dart';
import 'package:vynody/player/remote/remote_service_providers.dart';

final lyricsControllerDependenciesProvider =
    Provider<LyricsControllerDependencies>((ref) {
      final audioService = ref.read(audioServiceProvider);
      return audioService.lyricsControllerDependencies;
    });

final lyricsAiRuntimeConfigProvider = Provider<LyricsAiRuntimeConfig>((ref) {
  return ref.watch(
    settingsServiceProvider.select(
      (settings) => LyricsAiRuntimeConfig(
        generationPrimaryModel: settings.generationPrimaryModel,
        generationFallbackModel: settings.generationFallbackModel,
        translationPrimaryModel: settings.translationPrimaryModel,
        translationFallbackModel: settings.translationFallbackModel,
        geminiApiKey: settings.geminiApiKey,
        openRouterApiKey: settings.openRouterApiKey,
        doubaoApiKey: settings.doubaoApiKey,
        deepseekApiKey: settings.deepseekApiKey,
        customProviderApiKey: settings.customProviderApiKey,
        customProviderBaseUrl: settings.customProviderBaseUrl,
        customProviderName: settings.customProviderName,
      ),
    ),
  );
});

final lyricsAiServiceProvider = Provider<LyricsAiService>((ref) {
  return LyricsAiService(
    readConfig: () => ref.read(lyricsAiRuntimeConfigProvider),
  );
});

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService(
    remoteLyricsFetcher: (uri) async {
      final resolver = await ref.read(remoteMediaResolverProvider.future);
      return resolver.fetchLyrics(MusicFile(path: uri, name: ''));
    },
  );
});



final lyricsTranslationLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(
    settingsServiceProvider.select(
      (settings) => settings.effectiveLyricsTranslationTargetLanguageCode,
    ),
  );
});

final lyricsControllerProvider =
    NotifierProvider<LyricsController, LyricsControllerState>(
      LyricsController.new,
    );

class _LyricsPanelScrollStateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setScrolling(bool value) {
    state = value;
  }
}

class _LyricsLayoutRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

final lyricsPanelScrollAnimatingProvider =
    NotifierProvider<_LyricsPanelScrollStateNotifier, bool>(
      _LyricsPanelScrollStateNotifier.new,
    );

final lyricsLayoutRevisionProvider =
    NotifierProvider<_LyricsLayoutRevisionNotifier, int>(
      _LyricsLayoutRevisionNotifier.new,
    );
