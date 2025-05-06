import Foundation

public struct IGRFUtils {
    public static func checkInt(_ s: String) -> Int {
        guard let intValue = Int(s) else {
            fatalError("Could not convert \(s) to integer.")
        }
        return intValue
    }

    public static func checkDouble(_ s: String) -> Double {
        guard let DoubleValue = Double(s) else {
            fatalError("Could not convert \(s) to Double.")
        }
        return DoubleValue
    }

    /// Load IGRF data from a SHC file
    ///     Load shc-file and return coefficient arrays.
    /**
    Parameters
    ----------
    filepath : str
        File path to spherical harmonic coefficient shc-file.
    leap_year : {True, False}, optional
        Take leap year in time conversion into account (default). Otherwise,
        use conversion factor of 365.25 days per year.

    Returns
    -------
    time : ndarray, shape (N,)
        Array containing `N` times for each model snapshot in modified
        Julian dates with origin January 1, 2000 0:00 UTC.
    coeffs : ndarray, shape (nmax(nmax+2), N)
        Coefficients of model snapshots. Each column is a snapshot up to
        spherical degree and order `nmax`.
    parameters : dict, {'SHC', 'nmin', 'nmax', 'N', 'order', 'step'}
        Dictionary containing parameters of the model snapshots and the
        following keys: ``'SHC'`` shc-file name, `nmin` minimum degree,
        ``'nmax'`` maximum degree, ``'N'`` number of snapshot models,
        ``'order'`` piecewise polynomial order and ``'step'`` number of
        snapshots until next break point. Extract break points of the
        piecewise polynomial with ``breaks = time[::step]``.
        */
    /// - Parameters:
    ///   - filepath: The path to the SHC file
    ///   - leapYear: Whether to use leap years (default is true)
    /// - Returns: An IGRF object containing the data, or nil if an error occurs
    public static func loadSHCFile(filepath: String, leapYear: Bool? = nil) -> IGRFModel? {
        // let useLeapYear = leapYear ?? true

        var readValuesFlag = false
        var data: [Double] = []
        var parameters: Parameters?

        do {
            let fileContents = try String(contentsOfFile: filepath, encoding: .utf8)
            let lines = fileContents.components(separatedBy: .newlines)

            for line in lines {
                if line.isEmpty || line.hasPrefix("#") {
                    continue
                }

                let components = line.split(separator: " ").compactMap { Double(String($0)) }

                if components.count == 7 && !readValuesFlag {
                    let name = URL(fileURLWithPath: filepath).lastPathComponent
                    let values = components.map { Int($0) }

                    // Create Parameters struct
                    parameters = Parameters(
                        shc: name,
                        nmin: values[0],
                        nmax: values[1],
                        N: values[2],
                        order: values[3],
                        step: values[4],
                        startYear: values[5],
                        endYear: values[6]
                    )

                    readValuesFlag = true
                } else {
                    data.append(contentsOf: components)
                }
            }

            guard let params = parameters else {
                print("Error: Could not extract parameters")
                return nil
            }

            let time = Array(data[..<params.N])

            // data[parameters['N']:]の部分
            let coeffsRaw = Array(data[params.N...])

            // reshape((-1, parameters['N']+2))の部分
            // 列数はparameters['N']+2
            let columnsCount = params.N + 2

            // 行数を計算（-1は自動計算を意味する）
            let rowsCount = coeffsRaw.count / columnsCount

            // 2次元配列に変換
            var coeffsReshaped: [[Double]] = []
            for i in 0..<rowsCount {
                let startIndex = i * columnsCount
                let endIndex = startIndex + columnsCount
                let row = Array(coeffsRaw[startIndex..<min(endIndex, coeffsRaw.count)])
                coeffsReshaped.append(row)
            }

            // coeffs = np.squeeze(coeffs[:, 2:])の部分
            // 最初の2列を捨てて、残りの列だけを取得
            let coeffsData = coeffsReshaped.map { Array($0[2...]) }

            // Create IGRF object
            return IGRFModel(
                time: time,
                coeffs: coeffsData,
                parameters: params
            )

        } catch {
            print("Error loading SHC file: \(error)")
            return nil
        }
    }

    /**
    Check the bounds of the given lat, long are within -90 to +90 and -180
    to +180 degrees

    Paramters
    ---------
    */
    /// - Parameters:
    ///   - latd: The latitude in degrees
    ///   - latm: The latitude in minutes
    ///   - lond: The longitude in degrees
    ///   - lonm: The longitude in minutes
    /// - Returns: A tuple containing the latitude and longitude in decimal degrees
    public static func checkLatLonBounds(latd: Double, latm: Double, lond: Double, lonm: Double)
        -> (
            lat: Double, lon: Double
        )
    {
        if latd < -90 || latd > 90 || latm < -60 || latm > 60 {
            fatalError("Latitude \(latd) or \(latm) out of bounds.")
        }
        if lond < -360 || lond > 360 || lonm < -60 || lonm > 60 {
            fatalError("Longitude \(lond) or \(lonm) out of bounds.")
        }
        if latm < 0 && lond != 0 {
            fatalError("Lat mins \(latm) and \(lond) out of bounds.")
        }
        if lonm < 0 && lond != 0 {
            fatalError("Longitude mins \(lonm) and \(lond) out of bounds.")
        }

        // Convert to decimal degrees
        var latmValue = latm
        if latd < 0 {
            latmValue = -latm
        }
        let lat = latd + latmValue / 60.0

        var lonmValue = lonm
        if lond < 0 {
            lonmValue = -lonm
        }
        let lon = lond + lonmValue / 60.0

        return (lat, lon)
    }

    /**
    Compute geocentric colatitude and radius from geodetic colatitude and
    height.

    - Parameters:
        - h: Altitude in kilometers
        - gdcolat: Geodetic colatitude in degrees

    - Returns: A tuple containing:
        - radius: Geocentric radius in kilometers
        - theta: Geocentric colatitude in degrees
        - sd: Rotation factor for B_X to geodetic latitude
        - cd: Rotation factor for B_Z to geodetic latitude

    References:
    - Equations (51)-(53) from "The main field" (chapter 4) by Langel, R. A. in:
      "Geomagnetism", Volume 1, Jacobs, J. A., Academic Press, 1987.
    - Malin, S.R.C. and Barraclough, D.R., 1981. An algorithm for synthesizing
      the geomagnetic field. Computers & Geosciences, 7(4), pp.401-405.
    */
    public static func ggToGeo(h: Double, gdcolat: Double) -> (
        radius: Double, thc: Double, sd: Double, cd: Double
    ) {
        // WGS-84楕円体パラメータを使用
        let eqrad: Double = 6378.137  // 赤道半径
        let flat: Double = 1.0 / 298.257223563
        let plrad: Double = eqrad * (1 - flat)  // 極半径

        let ctgd: Double = cos(gdcolat * Double.pi / 180.0)
        let stgd: Double = sin(gdcolat * Double.pi / 180.0)

        let a2: Double = eqrad * eqrad
        let a4: Double = a2 * a2
        let b2: Double = plrad * plrad
        let b4: Double = b2 * b2
        let c2: Double = ctgd * ctgd
        let s2: Double = 1 - c2

        let rho: Double = sqrt(a2 * s2 + b2 * c2)
        let rad: Double = sqrt(h * (h + 2 * rho) + (a4 * s2 + b4 * c2) / (rho * rho))

        let cd: Double = (h + rho) / rad
        let sd: Double = (a2 - b2) * ctgd * stgd / (rho * rad)

        let cthc: Double = ctgd * cd - stgd * sd
        let thc: Double = acos(cthc) * 180.0 / Double.pi  // ラジアンから度に変換

        return (rad, thc, sd, cd)
    }

    /**
    地心半径と地心余緯度から測地高度と測地余緯度を計算します。

    - Parameters:
        - radius: 地心半径（キロメートル）
        - theta: 地心余緯度（度）

    - Returns: タプルで以下を返します:
        - height: 高度（キロメートル）
        - beta: 測地余緯度（度）

    注意:
    丸め誤差により、特に地理的極に近い点でアルゴリズムが失敗する可能性があります。
    そのような場合、対応する測地座標はNaNとして返されます。

    参考文献:
    Zhu, J., "Conversion of Earth-centered Earth-fixed coordinates to geodetic
    coordinates", IEEE Transactions on Aerospace and Electronic Systems, 1994,
    vol. 30, num. 3, pp. 957-961
    */
    public static func geoToGg(radius: Double, theta: Double) -> (height: Double, beta: Double) {
        // WGS-84楕円体パラメータを使用
        let a: Double = 6378.137  // 赤道半径
        let b: Double = 6356.752  // 極半径

        let a2 = a * a
        let b2 = b * b

        let e2 = (a2 - b2) / a2  // 離心率の二乗
        let e4 = e2 * e2
        let ep2 = (a2 - b2) / b2  // 第二離心率の二乗

        let thetaRad = theta * Double.pi / 180.0
        let r = radius * sin(thetaRad)
        let z = radius * cos(thetaRad)

        let r2 = r * r
        let z2 = z * z

        let F = 54 * b2 * z2

        let G = r2 + (1 - e2) * z2 - e2 * (a2 - b2)

        let c = e4 * F * r2 / pow(G, 3)

        let s = pow(1 + c + sqrt(c * c + 2 * c), 1.0 / 3.0)

        let P = F / (3 * pow(s + 1 / s + 1, 2) * G * G)

        let Q = sqrt(1 + 2 * e4 * P)

        let r0 =
            -P * e2 * r / (1 + Q)
            + sqrt(
                0.5 * a2 * (1 + 1 / Q) - P * (1 - e2) * z2 / (Q * (1 + Q)) - 0.5 * P * r2)

        let U = sqrt(pow(r - e2 * r0, 2) + z2)

        let V = sqrt(pow(r - e2 * r0, 2) + (1 - e2) * z2)

        let z0 = b2 * z / (a * V)

        let height = U * (1 - b2 / (a * V))

        let beta = 90 - atan2(z + ep2 * z0, r) * 180.0 / Double.pi

        return (height, beta)
    }

    /**
     Based on chaosmagpy from Clemens Kloss (DTU Space, Copenhagen)
     Computes radial, colatitude and azimuthal field components from the
     magnetic potential field in terms of spherical harmonic coefficients.
     A reduced version of the DTU synth_values chaosmagpy code

     - Parameters:
        - coeffs: Coefficients of the spherical harmonic expansion. The last dimension is
                 equal to the number of coefficients, `N` at the grid points.
        - radius: Array containing the radius in kilometers.
        - theta: Array containing the colatitude in degrees [0°,180°].
        - phi: Array containing the longitude in degrees.
        - nmax: Maximum degree up to which expansion is to be used (default is given by
               the ``coeffs``, but can also be smaller if specified
               N ≥ nmax (nmax + 2)
        - nmin: Minimum degree from which expansion is to be used (defaults to 1).
               Note that it will just skip the degrees smaller than ``nmin``, the
               whole sequence of coefficients 1 through ``nmax`` must still be given
               in ``coeffs``.
        - grid: If ``true``, field components are computed on a regular grid. Arrays
               ``theta`` and ``phi`` must have one dimension less than the output grid
               since the grid will be created as their outer product (defaults to
               ``false``).

     - Returns: Tuple of (B_radius, B_theta, B_phi) - Radial, colatitude and azimuthal field components.
     */
    public static func synthValues(
        coeffs: [Double],
        radius: Double,
        theta: Double,
        phi: Double,
        nmax: Int? = nil,
        nmin: Int? = nil,
        grid: Bool? = nil
    ) -> MagneticFieldComponents {
        // 地球の平均半径で正規化
        let radiusNormalized = radius / 6371.2

        // 余緯度の境界チェック
        if theta <= 0.0 || theta >= 180.0 {
            if theta == 0.0 || theta == 180.0 {
                print("警告: 地理的な極が含まれています。")
            } else {
                fatalError("余緯度が境界 [0, 180] の外です。")
            }
        }

        // nminの処理
        let actualNmin = nmin ?? 1
        assert(actualNmin > 0, "正のnminのみ許可されています。")

        // nmaxの処理
        let nmax_coeffs = Int(sqrt(Double(coeffs.count + 1)) - 1)  // 次数
        let actualNmax: Int
        if let nmax = nmax {
            assert(nmax > 0, "正のnmaxのみ許可されています。")
            if nmax > nmax_coeffs {
                print(
                    "警告: 指定されたnmax = \(nmax)とnmin = \(actualNmin)はモデル係数の数と互換性がありません。代わりにnmax = \(nmax_coeffs)を使用します。"
                )
                actualNmax = nmax_coeffs
            } else {
                actualNmax = nmax
            }
        } else {
            actualNmax = nmax_coeffs
        }

        if actualNmax < actualNmin {
            fatalError("計算するものがありません: nmax < nmin (\(actualNmax) < \(actualNmin))")
        }

        // グリッドオプションの処理
        // let useGrid = grid ?? false

        // TODO: グリッド処理の実装（現在のバージョンでは単一点のみサポート）

        // 放射状依存性の初期化
        var r_n = pow(radiusNormalized, Double(-(actualNmin + 2)))

        // ルジャンドル多項式の計算
        let Pnm = legendrePoly(nmax: actualNmax, theta: theta)

        // 高速アクセス用にsinthを保存
        let sinth = Pnm[1][1]

        // cos(m*phi)とsin(m*phi)の計算
        let phiRad = phi * Double.pi / 180.0
        var cmp: [[Double]] = Array(repeating: Array(repeating: 0, count: 1), count: actualNmax + 1)
        var smp: [[Double]] = Array(repeating: Array(repeating: 0, count: 1), count: actualNmax + 1)

        for m in 0...actualNmax {
            cmp[m][0] = cos(Double(m) * phiRad)
            smp[m][0] = sin(Double(m) * phiRad)
        }

        // メモリ内に配列を割り当て
        var radialField: Double = 0
        var thetaField: Double = 0
        var phiField: Double = 0

        var num = actualNmin * actualNmin - 1
        for n in actualNmin...actualNmax {
            radialField += Double(n + 1) * Pnm[n][0] * r_n * coeffs[num]

            thetaField += -Pnm[0][n + 1] * r_n * coeffs[num]

            num += 1

            for m in 1...n {
                radialField +=
                    Double(n + 1) * Pnm[n][m] * r_n
                    * (coeffs[num] * cmp[m][0]
                        + coeffs[num + 1] * smp[m][0])

                thetaField +=
                    -Pnm[m][n + 1] * r_n
                    * (coeffs[num] * cmp[m][0]
                        + coeffs[num + 1] * smp[m][0])

                // 極の処理にL'Hopitalの法則を使用
                var div_Pnm: Double
                if theta == 0.0 {
                    div_Pnm = Pnm[m][n + 1]
                } else if theta == 180.0 {
                    div_Pnm = -Pnm[m][n + 1]
                } else {
                    div_Pnm = Pnm[n][m] / sinth
                }

                phiField +=
                    Double(m) * div_Pnm * r_n
                    * (coeffs[num] * smp[m][0]
                        - coeffs[num + 1] * cmp[m][0])

                num += 2
            }

            r_n = r_n / radiusNormalized  // r_n = radius**(-(n+2))と同等
        }

        return MagneticFieldComponents(radial: radialField, theta: thetaField, phi: phiField)
    }

    /**
     ルジャンドル多項式を計算する

     - Parameters:
        - nmax: 最大次数
        - theta: 余緯度（度）

     - Returns: ルジャンドル多項式の配列
     */
    public static func legendrePoly(nmax: Int, theta: Double) -> [[Double]] {
        let thetaRad = theta * Double.pi / 180.0
        let costh = cos(thetaRad)
        let sinth = sqrt(1 - costh * costh)

        // 結果を格納する配列を初期化
        var Pnm = Array(repeating: Array(repeating: Double(0), count: nmax + 2), count: nmax + 1)

        // 基本値の設定
        Pnm[0][0] = 1.0
        Pnm[1][1] = sinth

        // 事前計算された平方根値
        var rootn = [Double](repeating: 0, count: 2 * nmax * nmax + 1)
        for i in 0..<rootn.count {
            rootn[i] = sqrt(Double(i))
        }

        // Langel (1987)の再帰関係に基づく計算
        for m in 0..<nmax {
            let Pnm_tmp = rootn[m + m + 1] * Pnm[m][m]
            Pnm[m + 1][m] = costh * Pnm_tmp

            if m > 0 {
                Pnm[m + 1][m + 1] = sinth * Pnm_tmp / rootn[m + m + 2]
            }

            if m + 2 <= nmax {
                for n in (m + 2)...nmax {
                    let d = n * n - m * m
                    let e = 2 * n - 1
                    Pnm[n][m] =
                        (Double(e) * costh * Pnm[n - 1][m] - rootn[d - e] * Pnm[n - 2][m])
                        / rootn[d]
                }
            }
        }

        // 導関数の計算
        Pnm[0][2] = -Pnm[1][1]
        Pnm[1][2] = Pnm[1][0]

        for n in 2...nmax {
            Pnm[0][n + 1] = -sqrt(Double(n * n + n) / 2) * Pnm[n][1]
            Pnm[1][n + 1] =
                (sqrt(2 * Double(n * n + n)) * Pnm[n][0] - sqrt(Double(n * n + n - 2)) * Pnm[n][2])
                / 2

            for m in 2..<n {
                Pnm[m][n + 1] =
                    0.5
                    * (sqrt(Double((n + m) * (n - m + 1))) * Pnm[n][m - 1] - sqrt(
                        Double((n + m + 1) * (n - m))) * Pnm[n][m + 1])
            }

            Pnm[n][n + 1] = sqrt(Double(2 * n)) * Pnm[n][n - 1] / 2
        }

        return Pnm
    }

    /**
     * X, Y, Z成分からD, H, I, Fを計算します
     *
     * D. Kerridge (2019)のコードに基づいています
     *
     * - Parameters:
     *   - x: 北向き成分 (nT)
     *   - y: 東向き成分 (nT)
     *   - z: 鉛直成分 (nT)
     * - Returns: (D, H, I, F)のタプル
     *   - D: 偏角 (度)
     *   - H: 水平強度 (nT)
     *   - I: 伏角 (度)
     *   - F: 全磁力 (nT)
     */
    public static func xyz2dhif(x: Double, y: Double, z: Double) -> GeomagneticComponents {
        let hsq = x * x + y * y
        let hoz = sqrt(hsq)
        let eff = sqrt(hsq + z * z)
        let dec = atan2(y, x)
        let inc = atan2(z, hoz)

        // ラジアンから度への変換にヘルパー関数を使用
        return GeomagneticComponents(
            declination: radiansToDegrees(dec),
            horizontalIntensity: hoz,
            inclination: radiansToDegrees(inc),
            effectiveField: eff
        )
    }

    /**
     * 直交座標系の磁場成分とその時間変化率から地磁気要素の永年変化を計算します
     *
     * D. Kerridge (2019)のコードに基づいています
     *
     * - Parameters:
     *   - field: 磁場の直交座標成分
     *   - sv: 磁場成分の時間変化率
     * - Returns: 地磁気要素の永年変化
     */
    public static func xyz2dhifSV(
        field: CartesianMagneticComponents, 
        sv: CartesianMagneticComponents
    ) -> GeomagneticComponents {
        let h2 = field.x * field.x + field.y * field.y
        let h = sqrt(h2)
        let f2 = h2 + field.z * field.z
        let hdot = (field.x * sv.x + field.y * sv.y) / h
        let fdot = (field.x * sv.x + field.y * sv.y + field.z * sv.z) / sqrt(f2)
        let ddot = radiansToDegrees((sv.y * field.x - sv.x * field.y) / h2) * 60
        let idot = radiansToDegrees((h * sv.z - hdot * field.z) / f2) * 60

        return GeomagneticComponents(
            declination: ddot,
            horizontalIntensity: hdot,
            inclination: idot,
            effectiveField: fdot
        )
    }

    /**
     * ラジアンから度に変換します
     *
     * - Parameter radians: ラジアン値
     * - Returns: 度数値
     */
    public static func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
}
