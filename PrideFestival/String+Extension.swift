import Foundation

extension String {

  func firstCharacter() -> String {
    return self.count > 0 ? String(self[startIndex]) : ""
  }

  func isNumber() -> Bool {
    if let _ = Int(firstCharacter()) { return true }
    return false
  }

}
