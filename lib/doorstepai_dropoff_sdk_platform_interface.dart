import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'doorstepai_dropoff_sdk_method_channel.dart';

abstract class DoorstepaiDropoffSdkPlatform extends PlatformInterface {
  /// Constructs a DoorstepaiDropoffSdkPlatform.
  DoorstepaiDropoffSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static DoorstepaiDropoffSdkPlatform _instance = MethodChannelDoorstepaiDropoffSdk();

  /// The default instance of [DoorstepaiDropoffSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelDoorstepaiDropoffSdk].
  static DoorstepaiDropoffSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DoorstepaiDropoffSdkPlatform] when
  /// they register themselves.
  static set instance(DoorstepaiDropoffSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
