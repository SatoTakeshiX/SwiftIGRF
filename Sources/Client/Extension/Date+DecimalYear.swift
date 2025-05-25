import Foundation

extension Date {
    /// Converts Date to a Double value in years
    /// Example: July 1, 2022 → 2022.5
    func decimalYear() -> Double {
        let calendar = Calendar(identifier: .gregorian)
        // 1) Integer part of the year
        let year = calendar.component(.year, from: self)

        // 2) January 1st 00:00 of the year
        guard
            let startOfYear = calendar.date(
                from: DateComponents(year: year, month: 1, day: 1)
            ),
            // 3) January 1st 00:00 of the next year
            let startOfNextYear = calendar.date(
                from: DateComponents(year: year + 1, month: 1, day: 1)
            )
        else {
            return Double(year)  // Return only integer part if failed
        }

        // 4) Calculate elapsed seconds and total seconds in the year
        let elapsed = self.timeIntervalSince(startOfYear)
        let yearLength = startOfNextYear.timeIntervalSince(startOfYear)

        // 5) Year + elapsed proportion
        return Double(year) + elapsed / yearLength
    }
}
