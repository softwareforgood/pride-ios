import UIKit

class ParadeViewController: PrideTableViewController {

  var filteredParadeEvents: [ParadeEvent] = []
  var showFilteredParadeEvents = false
  var sourceParadeEvents: [Item] {
    return showFilteredParadeEvents
      ? filteredParadeEvents
      : SponsorsManager.shared.verifiedParadeEventsWithSponsorVendors
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    noItemsMessageLabel?.text = "There is nothing in the parade to display yet."

    NotificationCenter.default.addObserver(self,
      selector: #selector(PrideTableViewController.updateTable),
      name: NotificationName.paradeEventsDidUpdate,
      object: nil)
  }

  // MARK: UITableView Data Source

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.row+1 <= sourceParadeEvents.count else {
      return UITableViewCell()
    }
    return cell(forItem: sourceParadeEvents[indexPath.row],
                indexPath: indexPath)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return (sourceParadeEvents.count > 0) ? 1 : 0
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return sourceParadeEvents.count
  }

}

extension ParadeViewController {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      showFilteredParadeEvents = false
    } else {
      filterParadeEventsBy(text: searchText)
      showFilteredParadeEvents = true
    }

    tableView.reloadData()
  }

  private func filterParadeEventsBy(text: String) {
    let lowercaseText = text.lowercased()

    filteredParadeEvents = []

    for paradeEvent in ParseManager.shared.verifiedParadeEvents {
      if (paradeEvent.name?.lowercased().range(of: lowercaseText) != nil)
        || (paradeEvent.details?.lowercased().range(of: lowercaseText) != nil)
        || (paradeEvent.locationName?.lowercased().range(of: lowercaseText) != nil) {
          filteredParadeEvents.append(paradeEvent)
      }
    }
  }
}
