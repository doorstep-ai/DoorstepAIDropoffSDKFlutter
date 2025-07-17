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
    super.key,
    required this.apiKey,
    this.notificationTitle,
    this.notificationText
  });

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

    
    // Initialize SDK first
    await DoorstepAI.init(
      notificationTitle: widget.notificationTitle,
      notificationText: widget.notificationText,
    ).then((value) {
      print("initialized DoorstepAiView");
    }).catchError((error) {
      print("error initializing DoorstepAiView: $error");
    });

    print("setting api key: ${widget.apiKey}");
    
    // Set API key after initialization
    await DoorstepAI.setApiKey(widget.apiKey);

    // Request permissions on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final permissions = {
        Permission.location: 'Location',
        Permission.activityRecognition: 'Activity Recognition',
      };

      debugPrint('Checking Android permission statuses...');
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        final status = await permission.status;
        debugPrint('- $name status: $status');
      }

      debugPrint('Requesting Android permissions sequentially...');
      // final results = await Future.wait(
      //   permissions.keys.map((permission) => permission.request()),
      // );

      // Request permissions sequentially
      Map<Permission, PermissionStatus> results = {};
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        debugPrint('Requesting $name...');
        final status = await permission.request();
        results[permission] = status;
        debugPrint('- $name requested, status: $status');
      }

      // Re-check status after request
      debugPrint('Permission statuses after sequential request:');
      // int index = 0;
      for (var entry in permissions.entries) {
        final permission = entry.key;
        final name = entry.value;
        final status = results[permission]; // Use the results map
        debugPrint('- $name status: $status');
        // index++;
      }

      if (results.values.every((status) => status.isGranted)) {
        debugPrint('Required Android permissions granted');
      } else {
        debugPrint('One or more required Android permissions denied');
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('iOS: Ensure location and motion usage descriptions are in Info.plist');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only supported on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const SizedBox(
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
