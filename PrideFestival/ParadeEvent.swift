import UIKit
import Parse

class ParadeEvent: Item {

  var lineupNumber: Int?

  override init(object: PFObject) {
    super.init(object: object)

    self.lineupNumber = object["lineupNumber"] as? Int
  }
  
}
