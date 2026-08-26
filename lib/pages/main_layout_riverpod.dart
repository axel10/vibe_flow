import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayoutUiState {
  const MainLayoutUiState({
    this.showVolumeHud = false,
    this.showImmersiveTabBar = true,
    this.snackBarOffset = 0.0,
  });

  final bool showVolumeHud;
  final bool showImmersiveTabBar;
  final double snackBarOffset;

  MainLayoutUiState copyWith({
    bool? showVolumeHud,
    bool? showImmersiveTabBar,
    double? snackBarOffset,
  }) {
    return MainLayoutUiState(
      showVolumeHud: showVolumeHud ?? this.showVolumeHud,
      showImmersiveTabBar: showImmersiveTabBar ?? this.showImmersiveTabBar,
      snackBarOffset: snackBarOffset ?? this.snackBarOffset,
    );
  }
}

class MainLayoutUiController extends Notifier<MainLayoutUiState> {
  Timer? _hudTimer;
  Timer? _immersiveTabBarTimer;
  bool _disposed = false;

  @override
  MainLayoutUiState build() {
    ref.onDispose(() {
      _disposed = true;
      _hudTimer?.cancel();
      _immersiveTabBarTimer?.cancel();
    });
    return const MainLayoutUiState();
  }

  void setVolumeHudVisible(bool visible) {
    _hudTimer?.cancel();
    if (!visible) {
      state = state.copyWith(showVolumeHud: false);
      return;
    }

    state = state.copyWith(showVolumeHud: true);
    _hudTimer = Timer(const Duration(seconds: 2), () {
      if (_disposed) return;
      state = state.copyWith(showVolumeHud: false);
    });
  }

  void showImmersiveTabBar() {
    _immersiveTabBarTimer?.cancel();
    state = state.copyWith(showImmersiveTabBar: true);
  }

  void hideImmersiveTabBarAfter(Duration delay) {
    _immersiveTabBarTimer?.cancel();
    _immersiveTabBarTimer = Timer(delay, () {
      if (_disposed) return;
      state = state.copyWith(showImmersiveTabBar: false);
    });
  }

  void setSnackBarOffset(double offset) {
    state = state.copyWith(snackBarOffset: offset);
  }
}

final mainLayoutUiControllerProvider =
    NotifierProvider.autoDispose<MainLayoutUiController, MainLayoutUiState>(
      MainLayoutUiController.new,
    );

class MainTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    if (state != index) {
      state = index;
    }
  }
}

final mainTabIndexProvider =
    NotifierProvider<MainTabIndexNotifier, int>(MainTabIndexNotifier.new);
