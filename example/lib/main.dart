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
  final String _apiKey = 'your_api_key';
  String? _currentDeliveryId;
  
  // Controllers for input fields
  final TextEditingController _deliveryIdController = TextEditingController();
  final TextEditingController _placeIdController = TextEditingController();
  final TextEditingController _plusCodeController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  
  // Address component controllers
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _subPremiseController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _administrativeAreaController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Global key for ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    // Initialization and API key setting are handled by DoorstepAiView
    
    // Set some default values for testing
    _deliveryIdController.text = "test_delivery_${DateTime.now().millisecondsSinceEpoch}";
    _placeIdController.text = 'place_id';
    _plusCodeController.text = 'plus_code';
    _eventNameController.text = 'test_event';
    
    // Default address values
    _streetNumberController.text = '123';
    _routeController.text = 'Main Street';
    _subPremiseController.text = 'Apt 4B';
    _localityController.text = 'San Francisco';
    _administrativeAreaController.text = 'CA';
    _postalCodeController.text = '94102';
  }

  @override
  void dispose() {
    _deliveryIdController.dispose();
    _placeIdController.dispose();
    _plusCodeController.dispose();
    _eventNameController.dispose();
    _streetNumberController.dispose();
    _routeController.dispose();
    _subPremiseController.dispose();
    _localityController.dispose();
    _administrativeAreaController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _startDeliveryByPlaceID() async {
    try {
      final deliveryId = _deliveryIdController.text.isNotEmpty 
          ? _deliveryIdController.text 
          : "delivery_${DateTime.now().millisecondsSinceEpoch}";
      
      await DoorstepAI.startDeliveryByPlaceID(
        placeID: _placeIdController.text,
        deliveryId: deliveryId,
      );
      setState(() {
        _currentDeliveryId = deliveryId;
      });
      _showSnackBar('Started delivery by Place ID: $deliveryId');
      print('Started delivery by Place ID: $deliveryId');
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
      debugPrint('Start delivery by Place ID error: ${e.message}');
    }
  }

  Future<void> _startDeliveryByPlusCode() async {
    try {
      final deliveryId = _deliveryIdController.text.isNotEmpty 
          ? _deliveryIdController.text 
          : "delivery_${DateTime.now().millisecondsSinceEpoch}";
      
      await DoorstepAI.startDeliveryByPlusCode(
        plusCode: _plusCodeController.text,
        deliveryId: deliveryId,
      );
      setState(() {
        _currentDeliveryId = deliveryId;
      });
      _showSnackBar('Started delivery by Plus Code: $deliveryId');
      print('Started delivery by Plus Code: $deliveryId');
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
      debugPrint('Start delivery by Plus Code error: ${e.message}');
    }
  }

  Future<void> _startDeliveryByAddress() async {
    try {
      final deliveryId = _deliveryIdController.text.isNotEmpty 
          ? _deliveryIdController.text 
          : "delivery_${DateTime.now().millisecondsSinceEpoch}";
      
      final address = AddressType(
        streetNumber: _streetNumberController.text,
        route: _routeController.text,
        subPremise: _subPremiseController.text,
        locality: _localityController.text,
        administrativeAreaLevel1: _administrativeAreaController.text,
        postalCode: _postalCodeController.text,
      );
      
      await DoorstepAI.startDeliveryByAddress(
        address: address,
        deliveryId: deliveryId,
      );
      setState(() {
        _currentDeliveryId = deliveryId;
      });
      _showSnackBar('Started delivery by Address: $deliveryId');
      print('Started delivery by Address: $deliveryId');
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
      debugPrint('Start delivery by Address error: ${e.message}');
    }
  }

  Future<void> _sendEvent() async {
    if (_currentDeliveryId == null) {
      _showSnackBar('No active delivery. Start a delivery first.', isError: true);
      return;
    }
    
    try {
      await DoorstepAI.newEvent(
        eventName: _eventNameController.text,
        deliveryId: _currentDeliveryId!,
      );
      _showSnackBar('Event sent: ${_eventNameController.text}');
      print('Event sent: ${_eventNameController.text}');
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
      debugPrint('Send event error: ${e.message}');
    }
  }

  Future<void> _stopDelivery() async {
    if (_currentDeliveryId == null) {
      _showSnackBar('No active delivery to stop.', isError: true);
      return;
    }
    try {
      await DoorstepAI.stopDelivery(deliveryId: _currentDeliveryId!);
      _showSnackBar('Stopped delivery: $_currentDeliveryId');
      print('Stopped delivery with ID: $_currentDeliveryId');
      setState(() {
        _currentDeliveryId = null;
      });
    } on PlatformException catch (e) {
      _showSnackBar('Error: ${e.message}', isError: true);
      debugPrint('Stop delivery error: ${e.message}');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? placeholder,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: placeholder,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('doorstep.ai DropOff SDK Test App'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // SDK Status Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'DoorstepAI SDK ready',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Delivery ID Section
              _buildSection(
                title: 'Delivery ID',
                children: [
                  _buildInputField(
                    label: 'Delivery ID',
                    controller: _deliveryIdController,
                    placeholder: 'Enter Delivery ID',
                  ),
                ],
              ),

              // Start New Delivery Section
              _buildSection(
                title: 'Start New Delivery',
                children: [
                  _buildInputField(
                    label: 'Place ID',
                    controller: _placeIdController,
                    placeholder: 'Enter Google Place ID',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startDeliveryByPlaceID,
                      child: const Text('Start Delivery by Place ID'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Plus Code',
                    controller: _plusCodeController,
                    placeholder: 'Enter Plus Code',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startDeliveryByPlusCode,
                      child: const Text('Start Delivery by Plus Code'),
                    ),
                  ),
                ],
              ),

              // Address Components Section
              _buildSection(
                title: 'Address Components',
                children: [
                  _buildInputField(
                    label: 'Street Number',
                    controller: _streetNumberController,
                    placeholder: 'e.g., 123',
                  ),
                  _buildInputField(
                    label: 'Route',
                    controller: _routeController,
                    placeholder: 'e.g., Main Street',
                  ),
                  _buildInputField(
                    label: 'Sub Premise (Apt/Suite)',
                    controller: _subPremiseController,
                    placeholder: 'e.g., Apt 4B',
                  ),
                  _buildInputField(
                    label: 'Locality (City)',
                    controller: _localityController,
                    placeholder: 'e.g., San Francisco',
                  ),
                  _buildInputField(
                    label: 'Administrative Area (State)',
                    controller: _administrativeAreaController,
                    placeholder: 'e.g., CA',
                  ),
                  _buildInputField(
                    label: 'Postal Code',
                    controller: _postalCodeController,
                    placeholder: 'e.g., 94102',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startDeliveryByAddress,
                      child: const Text('Start Delivery by Address'),
                    ),
                  ),
                ],
              ),

              // Events Section
              _buildSection(
                title: 'Events',
                children: [
                  _buildInputField(
                    label: 'Event Name',
                    controller: _eventNameController,
                    placeholder: 'Enter event name',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendEvent,
                      child: const Text('Send Event'),
                    ),
                  ),
                ],
              ),

              // Control Section
              _buildSection(
                title: 'Delivery Control',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentDeliveryId != null ? _stopDelivery : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Stop Delivery'),
                        ),
                      ),
                    ],
                  ),
                  if (_currentDeliveryId != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Active Delivery: $_currentDeliveryId',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // DoorstepAI View
              Container(
                margin: const EdgeInsets.all(16),
                child: DoorstepAiView(
                  apiKey: _apiKey, 
                  notificationTitle: "Delivery Update", 
                  notificationText: "Your driver is approaching."
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
