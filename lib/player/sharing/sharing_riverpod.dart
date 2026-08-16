import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sharing_service.dart';
import 'lan_device.dart';
import 'remote_control/remote_control_service.dart';
import 'security/tls_certificate_service.dart';

final tlsCertificateServiceProvider = Provider<TlsCertificateService>((ref) {
  return TlsCertificateService();
});

// Provider that instantiates and holds the SharingService
final sharingServiceProvider = Provider<SharingService>((ref) {
  final service = SharingService(ref);

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.stop();
  });

  return service;
});

final remoteControlServiceProvider = Provider<RemoteControlService>((ref) {
  final service = RemoteControlService(ref);
  service.init();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});


// State of the Sharing Server running status
class SharingServerState {
  final bool isRunning;
  final String? localIp;
  final int? httpPort;

  SharingServerState({required this.isRunning, this.localIp, this.httpPort});
}

class SharingServerStateNotifier extends Notifier<SharingServerState> {
  @override
  SharingServerState build() {
    return SharingServerState(isRunning: false);
  }

  Future<void> start() async {
    if (state.isRunning) return;
    final service = ref.read(sharingServiceProvider);
    final started = await service.start();
    if (!started) {
      return;
    }
    state = SharingServerState(
      isRunning: true,
      localIp: service.localIp,
      httpPort: service.httpPort,
    );
  }

  Future<void> stop() async {
    if (!state.isRunning) return;
    final service = ref.read(sharingServiceProvider);
    await service.stop();
    state = SharingServerState(isRunning: false);
  }
}

final sharingServerStateProvider =
    NotifierProvider<SharingServerStateNotifier, SharingServerState>(
      SharingServerStateNotifier.new,
    );

final discoveredDevicesProvider = StreamProvider<List<LanDevice>>((ref) {
  final service = ref.watch(sharingServiceProvider);
  // Only listen when the server is active
  final serverState = ref.watch(sharingServerStateProvider);
  if (!serverState.isRunning) {
    return Stream.value([]);
  }

  // Prepend current devices to avoid starting in AsyncLoading state
  Stream<List<LanDevice>> getDevicesStream() async* {
    yield service.discoveredDevices;
    yield* service.discoveredDevicesStream;
  }

  return getDevicesStream();
});
