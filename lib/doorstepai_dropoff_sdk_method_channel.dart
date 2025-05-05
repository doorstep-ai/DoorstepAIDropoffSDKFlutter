import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'doorstepai_dropoff_sdk_platform_interface.dart';

/// An implementation of [DoorstepaiDropoffSdkPlatform] that uses method channels.
class MethodChannelDoorstepaiDropoffSdk extends DoorstepaiDropoffSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('doorstepai_dropoff_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
