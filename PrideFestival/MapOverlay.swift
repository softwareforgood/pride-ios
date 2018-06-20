import UIKit
import MapKit

class MapOverlay: NSObject, MKOverlay {
  
  enum MapOverlayType {
    case mainOverlay
    case sponsorVendors
  }

  var coordinate: CLLocationCoordinate2D
  var boundingMapRect: MKMapRect
  var image: UIImage
  var type: MapOverlayType

  init(coordinate: CLLocationCoordinate2D,
       rect: MKMapRect,
       image: UIImage,
       type: MapOverlayType) {
    self.coordinate = coordinate
    self.boundingMapRect = rect
    self.image = image
    self.type = type
  }

}
