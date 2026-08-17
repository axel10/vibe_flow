/// Represents the distribution channel of the application.
enum AppDistributionChannel {
  /// GitHub release / Sideloading (Full-featured version, unlocked by default).
  github,

  /// App Store / Microsoft Store (Managed trial and StoreKit/Store IAP).
  store,
}

/// Global helper to access the application's distribution channel at runtime.
class AppChannel {
  AppChannel._();

  /// Read the channel configured at compile time via `--dart-define=CHANNEL=...`.
  /// Defaults to `github` so standard builds have full access.
  static const String _rawChannel = String.fromEnvironment(
    'CHANNEL',
    defaultValue: 'github',
  );

  /// Current active distribution channel.
  static AppDistributionChannel get current {
    final normalized = _rawChannel.trim().toLowerCase();
    if (normalized == 'store' || normalized == 'appstore' || normalized == 'msstore') {
      return AppDistributionChannel.store;
    }
    return AppDistributionChannel.github;
  }

  /// Whether the app is running in GitHub / Community full-featured mode.
  static bool get isGitHubRelease => current == AppDistributionChannel.github;

  /// Whether the app is running in Store mode with trial/pro gates enabled.
  static bool get isStoreRelease => current == AppDistributionChannel.store;
}

/// Global configuration for Pro tier and trial periods.
class ProConfig {
  ProConfig._();

  /// Default trial duration in days.
  /// Can also be overridden at compile time via `--dart-define=TRIAL_DAYS=...`.
  static const int trialDays = int.fromEnvironment(
    'TRIAL_DAYS',
    defaultValue: 15,
  );
}
