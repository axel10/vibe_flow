import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppLog {
  AppLog._();

  static final DebugPrintCallback _defaultDebugPrint = debugPrint;

  static IOSink? _sink;
  static Future<void> _writeQueue = Future<void>.value();
  static bool _installed = false;
  static String? _logFilePath;

  static String? get logFilePath => _logFilePath;

  static Future<void> init() async {
    if (_sink != null) {
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();

    final supportDir = await getApplicationSupportDirectory();
    final logDir = Directory(p.join(supportDir.path, 'logs'));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final file = File(p.join(logDir.path, 'vynody.log'));
    final exists = await file.exists();
    if (exists) {
      final length = await file.length();
      const maxBytes = 2 * 1024 * 1024;
      if (length > maxBytes) {
        final backup = File(p.join(logDir.path, 'vynody.previous.log'));
        if (await backup.exists()) {
          await backup.delete();
        }
        await file.rename(backup.path);
      }
    }

    _logFilePath = file.path;
    _sink = file.openWrite(mode: FileMode.append, encoding: utf8);
    log(
      '=== session start pid=$pid mode=${kReleaseMode ? "release" : kDebugMode ? "debug" : "profile"} '
      'platform=${Platform.operatingSystem} executable=${Platform.resolvedExecutable} ===',
      mirrorToConsole: true,
    );
    log('log file path=$_logFilePath', mirrorToConsole: true);
    await logDeviceInfo();
  }

  static Future<void> logDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final appInfoStr =
          'App: ${packageInfo.appName} v${packageInfo.version}+${packageInfo.buildNumber} (${packageInfo.packageName})';

      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceStr = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceStr =
            'Device: ${androidInfo.manufacturer} ${androidInfo.model} (${androidInfo.brand}/${androidInfo.product}), '
            'OS: Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), '
            'Arch: ${androidInfo.supportedAbis.join(",")}, '
            'Physical: ${androidInfo.isPhysicalDevice}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceStr =
            'Device: ${iosInfo.name} (${iosInfo.model} / ${iosInfo.utsname.machine}), '
            'OS: ${iosInfo.systemName} ${iosInfo.systemVersion}, '
            'Physical: ${iosInfo.isPhysicalDevice}';
      } else if (Platform.isWindows) {
        final winInfo = await deviceInfoPlugin.windowsInfo;
        deviceStr =
            'Device: ${winInfo.computerName}, '
            'OS: Windows (Build ${winInfo.buildNumber}, Major ${winInfo.majorVersion}.${winInfo.minorVersion}), '
            'Cores: ${winInfo.numberOfCores}, Memory: ${winInfo.systemMemoryInMegabytes} MB';
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfoPlugin.macOsInfo;
        deviceStr =
            'Device: ${macInfo.computerName} (${macInfo.model}), '
            'OS: macOS ${macInfo.majorVersion}.${macInfo.minorVersion}.${macInfo.patchVersion} (${macInfo.osRelease}), '
            'Arch: ${macInfo.arch}, Cores: ${macInfo.activeCPUs}, Memory: ${(macInfo.memorySize / (1024 * 1024)).round()} MB';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfoPlugin.linuxInfo;
        deviceStr =
            'Device: ${linuxInfo.name}, '
            'OS: ${linuxInfo.prettyName} (${linuxInfo.versionId ?? "unknown"})';
      } else {
        deviceStr =
            'OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
      }

      log('=== App Info: $appInfoStr ===', mirrorToConsole: true);
      log('=== Device Info: $deviceStr ===', mirrorToConsole: true);
    } catch (e, st) {
      log(
        'Failed to retrieve device/package info: $e',
        mirrorToConsole: true,
        stackTrace: st,
      );
    }
  }

  static void install() {
    if (_installed) {
      return;
    }
    _installed = true;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message == null) {
        _defaultDebugPrint(message, wrapWidth: wrapWidth);
        return;
      }
      log(message, mirrorToConsole: true);
    };
  }

  static void log(
    Object message, {
    bool mirrorToConsole = false,
    StackTrace? stackTrace,
  }) {
    final text = message.toString();
    final buffer = StringBuffer()
      ..write('[${DateTime.now().toIso8601String()}] ')
      ..writeln(text);
    if (stackTrace != null) {
      buffer.writeln(stackTrace);
    }
    final payload = buffer.toString();

    if (mirrorToConsole) {
      _defaultDebugPrint(text);
      if (stackTrace != null) {
        _defaultDebugPrint(stackTrace.toString());
      }
    }

    final sink = _sink;
    if (sink == null) {
      return;
    }

    _writeQueue = _writeQueue.then((_) async {
      sink.write(payload);
      await sink.flush();
    }).catchError((_) {});
  }

  static Future<void> flush() async {
    await _writeQueue;
    await _sink?.flush();
  }
}
