import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vynody/dialogs/upgrade_to_pro_dialog.dart';
import 'package:vynody/player/pro/pro_license_service.dart';
import 'package:vynody/player/pro/pro_models.dart';
import 'package:vynody/widgets/pro/pro_badge.dart';

/// A wrapper widget that gates interaction behind a Pro license.
/// If locked, clicking the widget intercepts touch events and displays the upgrade dialog.
class ProGate extends ConsumerWidget {
  const ProGate({
    super.key,
    required this.feature,
    required this.child,
    this.showBadge = true,
    this.badgeAlignment = Alignment.topRight,
    this.badgeOffset = const Offset(0, 0),
    this.lockedOpacity = 0.75,
  });

  final ProFeature feature;
  final Widget child;
  final bool showBadge;
  final Alignment badgeAlignment;
  final Offset badgeOffset;
  final double lockedOpacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(isProUnlockedProvider);

    if (isUnlocked) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showUpgradeToProDialog(context, initialFeature: feature);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: lockedOpacity,
            child: IgnorePointer(
              child: child,
            ),
          ),
          if (showBadge)
            Positioned(
              top: badgeOffset.dy,
              right: badgeOffset.dx,
              child: const ProBadge(),
            ),
        ],
      ),
    );
  }
}
