import UIKit
import MapKit
import Parse

class Vendor: Item {

  enum VendorType {
    case food
    case nonfood
  }

  var type: VendorType?
  var logo: UIImage?
  var isSponsor: Bool
  var showInParadeList: Bool
  var sectionColor = Color.Vendor.gray

  override init(object: PFObject) {
    if let type = object["type"] as? String {
      self.type = type == "food" ? .food : .nonfood
    }

    self.isSponsor = object["isSponsor"] as? Bool ?? false
    self.showInParadeList = object["showInParadeList"] as? Bool ?? false

    if let sectionColor = object["sectionColor"] as? String {
      switch sectionColor.lowercased() {
      case "red": self.sectionColor = Color.Vendor.red
      case "orange": self.sectionColor = Color.Vendor.orange
      case "yellow": self.sectionColor = Color.Vendor.yellow
      case "green": self.sectionColor = Color.Vendor.green
      case "blue": self.sectionColor = Color.Vendor.blue
      case "purple": self.sectionColor = Color.Vendor.purple
      default: break
      }
    }

    super.init(object: object)

    if let logo = object["logo"] as? PFFile {
      ParseManager.shared.fetchDataFrom(file: logo) {
        (logoData: Data) in
        self.logo = UIImage(data: logoData)
      }
    }
  }
  
}
