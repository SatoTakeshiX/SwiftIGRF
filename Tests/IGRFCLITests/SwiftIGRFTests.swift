import XCTest

@testable import IGRFCore

final class SwiftIGRFTests: XCTestCase {
    func testExample() throws {
        // これは基本的なテストケースの例です
        XCTAssertTrue(true)
    }

    // テスト用の入力データ
    let coeffs: [[Double]] = [
        [-31543, -2298, 5922],  // n=1の係数
        [-677, 2905, -1061],  // n=2の係数
    ]
    let radius: Double = 6371.2  // 地球の平均半径
    let theta: Double = 45.0  // 余緯度
    let phi: Double = 0.0  // 経度

    // Pythonの結果（事前に計算）
    let expectedB_radius: Double = -29496.57
    let expectedB_theta: Double = -1669.05
    let expectedB_phi: Double = 5077.99

    func testSynthValues() {
        // 入力値の準備
        let coeffsT: [Double] = [
            -2.934685e+04, -1.407800e+03, 4.540125e+03, -2.559000e+03, 2.949575e+03,
            -3.140425e+03, 1.646625e+03, -8.169750e+02, 1.360525e+03, -2.405300e+03,
            -5.595000e+01, 1.243900e+03, 2.375500e+02, 4.495000e+02, -5.505750e+02,
            8.942750e+02, 7.990250e+02, 2.782750e+02, 5.435000e+01, -1.329750e+02,
            -2.797500e+02, 2.124000e+02, 1.030000e+01, -3.764250e+02, -2.327500e+02,
            3.693250e+02, 4.517500e+01, 1.872000e+02, 2.205250e+02, -1.385250e+02,
            -1.227750e+02, -1.413250e+02, 4.332500e+01, 2.115000e+01, 1.066750e+02,
            6.425000e+01, 6.372500e+01, -1.832500e+01, 7.690000e+01, 1.640000e+01,
            -1.154000e+02, 4.880000e+01, -4.110000e+01, -5.960000e+01, 1.500000e+01,
            1.107500e+01, -6.057500e+01, 7.302500e+01, 7.957500e+01, -7.692500e+01,
            -4.875000e+01, -8.825000e+00, -1.427500e+01, 5.942500e+01, -1.175000e+00,
            1.577500e+01, 2.350000e+01, 2.300000e+00, -7.625000e+00, -1.140000e+01,
            -2.497500e+01, 1.452500e+01, -2.275000e+00, 2.307500e+01, 1.095000e+01,
            7.125000e+00, -1.750000e+01, -1.250000e+01, 2.100000e+00, 1.142500e+01,
            -2.182500e+01, -9.600000e+00, 1.697500e+01, 1.257500e+01, 1.492500e+01,
            5.500000e-01, -1.680000e+01, -5.125000e+00, 1.075000e+00, 3.950000e+00,
            4.700000e+00, 8.000000e+00, -2.480000e+01, 3.000000e+00, 1.210000e+01,
            -2.000000e-01, 8.300000e+00, -2.500000e+00, -3.400000e+00, -1.310000e+01,
            -5.300000e+00, 2.400000e+00, 7.200000e+00, 8.600000e+00, -6.000000e-01,
            -8.700000e+00, 8.000000e-01, -1.280000e+01, 9.800000e+00, -1.300000e+00,
            -6.400000e+00, 3.300000e+00, 2.000000e-01, 1.000000e-01, 2.000000e+00,
            2.500000e+00, -1.000000e+00, 5.400000e+00, -5.000000e-01, -9.000000e+00,
            -9.000000e-01, 4.000000e-01, 1.500000e+00, -4.200000e+00, 9.000000e-01,
            -3.800000e+00, -2.600000e+00, 9.000000e-01, -3.900000e+00, -9.000000e+00,
            3.000000e+00, -1.400000e+00, 0.000000e+00, -2.500000e+00, 2.800000e+00,
            2.400000e+00, -6.000000e-01, -6.000000e-01, 1.000000e-01, 0.000000e+00,
            5.000000e-01, -6.000000e-01, -3.000000e-01, -1.000000e-01, -1.200000e+00,
            1.100000e+00, -1.700000e+00, -1.000000e+00, -2.900000e+00, -1.000000e-01,
            -1.800000e+00, 2.600000e+00, -2.300000e+00, -2.000000e+00, -1.000000e-01,
            -1.200000e+00, 4.000000e-01, 6.000000e-01, 1.200000e+00, 1.000000e+00,
            -1.200000e+00, -1.500000e+00, 6.000000e-01, 0.000000e+00, 5.000000e-01,
            6.000000e-01, 5.000000e-01, -2.000000e-01, -1.000000e-01, 8.000000e-01,
            -5.000000e-01, 1.000000e-01, -2.000000e-01, -9.000000e-01, -1.200000e+00,
            1.000000e-01, -7.000000e-01, 2.000000e-01, 2.000000e-01, -9.000000e-01,
            -9.000000e-01, 6.000000e-01, 7.000000e-01, 7.000000e-01, 1.200000e+00,
            -2.000000e-01, -3.000000e-01, 5.000000e-01, -1.300000e+00, 1.000000e-01,
            -1.000000e-01, 7.000000e-01, 2.000000e-01, 0.000000e+00, -2.000000e-01,
            3.000000e-01, 5.000000e-01, 2.000000e-01, 6.000000e-01, 4.000000e-01,
            -6.000000e-01, -5.000000e-01, -3.000000e-01, -4.000000e-01, -5.000000e-01,
        ]

        let alt: Double = 6370.910156840483
        let colat: Double = 54.52408663919481
        let lon: Double = 139.7016
        let nmax: Int = 13

        // 期待される出力値
        let expectedBr: Double = -35691.608290802906
        let expectedBt: Double = -30013.23988558015
        let expectedBp: Double = -4161.5644558610265

        // Swiftの実装を呼び出し
        let magneticField = IGRFUtils.synthValues(
            coeffs: coeffsT,
            radius: alt,
            theta: colat,
            phi: lon,
            nmax: nmax
        )

        // 各成分の比較（浮動小数点の誤差を考慮）
        XCTAssertEqual(magneticField.radial, expectedBr, accuracy: 0.001)
        XCTAssertEqual(magneticField.theta, expectedBt, accuracy: 0.001)
        XCTAssertEqual(magneticField.phi, expectedBp, accuracy: 0.001)
    }

    func testLegendrePoly() {
        // 入力値
        let nmax: Int = 13
        let theta: Double = 54.52408663919481

        // 期待される出力値（Pythonの出力を変換）
        let expectedPnm: [[Double]] = [
            [
                1.0, 0.0, -0.81435957, -1.41786676, -0.83564587, 0.75887839, 2.03550944, 1.68827105,
                -0.25184781, -2.24265811, -2.48246611, -0.54968961, 2.06077446, 3.10037281,
                1.51610767,
            ],
            [
                0.58036066, 0.81435957, 0.58036066, -0.56527732, -2.113802, -2.30655883,
                -0.42909867, 2.24277431, 3.37170571, 1.66711249, -1.73169331, -3.99323385,
                -2.98556908, 0.72273215, 4.11491008,
            ],
            [
                0.00522774, 0.81860576, 0.57433203, 0.81860576, 0.01648829, -1.73557696,
                -2.79572869, -1.76542882, 0.99714981, 3.36586427, 3.16832653, 0.21535719,
                -3.24283575, -4.24464833, -1.68309852,
            ],
            [
                -0.38185048, 0.341151, 0.74532554, 0.42696141, 0.91283364, 0.48171888, -1.17600121,
                -2.80464899, -2.71454772, -0.41154537, 2.61790381, 3.89923402, 2.07687325,
                -1.68165222, -4.37978237,
            ],
            [
                -0.39174005, -0.23997842, 0.50335068, 0.65559496, 0.32524367, 0.92715128, 0.8196505,
                -0.58618656, -2.49561287, -3.23910959, -1.70021089, 1.43193926, 3.8692068,
                3.47853609, 0.21165114,
            ],
            [
                -0.10375054, -0.52556628, 0.01030882, 0.573675, 0.56627589, 0.25127328, 0.89536079,
                1.04475465, -0.04237281, -2.00286727, -3.38553856, -2.71659622, 0.07953807,
                3.22384451, 4.24860616,
            ],
            [
                0.21606004, -0.36841095, -0.39612677, 0.20013704, 0.59017788, 0.48366049,
                0.19591525, 0.83772455, 1.17770615, 0.42032953, -1.42718264, -3.23297075,
                -3.40133643, -1.2322278, 2.16151903,
            ],
            [
                0.32180127, 0.04759476, -0.45421526, -0.23257463, 0.33427184, 0.57475003,
                0.40995659, 0.15374185, 0.76695855, 1.23901162, 0.79014362, -0.83919571,
                -2.86671593, -3.75537995, -2.3650832,
            ],
            [
                0.16112396, 0.37377635, -0.16742014, -0.4436822, -0.06933117, 0.42177623,
                0.54095365, 0.34556973, 0.12122549, 0.69113945, 1.24678183, 1.06834901, -0.28510311,
                -2.36507666, -3.81503745,
            ],
            [
                -0.10941556, 0.3700642, 0.21271279, -0.31261275, -0.37209597, 0.07643496,
                0.47223271, 0.49744902, 0.29007905, 0.0959397, 0.61535058, 1.21611475, 1.26311789,
                0.20757301, -1.79364409,
            ],
            [
                -0.26566249, 0.07412013, 0.38933194, 0.03329705, -0.38669101, -0.26713388,
                0.19730163, 0.4943632, 0.44980556, 0.24270186, 0.07615113, 0.54269787, 1.1591446,
                1.38578469, 0.62494561,
            ],
            [
                -0.19487506, -0.2536638, 0.24599665, 0.32013079, -0.12711189, -0.39984451,
                -0.14894809, 0.2913977, 0.49558229, 0.40157059, 0.20252748, 0.06058859, 0.47496905,
                1.08535638, 1.44861572,
            ],
            [
                0.02675313, -0.35104809, -0.0783993, 0.33745023, 0.20025942, -0.24933059,
                -0.36635128, -0.03130757, 0.35991986, 0.48194268, 0.35494342, 0.16863695,
                0.04830203, 0.41307449, 1.00198481,
            ],
            [
                0.20974326, -0.15893127, -0.31514947, 0.09300949, 0.35116524, 0.06202058,
                -0.32668219, -0.30073944, 0.07704345, 0.40562998, 0.45824449, 0.3112183, 0.14016298,
                0.03857136, 0.35734689,
            ],
        ]

        // Swiftの実装を呼び出し
        let actualPnm = IGRFUtils.legendrePoly(nmax: nmax, theta: theta)

        // 結果の検証
        XCTAssertEqual(actualPnm.count, expectedPnm.count)

        for i in 0..<expectedPnm.count {
            XCTAssertEqual(actualPnm[i].count, expectedPnm[i].count)
            for j in 0..<expectedPnm[i].count {
                XCTAssertEqual(
                    actualPnm[i][j], expectedPnm[i][j], accuracy: 0.0001,
                    "位置 [\(i)][\(j)] での値が一致しません")
            }
        }
    }

    func testXYZ2DHIF() {
        // 入力値
        let x: Double = 30126.51646881173
        let y: Double = -4161.5644558610265
        let z: Double = 35596.04579539566

        // 期待される出力値
        let expectedDec: Double = -7.864852276442103
        let expectedHoz: Double = 30412.58971652809
        let expectedInc: Double = 49.490048033130854
        let expectedEff: Double = 46818.843316914346

        // Swiftの実装を呼び出し

        let actualGeoField = IGRFUtils.xyz2dhif(x: x, y: y, z: z)

        // 結果の検証
        XCTAssertEqual(actualGeoField.declination, expectedDec, accuracy: 0.0001, "偏角(D)の値が一致しません")
        XCTAssertEqual(
            actualGeoField.horizontalIntensity, expectedHoz, accuracy: 0.0001, "水平強度(H)の値が一致しません")
        XCTAssertEqual(actualGeoField.inclination, expectedInc, accuracy: 0.0001, "伏角(I)の値が一致しません")
        XCTAssertEqual(
            actualGeoField.effectiveField, expectedEff, accuracy: 0.0001, "全磁力(F)の値が一致しません")
    }

    func testXYZ2DHIFSV() {
        // 入力値
        let x: Double = 30125.655498480617
        let y: Double = -4156.093651850294
        let z: Double = 35587.58259032115
        let xdot: Double = 3.443881324490017
        let ydot: Double = -21.883216042947765
        let zdot: Double = 33.852820298061374

        // 期待される出力値
        let expectedDdot: Double = -2.3973281950799517
        let expectedHdot: Double = 6.402221235353554
        let expectedIdot: Double = 1.2576517947301946
        let expectedFdot: Double = 29.895257190842557

        // Swiftの実装を呼び出し
        let field = CartesianMagneticComponents(x: x, y: y, z: z)
        let sv = CartesianMagneticComponents(x: xdot, y: ydot, z: zdot)
        let geomagneticComp = IGRFUtils.xyz2dhifSV(field: field, sv: sv)

        // 結果の検証
        XCTAssertEqual(
            geomagneticComp.declination, expectedDdot, accuracy: 0.0001, "偏角変化率(Ddot)の値が一致しません")
        XCTAssertEqual(
            geomagneticComp.horizontalIntensity, expectedHdot, accuracy: 0.0001,
            "水平強度変化率(Hdot)の値が一致しません")
        XCTAssertEqual(
            geomagneticComp.inclination, expectedIdot, accuracy: 0.0001, "伏角変化率(Idot)の値が一致しません")
        XCTAssertEqual(
            geomagneticComp.effectiveField, expectedFdot, accuracy: 0.0001, "全磁力変化率(Fdot)の値が一致しません")
    }
}
