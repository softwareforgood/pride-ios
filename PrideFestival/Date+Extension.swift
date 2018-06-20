import Foundation

extension Date {
  static func dateString(fromDate date: Date,
                         showYear: Bool,
                         timezone: TimeZone = .current) -> String {
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = showYear ? "MMM d, yyyy" : "MMM d"
    outputFormatter.timeZone = timezone
    return outputFormatter.string(from: date)
  }

  static func timeString(fromDate date: Date,
                         timezone: TimeZone = .current) -> String {
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "h:mm a"
    outputFormatter.timeZone = timezone
    return outputFormatter.string(from: date)
  }

  static func isDate(_ date1: Date, onSameDayAsDate date2: Date) -> Bool {
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.month, .year, .day]

    let dateComponents1 = calendar.dateComponents(components, from: date1)
    let dateComponents2 = calendar.dateComponents(components, from: date2)

    return dateComponents1 == dateComponents2
  }
}
