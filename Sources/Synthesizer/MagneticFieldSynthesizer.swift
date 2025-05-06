public struct MagneticFieldSynthesizer {
    public init() {}

    public func synthesize(input: GeomagneticInput, igrfData: IGRFModel)
        -> MagneticFieldSynthesizerResult
    {
        // (date, alt, lat, colat, lon, itype, sd, cd) = IOOptions.option1()
        // 地磁気係数を目的の日付に補間する
        // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

        // 時間と係数の配列を使用して補間器を作成
        let timeInterpolator = Interpolator(x: igrfData.time, y: igrfData.coeffs)

        // 目的の日付に係数を補間
        let coeffs = timeInterpolator.interpolate(input.date)

        // 主磁場のB_r、B_theta、B_phiの値を計算
        let magneticField = IGRFUtils.synthValues(
            coeffs: coeffs,
            radius: input.alt,
            theta: input.colat,
            phi: input.lon,
            nmax: igrfData.parameters.nmax
        )

        // 5年ごとの期間内での日付を特定し、その期間内でのSVを計算
        // IGRFは各5年期間内で一定のSVを持つ
        let epoch = Int((input.date - 1900) / 5)
        let epochStart = Double(epoch * 5)

        // SV係数を計算（nT/年単位）
        let timeInterpolatorStart = Interpolator(x: igrfData.time, y: igrfData.coeffs)
        let coeffsStart = timeInterpolatorStart.interpolate(1900 + epochStart)
        let coeffsNext = timeInterpolatorStart.interpolate(1900 + epochStart + 1)
        let coeffsSV = zip(coeffsNext, coeffsStart).map { $0 - $1 }

        // SVのための磁場成分を計算
        let magneticFieldSV = IGRFUtils.synthValues(
            coeffs: coeffsSV,
            radius: input.alt,
            theta: input.colat,
            phi: input.lon,
            nmax: igrfData.parameters.nmax
        )

        // 各5年エポックの開始時点での主磁場係数を使用して
        // 偏角、伏角、水平成分、全磁力のSVを計算
        // （これらはX、Y、Zの非線形成分なので別々に扱う）
        let mainMagneticField = IGRFUtils.synthValues(
            coeffs: coeffsStart,
            radius: input.alt,
            theta: input.colat,
            phi: input.lon,
            nmax: igrfData.parameters.nmax
        )

        // X、Y、Z成分に並べ替え
        let X = -magneticField.theta
        let Y = magneticField.phi
        let Z = -magneticField.radial
        // SVのため
        let dX = -magneticFieldSV.theta
        let dY = magneticFieldSV.phi
        let dZ = -magneticFieldSV.radial
        let Xm = -mainMagneticField.theta
        let Ym = mainMagneticField.phi
        let Zm = -mainMagneticField.radial

        // 必要に応じて測地座標系に戻す
        var finalX = X
        var finalZ = Z
        var finaldX = dX
        var finaldZ = dZ
        var finalXm = Xm
        var finalZm = Zm

        if case .geodetic = input.coordinateSystem {
            let t = X
            finalX = X * input.cd + Z * input.sd
            finalZ = Z * input.cd - t * input.sd

            let tdX = dX
            finaldX = dX * input.cd + dZ * input.sd
            finaldZ = dZ * input.cd - tdX * input.sd

            let tXm = Xm
            finalXm = Xm * input.cd + Zm * input.sd
            finalZm = Zm * input.cd - tXm * input.sd
        }

        // 非線形成分を計算
        let geomagneticComp = IGRFUtils.xyz2dhif(x: finalX, y: Y, z: finalZ)

        // 各5年エポック開始時点での主磁場成分に対するIGRF SV係数
        let geomagneticCompSV = IGRFUtils.xyz2dhifSV(
            field: CartesianMagneticComponents(x: finalXm, y: Ym, z: finalZm),
            sv: CartesianMagneticComponents(x: finaldX, y: dY, z: finaldZ)
        )
        return MagneticFieldSynthesizerResult(
            geoComponents: geomagneticComp,
            geoComponentsSV: geomagneticCompSV,
            cartesianComps: CartesianMagneticComponents(x: finalX, y: Y, z: finalZ),
            cartesianCompsSV: CartesianMagneticComponents(x: finaldX, y: dY, z: finaldZ),
            cartesianCompsMain: CartesianMagneticComponents(x: finalXm, y: Ym, z: finalZm)
        )
    }
}
