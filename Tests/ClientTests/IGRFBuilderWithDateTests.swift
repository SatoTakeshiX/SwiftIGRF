import IGRFCore
import XCTest

@testable import IGRFClient

final class IGRFBuilderWithDateTests: XCTestCase {
    func test_setDate_succeeds_whenDateIsInRange() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: .degreesAndMinutes(
                    latDegrees: 35, latMinutes: 39.48, lonDegrees: 139, lonMinutes: 42.096)
            )
            .set(alt: 0)
            .set(decimalYear: 2025.25)

        let result = try builder.synthesize()
        XCTAssertEqual(String(format: "%.4f", result.input.lat), "35.6580")
        XCTAssertEqual(String(format: "%.4f", result.input.lon), "139.7016")
        XCTAssertEqual(String(format: "%.1f", result.alt), "0.0")
        XCTAssertEqual(String(format: "%.2f", result.input.decimalYear), "2025.25")
        XCTAssertEqual(result.igrfGeneration, 14)
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.declination), "-7.865")
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.inclination), "49.490")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.horizontalIntensity), "30412.6")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.effectiveField), "46818.8")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.x), "30126.5")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.y), "-4161.6")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.z), "35596.0")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.declination), "-2.40")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.inclination), "1.26")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponentsSV.horizontalIntensity), "6.4")
        XCTAssertEqual(String(format: "%.1f", result.result.geoComponentsSV.effectiveField), "29.9")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.x), "3.4")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.y), "-21.9")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.z), "33.9")
    }

    func test_setDate_succeeds_whenDateIsInRange_withDecimalDegrees() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: .decimalDegrees(
                    latitude: 35.6812, longitude: 139.7671248)
            )
            .set(alt: 0)
            .set(decimalYear: 2025.0)

        let result = try builder.synthesize()
        XCTAssertEqual(String(format: "%.4f", result.input.lat), "35.6812")
        XCTAssertEqual(String(format: "%.4f", result.input.lon), "139.7671")
        XCTAssertEqual(String(format: "%.1f", result.alt), "0.0")
        XCTAssertEqual(String(format: "%.2f", result.input.decimalYear), "2025.00")
        XCTAssertEqual(result.igrfGeneration, 14)
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.declination), "-7.852")
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.inclination), "49.502")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.horizontalIntensity), "30397.1")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.effectiveField), "46806.1")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.x), "30112.1")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.y), "-4152.5")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.z), "35592.6")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.declination), "-2.40")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.inclination), "1.25")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponentsSV.horizontalIntensity), "6.5")
        XCTAssertEqual(String(format: "%.1f", result.result.geoComponentsSV.effectiveField), "29.9")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.x), "3.5")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.y), "-21.9")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.z), "33.8")
    }

    func test_setDate_succeeds_whenDateIsInRange_withDate() throws {
        let builder = try IGRFClient.create(igrfGen: .igrf14)
            .set(system: .geodetic)
            .set(
                inputLocation: .decimalDegrees(
                    latitude: 35.6812, longitude: 139.7671248)
            )
            .set(alt: 0)
            .set(date: Date(timeIntervalSince1970: 1_577_836_800))  // January 1, 2020

        let result = try builder.synthesize()
        XCTAssertEqual(String(format: "%.4f", result.input.lat), "35.6812")
        XCTAssertEqual(String(format: "%.4f", result.input.lon), "139.7671")
        XCTAssertEqual(String(format: "%.1f", result.alt), "0.0")
        XCTAssertEqual(String(format: "%.2f", result.input.decimalYear), "2020.00")
        XCTAssertEqual(result.igrfGeneration, 14)
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.declination), "-7.610")
        XCTAssertEqual(String(format: "%.3f", result.result.geoComponents.inclination), "49.499")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.horizontalIntensity), "30315.1")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponents.effectiveField), "46677.2")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.x), "30048.1")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.y), "-4014.4")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianComps.z), "35493.1")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.declination), "-2.91")
        XCTAssertEqual(String(format: "%.2f", result.result.geoComponentsSV.inclination), "0.04")
        XCTAssertEqual(
            String(format: "%.1f", result.result.geoComponentsSV.horizontalIntensity), "16.4")
        XCTAssertEqual(String(format: "%.1f", result.result.geoComponentsSV.effectiveField), "25.8")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.x), "12.8")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.y), "-27.6")
        XCTAssertEqual(String(format: "%.1f", result.result.cartesianCompsSV.z), "19.9")
    }
}
