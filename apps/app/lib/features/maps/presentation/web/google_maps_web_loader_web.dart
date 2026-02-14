import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

class GoogleMapsWebLoader {
  static Future<void>? _inFlightLoad;
  static String? _loadedApiKey;

  static Future<void> ensureLoaded({
    required String apiKey,
    required String language,
    required String region,
  }) {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      return Future<void>.error(
        StateError('Google Maps API key is missing for web renderer.'),
      );
    }

    if (_isGoogleMapsReady() && _loadedApiKey == trimmedKey) {
      return Future<void>.value();
    }

    if (_inFlightLoad != null && _loadedApiKey == trimmedKey) {
      return _inFlightLoad!;
    }

    final completer = Completer<void>();
    _loadedApiKey = trimmedKey;

    if (_isGoogleMapsReady()) {
      completer.complete();
      _inFlightLoad = completer.future;
      return _inFlightLoad!;
    }

    final callbackName =
        '__rideIqGoogleMapsReady${DateTime.now().millisecondsSinceEpoch}';
    void clearCallback() {
      globalContext.delete(callbackName.toJS);
    }

    globalContext[callbackName] = (() {
      clearCallback();
      if (!completer.isCompleted) {
        completer.complete();
      }
    }).toJS;

    final existingScript = web.document.querySelector(
      'script[data-rideiq-google-maps="1"]',
    );
    existingScript?.remove();

    final script = web.document.createElement('script') as web.HTMLScriptElement
      ..async = true
      ..defer = true
      ..src =
          'https://maps.googleapis.com/maps/api/js?${Uri(queryParameters: <String, String>{'key': trimmedKey, 'v': 'weekly', 'loading': 'async', 'language': language, 'region': region, 'callback': callbackName}).query}';
    script.setAttribute('data-rideiq-google-maps', '1');
    script.addEventListener(
      'error',
      ((web.Event _) {
        clearCallback();
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Failed to load Google Maps JavaScript SDK.'),
          );
        }
      }).toJS,
    );

    final head = web.document.head;
    if (head == null) {
      clearCallback();
      completer.completeError(
        StateError('Document head is not available on web.'),
      );
    } else {
      head.appendChild(script);
    }

    _inFlightLoad = completer.future
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            clearCallback();
            throw TimeoutException('Timed out while loading Google Maps SDK.');
          },
        )
        .whenComplete(() {
          _inFlightLoad = null;
        });

    return _inFlightLoad!;
  }

  static bool _isGoogleMapsReady() {
    final google = globalContext.getProperty('google'.toJS);
    if (google == null) {
      return false;
    }
    try {
      final maps = (google as JSObject).getProperty('maps'.toJS);
      if (maps == null) {
        return false;
      }
      final mapTypeId = (maps as JSObject).getProperty('MapTypeId'.toJS);
      return mapTypeId != null;
    } catch (_) {
      return false;
    }
  }
}
