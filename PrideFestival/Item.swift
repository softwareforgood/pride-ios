import UIKit
import Parse

class Item: NSObject {

  var objectId: String?
  var name: String?
  var details: String?
  var locationName: String?
  var location: CLLocation?
  var website: String?
  var verified: Bool

  init(object: PFObject) {
    self.objectId = object.objectId
    self.name = object["name"] as? String
    self.details = object["details"] as? String
    self.locationName = object["locationName"] as? String
    self.website = object["website"] as? String

    if let location = object["location"] as? PFGeoPoint {
      self.location = CLLocation(
        latitude: location.latitude,
        longitude: location.longitude)
    }
    
    self.verified = object["verified"] as? Bool ?? false
  }
  
}
