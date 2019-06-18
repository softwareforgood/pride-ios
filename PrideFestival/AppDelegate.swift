import UIKit
import Parse
import Fabric
import Crashlytics
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Parse.initialize(with: ParseClientConfiguration {
      $0.applicationId = parseApplicationID
      $0.server = parseServerURL
      $0.isLocalDatastoreEnabled = true
    })
    PFInstallation.current()?.saveInBackground()
    let _ = ParseManager.shared

    do {
      if let url = Bundle.main.url(forResource: "fabric.apikey", withExtension: nil) {
        let keyFileContents = try String(contentsOf: url, encoding: .utf8)
        let key = keyFileContents.trimmingCharacters(in: .whitespacesAndNewlines)
        Crashlytics.start(withAPIKey: key)
      }
    } catch {
      print("Could not retrieve Fabric API key from fabric.apikey file.")
    }

    application.shortcutItems = ShortcutManager.shared.shortcutItems()

    setUpSentry()

    return true
  }

  private func setUpSentry() {
    do {
      Client.shared = try Client(dsn: "https://889c06b81eef4e748b669945a45bc04b@sentry.io/1484989")
      try Client.shared?.startCrashHandler()
    } catch let error {
      print("\(error)")
    }

    Client.shared?.enableAutomaticBreadcrumbTracking()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    ParseManager.shared.reloadData()
  }
  
  func application(_ application: UIApplication,
                   performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    completionHandler(ShortcutManager.shared.handle(shortcutItem: shortcutItem))
  }

}
