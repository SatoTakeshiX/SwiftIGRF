import IGRFCore
import XCTest

@testable import IGRFClient

final class DateDecimalYearTests: XCTestCase {
    func test_toYearDouble() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2022, month: 1, day: 1))
            .unsafelyUnwrapped
        let yearDouble = date.decimalYear()
        XCTAssertEqual(yearDouble, 2022.0)

        let date2 = calendar.date(from: DateComponents(year: 2022, month: 7, day: 1))
            .unsafelyUnwrapped
        let yearDouble2 = date2.decimalYear()

        XCTAssertEqual(yearDouble2, 2022.495890410959)
    }
}
