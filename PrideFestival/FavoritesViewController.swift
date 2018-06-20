import UIKit

class FavoritesViewController: PrideTableViewController {

  var favoritedItemsByDayAndType: [[Item]] = []
  var filteredFavoritedItemsByDayAndType: [[Item]] = []
  var showFilteredFavoritedItems = false
  var sourceFavoritedItems: [[Item]] {
    return showFilteredFavoritedItems
      ? filteredFavoritedItemsByDayAndType
      : favoritedItemsByDayAndType
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    noItemsMessageLabel?.text = "You haven't added any favorites yet! " +
      "Tap the heart on any card to add it to your favorites."

    NotificationCenter.default.addObserver(self,
      selector: #selector(FavoritesViewController.updateTable),
      name: NotificationName.eventsDidUpdate,
      object: nil)
    NotificationCenter.default.addObserver(self,
      selector: #selector(FavoritesViewController.updateTable),
      name: NotificationName.vendorsDidUpdate,
      object: nil)
  }

  override func updateTable() {
    // ParseManager.shared.verifiedEvents are assumed to already be
    // ordered by startTime
    favoritedItemsByDayAndType = []
    var previousItem: Item?
    for item in FavoritesManager.allFavoritedItems() {
      guard previousItem != nil else {
        favoritedItemsByDayAndType.append([])
        favoritedItemsByDayAndType[favoritedItemsByDayAndType.count-1]
          .append(item)
        previousItem = item
        continue
      }

      switch (item, previousItem) {
      case (let event as Event, let previousEvent as Event):
        guard let eventStartTime = event.startTime else {
          previousItem = item
          continue
        }

        guard let previousStartTime = previousEvent.startTime else {
          previousItem = item
          favoritedItemsByDayAndType.append([])
          favoritedItemsByDayAndType[favoritedItemsByDayAndType.count-1]
            .append(item)
          continue
        }

        if !Date.isDate(eventStartTime, onSameDayAsDate: previousStartTime) {
          favoritedItemsByDayAndType.append([])
        }

        favoritedItemsByDayAndType[favoritedItemsByDayAndType.count-1]
          .append(item)
      case (_ as ParadeEvent, _ as ParadeEvent),
           (_ as Vendor, _ as Vendor):
        favoritedItemsByDayAndType[favoritedItemsByDayAndType.count-1]
          .append(item)
      default:
        // When item and previousItem are different types of Item subclasses
        favoritedItemsByDayAndType.append([])
        favoritedItemsByDayAndType[favoritedItemsByDayAndType.count-1]
          .append(item)
      }

      previousItem = item
    }

    super.updateTable()
  }

  // MARK: UITableView Data Source

  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView
      .dequeueReusableHeaderFooterView(withIdentifier: SubviewIdentifier.sectionHeaderView.rawValue)
      as? SectionHeaderView else {
        return UITableViewHeaderFooterView()
    }

    if section+1 > sourceFavoritedItems.count {
      return UITableViewHeaderFooterView()
    }

    let firstItem = sourceFavoritedItems[section][0]
    switch firstItem {
    case let firstEvent as Event:
      if let date = firstEvent.startTime {
        header.label.text
          = "Events on \(Date.dateString(fromDate: date, showYear: true))"
      }
    case is ParadeEvent: header.label.text = "Parade"
    case is Vendor: header.label.text = "Vendors"
    default: break
    }

    return header
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sourceFavoritedItems.count
  }

  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 72
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    guard indexPath.section+1 <= sourceFavoritedItems.count else { return UITableViewCell() }
    guard indexPath.row+1 <= sourceFavoritedItems[indexPath.section].count else { return UITableViewCell() }

    return cell(forItem: sourceFavoritedItems[indexPath.section][indexPath.row],
                indexPath: indexPath)
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section+1 > sourceFavoritedItems.count {
      return 0
    }

    return sourceFavoritedItems[section].count
  }
  
}

extension FavoritesViewController {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      showFilteredFavoritedItems = false
    } else {
      filterItemsBy(text: searchText)
      showFilteredFavoritedItems = true
    }

    tableView.reloadData()
  }

  private func filterItemsBy(text: String) {
    let lowercaseText = text.lowercased()

    filteredFavoritedItemsByDayAndType = []

    for section in favoritedItemsByDayAndType {
      let filteredSection = section.filter { item  -> Bool in
        switch item {
        case let event as Event:
          return (event.name?.lowercased().range(of: lowercaseText) != nil)
            || (event.details?.lowercased().range(of: lowercaseText) != nil)
            || (event.locationName?.lowercased().range(of: lowercaseText) != nil)
        case let paradeEvent as ParadeEvent:
          return (paradeEvent.name?.lowercased().range(of: lowercaseText) != nil)
            || (paradeEvent.details?.lowercased().range(of: lowercaseText) != nil)
        case let vendor as Vendor:
          return (vendor.name?.lowercased().range(of: lowercaseText) != nil)
            || (vendor.details?.lowercased().range(of: lowercaseText) != nil)
            || (vendor.locationName?.lowercased().range(of: lowercaseText) != nil)
        default:
          return false
        }
      }
      if filteredSection.count > 0 {
        filteredFavoritedItemsByDayAndType.append(filteredSection)
      }
    }
  }
}
