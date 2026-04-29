import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class VersionCheckService {
  static const String currentVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: 'dev');

  static const Duration _checkInterval = Duration(minutes: 5);

  final ValueNotifier<bool> updateAvailable = ValueNotifier(false);

  Timer? _timer;
  DateTime? _snoozeUntil;

  void start() {
    if (!kIsWeb) return;
    if (currentVersion == 'dev') return;

    _check();
    _timer = Timer.periodic(_checkInterval, (_) => _check());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void snooze() {
    _snoozeUntil = DateTime.now().add(const Duration(minutes: 30));
    updateAvailable.value = false;
  }

  Future<void> _check() async {
    if (_snoozeUntil != null && DateTime.now().isBefore(_snoozeUntil!)) {
      return;
    }

    try {
      final url = 'build_info.json?t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final serverVersion = data['version'] as String;

      debugPrint('[VersionCheck] Aktuell: $currentVersion, Server: $serverVersion');

      if (serverVersion != currentVersion) {
        updateAvailable.value = true;
      }
    } catch (e) {
      debugPrint('Version check failed: $e');
    }
  }

Future<void> reloadAndUpdate() async {
  if (!kIsWeb) return;
  
  // Vorsichtshalber nochmal aufräumen, falls doch was registriert wurde
  await cleanupServiceWorkers();
  
  // Hard reload mit Cache-Buster
  final base = web.window.location.origin + web.window.location.pathname;
  web.window.location.replace('$base?_v=${DateTime.now().millisecondsSinceEpoch}');
}

Future<Map<String, dynamic>> diagnose() async {
  final result = <String, dynamic>{};
  
  result['currentVersion'] = currentVersion;
  result['kIsWeb'] = kIsWeb;
  
  if (!kIsWeb) {
    result['error'] = 'Not running on web';
    return result;
  }
  
  // Server build_info.json
  try {
    final url = 'build_info.json?t=${DateTime.now().millisecondsSinceEpoch}';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Cache-Control': 'no-cache'},
    );
    result['serverVersionStatus'] = response.statusCode;
    result['serverVersionBody'] = response.body;
    result['serverVersionCacheControl'] = 
        response.headers['cache-control'] ?? '(none)';
  } catch (e) {
    result['serverVersionError'] = e.toString();
  }
  
  // Service Worker Headers
  try {
    final url = 'flutter_service_worker.js?t=${DateTime.now().millisecondsSinceEpoch}';
    final response = await http.get(Uri.parse(url));
    result['swStatus'] = response.statusCode;
    result['swCacheControl'] = response.headers['cache-control'] ?? '(none)';
    result['swBodyLength'] = response.body.length;
  } catch (e) {
    result['swHeaderError'] = e.toString();
  }
  
  // Service Worker Registrations
  try {
    final regs = (await web.window.navigator.serviceWorker
        .getRegistrations()
        .toDart).toDart;
    result['serviceWorkerCount'] = regs.length;
    result['serviceWorkers'] = regs
        .map((r) => r.active?.scriptURL ?? 'inactive')
        .toList();
  } catch (e) {
    result['swError'] = e.toString();
  }
  
  // Caches
  try {
    final cacheNames = (await web.window.caches.keys().toDart).toDart;
    result['cacheCount'] = cacheNames.length;
    result['cacheNames'] = cacheNames.map((n) => n.toDart).toList();
  } catch (e) {
    result['cacheError'] = e.toString();
  }
  
  // Display Mode
  result['displayMode'] = _detectDisplayMode();
  
  // User Agent (gekürzt)
  try {
    final ua = web.window.navigator.userAgent;
    result['userAgent'] = ua.length > 200 ? ua.substring(0, 200) : ua;
  } catch (e) {
    result['uaError'] = e.toString();
  }
  
  return result;
}

String _detectDisplayMode() {
  try {
    if (web.window.matchMedia('(display-mode: standalone)').matches) {
      return 'standalone (PWA)';
    }
    if (web.window.matchMedia('(display-mode: minimal-ui)').matches) {
      return 'minimal-ui';
    }
    if (web.window.matchMedia('(display-mode: fullscreen)').matches) {
      return 'fullscreen';
    }
    return 'browser';
  } catch (e) {
    return 'unknown';
  }
}

/// Räumt alte Service Worker und Caches auf.
/// Sollte bei jedem App-Start aufgerufen werden.
Future<void> cleanupServiceWorkers() async {
  if (!kIsWeb) return;
  
  try {
    final regs = (await web.window.navigator.serviceWorker
        .getRegistrations().toDart).toDart;
    for (final reg in regs) {
      await reg.unregister().toDart;
      debugPrint('[VersionCheck] SW deregistriert: ${reg.scope}');
    }
    
    final cacheNames = (await web.window.caches.keys().toDart).toDart;
    for (final name in cacheNames) {
      await web.window.caches.delete(name.toDart).toDart;
      debugPrint('[VersionCheck] Cache gelöscht: ${name.toDart}');
    }
  } catch (e) {
    debugPrint('[VersionCheck] Cleanup-Fehler: $e');
  }
}

}