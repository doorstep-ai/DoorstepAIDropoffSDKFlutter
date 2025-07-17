package ai.doorstep.com.doorstepai_dropoff_sdk

import android.content.Context // Import Context
import androidx.annotation.NonNull
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch

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
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "init" -> {
        val notificationTitle = call.argument<String>("notificationTitle")
        val notificationText = call.argument<String>("notificationText")



        try {
          if (notificationTitle != null && notificationText != null && this.context != null) {
            DoorstepAI.init(this.context!!, notificationTitle, notificationText) { sdkResult ->
              sdkResult.onSuccess {
                result.success(true)
              }.onFailure { error ->
                result.error("INIT_ERROR", error.message ?: "Failed to initialize DoorstepAI", null)
              }
            }
          } else {
            result.error("BAD_ARGS", "notificationTitle, notificationText, or context missing", null)
          }
        } catch (e: Exception) {
          result.error("INIT_ERROR", e.message ?: "Failed to initialize DoorstepAI", null)
        }
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
        try {
          DoorstepAI.startDeliveryByPlaceID(placeID, deliveryId) { sdkResult ->
            sdkResult.onSuccess { sessionId ->
              result.success(sessionId)
            }.onFailure { error ->
              result.error("DELIVERY_ERROR", error.message ?: "Failed to start delivery by Place ID", null)
            }
          }
        } catch (e: Exception) {
          result.error("DELIVERY_ERROR", e.message ?: "Failed to start delivery by Place ID", null)
        }
      }

      "startDeliveryByPlusCode" -> {
        val plusCode = call.argument<String>("plusCode")
        val deliveryId = call.argument<String>("deliveryId")
        if (plusCode == null || deliveryId == null) {
          return result.error("BAD_ARGS", "plusCode or deliveryId missing", null)
        }
        try {
          DoorstepAI.startDeliveryByPlusCode(plusCode, deliveryId) { sdkResult ->
            sdkResult.onSuccess { sessionId ->
              result.success(sessionId)
            }.onFailure { error ->
              result.error("DELIVERY_ERROR", error.message ?: "Failed to start delivery by Plus Code", null)
            }
          }
        } catch (e: Exception) {
          result.error("DELIVERY_ERROR", e.message ?: "Failed to start delivery by Plus Code", null)
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
        
        try {
          val addressType = AddressType(
            streetNumber = addr["streetNumber"]!!,
            route = addr["route"]!!,
            subPremise = addr["subPremise"] ?: "",
            locality = addr["locality"]!!,
            administrativeAreaLevel1 = addr["administrativeAreaLevel1"]!!,
            postalCode = addr["postalCode"]!!
          )
          
          DoorstepAI.startDeliveryByAddressType(addressType, deliveryId) { sdkResult ->
            sdkResult.onSuccess { sessionId ->
              result.success(sessionId)
            }.onFailure { error ->
              result.error("DELIVERY_ERROR", error.message ?: "Failed to start delivery by address", null)
            }
          }
        } catch (e: Exception) {
          result.error("DELIVERY_ERROR", e.message ?: "Failed to start delivery by address", null)
        }
      }

      "newEvent" -> {
        val eventName = call.argument<String>("eventName")
        val deliveryId = call.argument<String>("deliveryId")
        if (eventName == null || deliveryId == null) {
          return result.error("BAD_ARGS", "eventName or deliveryId missing", null)
        }
        try {
          DoorstepAI.newEvent(eventName, deliveryId) { /* Callback might not be invoked or provide useful data */ }
          result.success("Event $eventName triggered for $deliveryId")
        } catch (e: Exception) {
          result.error("EVENT_CREATION_ERROR", e.message ?: "Failed to save event", null)
        }
      }

      "stopDelivery" -> {
        val deliveryId = call.argument<String>("deliveryId")
        if (deliveryId == null) {
          return result.error("BAD_ARGS", "deliveryId missing", null)
        }
        try {
          DoorstepAI.stopDelivery(deliveryId)
          result.success(true)
        } catch (e: Exception) {
          result.error("DELIVERY_STOP_ERROR", e.message ?: "Failed to stop delivery", null)
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
