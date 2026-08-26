import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/main_layout_riverpod.dart';

class AppSnackBar {
  static Timer? _autoDismissTimer;

  static void show(
    BuildContext context,
    WidgetRef? ref,
    SnackBar snackBar, {
    double offset = 70.0,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref != null
        ? ref.read(mainLayoutUiControllerProvider.notifier)
        : ProviderScope.containerOf(context, listen: false)
            .read(mainLayoutUiControllerProvider.notifier);

    // Cancel any previous timer
    _autoDismissTimer?.cancel();

    // Dismiss any active snackbar immediately to avoid queuing and layout collision
    messenger.hideCurrentSnackBar();
    controller.setSnackBarOffset(offset);

    // Use passed duration or snackBar's own duration if set
    final effectiveDuration = snackBar.duration != const Duration(milliseconds: 4000)
        ? snackBar.duration
        : duration;

    final snackBarToDisplay = SnackBar(
      key: snackBar.key,
      content: snackBar.content,
      backgroundColor: snackBar.backgroundColor,
      elevation: snackBar.elevation,
      margin: snackBar.margin,
      padding: snackBar.padding,
      width: snackBar.width,
      shape: snackBar.shape,
      behavior: snackBar.behavior,
      action: snackBar.action,
      actionOverflowThreshold: snackBar.actionOverflowThreshold,
      showCloseIcon: snackBar.showCloseIcon ?? true,
      closeIconColor: snackBar.closeIconColor,
      duration: effectiveDuration,
      animation: snackBar.animation,
      onVisible: snackBar.onVisible,
      dismissDirection: snackBar.dismissDirection ?? DismissDirection.horizontal,
      clipBehavior: snackBar.clipBehavior,
    );

    final controllerEntry = messenger.showSnackBar(snackBarToDisplay);

    controllerEntry.closed.then((reason) {
      _autoDismissTimer?.cancel();
      controller.setSnackBarOffset(0.0);
    });

    // Fallback timer to guarantee dismissal even if Flutter's internal timer is skipped by accessibleNavigation or desktop mouse events
    _autoDismissTimer = Timer(effectiveDuration + const Duration(milliseconds: 300), () {
      try {
        messenger.hideCurrentSnackBar();
      } catch (_) {}
    });
  }
}

