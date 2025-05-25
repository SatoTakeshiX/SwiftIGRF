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
            inputLocation:
                .degreesAndMinutes(latDegrees: 35, latMinutes: 30, lonDegrees: 139, lonMinutes: 30)
        )

        XCTAssertEqual(igrfBuilderWithLocation.igrfGen, .igrf14)
        XCTAssertEqual(igrfBuilderWithLocation.coordinateSystem, .geodetic)
        XCTAssertEqual(
            igrfBuilderWithLocation.inputLocation,
            .degreesAndMinutes(latDegrees: 35, latMinutes: 30, lonDegrees: 139, lonMinutes: 30))
        XCTAssertEqual(
            igrfBuilderWithLocation.degreesLocation,
            DegreesLocation(latitude: 35.5, longitude: 139.5))

        // 分が0のケース
        let igrfBuilderWithLocation0 = igrfBuilderWithCoordinate.set(
            inputLocation: .degreesAndMinutes(
                latDegrees: 35, latMinutes: 0, lonDegrees: 139, lonMinutes: 0)
        )

        XCTAssertEqual(
            igrfBuilderWithLocation0.degreesLocation,
            DegreesLocation(latitude: 35.0, longitude: 139.0)
        )

        // 分が15のケース
        let igrfBuilderWithLocation15 = igrfBuilderWithCoordinate.set(
            inputLocation: .degreesAndMinutes(
                latDegrees: 35, latMinutes: 15, lonDegrees: 139, lonMinutes: 15)
        )

        XCTAssertEqual(
            igrfBuilderWithLocation15.degreesLocation,
            DegreesLocation(latitude: 35.25, longitude: 139.25)
        )

        // 分が45のケース
        let igrfBuilderWithLocation45 = igrfBuilderWithCoordinate.set(
            inputLocation: .degreesAndMinutes(
                latDegrees: 35, latMinutes: 45, lonDegrees: 139, lonMinutes: 45)
        )

        XCTAssertEqual(
            igrfBuilderWithLocation45.degreesLocation,
            DegreesLocation(latitude: 35.75, longitude: 139.75)
        )

        // 分が60のケース
        let igrfBuilderWithLocation60 = igrfBuilderWithCoordinate.set(
            inputLocation: .degreesAndMinutes(
                latDegrees: 35, latMinutes: 60, lonDegrees: 139, lonMinutes: 60)
        )

        XCTAssertEqual(
            igrfBuilderWithLocation60.degreesLocation,
            DegreesLocation(latitude: 36.0, longitude: 140.0)
        )
    }
}
