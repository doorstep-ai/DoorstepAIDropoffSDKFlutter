import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelDoorstepaiDropoffSdk platform = MethodChannelDoorstepaiDropoffSdk();
  const MethodChannel channel = MethodChannel('doorstepai_dropoff_sdk');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
