import UIKit

class VendorsViewController: PrideTableViewController {

  var vendorsByLetter = [[Vendor]]()
  var filteredVendorsByLetter = [[Vendor]]()
  var showFilteredVendors = false
  var sourceVendors: [[Vendor]] {
    return showFilteredVendors
      ? filteredVendorsByLetter
      : vendorsByLetter
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    noItemsMessageLabel?.text = "There are no vendors to display yet."

    NotificationCenter.default.addObserver(self,
      selector: #selector(VendorsViewController.updateTable),
      name: NotificationName.vendorsDidUpdate,
      object: nil)
  }

  override func updateTable() {
    // ParseManager.shared.verifiedVendors are assumed to already be
    // ordered alphabetically
    vendorsByLetter = []
    var previousVendor: Vendor?
    for vendor in ParseManager.shared.verifiedVendors {
      guard let previous = previousVendor else {
        vendorsByLetter.append([])
        vendorsByLetter[vendorsByLetter.count-1].append(vendor)
        previousVendor = vendor
        continue
      }

      guard let vendorName = vendor.name,
        let previousVendorName = previous.name else {
          continue
      }

      if (previousVendorName.firstCharacter().uppercased()
          != vendorName.firstCharacter().uppercased()
          && !previousVendorName.isNumber() && !vendorName.isNumber())
        || (previousVendorName.isNumber() && !vendorName.isNumber()) {
          vendorsByLetter.append([])
      }

      vendorsByLetter[vendorsByLetter.count-1].append(vendor)
      previousVendor = vendor
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

    if section+1 <= sourceVendors.count {
      let firstVendor = sourceVendors[section][0]
      if let name = firstVendor.name {
        let text = name.firstCharacter().uppercased()
        if let _ = Int(text) {
          header.label.text = "#"
        } else if text != "" {
          header.label.text = text
        } else {
          header.label.text = "Vendors without a name"
        }
      }
    }

    return header
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return sourceVendors.count
  }

  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 72
  }

  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.section+1 <= sourceVendors.count else {
      return UITableViewCell()
    }
    guard indexPath.row+1 <= sourceVendors[indexPath.section].count else {
        return UITableViewCell()
    }
    return cell(forItem: sourceVendors[indexPath.section][indexPath.row],
                indexPath: indexPath)
  }

  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section+1 > sourceVendors.count {
      return 0
    }
      return sourceVendors[section].count
  }

}

extension VendorsViewController {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText == "" {
      showFilteredVendors = false
    } else {
      filterVendorsBy(text: searchText)
      showFilteredVendors = true
    }

    tableView.reloadData()
  }

  private func filterVendorsBy(text: String) {
    let lowercaseText = text.lowercased()

    filteredVendorsByLetter = []

    for letter in vendorsByLetter {
      let filteredLetter = letter.filter { vendor -> Bool in
        return (vendor.name?.lowercased().range(of: lowercaseText) != nil)
          || (vendor.details?.lowercased().range(of: lowercaseText) != nil)
          || (vendor.locationName?.lowercased().range(of: lowercaseText) != nil)
      }
      if filteredLetter.count > 0 {
        filteredVendorsByLetter.append(filteredLetter)
      }
    }
  }
}
