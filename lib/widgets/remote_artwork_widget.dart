import 'package:flutter/material.dart';
import '../player/remote/remote_server_models.dart';
import '../player/remote/clients/subsonic_client.dart';

class RemoteArtworkWidget extends StatelessWidget {
  /// In-memory negative cache to prevent repeated 404 / failed HTTP requests
  static final Set<String> _failedUrls = <String>{};

  /// Method to clear the failed URLs cache if needed (e.g. on manual refresh)
  static void clearFailedCache() {
    _failedUrls.clear();
  }

  final RemoteServer? server;
  final String? password;
  final String? coverArtId;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool isArtist;
  final IconData? fallbackIcon;

  const RemoteArtworkWidget({
    super.key,
    this.server,
    this.password,
    this.coverArtId,
    this.size = 50.0,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.isArtist = false,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final radius = borderRadius ?? BorderRadius.circular(8);

    if (server != null &&
        password != null &&
        coverArtId != null &&
        coverArtId!.isNotEmpty &&
        server!.type == RemoteServerType.subsonic) {
      final client = SubsonicClient(server: server!, password: password!);
      final imageUrl = client.buildCoverArtUrl(coverArtId!, size: (size * 2).toInt());

      if (_failedUrls.contains(imageUrl)) {
        return _buildFallback(context, w, h, radius);
      }

      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          imageUrl,
          width: w,
          height: h,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return _buildFallback(context, w, h, radius);
          },
          errorBuilder: (_, _, _) {
            _failedUrls.add(imageUrl);
            return _buildFallback(context, w, h, radius);
          },
        ),
      );
    }

    return _buildFallback(context, w, h, radius);
  }

  Widget _buildFallback(BuildContext context, double w, double h, BorderRadius radius) {
    final theme = Theme.of(context);
    final icon = fallbackIcon ?? (isArtist ? Icons.person_rounded : Icons.music_note_rounded);
    final bgColor = isArtist
        ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7)
        : theme.colorScheme.primary.withValues(alpha: 0.1);
    final iconColor = isArtist
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.primary.withValues(alpha: 0.7);

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: (size * 0.5).clamp(16.0, 48.0),
        ),
      ),
    );
  }
}
