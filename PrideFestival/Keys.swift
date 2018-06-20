import Foundation

// Notifications

struct NotificationName {
  static let eventsDidUpdate = NSNotification.Name(rawValue: bundleID + ".eventsDidUpdateNotification")
  static let vendorsDidUpdate = NSNotification.Name(rawValue: bundleID + ".vendorsDidUpdateNotification")
  static let paradeEventsDidUpdate = NSNotification.Name(rawValue: bundleID + ".paradeEventsDidUpdateNotification")
  static let itemFavoritesDidUpdate = NSNotification.Name(rawValue: bundleID + ".itemFavoritesDidUpdateNotification")
}

// FavoritesManager

let itemFavoritedKey = bundleID + ".item.with.objectid.%@.favorited"
