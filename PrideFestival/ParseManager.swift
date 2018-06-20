import UIKit
import Parse
import Reachability

class ParseManager {

  enum ParseClass: String {
    case Event
    case Vendor
    case ParadeEvent
    case Info
  }

  var events: [Event] = []
  var verifiedEvents: [Event] { return events.filter {$0.verified} }
  var vendors: [Vendor] = []
  var verifiedVendors: [Vendor] { return vendors.filter {$0.verified} }
  var paradeEvents: [ParadeEvent] = []
  var verifiedParadeEvents: [ParadeEvent] {
    return paradeEvents.filter {$0.verified}
  }
  var infoText = ""
  var reachability: Reachability?

  static let shared = ParseManager()

  init() {
    reachability = Reachability()

    do {
      try self.reachability!.startNotifier()
    } catch {
      print("Unable to start the notification")
      return
    }

    reloadData()
  }

  func reloadData() {
    fetchObjects(ofType: .Event)
    fetchObjects(ofType: .Vendor)
    fetchObjects(ofType: .ParadeEvent)
    fetchObjects(ofType: .Info)
  }

  // Retrieves events from Parse app
  private func fetchObjects(ofType type: ParseClass) {
    switch type {
    case .Event: events = []
    case .Vendor: vendors = []
    case .ParadeEvent: paradeEvents = []
    case .Info: infoText = ""
    }

    let query = PFQuery(className: type.rawValue)
    query.limit = 1000

    if let reachability = reachability {
      if reachability.connection == .none {
        print("No reachability, fetching from local datastore instead")
        query.fromLocalDatastore()
      }
    }

    query.findObjectsInBackground {(objects: [PFObject]?, error: Error?) ->
      Void in
      if let error = error {
        print("Error: \(error)")
        return
      }
      guard let objects = objects else { return }
      PFObject.pinAll(inBackground: objects)
      switch type {
      case .Event: self.saveAndSort(eventObjects: objects)
      case .Vendor: self.saveAndSort(vendorObjects: objects)
      case .ParadeEvent: self.saveAndSort(paradeEventObjects: objects)
      case .Info: self.save(infoObjects: objects)
      }
    }
  }

  private func saveAndSort(eventObjects: [PFObject]) {
    for eventObject in eventObjects {
      events.append(Event(object: eventObject))
    }

    events.sort(by: {
      if $0.startTime == nil && $1.startTime == nil { return true }
      if $1.startTime == nil { return true }
      if $0.startTime == nil { return false }
      guard let s0 = $0.startTime, let s1 = $1.startTime else { return true }
      return s0.compare(s1) == ComparisonResult.orderedAscending
    })

    NotificationCenter.default.post(name: NotificationName.eventsDidUpdate,
                                    object: self)
  }

  private func saveAndSort(vendorObjects: [PFObject]) {
    for vendorObject in vendorObjects {
      vendors.append(Vendor(object: vendorObject))
    }

    vendors.sort(by: {
      let name0 = $0.name ?? ""
      let name1 = $1.name ?? ""

      if name0.isEmpty && name1.isEmpty { return true }
      if name1.isEmpty { return true }
      if name0.isEmpty { return false }
      return name0.uppercased() < name1.uppercased()
    })

    NotificationCenter.default.post(name: NotificationName.vendorsDidUpdate,
                                    object: self)
  }

  private func saveAndSort(paradeEventObjects: [PFObject]) {
    for paradeEventObject in paradeEventObjects {
      paradeEvents.append(ParadeEvent(object: paradeEventObject))
    }

    paradeEvents.sort(by: {
      if $0.lineupNumber == nil && $1.lineupNumber == nil { return true }
      if $1.lineupNumber == nil { return true }
      if $0.lineupNumber == nil { return false }
      return $0.lineupNumber! < $1.lineupNumber!
    })

    NotificationCenter.default.post(name: NotificationName.paradeEventsDidUpdate,
                                    object: self)
  }

  private func save(infoObjects: [PFObject]) {
    for infoObject in infoObjects {
      guard let text = infoObject["text"] as? String else { continue }
      infoText = text
      break
    }
  }

  func itemsWithSameLocationAs(item: Item) -> [Item] {
    var itemsWithLocation: [Item] = []

    var items: [Item] = []
    for event in events {
      items.append(event as Item)
    }
    for vendor in vendors {
      items.append(vendor as Item)
    }
    for otherItem in items {
      if otherItem == item { continue }
      guard let otherItemCoord = otherItem.location?.coordinate,
        let itemCoord = item.location?.coordinate else { continue }
      if otherItemCoord.latitude == itemCoord.latitude && otherItemCoord.longitude == itemCoord.longitude {
        itemsWithLocation.append(otherItem)
      }
    }

    return itemsWithLocation
  }

  func fetchDataFrom(file: PFFile, completion: @escaping (_ data: Data) -> Void) {
    file.getDataInBackground {(data: Data?, error: Error?) -> Void in
      if error != nil {
        print("Error getting data: \(String(describing: error))")
        return
      }
      if let data = data {
        completion(data)
      }
    }
  }

}
