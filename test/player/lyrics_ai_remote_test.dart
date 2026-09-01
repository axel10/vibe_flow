import 'package:flutter_test/flutter_test.dart';
import 'package:vynody/player/lyrics/lyrics_ai_service.dart';
import 'package:vynody/player/remote/proxy/remote_media_resolver.dart';
import 'package:vynody/player/remote/remote_server_models.dart';
import 'package:vynody/player/remote/remote_server_storage.dart';
import 'package:vynody/player/settings/settings_service.dart';

class _FakeRemoteServerStorage implements RemoteServerStorage {
  @override
  List<RemoteServer> loadServers() => [
        RemoteServer(
          id: 'server1',
          name: 'Test Server',
          type: RemoteServerType.webdav,
          url: 'http://127.0.0.1:8080',
          username: 'user',
          createdAt: DateTime.now(),
        ),
      ];

  @override
  Future<String?> getPassword(String serverId) async => 'password';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LyricsAiService recognizes remote URIs', () async {
    expect(RemoteMediaResolver.isRemoteUri('webdav://server1/test.mp3'), isTrue);
    expect(RemoteMediaResolver.isRemoteUri('subsonic://server1/12345'), isTrue);
    expect(RemoteMediaResolver.isRemoteUri('/local/path/song.mp3'), isFalse);
  });

  test('LyricsAiService initializes with remoteMediaResolver', () {
    final storage = _FakeRemoteServerStorage();
    final resolver = RemoteMediaResolver(storage: storage);
    final service = LyricsAiService(
      readConfig: () => const LyricsAiRuntimeConfig(
        generationPrimaryModel: LyricsAiModelSelection(
          provider: LyricsAiProvider.googleAiStudio,
          modelId: 'gemini-2.5-flash',
        ),
        generationFallbackModel: LyricsAiModelSelection(
          provider: LyricsAiProvider.googleAiStudio,
          modelId: '',
        ),
        translationPrimaryModel: LyricsAiModelSelection(
          provider: LyricsAiProvider.googleAiStudio,
          modelId: '',
        ),
        translationFallbackModel: LyricsAiModelSelection(
          provider: LyricsAiProvider.googleAiStudio,
          modelId: '',
        ),
        geminiApiKey: '',
        openRouterApiKey: '',
        doubaoApiKey: '',
        deepseekApiKey: '',
        customProviderApiKey: '',
        customProviderBaseUrl: '',
        customProviderName: '',
      ),
      remoteMediaResolver: () async => resolver,
    );

    expect(service.currentGenerationProviderTag, 'google_ai_studio');
  });
}
