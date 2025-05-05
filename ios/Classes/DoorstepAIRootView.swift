import Flutter
import UIKit
import SwiftUI
import DoorstepDropoffSDK

// 1) The PlatformView itself:
@available(iOS 13.0, *)
class DoorstepAIRootView: NSObject, FlutterPlatformView {
  private let hostingController: UIHostingController<DoorstepAIRoot>

  init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, messenger: FlutterBinaryMessenger) {
    // Instantiate your SwiftUI view
    let view = DoorstepAIRoot()
    hostingController = UIHostingController(rootView: view)
    super.init()

    hostingController.view.frame = frame
  }

  func view() -> UIView {
    return hostingController.view
  }
}

// 2) The Factory:
@available(iOS 13.0, *)
class DoorstepAIRootFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return DoorstepAIRootView(frame: frame, viewIdentifier: viewId, arguments: args, messenger: messenger)
  }
}