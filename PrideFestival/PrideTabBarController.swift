import UIKit

class PrideTabBarController: UITabBarController {

  enum Index: Int {
    case events = 0
    case parade = 1
    case map = 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tabBar.tintColor = Color.appPurple
    selectedIndex = Index.map.rawValue
    ShortcutManager.shared.tabBarController = self
  }

  override var canBecomeFirstResponder: Bool { return true }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    tabBar.isTranslucent = false
  }

  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    super.motionEnded(motion, with: event)

    if motion != .motionShake { return }

    ParseManager.shared.reloadData()
  }

}
