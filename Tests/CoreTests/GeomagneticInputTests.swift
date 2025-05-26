import XCTest

@testable import IGRFCore

final class GeomagneticInputTests: XCTestCase {
    func testDate() {
        // 2025.25年のテストケース
        let input = GeomagneticInput(
            decimalYear: 2025.25,
            alt: 6370.910156840483,
            lat: 35.658,
            colat: 54.52408663919481,
            lon: 139.7016,
            coordinateSystem: .geodetic,
            sd: 0.003178006028319621,
            cd: 0.9999949501260912
        )

        // 2025年4月1日を期待値として設定
        let calendar = Calendar(identifier: .gregorian)
        let expectedDate = calendar.date(from: DateComponents(year: 2025, month: 4, day: 2))
            .unsafelyUnwrapped

        let inputDate = input.date.unsafelyUnwrapped
        XCTAssertEqual(
            calendar.component(.year, from: inputDate),
            calendar.component(.year, from: expectedDate),
            "年が一致しません"
        )
        XCTAssertEqual(
            calendar.component(.month, from: inputDate),
            calendar.component(.month, from: expectedDate),
            "月が一致しません"
        )
        XCTAssertEqual(
            calendar.component(.day, from: inputDate),
            calendar.component(.day, from: expectedDate),
            "日が一致しません"
        )
    }
}
