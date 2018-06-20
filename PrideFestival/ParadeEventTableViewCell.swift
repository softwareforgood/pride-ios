import UIKit

class ParadeEventTableViewCell: PrideTableViewCell {

  @IBOutlet var lineupNumberLabel: UILabel!

  var paradeEvent: ParadeEvent? {
    didSet {
      guard let paradeEvent = paradeEvent else {
        print("Error: ParadeEventTableViewCell event variable is nil")
        return
      }

      nameLabel.text = paradeEvent.name ?? ""
      detailsLabel.text = paradeEvent.details ?? ""

      if let lineupNumber = paradeEvent.lineupNumber {
        lineupNumberLabel.text = "Lineup number: \(lineupNumber)"
      } else {
        lineupNumberLabel.text = ""
      }

      refreshFavoriteButton()
    }
  }

  @IBAction func didTapMakeFavoriteButton(_ sender: AnyObject) {
    guard let paradeEvent = paradeEvent else { return }
    FavoritesManager.toggleFavorite(item: paradeEvent)
    refreshFavoriteButton()

    NotificationCenter.default
      .post(name: NotificationName.itemFavoritesDidUpdate,
            object: self)
  }

  private func refreshFavoriteButton() {
    guard let paradeEvent = paradeEvent else { return }

    if FavoritesManager.isFavorited(item: paradeEvent) {
      makeFavoriteButton.setImage(UIImage(named: "make_favorite_button_favorited"),
                                  for: .normal)
    } else {
      makeFavoriteButton.setImage(UIImage(named: "make_favorite_button_not_favorited"),
                                  for: .normal)
    }
  }

}
