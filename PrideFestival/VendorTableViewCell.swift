import UIKit

class VendorTableViewCell: PrideTableViewCell {

  @IBOutlet var locationNameLabel: UILabel!

  private var vendorIsFavorite = false

  var vendor: Vendor? {
    didSet {
      guard let vendor = vendor else {
        print("Error: VendorTableViewCell vendor variable is nil")
        return
      }

      nameLabel.text = vendor.name ?? ""
      detailsLabel.text = vendor.details ?? ""
      locationNameLabel.text = vendor.locationName ?? ""
      locationNameLabel.textColor = vendor.sectionColor
      iconImageView.backgroundColor = vendor.sectionColor

      if let type = vendor.type {
        switch type {
        case .food:
          iconImageView.image = UIImage(named: "cell_type_food_icon")
        case .nonfood:
          iconImageView.image = UIImage(
            named: "vendor_cell_type_nonfood_icon")
        }
      } else {
        iconImageView.image = UIImage(
          named: "cell_type_miscellaneous_icon")
      }

      if vendor.isSponsor, let logo = vendor.logo {
        self.iconImageView.image = logo
        self.iconImageView.contentMode = .scaleAspectFit
      } else {
        self.iconImageView.contentMode = .center
      }

      refreshFavoriteButton()
    }
  }

  @IBAction func didTapMakeFavoriteButton(_ sender: AnyObject) {
    guard let vendor = vendor else { return }
    FavoritesManager.toggleFavorite(item: vendor)
    refreshFavoriteButton()

    NotificationCenter.default.post(name: NotificationName.itemFavoritesDidUpdate,
                                    object: self)
  }

  private func refreshFavoriteButton() {
    guard let vendor = vendor else { return }
    if FavoritesManager.isFavorited(item: vendor) {
      makeFavoriteButton.setImage(UIImage(
        named: "make_favorite_button_favorited"),
        for: UIControlState())
    } else {
      makeFavoriteButton.setImage(UIImage(
        named: "make_favorite_button_not_favorited"),
        for: UIControlState())
    }
  }

}
