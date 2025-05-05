import Flutter
import UIKit
import DoorstepDropoffSDK
import CoreLocation

@available(iOS 13.0, *)
public class DoorstepaiDropoffSdkPlugin: NSObject, FlutterPlugin {
  private let channelName = "doorstep_ai"
  private let locationManager = CLLocationManager()
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "doorstepai_dropoff_sdk", binaryMessenger: registrar.messenger())
    let instance = DoorstepaiDropoffSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let factory = DoorstepAIRootFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "DoorstepAIRootView")
  }

   override init() {
        super.init()
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Request authorization
        locationManager.requestAlwaysAuthorization()
        
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      
    case "setApiKey":
      guard let args = call.arguments as? [String: Any],
            let apiKey = args["key"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      }
      DoorstepAI.setApiKey(key: apiKey)
      result(nil)
      
    case "startDeliveryByPlaceID":
      guard let args = call.arguments as? [String: Any],
            let placeID = args["placeID"] as? String,
            let deliveryId = args["deliveryId"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "placeID or deliveryId missing", details: nil))
      }
      Task {
        do {
          try await DoorstepAI.startDeliveryByPlaceID(placeID: placeID, deliveryId: deliveryId)
          result(nil)
        } catch {
          result(FlutterError(code: "DELIVERY_ERR",
                            message: (error as? DoorstepAIError)?.localizedDescription,
                            details: nil))
        }
      }
      
    case "startDeliveryByPlusCode":
      guard let args = call.arguments as? [String: Any],
            let plusCode = args["plusCode"] as? String,
            let deliveryId = args["deliveryId"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "plusCode or deliveryId missing", details: nil))
      }
      Task {
        do {
          try await DoorstepAI.startDeliveryByPlusCode(plusCode: plusCode, deliveryId: deliveryId)
          result(nil)
        } catch {
          result(FlutterError(code: "DELIVERY_ERR",
                            message: (error as? DoorstepAIError)?.localizedDescription,
                            details: nil))
        }
      }
      
    case "startDeliveryByAddress":
      guard let args = call.arguments as? [String: Any],
            let addr = args["address"] as? [String: String],
            let deliveryId = args["deliveryId"] as? String,
            let street = addr["streetNumber"],
            let route = addr["route"],
            let locality = addr["locality"],
            let admin1 = addr["administrativeAreaLevel1"],
            let postal = addr["postalCode"] else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid address arguments or deliveryId missing", details: nil))
      }
      let address = AddressType(
        streetNumber: street,
        route: route,
        subPremise: addr["subPremise"] ?? "",
        locality: locality,
        administrativeAreaLevel1: admin1,
        postalCode: postal
      )
      Task {
        do {
          try await DoorstepAI.startDeliveryByAddressType(address: address, deliveryId: deliveryId)
          result(nil)
        } catch {
          result(FlutterError(code: "DELIVERY_ERR",
                            message: (error as? DoorstepAIError)?.localizedDescription,
                            details: nil))
        }
      }
      
    case "newEvent":
      guard let args = call.arguments as? [String: Any],
            let name = args["eventName"] as? String,
            let deliveryId = args["deliveryId"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "eventName or deliveryId missing", details: nil))
      }
      Task {
        do {
          try await DoorstepAI.newEvent(eventName: name, deliveryId: deliveryId)
          result(nil)
        } catch {
          result(FlutterError(code: "EVENT_ERR",
                            message: error.localizedDescription,
                            details: nil))
        }
      }
      
    case "stopDelivery":
      guard let args = call.arguments as? [String: Any],
            let deliveryId = args["deliveryId"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "deliveryId missing", details: nil))
      }
      Task {
        await DoorstepAI.stopDelivery(deliveryId: deliveryId)
        result(nil)
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
