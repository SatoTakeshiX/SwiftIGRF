import XCTest

@testable import SwiftIGRF

final class IOOptionsTests: XCTestCase {
    // makeGridArraysをテスト
    func testMakeGridArrays() {
        // 入力値
        let lats: Double = 0
        let late: Double = 90
        let lati: Double = 10
        let lons: Double = 0
        let lone: Double = 360
        let loni: Double = 20

        // 関数を実行
        let (colatArray, lonArray, latArray) = IOOptions.makeGridArrays(
            lats: lats, late: late, lati: lati, lons: lons, lone: lone, loni: loni
        )

        // 期待される出力値
        let expectedColatArray: [Double] = [
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
            90, 80, 70, 60, 50, 40, 30, 20, 10,
        ]

        let expectedLonArray: [Double] = [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            20, 20, 20, 20, 20, 20, 20, 20, 20,
            40, 40, 40, 40, 40, 40, 40, 40, 40,
            60, 60, 60, 60, 60, 60, 60, 60, 60,
            80, 80, 80, 80, 80, 80, 80, 80, 80,
            100, 100, 100, 100, 100, 100, 100, 100, 100,
            120, 120, 120, 120, 120, 120, 120, 120, 120,
            140, 140, 140, 140, 140, 140, 140, 140, 140,
            160, 160, 160, 160, 160, 160, 160, 160, 160,
            180, 180, 180, 180, 180, 180, 180, 180, 180,
            200, 200, 200, 200, 200, 200, 200, 200, 200,
            220, 220, 220, 220, 220, 220, 220, 220, 220,
            240, 240, 240, 240, 240, 240, 240, 240, 240,
            260, 260, 260, 260, 260, 260, 260, 260, 260,
            280, 280, 280, 280, 280, 280, 280, 280, 280,
            300, 300, 300, 300, 300, 300, 300, 300, 300,
            320, 320, 320, 320, 320, 320, 320, 320, 320,
            340, 340, 340, 340, 340, 340, 340, 340, 340,
        ]

        let expectedLatArray: [Double] = [
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
            0, 10, 20, 30, 40, 50, 60, 70, 80,
        ]

        // 結果を検証
        XCTAssertEqual(colatArray, expectedColatArray, "余緯度の配列が期待値と一致しません")
        XCTAssertEqual(lonArray, expectedLonArray, "経度の配列が期待値と一致しません")
        XCTAssertEqual(latArray, expectedLatArray, "緯度の配列が期待値と一致しません")
    }

    func testMakeContents() {
        // SinglePointTimeのmakeContentメソッドのテスト
        let singlePointTime = SinglePointTime()
        
        // テスト用の入力データを作成
        let input = GeomagneticInput(
            date: 2025.25,
            alt: 6370.910156840483,
            lat: 35.658,
            colat: 54.52408663919481,
            lon: 139.7016,
            coordinateSystem: .geodetic,
            sd: 0.003178006028319621,
            cd: 0.9999949501260912
        )
        
        // テスト用の結果データを作成
        let result = MagneticFieldSynthesizerResult(
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
        
        // makeContentメソッドを呼び出し
        let content = singlePointTime.makeContent(input: input, result: result, igrfGen: 14)
        
        // 期待される出力
        let expectedContent = """

            Geomagnetic field values at: 35.6580° / 139.7016°, at altitude 0.0 for 2025.25 using IGRF-14
            Declination (D):  -7.865°
            Inclination (I):  49.490°
            Horizontal intensity (H):  30412.6 nT
            Total intensity (F)     :  46818.8 nT
            North component (X)     :  30126.5 nT
            East component (Y)      :  -4161.6 nT
            Vertical component (Z)  :  35596.0 nT
            Declination SV (D):  -2.40 arcmin/yr
            Inclination SV (I):  1.26 arcmin/yr
            Horizontal SV (H):  6.4 nT/yr
            Total SV (F)     :  29.9 nT/yr
            North SV (X)     :  3.4 nT/yr
            East SV (Y)      :  -21.9 nT/yr
            Vertical SV (Z)  :  33.9 nT/yr
            """
        
        // 結果を検証
        XCTAssertEqual(content, expectedContent, "makeContentの出力が期待値と一致しません")
    }
}
