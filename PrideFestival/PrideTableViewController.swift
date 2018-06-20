import UIKit

class PrideTableViewController: UITableViewController, UISearchBarDelegate {

  enum SubviewIdentifier: String {
    case eventCell
    case paradeEventCell
    case vendorCell
    case sectionHeaderView
    case purpleButtonCell
  }

  var searchBar: UISearchBar?
  
  var noItemsMessageLabel: UILabel?

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(
      UINib(nibName: "EventTableViewCell", bundle: Bundle.main),
      forCellReuseIdentifier: SubviewIdentifier.eventCell.rawValue)
    tableView.register(
      UINib(nibName: "ParadeEventTableViewCell", bundle: Bundle.main),
      forCellReuseIdentifier: SubviewIdentifier.paradeEventCell.rawValue)
    tableView.register(
      UINib(nibName: "VendorTableViewCell", bundle: Bundle.main),
      forCellReuseIdentifier: SubviewIdentifier.vendorCell.rawValue)
    tableView.register(
      UINib(nibName: "SectionHeaderView", bundle: Bundle.main),
      forHeaderFooterViewReuseIdentifier: SubviewIdentifier.sectionHeaderView.rawValue)

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self,
      action: #selector(PrideTableViewController.reloadData),
      for: .valueChanged)

    NotificationCenter.default.addObserver(self,
      selector: #selector(PrideTableViewController.updateTable),
      name: NotificationName.itemFavoritesDidUpdate,
      object: nil)

    searchBar = UISearchBar()
    searchBar?.delegate = self
    navigationItem.titleView = searchBar

    let infoButtonItem = UIBarButtonItem(
      image: UIImage(named: "info_bar_button_item_icon"),
        style: .plain,
        target: self,
        action: #selector(PrideTableViewController.showInfoPage))
    infoButtonItem.tintColor = Color.appPurple
    navigationItem.rightBarButtonItem = infoButtonItem

    navigationController?.navigationBar.tintColor = Color.appPurple
    
    let noItemsMessageLabel = UILabel(frame: CGRect(x: view.frame.origin.x + 10,
                                           y: view.frame.origin.y,
                                           width: view.frame.width - 20,
                                           height: normalCellHeight))
    noItemsMessageLabel.textAlignment = NSTextAlignment.center
    noItemsMessageLabel.font = noItemsMessageLabel.font.withSize(20)
    noItemsMessageLabel.numberOfLines = 0
    noItemsMessageLabel.isHidden = true
    noItemsMessageLabel.textColor = Color.appPurple
    noItemsMessageLabel.text = "There are no items to display."
    view.addSubview(noItemsMessageLabel)
    self.noItemsMessageLabel = noItemsMessageLabel

    updateTable()
  }
  
  override func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
    return normalCellHeight
  }

  func cell(forItem item: Item, indexPath: IndexPath) -> UITableViewCell {
    switch item {
    case is Event:
      guard let cell: EventTableViewCell = tableView
        .dequeueReusableCell(withIdentifier: SubviewIdentifier.eventCell.rawValue,
          for: indexPath) as? EventTableViewCell else {
            return UITableViewCell()
      }
      cell.event = item as? Event
      return cell
    case is ParadeEvent:
      guard let cell = tableView
        .dequeueReusableCell(withIdentifier: SubviewIdentifier.paradeEventCell.rawValue,
          for: indexPath) as? ParadeEventTableViewCell else {
            return UITableViewCell()
      }
      cell.paradeEvent = item as? ParadeEvent
      return cell
    case is Vendor:
      guard let cell = tableView
        .dequeueReusableCell(withIdentifier: SubviewIdentifier.vendorCell.rawValue,
          for: indexPath) as? VendorTableViewCell else {
            return UITableViewCell()
      }
      cell.vendor = item as? Vendor
      return cell
    default: return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let item = (tableView.cellForRow(at: indexPath) as? EventTableViewCell)?.event
      ?? (tableView.cellForRow(at: indexPath) as? VendorTableViewCell)?.vendor
      ?? (tableView.cellForRow(at: indexPath) as? ParadeEventTableViewCell)?.paradeEvent else {
        print("Cell's item object could not be obtained")
        return
    }
    
    guard item.location != nil else {
      let alertMessage = "This can't be shown on the map because it "
        + "does not have a location."
      let alert = UIAlertController(title: "No Location",
                                    message: alertMessage,
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default,
                                    handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    
    guard let mapVC = tabBarController?
      .viewControllers?[PrideTabBarController.Index.map.rawValue]
      as? MapViewController else {
        print("failed to get mapVC")
        return
    }
    
    // Automatically switch to map tab
    mapVC.itemToSelectCorrespondingAnnotation = item
    tabBarController?.selectedIndex = PrideTabBarController.Index.map.rawValue
  }

  @objc func showInfoPage() {
    navigationController?.pushViewController(InfoViewController(), animated: true)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc func reloadData() {
    ParseManager.shared.reloadData()
  }

  @objc func updateTable() {
    tableView.reloadData()
    refreshControl?.endRefreshing()
    noItemsMessageLabel?.isHidden = !(tableView.numberOfSections == 0)
  }

}
