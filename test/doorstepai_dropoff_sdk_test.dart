import 'package:flutter_test/flutter_test.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk_platform_interface.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDoorstepaiDropoffSdkPlatform
    with MockPlatformInterfaceMixin
    implements DoorstepaiDropoffSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DoorstepaiDropoffSdkPlatform initialPlatform = DoorstepaiDropoffSdkPlatform.instance;

  test('$MethodChannelDoorstepaiDropoffSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDoorstepaiDropoffSdk>());
  });

  test('getPlatformVersion', () async {
    DoorstepaiDropoffSdk doorstepaiDropoffSdkPlugin = DoorstepaiDropoffSdk();
    MockDoorstepaiDropoffSdkPlatform fakePlatform = MockDoorstepaiDropoffSdkPlatform();
    DoorstepaiDropoffSdkPlatform.instance = fakePlatform;

    expect(await doorstepaiDropoffSdkPlugin.getPlatformVersion(), '42');
  });
}
