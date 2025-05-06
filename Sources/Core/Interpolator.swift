import Foundation

/// 補間器
/// 線形補間を行う
/// x, yの各要素数 は同じ長さである必要がある
public struct Interpolator {
    private let x: [Double]
    private let y: [[Double]]

    public init(x: [Double], y: [[Double]]) {
        guard !y.isEmpty && y.allSatisfy({ $0.count == x.count }) else {
            fatalError("x and y arrays must have compatible dimensions")
        }
        self.x = x
        self.y = y
    }

    /// 補間を行う
    /// - Parameter xNew: 補間したいx座標
    /// - Returns: 補間されたy値。xに値がない場合はnilを返す
    /// note: xNewがxの範囲外の場合は線形外挿を行う
    public func interpolate(_ xNew: Double) -> [Double] {
        // 各行（各係数）に対して補間を実行
        return y.map { coefficients in
            let singleInterpolator = SingleInterpolator(
                x: x, y: coefficients
            )
            return singleInterpolator.interpolate(xNew)
        }
    }

    /// 補間を行う
    /// - Parameter xNew: 補間したいx座標
    /// - Returns: 補間されたy値。xに値がない場合はnilを返す
    /// note: xNewがxの範囲外の場合は線形外挿を行う
    public func interpolate(_ xNew: [Double]) -> [[Double]] {
        return xNew.map { interpolate($0) }
    }
}

// 単一の係数に対する補間を行うクラス
struct SingleInterpolator {
    private let x: [Double]
    private let y: [Double]

    init(x: [Double], y: [Double]) {
        self.x = x
        self.y = y
    }

    func interpolate(_ xNew: Double) -> Double {
        return extrapolateValue(xNew)
    }

    private func linearExtrapolate(_ xNew: Double, isLeft: Bool) -> Double {
        if isLeft {
            // 左側の外挿（最初の2点を使用）
            let x0 = x[0]
            let x1 = x[1]
            let y0 = y[0]
            let y1 = y[1]
            let slope = (y1 - y0) / (x1 - x0)
            return y0 + slope * (xNew - x0)
        } else {
            // 右側の外挿（最後の2点を使用）
            let x0 = x[x.count - 2]
            let x1 = x[x.count - 1]
            let y0 = y[y.count - 2]
            let y1 = y[y.count - 1]
            let slope = (y1 - y0) / (x1 - x0)
            return y1 + slope * (xNew - x1)
        }
    }

    private func linearInterpolate(_ xNew: Double) -> Double {
        // 補間区間を探す
        var i = 0
        while i < x.count - 1 && x[i + 1] < xNew {
            i += 1
        }

        // 線形補間
        let x0 = x[i]
        let x1 = x[i + 1]
        let y0 = y[i]
        let y1 = y[i + 1]

        return y0 + (y1 - y0) * (xNew - x0) / (x1 - x0)
    }

    private func extrapolateValue(_ xNew: Double) -> Double {
        guard let xFirst = x.first, let xLast = x.last else {
            return 0.0
        }

        // データ範囲の外側の場合、線形外挿を実行
        if xNew < xFirst {
            return linearExtrapolate(xNew, isLeft: true)
        } else if xNew > xLast {
            return linearExtrapolate(xNew, isLeft: false)
        }

        // データ範囲内の場合は通常の補間
        return linearInterpolate(xNew)
    }
}
