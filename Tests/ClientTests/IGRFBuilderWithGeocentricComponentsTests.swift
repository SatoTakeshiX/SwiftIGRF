import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderWithGeocentricComponentsTests: XCTestCase {
    func test_setDate_succeeds_whenDateIsInRange() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 39.9, longitude: 139.7, format: .decimalDegrees)
            )
            .set(alt: 0)

        let validDate = Date(timeIntervalSince1970: 1_577_836_800)  // January 1, 2020
        let result = try builder.set(date: validDate)
        XCTAssertEqual(result.date, 2020.0, accuracy: 0.01)
    }

    func test_setDate_throwsError_whenDateIsOutOfRange() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 39.9, longitude: 139.7, format: .decimalDegrees)
            )
            .set(alt: 0)

        let invalidDate = Date(timeIntervalSince1970: 2082_758_400)  // January 1, 2036
        XCTAssertThrowsError(try builder.set(date: invalidDate)) { error in
            guard case IGRFError.invalidDate = error else {
                XCTFail("Expected IGRFError.invalidDate but got \(error)")
                return
            }
        }
    }

    func test_setDecimalYear_succeeds_whenDateIsInRange() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 39.9, longitude: 139.7, format: .decimalDegrees)
            )
            .set(alt: 0)

        let validDecimalYear = 2020.5
        let result = try builder.set(decimalYear: validDecimalYear)
        XCTAssertEqual(result.date, validDecimalYear, accuracy: 0.01)
    }

    func test_setDecimalYear_throwsError_whenDateIsOutOfRange() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 39.9, longitude: 139.7, format: .decimalDegrees)
            )
            .set(alt: 0)

        let invalidDecimalYear = 2036.0
        XCTAssertThrowsError(try builder.set(decimalYear: invalidDecimalYear)) { error in
            guard case IGRFError.invalidDate = error else {
                XCTFail("Expected IGRFError.invalidDate but got \(error)")
                return
            }
        }
    }
}
