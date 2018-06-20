import UIKit

class EventTableViewCell: PrideTableViewCell {

  @IBOutlet var iconBackgroundView: UIView!
  
  @IBOutlet var locationNameLabel: UILabel!
  @IBOutlet var dateAndTimeLabel: UILabel!

  var showDate = false

  var event: Event? {
    didSet {
      guard let event = event else {
        print("Error: EventTableViewCell event variable is nil")
        return
      }

      nameLabel.text = event.name ?? ""
      detailsLabel.text = event.details ?? ""
      locationNameLabel.text = event.locationName ?? ""
      dateAndTimeLabel.text = dateAndTimeText()

      if let type = event.type {
        switch type {
        case .performance:
          iconImageView.image = UIImage(
            named: "event_cell_type_performance_icon")
          iconBackgroundView.backgroundColor = Color.Event.blue
        case .music:
          iconImageView.image = UIImage(named: "event_cell_type_music_icon")
          iconBackgroundView.backgroundColor = Color.Event.blue
        case .sports:
          iconImageView.image = UIImage(named: "cell_type_sport_icon")
          iconBackgroundView.backgroundColor = Color.Event.green
        case .food:
          iconImageView.image = UIImage(named: "cell_type_food_icon")
          iconBackgroundView.backgroundColor = Color.Event.green
        case .miscellaneous:
          iconImageView.image = UIImage(named: "cell_type_miscellaneous_icon")
          iconBackgroundView.backgroundColor = Color.Event.yellow
        }
      } else {
        iconImageView.image = UIImage(named: "cell_type_miscellaneous_icon")
        iconBackgroundView.backgroundColor = Color.Event.yellow
      }
      
      if let image = event.image {
        self.iconImageView.image = image
        self.iconImageView.contentMode = .scaleAspectFill
        self.iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        self.iconImageView.layer.masksToBounds = true
      } else {
        self.iconImageView.contentMode = .center
      }

      refreshFavoriteButton()
    }
  }

  private func dateAndTimeText() -> String {
    var text = ""
    guard let event = event, let startTime = event.startTime else {
      return text
    }
    if showDate {
      text += "\(Date.dateString(fromDate: startTime, showYear: false)),"
    }
    if let endTime = event.endTime {
      return text + "\(Date.timeString(fromDate: startTime))"
        + " to \(Date.timeString(fromDate: endTime))"
    } else if showDate {
      text += " starts at "
    } else {
      text += "Starts at "
    }
    return text + Date.timeString(fromDate: startTime)
  }

  @IBAction func didTapMakeFavoriteButton(_ sender: AnyObject) {
    guard let event = event else { return }
    FavoritesManager.toggleFavorite(item: event)
    refreshFavoriteButton()

    NotificationCenter.default.post(
      name: NotificationName.itemFavoritesDidUpdate,
      object: self)
  }

  private func refreshFavoriteButton() {
    guard let event = event else { return }

    if FavoritesManager.isFavorited(item: event) {
      makeFavoriteButton.setImage(UIImage(named: "make_favorite_button_favorited"),
                                  for: .normal)
    } else {
      makeFavoriteButton.setImage(UIImage(named: "make_favorite_button_not_favorited"),
                                  for: .normal)
    }
  }

}
