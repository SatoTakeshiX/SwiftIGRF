import XCTest

@testable import SwiftIGRF

final class TransposeArrayTests: XCTestCase {
    func testTransposeIntArray() {
        let array = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
        ]
        let transposed = array.transpose
        XCTAssertEqual(
            transposed,
            [
                [1, 4, 7],
                [2, 5, 8],
                [3, 6, 9],
            ]
        )
    }

    func testTransposeDoubleArray() {
        let array = [
            [1.0, 2.0, 3.0],
            [4.0, 5.0, 6.0],
        ]
        let transposed = array.transpose
        XCTAssertEqual(transposed, [[1.0, 4.0], [2.0, 5.0], [3.0, 6.0]])
    }
    func testTransposeStringArray() {
        let array = [
            ["a", "b", "c"],
            ["d", "e", "f"],
            ["g", "h", "i"],
        ]
        let transposed = array.transpose
        XCTAssertEqual(
            transposed,
            [
                ["a", "d", "g"],
                ["b", "e", "h"],
                ["c", "f", "i"],
            ]
        )
    }

    func testTransposeEmptyArray() {
        let array: [[Int]] = []
        let transposed = array.transpose
        XCTAssertEqual(transposed, [])
    }
}
