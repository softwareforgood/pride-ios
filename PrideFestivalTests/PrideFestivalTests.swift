import XCTest
@testable import PrideFestival

class PrideFestivalTests: XCTestCase {

  func testThatItReturnsDateString() {
    let date1 = Date(timeIntervalSince1970: 1454023425)
    let dateString1 = Date.dateString(fromDate: date1, showYear: true,
                                      timezone: TimeZone(identifier: "US/Central")!)
    XCTAssertEqual(dateString1, "Jan 28, 2016")

    let date2 = Date(timeIntervalSince1970: 1420072075)
    let dateString2 = Date.dateString(fromDate: date2, showYear: true,
                                      timezone: TimeZone(identifier: "Europe/Istanbul")!)
    XCTAssertEqual(dateString2, "Jan 1, 2015")
  }

  func testThatItReturnsTimeString() {
    let date1 = Date(timeIntervalSince1970: 1454023425)
    let timeString1 = Date.timeString(fromDate: date1,
                                      timezone: TimeZone(identifier: "US/Central")!)
    XCTAssertEqual(timeString1, "5:23 PM")

    let date2 = Date(timeIntervalSince1970: 1420072075)
    let timeString2 = Date.timeString(fromDate: date2,
                                      timezone: TimeZone(identifier: "Europe/Istanbul")!)
    XCTAssertEqual(timeString2, "2:27 AM")
  }

}
