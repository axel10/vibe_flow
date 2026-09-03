import 'package:flutter_secure_storage/flutter_secure_storage.dart';
export 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Global FlutterSecureStorage instance configured for cross-platform compatibility.
///
/// On macOS:
/// [useDataProtectionKeyChain: false] is explicitly set to use the standard/legacy
/// macOS Keychain. This avoids requiring the `keychain-access-groups` entitlement,
/// which allows unsigned or ad-hoc signed DMGs to open cleanly without codesign crashes,
/// while ensuring passwords and sensitive tokens are reliably persisted.
const appSecureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
  mOptions: MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock,
    useDataProtectionKeyChain: false,
  ),
);
