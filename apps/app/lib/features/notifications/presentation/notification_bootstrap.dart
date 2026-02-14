import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/fcm_device_token_registrar.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
}

final notificationBootstrapProvider = Provider<NotificationBootstrap>((ref) {
  return NotificationBootstrap(
    registrar: ref.read(fcmDeviceTokenRegistrarProvider),
  );
});

class NotificationBootstrap {
  NotificationBootstrap({required FcmDeviceTokenRegistrar registrar})
    : _registrar = registrar;

  final FcmDeviceTokenRegistrar _registrar;

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp();
      } catch (error) {
        debugPrint('Firebase initializeApp failed: $error');
        return;
      }
    }

    try {
      await Permission.notification.request();
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    NotificationSettings settings;
    try {
      settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      debugPrint('Firebase messaging permission failed: $error');
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    String? token;
    try {
      token = await messaging.getToken();
    } catch (error) {
      debugPrint('FCM getToken failed: $error');
    }
    if (token != null && token.isNotEmpty) {
      try {
        await _registrar.registerToken(token);
      } catch (error) {
        debugPrint('FCM token registrar failed: $error');
      }
    }

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground push received: ${message.messageId}');
    }, onError: (Object error) {
      debugPrint('Foreground push stream error: $error');
    });
  }
}
