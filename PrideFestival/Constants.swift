import UIKit

let isIPhone6PlusSize = UIScreen.main.bounds.height == 736
let isIPhone6Size = UIScreen.main.bounds.height == 667
let isIPhone5Size = UIScreen.main.bounds.height == 568

let normalCellHeight: CGFloat = 130

let bundleID = Bundle.main.bundleIdentifier
  ?? "com.softwareforgood.Twin-Cities-Pride-Festival-App"

let parseApplicationID = (Bundle.main.infoDictionary?["CFBundleParseApplicationID"] as? String) ?? ""
let parseServerURL = (Bundle.main.infoDictionary?["CFBundleParseServerURL"] as? String) ?? ""
