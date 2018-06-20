import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController, CLLocationManagerDelegate {

  // MARK: Varables

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var mapViewBottomConstraint: NSLayoutConstraint!
  var mapViewBottomConstraintOriginalConstant: CGFloat = 0

  @IBOutlet var backToParkButton: UIButton!
  @IBOutlet var directionsButton: UIButton!

  var locationManager: CLLocationManager?

  let parkTopLeftCoordinate = CLLocationCoordinate2D(
    latitude: 44.972189,
    longitude: -93.287307)
  let parkBottomRightCoordinate = CLLocationCoordinate2D(
    latitude: 44.967810,
    longitude: -93.28186)
  let parkMapRect: MKMapRect
  let parkCenterCoordinate: CLLocationCoordinate2D

  let sponsorVendorsTopLeftCoordinate = CLLocationCoordinate2D(
    latitude: 44.972197,
    longitude: -93.287307)
  let sponsorVendorsBottomRightCoordinate = CLLocationCoordinate2D(
    latitude: 44.967803,
    longitude: -93.28183)
  let sponsorVendorsMapRect: MKMapRect
  let sponsorVendorsCenterCoordinate: CLLocationCoordinate2D

  var oldLongitudinalDistanceOfMapView: Double = 0
  var overlayViewMain: MapOverlayView?
  var overlayViewSponsorVendors: MapOverlayView?

  var itemPreviewPageViewController: UIPageViewController?
  let itemPreviewsHeight: CGFloat = isIPhone5Size ? 250 : 220
  let pageIndicatorHeight: CGFloat = 36
  let callToActionButtonCellHeight: CGFloat = 30
  var selectedItems: [Item] = []
  var deselectItemTimer: Timer?

  var itemToSelectCorrespondingAnnotation: Item?

  var isInitialAppearance = true

  var annotationLargeImage = UIImage(named: "annotation_large")
  var annotationLargeSelectedImage = UIImage(named: "annotation_large_selected")
  var annotationSmallImage = UIImage(named: "annotation_small")
  var annotationSmallSelectedImage = UIImage(named: "annotation_small_selected")
  var annotationImage: UIImage?
  var annotationSelectedImage: UIImage?

  // MARK: Init, viewDidLoad, etc.

  required init?(coder aDecoder: NSCoder) {
    let parkTopLeft = MKMapPointForCoordinate(parkTopLeftCoordinate)
    let parkBottomRight = MKMapPointForCoordinate(parkBottomRightCoordinate)
    parkMapRect = MKMapRectMake(
      parkTopLeft.x,
      parkTopLeft.y,
      parkBottomRight.x - parkTopLeft.x,
      parkBottomRight.y - parkTopLeft.y)
    parkCenterCoordinate = CLLocationCoordinate2DMake(
      parkMapRect.origin.x + parkMapRect.size.width / 2,
      parkMapRect.origin.y + parkMapRect.size.height / 2)

    let sponsorVendorsTopLeft = MKMapPointForCoordinate(
      sponsorVendorsTopLeftCoordinate)
    let sponsorVendorsBottomRight = MKMapPointForCoordinate(
      sponsorVendorsBottomRightCoordinate)
    sponsorVendorsMapRect = MKMapRectMake(
      sponsorVendorsTopLeft.x,
      sponsorVendorsTopLeft.y,
      sponsorVendorsBottomRight.x - sponsorVendorsTopLeft.x,
      sponsorVendorsBottomRight.y - sponsorVendorsTopLeft.y)
    sponsorVendorsCenterCoordinate = CLLocationCoordinate2DMake(
      sponsorVendorsMapRect.origin.x + sponsorVendorsMapRect.size.width / 2,
      sponsorVendorsMapRect.origin.y + sponsorVendorsMapRect.size.height / 2)

    annotationImage = annotationLargeImage
    annotationSelectedImage = annotationLargeSelectedImage

    super.init(coder: aDecoder)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager()
    locationManager?.delegate = self

    NotificationCenter.default.addObserver(self,
      selector: #selector(MapViewController.reloadMap),
      name: NotificationName.eventsDidUpdate,
      object: nil)
    NotificationCenter.default.addObserver(self,
      selector: #selector(MapViewController.reloadMap),
      name: NotificationName.vendorsDidUpdate,
      object: nil)

    backToParkButton.isHidden = true
    backToParkButton.layer.cornerRadius = 15
    backToParkButton.clipsToBounds = true
    directionsButton.isHidden = true
    directionsButton.layer.cornerRadius = 15
    directionsButton.clipsToBounds = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if isInitialAppearance {
      mapViewBottomConstraintOriginalConstant = mapViewBottomConstraint.constant
      checkLocation()
      reloadMap()
      addMapOverlays()
      mapView.setVisibleMapRect(parkMapRect, animated: true)
      isInitialAppearance = false
    }

    // An async dispatch is used here as a workaround to a bug. At this point
    // in the code, the view frame height does not account for the height of the
    // tab bar, so the itemPreviewTableView appears behind the tab bar, instead
    // of above it.
    DispatchQueue.main.async {
      if let item = self.itemToSelectCorrespondingAnnotation {
        self.selectAnnotationWith(item: item)
        self.itemToSelectCorrespondingAnnotation = nil
      }
    }
  }

  // MARK: Location

  private func checkLocation() {
    if CLLocationManager.authorizationStatus() == .notDetermined {
      print("location authorization not determined")
      locationManager?.requestWhenInUseAuthorization()
    }
  }

  // MARK: Map and map elements

  @objc func reloadMap() {
    mapView.removeAnnotations(mapView.annotations)

    for event in ParseManager.shared.verifiedEvents {
      guard let location = event.location else { continue }
      let annotation = PrideAnnotation(coordinate: location.coordinate)
      annotation.item = event
      mapView.addAnnotation(annotation)
    }

    for vendor in ParseManager.shared.verifiedVendors {
      guard let location = vendor.location else { continue }
      let annotation = PrideAnnotation(coordinate: location.coordinate)
      annotation.item = vendor
      mapView.addAnnotation(annotation)
    }
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
    -> MKAnnotationView? {
      if annotation.isEqual(mapView.userLocation) { return nil }
      let view = MKAnnotationView()
      view.image = annotationImage
      return view
  }

  private func addMapOverlays() {
    if let image = UIImage(named: "loring_park_main_overlay") {
      let overlay = MapOverlay(coordinate: parkCenterCoordinate,
                               rect: parkMapRect,
                               image: image,
                               type: .mainOverlay)
      overlayViewMain = MapOverlayView(overlay: overlay, overlayImage: image)
      mapView.add(overlay, level: .aboveRoads)
    }
    if let image = UIImage(named: "loring_park_sponsor_vendors_overlay") {
      let overlay = MapOverlay(coordinate: parkCenterCoordinate,
                               rect: sponsorVendorsMapRect,
                               image: image,
                               type: .sponsorVendors)
      overlayViewSponsorVendors = MapOverlayView(overlay: overlay,
                                                 overlayImage: image)
      mapView.add(overlay, level: .aboveRoads)
    }
  }

  func selectAnnotationWith(item: Item) {
    for annotation in mapView.annotations {
      guard let prideAnnotation = annotation as? PrideAnnotation else {
        continue
      }

      if item.isEqual(prideAnnotation.item) {
        // The selection of a PrideAnnotation results in the appearance of
        // the itemPreviewTableView
        mapView.selectAnnotation(prideAnnotation, animated: false)
        mapView.showAnnotations([prideAnnotation], animated: true)
        break
      }
    }
  }

  // MARK: Button actions

  @IBAction func moveToUserLocation(_ sender: AnyObject) {
    if let location = locationManager?.location {
      mapView.setCenter(location.coordinate, animated: true)
    }
  }

  @IBAction func didPressBackToParkButton(_ sender: AnyObject) {
    mapView.setVisibleMapRect(parkMapRect, animated: true)
  }
  
  @IBAction func didPressDirectionsButton(_ sender: Any) {
    guard !selectedItems.isEmpty else { return }
    guard let name = selectedItems[0].name,
      let coordinate = selectedItems[0].location?.coordinate else { return }
    
    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate,
                                                   addressDictionary: nil))  
    mapItem.name = name
    mapItem.openInMaps(launchOptions:
      [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
  }
}

// MARK: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    let region = mapView.region
    let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
      region.center.latitude + region.span.latitudeDelta / 2,
      region.center.longitude - region.span.longitudeDelta / 2))
    let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
      region.center.latitude - region.span.latitudeDelta / 2,
      region.center.longitude + region.span.longitudeDelta / 2))
    let mapViewRect = MKMapRectMake(min(a.x, b.x), min(a.y, b.y),
      abs(a.x - b.x), abs(a.y - b.y))

    let parkIsVisibleInMapView = !(
      (mapViewRect.origin.y + mapViewRect.size.height) < parkMapRect.origin.y ||
      mapViewRect.origin.y > (parkMapRect.origin.y + parkMapRect.size.height) ||
      (mapViewRect.origin.x + mapViewRect.size.width) < parkMapRect.origin.x ||
      mapViewRect.origin.x > (parkMapRect.origin.x + parkMapRect.size.width)
    )

    let currentLongitudinalDistance = longitudinalDistanceOfMapView()

    backToParkButton.isHidden
      = parkIsVisibleInMapView && currentLongitudinalDistance < 0.06

    if oldLongitudinalDistanceOfMapView != currentLongitudinalDistance {
      updateAnnotationImages()
      overlayViewSponsorVendors?.alpha
        = (longitudinalDistanceOfMapView() < 0.005) ? 1 : 0
    }

    oldLongitudinalDistanceOfMapView = currentLongitudinalDistance
  }

  private func updateAnnotationImages() {
    if longitudinalDistanceOfMapView() < 0.0014 {
      annotationImage = annotationLargeImage
      annotationSelectedImage = annotationLargeSelectedImage
    } else {
      annotationImage = annotationSmallImage
      annotationSelectedImage = annotationSmallSelectedImage
    }

    for annotation in mapView.annotations {
      if annotation.isEqual(mapView.userLocation) { continue }
      mapView.view(for: annotation)?.image
        = parkContains(coordinate: annotation.coordinate)
          ? annotationImage
          : annotationLargeImage
    }

    for annotation in mapView.selectedAnnotations {
      if annotation.isEqual(mapView.userLocation) { continue }
      mapView.view(for: annotation)?.image
        = parkContains(coordinate: annotation.coordinate)
          ? annotationSelectedImage
          : annotationLargeSelectedImage
    }
  }

  private func longitudinalDistanceOfMapView() -> Double {
    let topLeftCoord = mapView.convert(CGPoint(
        x: mapView.bounds.origin.x,
        y: mapView.bounds.maxY),
      toCoordinateFrom: mapView)
    let topRightCoord = mapView.convert(CGPoint(
        x: mapView.bounds.maxX,
        y: mapView.bounds.maxY),
      toCoordinateFrom: mapView)
    return abs(abs(topRightCoord.longitude) - abs(topLeftCoord.longitude))
  }

  private func parkContains(coordinate: CLLocationCoordinate2D)
    -> Bool {
      return coordinate.latitude < parkTopLeftCoordinate.latitude
        && coordinate.latitude > parkBottomRightCoordinate.latitude
        && coordinate.longitude > parkTopLeftCoordinate.longitude
        && coordinate.longitude < parkBottomRightCoordinate.longitude
  }

  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay)
    -> MKOverlayRenderer {
      if let overlay = overlay as? MapOverlay {
        switch overlay.type {
        case .mainOverlay:
          return overlayViewMain ?? MKPolylineRenderer()
        case .sponsorVendors:
          return overlayViewSponsorVendors ?? MKPolylineRenderer()
        }
      }

      return MKPolylineRenderer()
  }

  // MARK: Annotation selected and related functions

  func mapView(_ mapView: MKMapView,
               didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation as? PrideAnnotation else {
      print("annotation is not a PrideAnnotation")
      directionsButton.isHidden = true
      return
    }
    
    view.image = parkContains(coordinate: annotation.coordinate)
      ? annotationSelectedImage
      : annotationLargeSelectedImage
    
    directionsButton.isHidden = parkContains(coordinate: annotation.coordinate)

    if let item = annotation.item {
      showItemPreviews(mainItem: item)
    }
  }

  func mapView(_ mapView: MKMapView,
               didDeselect view: MKAnnotationView) {
    directionsButton.isHidden = true
    
    guard let annotation = view.annotation as? PrideAnnotation else {
      print("annotation is not a PrideAnnotation")
      return
    }
    
    view.image = parkContains(coordinate: annotation.coordinate)
      ? annotationImage
      : annotationLargeImage
    selectedItems = []
    deselectItemTimer?.invalidate()
    deselectItemTimer = Timer.scheduledTimer(
      timeInterval: 0.05,
      target: self,
      selector: #selector(MapViewController.removeItemPreviews),
      userInfo: nil,
      repeats: false)
  }

  // Removes table view if no item is selected
  @objc func removeItemPreviews() {
    if selectedItems.count != 0 { return }

    UIView.animate(withDuration: 0.3, animations: {
      self.itemPreviewPageViewController?.view.frame.origin = CGPoint(
        x: 0,
        y: self.mapView.frame.height)
    }, completion: {_ in
      self.itemPreviewPageViewController?.view.removeFromSuperview()
      self.itemPreviewPageViewController = nil
    })
    updateMapViewSize(shrink: false)
  }

  func showItemPreviews(mainItem: Item) {
    selectedItems = [mainItem]
      + ParseManager.shared.itemsWithSameLocationAs(item: mainItem)
    refreshItemPreviews()
  }

  private func refreshItemPreviews() {
    guard itemPreviewPageViewController != nil else {
      setUpItemPreviews()
      return
    }
    UIView.animate(withDuration: 0.3, animations: {
      self.itemPreviewPageViewController?.view.frame.origin = CGPoint(
        x: -1,
        y: self.mapView.frame.height)
    }, completion: {_ in
      self.itemPreviewPageViewController?.view.removeFromSuperview()
      self.itemPreviewPageViewController = nil
      self.setUpItemPreviews()
    })
    updateMapViewSize(shrink: false)
  }

  private func setUpItemPreviews() {
    guard let firstPage = pageViewControllerFor(index: 0) else { return }

    let itemPreviewPageViewController = UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal,
      options: nil)
    itemPreviewPageViewController.dataSource = self
    itemPreviewPageViewController.view.frame = CGRect(
      x: -1,
      y: mapView.frame.height,
      width: mapView.frame.width + 2,
      height: itemPreviewsHeight
        + (selectedItems.count > 1 ? pageIndicatorHeight : 0))
    itemPreviewPageViewController.setViewControllers(
      [firstPage],
      direction: UIPageViewControllerNavigationDirection.forward,
      animated: false, completion: nil)

    // Appearance of page view
    let appearance = UIPageControl.appearance()
    appearance.pageIndicatorTintColor = UIColor.gray
    appearance.currentPageIndicatorTintColor = UIColor.black
    appearance.backgroundColor = UIColor.white

    addChildViewController(itemPreviewPageViewController)
    view.addSubview(itemPreviewPageViewController.view)
    itemPreviewPageViewController.didMove(toParentViewController: self)
    self.itemPreviewPageViewController = itemPreviewPageViewController

    UIView.animate(withDuration: 0.3, animations: {
      self.itemPreviewPageViewController?.view.frame.origin = CGPoint(
        x: -1,
        y: self.mapView.frame.height
          - self.itemPreviewsHeight
          - (self.selectedItems.count > 1 ? self.pageIndicatorHeight : 0))
    })
    updateMapViewSize(shrink: true)
  }

  fileprivate func itemPreviewTableViewFor(index: Int) -> UITableView? {
    guard selectedItems.count >= index+1 && index >= 0 else { return nil }

    let itemPreviewTableView = UITableView(frame: CGRect(
      x: -1,
      y: mapView.frame.height,
      width: mapView.frame.width + 2,
      height: itemPreviewsHeight + 1))
    itemPreviewTableView.tag = index
    itemPreviewTableView.dataSource = self
    itemPreviewTableView.delegate = self
    itemPreviewTableView.register(
      UINib(nibName: "EventTableViewCell", bundle: Bundle.main),
      forCellReuseIdentifier: PrideTableViewController.SubviewIdentifier.eventCell.rawValue)
    itemPreviewTableView.register(
      UINib(nibName: "VendorTableViewCell", bundle: Bundle.main),
      forCellReuseIdentifier: PrideTableViewController.SubviewIdentifier.vendorCell.rawValue)
    itemPreviewTableView.register(
      UINib(nibName: "PurpleButtonTableViewCell",
        bundle: Bundle.main),
      forCellReuseIdentifier: PrideTableViewController.SubviewIdentifier.purpleButtonCell.rawValue)
    itemPreviewTableView.rowHeight = itemPreviewsHeight
    itemPreviewTableView.isScrollEnabled = false
    itemPreviewTableView.layer.borderColor = UIColor.gray.cgColor
    itemPreviewTableView.layer.borderWidth = 1
    NotificationCenter.default.addObserver(itemPreviewTableView,
      selector: #selector(UITableView.reloadData),
      name: NotificationName.itemFavoritesDidUpdate,
      object: nil)

    return itemPreviewTableView
  }

  private func updateMapViewSize(shrink: Bool) {
    // Only update for some devices
    guard isIPhone5Size else { return }

    mapViewBottomConstraint.constant = mapViewBottomConstraintOriginalConstant
      + itemPreviewsHeight * (shrink ? 0.7 : 0)
  }

}

// MARK: UIPageViewControllerDataSource

extension MapViewController: UIPageViewControllerDataSource {

  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerBefore viewController: UIViewController)
    -> UIViewController? {
      guard let itemPreviewTableView = viewController.view
        as? UITableView else {
          return nil
      }
      return pageViewControllerFor(index: itemPreviewTableView.tag - 1)
  }

  func pageViewController(_ pageViewController: UIPageViewController,
                          viewControllerAfter viewController: UIViewController)
    -> UIViewController? {
      guard let itemPreviewTableView = viewController.view
        as? UITableView else {
          return nil
      }
      return pageViewControllerFor(index: itemPreviewTableView.tag + 1)
  }

  func presentationCount(
    for pageViewController: UIPageViewController) -> Int {
      return selectedItems.count > 1 ? selectedItems.count : 0
  }

  func presentationIndex(
    for pageViewController: UIPageViewController) -> Int {
      return 0
  }

  fileprivate func pageViewControllerFor(index: Int) -> UIViewController? {
    let vc = UIViewController()
    guard let itemPreviewTableView = itemPreviewTableViewFor(index: index) else {
      return nil
    }
    vc.view = itemPreviewTableView
    return vc
  }

}

// MARK: UITableViewDataSource for itemPreviewTableView

extension MapViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let index = tableView.tag
    guard selectedItems.count >= index+1 else {
      return UITableViewCell()
    }
    if indexPath.row == 1 {
      guard let cell = tableView
        .dequeueReusableCell(withIdentifier: PrideTableViewController.SubviewIdentifier.purpleButtonCell.rawValue,
                             for: indexPath) as? PurpleButtonTableViewCell else {
                              return UITableViewCell()
      }
      if let _ = selectedItems[index] as? Event {
        cell.label.text = "More Information"
      } else {
        cell.label.text = "Visit Vendor Website"
      }
      return cell
    }

    let mainSelectedItem = selectedItems[index]
    if let event = mainSelectedItem as? Event {
      guard let cell = tableView
        .dequeueReusableCell(withIdentifier: PrideTableViewController.SubviewIdentifier.eventCell.rawValue,
                             for: indexPath) as? EventTableViewCell else {
                              return UITableViewCell()
      }
      cell.showDate = true
      cell.event = event
      cell.detailsLabel.font = cell.detailsLabel.font.withSize(14)

      return cell
    } else if let vendor = mainSelectedItem as? Vendor {
      guard let cell = tableView
        .dequeueReusableCell(withIdentifier: PrideTableViewController.SubviewIdentifier.vendorCell.rawValue,
                             for: indexPath) as? VendorTableViewCell else {
                              return UITableViewCell()
      }
      cell.vendor = vendor
      cell.detailsLabel.font = cell.detailsLabel.font.withSize(14)

      return cell
    }

    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    let index = tableView.tag
    guard selectedItems.count >= index+1 else { return 0 }
    let mainSelectedItem = selectedItems[index]
    return (mainSelectedItem.website == nil) ? 1 : 2
  }

}

// MARK: UITableViewDelegate for itemPreviewTableView

extension MapViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView,
                 heightForRowAt indexPath: IndexPath) -> CGFloat {
    let index = tableView.tag
    guard selectedItems.count >= index+1 else { return 0 }
    let mainSelectedItem = selectedItems[index]
    if mainSelectedItem.website != nil {
      if indexPath.row == 0 {
        return itemPreviewsHeight - callToActionButtonCellHeight
      } else if indexPath.row == 1 {
        return callToActionButtonCellHeight
      }
    }

    return itemPreviewsHeight
  }

  func tableView(_ tableView: UITableView,
                 didSelectRowAt indexPath: IndexPath) {
    guard indexPath.row == 1 else { return }
    let index = tableView.tag
    guard selectedItems.count >= index+1 else { return }
    let mainSelectedItem = selectedItems[index]
    guard var urlString = mainSelectedItem.website else { return }

    if !urlString.hasPrefix("http") {
      urlString = "http://" + urlString
    }

    guard let url = URL(string: urlString) else { return }

    let svc = SFSafariViewController(url: url)
    present(svc, animated: true, completion: nil)
  }

}
