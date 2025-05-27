import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderTests: XCTestCase {
    func test_setLocation_degreesAndMinutes() {
        let igrfBuilder = IGRFClient.create(igrfGen: .igrf14)
        XCTAssertEqual(igrfBuilder.igrfGen, .igrf14)
        let igrfBuilderWithCoordinate = igrfBuilder.set(system: .geodetic)
        XCTAssertEqual(igrfBuilderWithCoordinate.igrfGen, .igrf14)
        XCTAssertEqual(igrfBuilderWithCoordinate.coordinateSystem, .geodetic)
    }
}
