import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vynody/player/remote/remote_server_models.dart';

import 'package:vynody/widgets/remote_artwork_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testServer = RemoteServer(
    id: 'subsonic_test',
    name: 'Navidrome Server',
    type: RemoteServerType.subsonic,
    url: 'http://127.0.0.1:4533',
    username: 'testuser',
    createdAt: DateTime.now(),
  );

  testWidgets('RemoteArtworkWidget renders fallback when cover is empty or loading', (tester) async {
    await tester.pumpWidget(
      OKToast(
        child: MaterialApp(
          home: Scaffold(
            body: RemoteArtworkWidget(
              server: testServer,
              password: 'testpwd',
              coverArtId: null,
              size: 80,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RemoteArtworkWidget), findsOneWidget);
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });
}
