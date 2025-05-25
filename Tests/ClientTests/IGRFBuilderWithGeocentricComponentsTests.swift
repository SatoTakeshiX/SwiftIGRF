import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderWithGeocentricComponentsTests: XCTestCase {
    func test_setAlt() throws {
        let builder: IGRFBuilderWithGeocentricComponents = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 1, longitude: 1, format: .degreesAndMinutes)
            )
            .set(alt: 0)
    }
    func test_setAlt_geocentric_throwsError_whenAltitudeIsLessThan3485() throws {
        // Test with altitude exactly at 3485 (should not throw)
        let builder1 = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geocentric)
            .set(
                inputLocation: IGRFLocation(
                    latitude: 1, longitude: 1, format: .degreesAndMinutes)
            )
            .set(alt: 3485)
        
        XCTAssertEqual(builder1.components.radius, 3485)
        
        // Test with altitude at 3484 (should throw)
        XCTAssertThrowsError(
            try IGRFClient.create(igrfGen: .igrf14)
                .set(system: .geocentric)
                .set(
                    inputLocation: IGRFLocation(
                        latitude: 1, longitude: 1, format: .degreesAndMinutes)
                )
                .set(alt: 3484)
        ) { error in
            guard case IGRFError.invalidAltitude = error else {
                XCTFail("Expected IGRFError.invalidAltitude but got \(error)")
                return
            }
        }
    }

    
}
