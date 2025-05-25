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

        // 分が0のケース
        let igrfBuilderWithLocation0 = igrfBuilderWithCoordinate.set(
            inputLocation: IGRFLocation(
                latitude: 35.00, longitude: 139.00, format: .degreesAndMinutes),
            altitude: 0.0
        )

        XCTAssertEqual(
            igrfBuilderWithLocation0.degreesLocation,
            DegreesLocation(latitude: 35.0, longitude: 139.0)
        )

        // 分が15のケース
        let igrfBuilderWithLocation15 = igrfBuilderWithCoordinate.set(
            inputLocation: IGRFLocation(
                latitude: 35.15, longitude: 139.15, format: .degreesAndMinutes),
            altitude: 0.0
        )

        XCTAssertEqual(
            igrfBuilderWithLocation15.degreesLocation,
            DegreesLocation(latitude: 35.25, longitude: 139.25)
        )

        // 分が45のケース
        let igrfBuilderWithLocation45 = igrfBuilderWithCoordinate.set(
            inputLocation: IGRFLocation(
                latitude: 35.45, longitude: 139.45, format: .degreesAndMinutes),
            altitude: 0.0
        )

        XCTAssertEqual(
            igrfBuilderWithLocation45.degreesLocation,
            DegreesLocation(latitude: 35.75, longitude: 139.75)
        )

        // 分が60のケース
        let igrfBuilderWithLocation60 = igrfBuilderWithCoordinate.set(
            inputLocation: IGRFLocation(
                latitude: 35.60, longitude: 139.60, format: .degreesAndMinutes),
            altitude: 0.0
        )

        XCTAssertEqual(
            igrfBuilderWithLocation60.degreesLocation,
            DegreesLocation(latitude: 36.0, longitude: 140.0)
        )
    }

    func test_splitUsingModf_roundsTo6DecimalPlaces() {
        let igrfBuilder = IGRFClient.create(igrfGen: .igrf14)
        let igrfBuilderWithCoordinate = igrfBuilder.set(system: .geodetic)

        // 小数点以下6桁以上の値をテスト
        let (degrees1, minutes1) = igrfBuilderWithCoordinate.splitUsingModf(35.123456)
        XCTAssertEqual(degrees1, 35.0)
        XCTAssertEqual(minutes1, 12.34560)

        // 小数点以下5桁の値をテスト
        let (degrees2, minutes2) = igrfBuilderWithCoordinate.splitUsingModf(35.12345)
        XCTAssertEqual(degrees2, 35.0)
        XCTAssertEqual(minutes2, 12.34500)

        // 小数点以下4桁の値をテスト
        let (degrees3, minutes3) = igrfBuilderWithCoordinate.splitUsingModf(35.1234)
        XCTAssertEqual(degrees3, 35.0)
        XCTAssertEqual(minutes3, 12.34000)
    }
}
