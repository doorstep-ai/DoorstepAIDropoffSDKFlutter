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
      
    // case "setDevMode":
    //   guard let args = call.arguments as? [String: Any],
    //         let devModeEnabled = args["devModeEnabled"] as? Bool else {
    //     return result(FlutterError(code: "INVALID_ARGUMENTS", message: "devModeEnabled missing", details: nil))
    //   }
    //   DoorstepAI.devMode = devModeEnabled
    //   result(nil)
      
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
          result(FlutterError(code: "E_START_DELIVERY",
                            message: "Failed to start delivery by Place ID: \(error.localizedDescription)",
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
          result(FlutterError(code: "E_START_DELIVERY",
                            message: "Failed to start delivery by Plus Code: \(error.localizedDescription)",
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
        return result(FlutterError(code: "E_INVALID_ADDRESS", message: "Missing or invalid fields in address dictionary or deliveryId missing", details: nil))
      }
      
      Task {
        print("Starting delivery by address: \(addr)")
        do {
          let address = AddressType(
            streetNumber: street,
            route: route,
            subPremise: addr["subPremise"] ?? "",
            locality: locality,
            administrativeAreaLevel1: admin1,
            postalCode: postal
          )
          
          try await DoorstepAI.startDeliveryByAddressType(address: address, deliveryId: deliveryId)
          result(nil)
        } catch let error as DoorstepAIError {
          result(FlutterError(code: "E_START_DELIVERY",
                            message: "Failed to start delivery by address: \(error.localizedDescription)",
                            details: nil))
        } catch {
          result(FlutterError(code: "E_UNKNOWN",
                            message: "An unexpected error occurred: \(error.localizedDescription)",
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
          result(FlutterError(code: "E_NEW_EVENT",
                            message: "Failed to send event: \(error.localizedDescription)",
                            details: nil))
        }
      }
      
    case "stopDelivery":
      guard let args = call.arguments as? [String: Any],
            let deliveryId = args["deliveryId"] as? String else {
        return result(FlutterError(code: "INVALID_ARGUMENTS", message: "deliveryId missing", details: nil))
      }
      Task {
        // stopDelivery does not throw so we simply await its completion
        await DoorstepAI.stopDelivery(deliveryId: deliveryId)
        result(nil)
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
