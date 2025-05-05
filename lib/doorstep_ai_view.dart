// lib/doorstep_ai_view.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'doorstepai_dropoff_sdk.dart';

/// A Flutter wrapper for the iOS SwiftUI DoorstepAIRoot view.
///
/// On iOS it renders the native view; on other platforms it shows a placeholder.
class DoorstepAiView extends StatefulWidget {
  /// API key for DoorstepAI
  final String apiKey;
  
  /// Optional notification title for Android
  final String? notificationTitle;
  
  /// Optional notification text for Android
  final String? notificationText;

  const DoorstepAiView({
    Key? key,
    required this.apiKey,
    this.notificationTitle,
    this.notificationText
  }) : super(key: key);

  @override
  State<DoorstepAiView> createState() => _DoorstepAiViewState();
}

class _DoorstepAiViewState extends State<DoorstepAiView> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize SDK
    await DoorstepAI.init(
      notificationTitle: widget.notificationTitle,
      notificationText: widget.notificationText,
    );
    
    // Set API key
    await DoorstepAI.setApiKey(widget.apiKey);

    // Request permissions on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final permissions = {
        Permission.location: 'Location',
        Permission.activityRecognition: 'Activity Recognition',
      };

      print('Checking Android permission statuses...');
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        final status = await permission.status;
        print('- $name status: $status');
      }

      print('Requesting Android permissions sequentially...');
      // final results = await Future.wait(
      //   permissions.keys.map((permission) => permission.request()),
      // );

      // Request permissions sequentially
      Map<Permission, PermissionStatus> results = {};
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        print('Requesting $name...');
        final status = await permission.request();
        results[permission] = status;
        print('- $name requested, status: $status');
      }

      // Re-check status after request
      print('Permission statuses after sequential request:');
      // int index = 0;
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        final status = results[permission]; // Use the results map
        print('- $name status: $status');
        // index++;
      }

      if (results.values.every((status) => status.isGranted)) {
        print('Required Android permissions granted');
      } else {
        print('One or more required Android permissions denied');
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      print('iOS: Ensure location and motion usage descriptions are in Info.plist');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only supported on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: 0,
        child: UiKitView(
          viewType: 'DoorstepAIRootView',
          layoutDirection: TextDirection.ltr,
          creationParams: {},
          creationParamsCodec: StandardMessageCodec(),
        ),
      );
    }

    // Fallback on Android / web / desktop
    return Container(
      height: 0,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const SizedBox(),
    );
  }
}
