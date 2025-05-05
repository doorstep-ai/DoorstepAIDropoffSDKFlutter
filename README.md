# DoorstepAI Dropoff SDK for Flutter

The `doorstepai_dropoff_sdk` package provides Flutter bindings to DoorstepAI’s Dropoff SDK, mirroring the underlying platform functionality via method channels and a native UIKit view on iOS.

## 📦 Installation

Add the SDK to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  doorstepai_dropoff_sdk: ^1.0.0
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

### `init`

Initializes the native SDK on Android. iOS does not require explicit initialization. Note: This initialization is handled automatically when using the `DoorstepAiView` widget, so you typically don't need to call this directly.

```dart
/// Android only: call once before any other API methods
await DoorstepAI.init(
  notificationTitle: 'Delivery in progress',  // optional
  notificationText: 'Tap to return to the app', // optional
);
```

### `setApiKey`

Set your DoorstepAI API key. This should be called within the Root component of your app:


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

On iOS, renders the native SwiftUI DoorstepAIRoot view. On Android and other platforms, shows a placeholder.

```dart
import 'package:flutter/material.dart';
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';

class DeliveryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DoorstepAiView(
          apiKey: 'YOUR_API_KEY',
          notificationTitle: 'Tracking Delivery',
          notificationText: 'Tap to return'
        ),
      ),
    );
  }
}
```

### Permissions

- **Android**: `init()` will prompt for `location` and `activityRecognition` via `permission_handler`.
- **iOS**: Ensure you’ve added usage descriptions for location and motion in `Info.plist`.

---

## ✅ Best Practices

- Call `init` once on Android before other methods.
- Wrap all SDK calls in `try/catch` for robust error handling.
- Keep your `deliveryId` unique per session.
- Securely store your API key; don’t hardcode it in production.

---

## 🧪 Debugging

- Check your debug console for errors printed by `catch` blocks.
- On Android, verify notification permissions and channel configuration.
- On iOS, confirm your `UiKitView` registration (`'DoorstepAIRootView'`) in AppDelegate.
