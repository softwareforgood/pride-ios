import UIKit
import MapKit

class PrideAnnotation: NSObject, MKAnnotation {
  var coordinate: CLLocationCoordinate2D
  var item: Item?

  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }
}
