package ai.doorstep.com.doorstepai_dropoff_sdk

import android.content.Context // Import Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Added imports for DoorstepAI SDK
import com.doorstepai.sdks.tracking.DoorstepAI
import com.doorstepai.sdks.tracking.AddressType

/** DoorstepaiDropoffSdkPlugin */
class DoorstepaiDropoffSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context: Context? = null // Store context as member variable

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    this.context = flutterPluginBinding.applicationContext // Initialize context
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "doorstepai_dropoff_sdk")
    channel.setMethodCallHandler(this)

    /*DoorstepAI.init(context) { result -> // Use context variable
      if (result.isSuccess) {
        android.util.Log.d("DoorstepAI", "SDK initialized successfully")
        // no-op
      } else {
        android.util.Log.d("DoorstepAI", "SDK init fail")
      }
    }*/
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "init" -> {
        // Android initialization happens in onAttachedToEngine via DoorstepAI.init(context)
        // This handler is mainly here to acknowledge the call from Flutter
        // We can potentially pass notification settings here if the native SDK supports updating them later
        // For now, just acknowledge the call.
        android.util.Log.d("DoorstepAI", "Received init call from Flutter.")
        // Optionally handle notificationTitle/notificationText if needed
        val title = call.argument<String>("notificationTitle")
        val text = call.argument<String>("notificationText")
        if (title != null && text != null && this.context != null) { // Check if context is not null
            DoorstepAI.init(this.context!!, title, text) { sdkResult -> // Use stored context
                if (sdkResult.isSuccess) {
                    android.util.Log.d("DoorstepAI", "SDK initialized with notifications successfully")
                } else {
                    android.util.Log.d("DoorstepAI", "SDK init with notifications failed")
                }
            }
        }
        result.success(null) // Indicate success back to Flutter
      }
      "getPlatformVersion" -> {
         result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "setApiKey" -> {
        val key = call.argument<String>("key")
        if (key == null) {
          return result.error("BAD_ARGS", "key missing", null)
        }
        try {
          DoorstepAI.setAPIKey(key)
          result.success(null)
        } catch (e: Exception) {
          result.error("SDK_ERR", e.localizedMessage, null)
        }
      }

      "startDeliveryByPlaceID" -> {
        val placeID = call.argument<String>("placeID")
        val deliveryId = call.argument<String>("deliveryId")
        if (placeID == null || deliveryId == null) {
          return result.error("BAD_ARGS", "placeID or deliveryId missing", null)
        }
        DoorstepAI.startDeliveryByPlaceID(placeID, deliveryId) { sdkResult ->
          if (sdkResult.isSuccess) {
            result.success(sdkResult.getOrNull())
          } else {
            result.error("DELIVERY_ERR", sdkResult.exceptionOrNull()?.localizedMessage, null)
          }
        }
      }

      "startDeliveryByPlusCode" -> {
        val plusCode = call.argument<String>("plusCode")
        val deliveryId = call.argument<String>("deliveryId")
        if (plusCode == null || deliveryId == null) {
          return result.error("BAD_ARGS", "plusCode or deliveryId missing", null)
        }
        DoorstepAI.startDeliveryByPlusCode(plusCode, deliveryId) { sdkResult ->
          if (sdkResult.isSuccess) {
            result.success(sdkResult.getOrNull())
          } else {
            result.error("DELIVERY_ERR", sdkResult.exceptionOrNull()?.localizedMessage, null)
          }
        }
      }

      "startDeliveryByAddress" -> {
        val addr = call.argument<Map<String, String>>("address")
        val deliveryId = call.argument<String>("deliveryId")
        if (addr == null
            || deliveryId == null
            || !addr.containsKey("streetNumber")
            || !addr.containsKey("route")
            || !addr.containsKey("locality")
            || !addr.containsKey("administrativeAreaLevel1")
            || !addr.containsKey("postalCode")
        ) {
          return result.error("BAD_ARGS", "address map missing fields or deliveryId missing", null)
        }
        val addressType = AddressType(
          streetNumber = addr["streetNumber"]!!,
          route = addr["route"]!!,
          subPremise = addr["subPremise"] ?: "",
          locality = addr["locality"]!!,
          administrativeAreaLevel1 = addr["administrativeAreaLevel1"]!!,
          postalCode = addr["postalCode"]!!
        )
        DoorstepAI.startDeliveryByAddressType(addressType, deliveryId) { sdkResult ->
          if (sdkResult.isSuccess) {
            result.success(sdkResult.getOrNull())
          } else {
            result.error("DELIVERY_ERR", sdkResult.exceptionOrNull()?.localizedMessage, null)
          }
        }
      }

      "newEvent" -> {
        val eventName = call.argument<String>("eventName")
        val deliveryId = call.argument<String>("deliveryId")
        if (eventName == null || deliveryId == null) {
          return result.error("BAD_ARGS", "eventName or deliveryId missing", null)
        }
        try {
          DoorstepAI.newEvent(eventName, deliveryId) { sdkResult ->
            if (sdkResult.isSuccess) {
              result.success(sdkResult.getOrNull())
            } else {
              result.error("EVENT_ERR", sdkResult.exceptionOrNull()?.localizedMessage, null)
            }
          }
        } catch (e: Exception) {
          result.error("EVENT_ERR", e.localizedMessage, null)
        }
      }

      "stopDelivery" -> {
        val deliveryId = call.argument<String>("deliveryId")
        if (deliveryId == null) {
          return result.error("BAD_ARGS", "deliveryId missing", null)
        }
        try {
          DoorstepAI.stopDelivery(deliveryId)
          result.success(null)
        } catch (e: Exception) {
          result.error("STOP_ERR", e.localizedMessage, null)
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    this.context = null // Clean up context
  }
}
