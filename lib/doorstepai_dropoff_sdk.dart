import 'doorstepai_dropoff_sdk_platform_interface.dart';

// class DoorstepaiDropoffSdk {
//   Future<String?> getPlatformVersion() {
//     return DoorstepaiDropoffSdkPlatform.instance.getPlatformVersion();
//   }
// }


import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AddressType {
  final String streetNumber;
  final String route;
  final String subPremise;
  final String locality;
  final String administrativeAreaLevel1;
  final String postalCode;

  AddressType({
    required this.streetNumber,
    required this.route,
    this.subPremise = '',
    required this.locality,
    required this.administrativeAreaLevel1,
    required this.postalCode,
  });

  Map<String, String> toMap() {
    return {
      'streetNumber': streetNumber,
      'route': route,
      'subPremise': subPremise,
      'locality': locality,
      'administrativeAreaLevel1': administrativeAreaLevel1,
      'postalCode': postalCode,
    };
  }
}

class DoorstepAI {
  static bool _isInitialized = false;
  static const _channel = MethodChannel('doorstepai_dropoff_sdk');

  static bool get isInitialized => _isInitialized;

  static Future<void> init({
    String? notificationTitle,
    String? notificationText,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_isInitialized) return;
      
      try {
        await _channel.invokeMethod('init', {
          'notificationTitle': notificationTitle,
          'notificationText': notificationText,
        });
        _isInitialized = true;
        print('DoorstepAI initialized with notifications successfully');
      } catch (e) {
        print('Failed to initialize DoorstepAI: $e');
        rethrow;
      }
    }
    // iOS does not require explicit init
  }

  static Future<void> setApiKey(String apiKey) async {
    try {
      await _channel.invokeMethod('setApiKey', {'key': apiKey});
    } catch (e) {
      print('Failed to set API key: $e');
      rethrow;
    }
  }

  static Future<void> startDeliveryByPlaceID({
    required String placeID,
    required String deliveryId,
  }) async {
    try {
      await _channel.invokeMethod('startDeliveryByPlaceID', {
        'placeID': placeID,
        'deliveryId': deliveryId,
      });
    } catch (e) {
      print('Failed to start delivery by Place ID: $e');
      rethrow;
    }
  }

  static Future<void> startDeliveryByPlusCode({
    required String plusCode,
    required String deliveryId,
  }) async {
    try {
      await _channel.invokeMethod('startDeliveryByPlusCode', {
        'plusCode': plusCode,
        'deliveryId': deliveryId,
      });
    } catch (e) {
      print('Failed to start delivery by Plus Code: $e');
      rethrow;
    }
  }

  static Future<void> startDeliveryByAddress({
    required AddressType address,
    required String deliveryId,
  }) async {
    try {
      await _channel.invokeMethod('startDeliveryByAddress', {
        'address': address.toMap(),
        'deliveryId': deliveryId,
      });
    } catch (e) {
      print('Failed to start delivery by Address: $e');
      rethrow;
    }
  }

  static Future<void> newEvent({
    required String eventName,
    required String deliveryId,
  }) async {
    try {
      await _channel.invokeMethod('newEvent', {
        'eventName': eventName,
        'deliveryId': deliveryId,
      });
    } catch (e) {
      print('Failed to send event: $e');
      rethrow;
    }
  }

  static Future<void> stopDelivery({
    required String deliveryId,
  }) async {
    try {
      await _channel.invokeMethod('stopDelivery', {
        'deliveryId': deliveryId,
      });
    } catch (e) {
      print('Failed to stop delivery: $e');
      rethrow;
    }
  }
}
