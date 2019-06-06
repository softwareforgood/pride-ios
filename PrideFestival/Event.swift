import UIKit
import MapKit
import Parse

class Event: Item {

  enum EventType {
    case performance
    case music
    case sports
    case food
    case miscellaneous
  }

  var startTime: Date?
  var endTime: Date?
  var type: EventType?
  var image: UIImage?
  var sponsor: Vendor?

  override init(object: PFObject) {
    super.init(object: object)

    self.startTime = object["startTime"] as? Date
    self.endTime = object["endTime"] as? Date

    if let type = object["type"] as? String {
      switch type {
      case "performance": self.type = .performance
      case "music": self.type = .music
      case "sports": self.type = .sports
      case "food": self.type = .food
      default: self.type = .miscellaneous
      }
    } else {
      self.type = .miscellaneous
    }

    if let sponsor = object["sponsor"] as? PFObject {
      self.sponsor = Vendor(object: sponsor)
    }
    
    if let image = object["image"] as? PFFileObject {
      ParseManager.shared.fetchDataFrom(file: image) {
        (imageData: Data) in
        self.image = UIImage(data: imageData)
      }
    }
  }
  
}
