import UIKit

class EventsViewController: PrideTableViewController {

  var eventsWithSponsorsByDay = [[Item]]()
  var filteredEventsWithSponsorsByDay = [[Item]]()
  var showFilteredEventsWithSponsors = false
  var sourceEventsWithSponsors: [[Item]] {
    return showFilteredEventsWithSponsors
      ? filteredEventsWithSponsorsByDay
      : eventsWithSponsorsByDay
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    noItemsMessageLabel?.text = "There are no events to display yet."

    NotificationCenter.default.addObserver(self,
      selector: #selector(EventsViewController.updateTable),
      name: NotificationName.eventsDidUpdate,
      object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  private func scrollToNextEvent() {
    for (dayIndex, day) in sourceEventsWithSponsors.enumerated() {
      for (itemIndex, item) in day.enumerated() {
        guard let event = item as? Event else { continue }
        guard let startTime = event.startTime else { continue }
        guard startTime.compare(Date()) == .orderedDescending else { continue }
        
        guard dayIndex <= tableView.numberOfSections-1 else { return }
        guard itemIndex <= tableView.numberOfRows(inSection: dayIndex) else {
          return
        }
        
        tableView.scrollToRow(at: IndexPath(row: itemIndex, section: dayIndex),
                              at: UITableViewScrollPosition.top,
                              animated: true)
        return
      }
    }
  }

  override func updateTable() {
    // ParseManager.shared.verifiedEvents are assumed to already be 
    // ordered by startTime
    eventsWithSponsorsByDay = []
    var previousItem: Item?
    for item in SponsorsManager.shared.verifiedEventsWithSponsorVendors {
      guard let previous = previousItem else {
        eventsWithSponsorsByDay.append([])
        eventsWithSponsorsByDay[eventsWithSponsorsByDay.count-1].append(item)
        previousItem = item
        continue
      }

      guard let event = item as? Event else {
        eventsWithSponsorsByDay[eventsWithSponsorsByDay.count-1].append(item)
        continue
      }

      guard let eventStartTime = event.startTime,
        let previousStartTime = (previous as? Event)?.startTime else {
          continue
      }

      if !Date.isDate(eventStartTime, onSameDayAsDate: previousStartTime) {
        eventsWithSponsorsByDay.append([])
      }

      eventsWithSponsorsByDay[eventsWithSponsorsByDay.count-1].append(event)
      previousItem = event
    }

    super.updateTable()
    
    scrollToNextEvent()
  }

  // MARK: UITableView Data Source

  override func tableView(_ tableView: UITableView,
                          viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView
      .dequeueReusableHeaderFooterView(withIdentifier: SubviewIdentifier.sectionHeaderView.rawValue)
      as? SectionHeaderView else {
        return UITableViewHeaderFooterView()
    }
    if section+1 <= sourceEventsWithSponsors.count {
      if let firstEvent = sourceEventsWithSponsors[section][0] as? Event {
        if let date = firstEvent.startTime {
          header.label.text = Date.dateString(fromDate: date, showYear: true)
        }
      }
    }
    return header
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sourceEventsWithSponsors.count
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 72
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.section+1 <= sourceEventsWithSponsors.count else {
      return UITableViewCell()
    }
    guard indexPath.row+1
      <= sourceEventsWithSponsors[indexPath.section].count else {
        return UITableViewCell()
    }
    let item = sourceEventsWithSponsors[indexPath.section][indexPath.row]
    let cell = self.cell(forItem: item, indexPath: indexPath)
    if let cell = cell as? VendorTableViewCell {
      cell.nameLabel.text = "Sponsored by "
        + (cell.nameLabel.text ?? "")
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section+1 > sourceEventsWithSponsors.count {
      return 0
    }
    return sourceEventsWithSponsors[section].count
  }

}

extension EventsViewController {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      showFilteredEventsWithSponsors = false
    } else {
      filterEventsBy(text: searchText)
      showFilteredEventsWithSponsors = true
    }

    tableView.reloadData()
  }

  private func filterEventsBy(text: String) {
    let lowercaseText = text.lowercased()

    filteredEventsWithSponsorsByDay = []

    for day in eventsWithSponsorsByDay {
      let filteredDay = day.filter { item -> Bool in
        guard let event = item as? Event else { return false }
        return (event.name?.lowercased().range(of: lowercaseText) != nil)
          || (event.details?.lowercased().range(of: lowercaseText) != nil)
          || (event.locationName?.lowercased().range(of: lowercaseText) != nil)
      }
      if filteredDay.count > 0 {
        filteredEventsWithSponsorsByDay.append(filteredDay)
      }
    }
  }
}
