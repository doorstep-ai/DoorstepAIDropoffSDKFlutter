import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Your plugin's Dart API:
import 'package:doorstepai_dropoff_sdk/doorstepai_dropoff_sdk.dart';
// The SwiftUI‐in‐Flutter view:
import 'package:doorstepai_dropoff_sdk/doorstep_ai_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Store the API key for reuse
  final String _apiKey = 'some_api_key';
  String? _currentDeliveryId;

  @override
  void initState() {
    super.initState();
    // Initialization and API key setting are handled by DoorstepAiView
    // DoorstepAI.setApiKey(_apiKey);
    // print("api key init"); // Removed redundant call
  }

  Future<void> _startDelivery() async {
    try {
      // Example: start by PlaceID — swap in your own ID or call the
      // other methods (ByPlusCode or ByAddress) as needed.
      const deliveryId = "1234567890"; // Example delivery ID
      await DoorstepAI.startDeliveryByPlaceID(
        placeID: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
        deliveryId: deliveryId,
      );
      setState(() {
        _currentDeliveryId = deliveryId;
      });
      print('Started delivery with ID: $deliveryId');
    } on PlatformException catch (e) {
      debugPrint('Start delivery error: ${e.message}');
    }
  }

  Future<void> _stopDelivery() async {
    if (_currentDeliveryId == null) {
      print('No active delivery to stop.');
      return;
    }
    try {
      await DoorstepAI.stopDelivery(deliveryId: _currentDeliveryId!);
      print('Stopped delivery with ID: $_currentDeliveryId');
      setState(() {
        _currentDeliveryId = null;
      });
    } on PlatformException catch (e) {
      debugPrint('Stop delivery error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DoorstepAI Demo'),
        ),
        body: Column(
          children: [
            DoorstepAiView(apiKey: _apiKey, notificationTitle: "Delivery Update", notificationText: "Your driver is approaching."), // Pass the API key here

            const Spacer(),

            // Control buttons:
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _startDelivery,
                    child: const Text('Start Delivery'),
                  ),
                  ElevatedButton(
                    onPressed: _stopDelivery,
                    child: const Text('Stop Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
