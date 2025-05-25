import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderWithCoordinateTests: XCTestCase {
    func test_setLocation_degreesAndMinutes() {
        let igrfBuilder = IGRFClient.create(igrfGen: .igrf14)
        let igrfBuilderWithCoordinate = igrfBuilder.set(system: .geodetic)
        XCTAssertEqual(igrfBuilderWithCoordinate.igrfGen, .igrf14)
        XCTAssertEqual(igrfBuilderWithCoordinate.coordinateSystem, .geodetic)
        let igrfBuilderWithLocation = igrfBuilderWithCoordinate.set(
            inputLocation: IGRFLocation(
                latitude: 35.30, longitude: 139.30, format: .degreesAndMinutes),
            altitude: 0.0
        )
        XCTAssertEqual(igrfBuilderWithLocation.igrfGen, .igrf14)
        XCTAssertEqual(igrfBuilderWithLocation.coordinateSystem, .geodetic)
        XCTAssertEqual(
            igrfBuilderWithLocation.inputLocation,
            IGRFLocation(latitude: 35.30, longitude: 139.30, format: .degreesAndMinutes))
        XCTAssertEqual(
            igrfBuilderWithLocation.degreesLocation,
            DegreesLocation(latitude: 35.5, longitude: 139.5))
        XCTAssertEqual(igrfBuilderWithLocation.altitude, 0.0)
    }
}
