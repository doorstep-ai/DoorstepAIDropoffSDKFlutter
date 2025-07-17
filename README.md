# DoorstepAI Dropoff SDK for Flutter

The `doorstepai_dropoff_sdk` package provides Flutter bindings to DoorstepAI's Dropoff SDK, enabling delivery tracking functionality through method channels and native platform integration.

## 📦 Installation

Add the SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  doorstepai_dropoff_sdk: ^1.0.0
  permission_handler: ^10.0.0  # Required for Android permissions
```

Then run:

```bash
flutter pub get
```

---

## 🔌 Imports

In your Dart code, import the SDK:

```dart
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';
```

---

## 🗺️ AddressType

A helper class to represent a structured address for deliveries:

```dart
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
```

---

## 🚚 DoorstepAI API

All calls go through a `MethodChannel('doorstepai_dropoff_sdk')`. Be sure to await each call and wrap in `try/catch`.

### `init` (Android Only)

Initializes the native SDK on Android. This is automatically called by `DoorstepAiView`, so you typically don't need to call this directly.

```dart
/// Android only: call once before any other API methods
await DoorstepAI.init(
  notificationTitle: 'Delivery in progress',  // optional
  notificationText: 'Tap to return to the app', // optional
);
```

### `setApiKey`

Set your DoorstepAI API key. This should be called after initialization. Again, you typically don't need to call this directly.

```dart
await DoorstepAI.setApiKey('YOUR_API_KEY');
```

### `startDeliveryByPlaceID`

Begin a delivery session using a Google Place ID:

```dart
await DoorstepAI.startDeliveryByPlaceID(
  placeID: 'destination_place_id',
  deliveryId: 'unique_delivery_id',
);
```

### `startDeliveryByPlusCode`

Begin a delivery via Google Plus Code:

```dart
await DoorstepAI.startDeliveryByPlusCode(
  plusCode: 'destination_plus_code',
  deliveryId: 'unique_delivery_id',
);
```

### `startDeliveryByAddress`

Begin a delivery with a structured address:

```dart
final address = AddressType(
  streetNumber: '123',
  route: 'Main St',
  subPremise: 'Apt 4B',
  locality: 'New York',
  administrativeAreaLevel1: 'NY',
  postalCode: '10001',
);
await DoorstepAI.startDeliveryByAddress(
  address: address,
  deliveryId: 'unique_delivery_id',
);
```

### `newEvent`

Send a delivery event (`taking_pod`, `pod_captured`, etc.):

```dart
await DoorstepAI.newEvent(
  eventName: 'taking_pod',
  deliveryId: 'unique_delivery_id',
);
```

### `stopDelivery`

End the delivery session:

```dart
await DoorstepAI.stopDelivery(
  deliveryId: 'unique_delivery_id',
);
```

---

## 📱 UI Component: `DoorstepAiView`

The `DoorstepAiView` widget automatically handles SDK initialization, API key setting, and permission requests. It renders an invisible view on iOS (height: 0) and shows nothing on other platforms.

```dart
import 'package:flutter/material.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';

class DeliveryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your delivery UI components here
          Expanded(
            child: Center(
              child: Text('Delivery Tracking Active'),
            ),
          ),
          // DoorstepAiView handles initialization automatically
          DoorstepAiView(
            apiKey: 'YOUR_API_KEY',
            notificationTitle: 'Tracking Delivery',
            notificationText: 'Tap to return'
          ),
        ],
      ),
    );
  }
}
```

### What DoorstepAiView Does Automatically:

1. **Initialization**: Calls `DoorstepAI.init()` on Android
2. **API Key Setting**: Calls `DoorstepAI.setApiKey()` with the provided key
3. **Permission Handling**: Requests location and activity recognition permissions on Android
4. **Platform Support**: Renders appropriately for each platform (invisible on iOS, placeholder on others)

---

## ✅ Best Practices

- Include `DoorstepAiView` in your app to handle automatic initialization
- Wrap all SDK calls in `try/catch` for robust error handling
- Keep your `deliveryId` unique per session
- Securely store your API key; don't hardcode it in production
- Use the same `deliveryId` for all operations within a single delivery session

---

## 🔧 Platform-Specific Setup

### Android

Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-feature android:name="android.hardware.sensor.accelerometer" />
    <uses-feature android:name="android.hardware.sensor.gyroscope" />
    <uses-feature android:name="android.hardware.sensor.barometer" />
    <uses-feature android:name="android.hardware.sensor.compass" />
    <uses-feature android:name="android.hardware.sensor.proximity" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

### iOS

Add usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track deliveries</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track deliveries</string>
<key>NSMotionUsageDescription</key>
<string>This app needs motion access to track delivery activity</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs background location access to track deliveries even when the app is not in use</string>
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>

```

---

## 🧪 Debugging

- Check your debug console for errors printed by `catch` blocks
- On Android, verify notification permissions and channel configuration
- On iOS, confirm your `UiKitView` registration (`'DoorstepAIRootView'`) in AppDelegate
- Use the example app in the `example/` directory to test functionality

---

## 📋 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';

class DeliveryApp extends StatefulWidget {
  @override
  _DeliveryAppState createState() => _DeliveryAppState();
}

class _DeliveryAppState extends State<DeliveryApp> {
  String? _currentDeliveryId;

  Future<void> _startDelivery() async {
    try {
      final deliveryId = 'delivery_${DateTime.now().millisecondsSinceEpoch}';
      
      await DoorstepAI.startDeliveryByAddress(
        address: AddressType(
          streetNumber: '123',
          route: 'Main St',
          locality: 'New York',
          administrativeAreaLevel1: 'NY',
          postalCode: '10001',
        ),
        deliveryId: deliveryId,
      );
      
      setState(() {
        _currentDeliveryId = deliveryId;
      });
    } catch (e) {
      print('Error starting delivery: $e');
    }
  }

  Future<void> _stopDelivery() async {
    if (_currentDeliveryId != null) {
      try {
        await DoorstepAI.stopDelivery(deliveryId: _currentDeliveryId!);
        setState(() {
          _currentDeliveryId = null;
        });
      } catch (e) {
        print('Error stopping delivery: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Delivery Tracker')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: _startDelivery,
              child: Text('Start Delivery'),
            ),
            if (_currentDeliveryId != null) ...[
              ElevatedButton(
                onPressed: _stopDelivery,
                child: Text('Stop Delivery'),
              ),
              Text('Active: $_currentDeliveryId'),
            ],
            // Automatic initialization and setup
            DoorstepAiView(
              apiKey: 'YOUR_API_KEY',
              notificationTitle: 'Delivery Update',
              notificationText: 'Your driver is approaching',
            ),
          ],
        ),
      ),
    );
  }
}
```
