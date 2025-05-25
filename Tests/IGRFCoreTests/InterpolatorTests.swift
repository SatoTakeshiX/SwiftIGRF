import IGRFCore
import XCTest

@testable import IGRFCLI

final class InterpolatorTests: XCTestCase {
    func testLinearInterpolation() {
        // テストデータ
        let x = [1.0, 2.0, 3.0, 4.0]
        let y = [
            [1.0, 1.0, 1.0, 1.0],  // 定数値1
            [2.0, 2.0, 2.0, 2.0],  // 定数値2
            [3.0, 3.0, 3.0, 3.0],  // 定数値3
            [4.0, 4.0, 4.0, 4.0],  // 定数値4
        ]

        let interpolator = Interpolator(x: x, y: y)

        // テストケース1: データ点での補間
        let result1 = interpolator.interpolate(2.0)
        XCTAssertEqual(result1, [1.0, 2.0, 3.0, 4.0], "データ点での補間が正しくない")

        // テストケース2: データ点間での補間
        let result2 = interpolator.interpolate(2.5)
        XCTAssertEqual(result2, [1.0, 2.0, 3.0, 4.0], "データ点間での補間が正しくない")

        // テストケース3: 範囲外での外挿
        let result3 = interpolator.interpolate(5.0)
        XCTAssertEqual(result3, [1.0, 2.0, 3.0, 4.0], "範囲外での外挿が正しくない")
    }

    // func testVaryingValues() {
    //     // 変化する値を持つテストデータ
    //     let x = [1.0, 2.0, 3.0, 4.0]
    //     let y = [
    //         [1.0, 2.0, 3.0, 4.0],  // 線形増加
    //         [4.0, 3.0, 2.0, 1.0],  // 線形減少
    //         [1.0, 4.0, 1.0, 4.0],  // 振動
    //         [1.0, 1.0, 4.0, 4.0],  // ステップ状
    //     ]

    //     let interpolator = Interpolator(x: x, y: y)

    //     // テストケース1: データ点間での補間
    //     let result1 = interpolator.interpolate(2.5)
    //     XCTAssertEqual(result1, [2.5, 2.5, 2.5, 1.0], "データ点間での補間が正しくない")

    //     // テストケース2: 範囲外での外挿
    //     let result2 = interpolator.interpolate(5.0)
    //     XCTAssertEqual(result2, [7.0, -2.0, 7.0, 4.0], "範囲外での外挿が正しくない")
    // }

    func testEdgeCases() {
        // エッジケースのテスト
        let x = [1.0, 2.0, 3.0, 4.0]
        let y = [
            [0.0, 0.0, 0.0, 0.0],  // すべて0
            [1.0, 1.0, 1.0, 1.0],  // すべて1
            [-1.0, -1.0, -1.0, -1.0],  // すべて-1
            [1e10, 1e10, 1e10, 1e10],  // 大きな数値
        ]

        let interpolator = Interpolator(x: x, y: y)

        // テストケース1: 最小値での補間
        let result1 = interpolator.interpolate(1.0)
        XCTAssertEqual(result1, [0.0, 1.0, -1.0, 1e10], "最小値での補間が正しくない")

        // テストケース2: 最大値での補間
        let result2 = interpolator.interpolate(4.0)
        XCTAssertEqual(result2, [0.0, 1.0, -1.0, 1e10], "最大値での補間が正しくない")
    }

    // func testNilValue() {
    //     let interpolator = Interpolator(x: [], y: [])
    //     XCTAssertNil(interpolator.interpolate(0))
    // }

    func testArrayInterpolation() {
        let x = [1.0, 2.0, 3.0, 4.0]
        let y = [
            [1.0, 2.0, 3.0, 4.0],  // 定数値1
            [4.0, 3.0, 2.0, 1.0],  // 定数値2
            [1.0, 4.0, 1.0, 4.0],  // 振動
        ]

        let interpolator = Interpolator(x: x, y: y)
        let result = interpolator.interpolate([1.0, 2.0])
        XCTAssertEqual(result, [[1.0, 4.0, 1.0], [2.0, 3.0, 4.0]])

        let result2 = interpolator.interpolate([1.5, 2.5])
        XCTAssertEqual(
            result2,
            [
                [1.5, 3.5, 2.5],
                [2.5, 2.5, 2.5],
            ]
        )
    }
}
