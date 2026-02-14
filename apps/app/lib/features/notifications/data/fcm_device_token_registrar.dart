import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';

final fcmDeviceTokenRegistrarProvider = Provider<FcmDeviceTokenRegistrar>((
  ref,
) {
  return FcmDeviceTokenRegistrar(ref);
});

class FcmDeviceTokenRegistrar {
  FcmDeviceTokenRegistrar(this._ref);

  final Ref _ref;

  Future<void> registerToken(String token) async {
    final edge = _ref.read(edgeFunctionsClientProvider);
    final platform = defaultTargetPlatform;

    String platformName;
    switch (platform) {
      case TargetPlatform.iOS:
        platformName = 'ios';
      case TargetPlatform.android:
        platformName = 'android';
      default:
        platformName = 'web';
    }

    await edge.deviceTokenUpsert(token: token, platform: platformName);
  }
}
