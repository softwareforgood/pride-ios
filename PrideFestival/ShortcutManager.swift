import UIKit

struct ShortcutManager {

  enum ShortcutIdentifier: String {
    case openMap
    case openEvents
    case openParade
  }
  
  static var shared = ShortcutManager()
  
  weak var tabBarController: PrideTabBarController?
  
  func shortcutItems() -> [UIApplicationShortcutItem] {
    return [
      UIApplicationShortcutItem(type: ShortcutIdentifier.openMap.rawValue,
                                localizedTitle: "Map",
                                localizedSubtitle: nil,
                                icon: UIApplicationShortcutIcon(
                                  templateImageName: "tab_bar_map_icon"),
                                userInfo: nil),
      UIApplicationShortcutItem(type: ShortcutIdentifier.openEvents.rawValue,
                                localizedTitle: "Events",
                                localizedSubtitle: nil,
                                icon: UIApplicationShortcutIcon(
                                  templateImageName: "tab_bar_events_icon"),
                                userInfo: nil),
      UIApplicationShortcutItem(type: ShortcutIdentifier.openParade.rawValue,
                                localizedTitle: "Parade",
                                localizedSubtitle: nil,
                                icon: UIApplicationShortcutIcon(
                                  templateImageName: "tab_bar_parade_icon"),
                                userInfo: nil)
    ]
  }
  
  func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
    switch shortcutItem.type {
    case ShortcutIdentifier.openMap.rawValue:
      tabBarController?.selectedIndex = PrideTabBarController.Index.map.rawValue
    case ShortcutIdentifier.openEvents.rawValue:
      tabBarController?.selectedIndex = PrideTabBarController.Index.events.rawValue
    case ShortcutIdentifier.openParade.rawValue:
      tabBarController?.selectedIndex = PrideTabBarController.Index.parade.rawValue
    default: break
    }
    
    return true
  }
  
}
