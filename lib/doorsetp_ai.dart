import 'package:flutter/services.dart';

class DoorstepAi {
  static const _channel = MethodChannel('doorstep_ai');

  static Future<void> setApiKey(String key) =>
    _channel.invokeMethod('setApiKey', {'key': key});

  static Future<void> startDeliveryByPlaceID(String placeID) =>
    _channel.invokeMethod('startDeliveryByPlaceID', {'placeID': placeID});

  static Future<void> startDeliveryByPlusCode(String plusCode) =>
    _channel.invokeMethod('startDeliveryByPlusCode', {'plusCode': plusCode});

  static Future<void> startDeliveryByAddress({
    required String streetNumber,
    required String route,
    required String locality,
    required String administrativeAreaLevel1,
    required String postalCode,
  }) =>
    _channel.invokeMethod('startDeliveryByAddress', {
      'address': {
        'streetNumber': streetNumber,
        'route': route,
        'locality': locality,
        'administrativeAreaLevel1': administrativeAreaLevel1,
        'postalCode': postalCode,
      }
    });

  static Future<void> newEvent(String eventName) =>
    _channel.invokeMethod('newEvent', {'eventName': eventName});

  static Future<void> stopDelivery() =>
    _channel.invokeMethod('stopDelivery');
}
