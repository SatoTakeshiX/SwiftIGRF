import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderWithLocationTests: XCTestCase {
    func test_setAlt_geocentric_throwsError_whenAltitudeIsLessThan3485() throws {
        let existedAlt: Double = 3485
        let invalidAlt: Double = 3484
        // Test with altitude exactly at 3485 (should not throw)
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geocentric)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 1, longitude: 1, format: .degreesAndMinutes)
            )
            .set(alt: existedAlt)

        XCTAssertEqual(builder.components.radius, 3485)

        // Test with altitude at 3484 (should throw)
        XCTAssertThrowsError(
            try IGRFClient.create(igrfGen: .igrf14)
                .set(system: .geocentric)
                .set(
                    inputLocation: IGRFLocation(
                        latitude: 1, longitude: 1, format: .degreesAndMinutes)
                )
                .set(alt: invalidAlt)
        ) { error in
            guard case IGRFError.invalidAltitude = error else {
                XCTFail("Expected IGRFError.invalidAltitude but got \(error)")
                return
            }
        }
    }
}
