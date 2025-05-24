// import XCTest

// @testable import DevFlyingStarApp

// final class IGRFDataManagerTests: XCTestCase {

//     func testSuccessfulSynthesis() throws {
//         // Given
//         let igrfGen = 13
//         let latitude = 35.6812
//         let longitude = 139.7671
//         let altitude = 0.0
//         let date = Date()

//         // When
//         let result = try IGRFDataManager.create(igrfGen: igrfGen)
//             .setCoordinateSystem(.geodetic)
//             .setLocation(latitude: latitude, longitude: longitude, altitude: altitude)
//             .setDate(date)
//             .synthesize()

//         // Then
//         XCTAssertNotNil(result)
//         // 地磁気の値が物理的に妥当な範囲内にあることを確認
//         XCTAssertTrue(result.totalIntensity >= 0)
//         XCTAssertTrue(result.totalIntensity <= 100000)  // 100,000 nT以下であることを確認
//     }

//     func testInvalidIGRFGeneration() {
//         // Given
//         let invalidIGRFGen = 15  // 1-14の範囲外

//         // When & Then
//         XCTAssertThrowsError(try IGRFDataManager.create(igrfGen: invalidIGRFGen)) { error in
//             XCTAssertEqual(error as? IGRFError, .invalidIGRFGeneration)
//         }
//     }

//     func testValidIGRFGenerationRange() {
//         // Given
//         let validIGRFGens = [1, 7, 14]  // 範囲内の値

//         for igrfGen in validIGRFGens {
//             // When & Then
//             XCTAssertNoThrow(try IGRFDataManager.create(igrfGen: igrfGen))
//         }
//     }

//     func testGeomagneticValuesAreReasonable() throws {
//         // Given
//         let testLocations = [
//             (lat: 35.6812, lon: 139.7671),  // 東京
//             (lat: 40.7128, lon: -74.0060),  // ニューヨーク
//             (lat: 51.5074, lon: -0.1278),  // ロンドン
//             (lat: -33.8688, lon: 151.2093),  // シドニー
//         ]

//         for location in testLocations {
//             // When
//             let result = try IGRFDataManager.create(igrfGen: 13)
//                 .setCoordinateSystem(.geodetic)
//                 .setLocation(latitude: location.lat, longitude: location.lon, altitude: 0)
//                 .setDate(Date())
//                 .synthesize()

//             // Then
//             // 地磁気の値が物理的に妥当な範囲内にあることを確認
//             XCTAssertTrue(result.totalIntensity >= 20000)  // 20,000 nT以上
//             XCTAssertTrue(result.totalIntensity <= 70000)  // 70,000 nT以下

//             // 偏角が-180度から180度の範囲内にあることを確認
//             XCTAssertTrue(result.declination >= -180)
//             XCTAssertTrue(result.declination <= 180)

//             // 伏角が-90度から90度の範囲内にあることを確認
//             XCTAssertTrue(result.inclination >= -90)
//             XCTAssertTrue(result.inclination <= 90)
//         }
//     }
// }
