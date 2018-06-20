import Foundation

struct FavoritesManager {

  static func isFavorited(item: Item) -> Bool {
    guard let id = item.objectId else { return false }
    return UserDefaults.standard
      .bool(forKey: String.localizedStringWithFormat(itemFavoritedKey, id))
  }

  static func toggleFavorite(item: Item) {
    if let id = item.objectId {
      UserDefaults.standard.set(!isFavorited(item: item),
        forKey: String.localizedStringWithFormat(itemFavoritedKey, id))
    }
  }

  static func allFavoritedItems() -> [Item] {
    var favoritedItems: [Item] = []

    for event in ParseManager.shared.verifiedEvents {
      if isFavorited(item: event) {
        favoritedItems.append(event)
      }
    }

    for paradeEvent in ParseManager.shared.verifiedParadeEvents {
      if isFavorited(item: paradeEvent) {
        favoritedItems.append(paradeEvent)
      }
    }

    for vendor in ParseManager.shared.verifiedVendors {
      if isFavorited(item: vendor) {
        favoritedItems.append(vendor)
      }
    }

    return favoritedItems
  }

}
