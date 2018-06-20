import Foundation

class SponsorsManager {

  static let shared = SponsorsManager()

  var verifiedEventsWithSponsorVendors: [Item] = []
  var verifiedParadeEventsWithSponsorVendors: [Item] = []

  init() {
    refreshEventsWithSponsors()
    refreshVerifiedParadeEventsWithSponsors()

    NotificationCenter.default.addObserver(self,
      selector: #selector(SponsorsManager.shared.refreshEventsWithSponsors),
      name: NotificationName.eventsDidUpdate,
      object: nil)
    NotificationCenter.default.addObserver(self,
      selector: #selector(SponsorsManager.shared.refreshEventsWithSponsors),
      name: NotificationName.vendorsDidUpdate,
      object: nil)
    NotificationCenter.default.addObserver(self,
      selector: #selector(SponsorsManager.shared.refreshVerifiedParadeEventsWithSponsors),
      name: NotificationName.paradeEventsDidUpdate,
      object: nil)
    NotificationCenter.default.addObserver(self,
      selector: #selector(SponsorsManager.shared.refreshVerifiedParadeEventsWithSponsors),
      name: NotificationName.vendorsDidUpdate,
      object: nil)
  }

  @objc func refreshEventsWithSponsors() {
    verifiedEventsWithSponsorVendors = []

    for event in ParseManager.shared.verifiedEvents {
      verifiedEventsWithSponsorVendors.append(event)
      if let sponsor = event.sponsor {
        verifiedEventsWithSponsorVendors.append(sponsor)
      }
    }
  }

  @objc func refreshVerifiedParadeEventsWithSponsors() {
    verifiedParadeEventsWithSponsorVendors = ParseManager.shared.verifiedParadeEvents
    var repeatedSponsors = paradeSponsorVendors()
    for _ in 0...3 {
      repeatedSponsors += paradeSponsorVendors()
    }

    var count = 0
    var increment = 15
    for sponsor in repeatedSponsors {
      count += 1
      increment += 1
      guard verifiedParadeEventsWithSponsorVendors.count >= count*increment + 1 else { break }
      verifiedParadeEventsWithSponsorVendors.insert(sponsor, at: count * increment)
    }
  }

  private func paradeSponsorVendors() -> [Vendor] {
    var paradeSponsorVendors = [Vendor]()

    for vendor in ParseManager.shared.verifiedVendors {
      if vendor.showInParadeList {
        paradeSponsorVendors.append(vendor)
      }
    }

    return paradeSponsorVendors
  }

}
