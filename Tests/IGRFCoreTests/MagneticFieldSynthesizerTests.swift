import XCTest

@testable import IGRFCore

final class MagneticFieldSynthesizerTests: XCTestCase {
    func testSynthesizeAtTokyo() throws {
        let synthesizer = MagneticFieldSynthesizer()

        guard
            let url = Bundle.module.url(forResource: "coeffs", withExtension: "json")
        else {
            XCTFail("coeffs.json が見つかりません")
            return
        }

        let data = try Data(contentsOf: url)

        // 4. JSON デコード
        let decoder = JSONDecoder()
        let mockCoeffs = try decoder.decode([[Double]].self, from: data)

        // 入力データとIGRFモデルデータを設定
        let input = GeomagneticInput(
            date: 2025.25,
            alt: 6370.910156840483,
            lat: 35.658,
            colat: 54.52408663919481,
            lon: 139.7016,
            coordinateSystem: CoordinateSystemType.geodetic,
            sd: 0.003178006028319621,
            cd: 0.9999949501260912
        )

        let igrfData = IGRFModel(
            time: [
                1900.0, 1905.0, 1910.0, 1915.0, 1920.0, 1925.0, 1930.0, 1935.0, 1940.0, 1945.0,
                1950.0, 1955.0, 1960.0, 1965.0, 1970.0, 1975.0, 1980.0, 1985.0, 1990.0, 1995.0,
                2000.0, 2005.0, 2010.0, 2015.0, 2020.0, 2025.0, 2030.0,
            ],
            coeffs: mockCoeffs,
            parameters: Parameters(
                shc: "IGRF14.SHC", nmin: 1, nmax: 13, N: 27, order: 2, step: 1, startYear: 1900,
                endYear: 2030)
        )

        let result = synthesizer.synthesize(input: input, igrfData: igrfData)

        // 期待される結果
        let expectedResult = MagneticFieldSynthesizerResult(
            geoComponents: GeomagneticComponents(
                declination: -7.864852276442097,
                horizontalIntensity: 30412.5897165281,
                inclination: 49.49004803313084,
                effectiveField: 46818.843316914346
            ),
            geoComponentsSV: GeomagneticComponents(
                declination: -2.397328195079951,
                horizontalIntensity: 6.402221235353567,
                inclination: 1.257651794730194,
                effectiveField: 29.895257190842567
            ),
            cartesianComps: CartesianMagneticComponents(
                x: 30126.516468811737,
                y: -4161.564455861024,
                z: 35596.04579539565
            ),
            cartesianCompsSV: CartesianMagneticComponents(
                x: 3.443881324490031,
                y: -21.883216042947762,
                z: 33.852820298061374
            ),
            cartesianCompsMain: CartesianMagneticComponents(
                x: 30125.655498480617,
                y: -4156.09365185029,
                z: 35587.582590321144
            )
        )

        // 結果の検証
        XCTAssertEqual(
            result.geoComponents.declination, expectedResult.geoComponents.declination,
            accuracy: 0.0001)
        XCTAssertEqual(
            result.geoComponents.horizontalIntensity,
            expectedResult.geoComponents.horizontalIntensity, accuracy: 0.0001)
        XCTAssertEqual(
            result.geoComponents.inclination, expectedResult.geoComponents.inclination,
            accuracy: 0.0001)
        XCTAssertEqual(
            result.geoComponents.effectiveField, expectedResult.geoComponents.effectiveField,
            accuracy: 0.0001)

        XCTAssertEqual(result.cartesianComps.x, expectedResult.cartesianComps.x, accuracy: 0.0001)
        XCTAssertEqual(result.cartesianComps.y, expectedResult.cartesianComps.y, accuracy: 0.0001)
        XCTAssertEqual(result.cartesianComps.z, expectedResult.cartesianComps.z, accuracy: 0.0001)
    }
}
