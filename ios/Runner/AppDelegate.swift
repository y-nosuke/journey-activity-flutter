import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let googleMapApiKey = Bundle.main.infoDictionary?["Google Maps API Key"] as? String {
          GMSServices.provideAPIKey(googleMapApiKey)
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
