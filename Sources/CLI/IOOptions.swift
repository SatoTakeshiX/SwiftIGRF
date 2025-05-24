import Foundation
import IGRFCore

protocol UserInputProtocol {
    associatedtype InputType: InputResultProtocol
    func input() -> InputType
}

struct SinglePointTime: UserInputProtocol {
    typealias InputType = GeomagneticInput

    func input() -> InputType {
        let format = readFormat()

        // 入力タイプの取得
        let coordinateSystem: CoordinateSystemType = readCoordinateSystem()

        let (lat, lon, colat) = readLatitudeLongitude(format: format)

        guard let lat = lat, let lon = lon, let colat = colat else {
            fatalError("Invalid input. Please enter valid latitude and longitude.")
        }

        // 高度の取得
        let (alt, newColat, sd, cd) = readAltitude(coordinateSystem: coordinateSystem, colat: colat)

        // 日付の取得
        let date = readDate()

        return GeomagneticInput(
            date: date,
            alt: alt,
            lat: lat,
            colat: newColat,
            lon: lon,
            coordinateSystem: coordinateSystem,
            sd: sd,
            cd: cd
        )
    }

    func makeContent(
        input: GeomagneticInput,
        result: MagneticFieldSynthesizerResult,
        igrfGen: Int
    )
        -> String
    {
        var printedAlt = 0.0
        var printedLat = 0.0

        if case .geodetic = input.coordinateSystem {
            // 測地座標系の場合、緯度と高度を変換
            let (convertedAlt, convertedLat) = IGRFUtils.geoToGg(
                radius: input.alt, theta: input.colat)
            printedAlt = convertedAlt
            printedLat = 90 - convertedLat
        } else if case .geocentric = input.coordinateSystem {
            printedAlt = input.alt
            printedLat = input.lat
        }

        let contents = """
            Geomagnetic field values at: \(String(format: "%.4f", printedLat))° / \(String(format: "%.4f", input.lon))°, at altitude \(String(format: "%.1f", printedAlt)) for \(input.date) using IGRF-\(igrfGen)
            Declination (D): \(String(format: " %.3f", result.geoComponents.declination))°
            Inclination (I): \(String(format: " %.3f", result.geoComponents.inclination))°
            Horizontal intensity (H): \(String(format: " %.1f", result.geoComponents.horizontalIntensity)) nT
            Total intensity (F)     : \(String(format: " %.1f", result.geoComponents.effectiveField)) nT
            North component (X)     : \(String(format: " %.1f", result.cartesianComps.x)) nT
            East component (Y)      : \(String(format: " %.1f", result.cartesianComps.y)) nT
            Vertical component (Z)  : \(String(format: " %.1f", result.cartesianComps.z)) nT
            Declination SV (D): \(String(format: " %.2f", result.geoComponentsSV.declination)) arcmin/yr
            Inclination SV (I): \(String(format: " %.2f", result.geoComponentsSV.inclination)) arcmin/yr
            Horizontal SV (H): \(String(format: " %.1f", result.geoComponentsSV.horizontalIntensity)) nT/yr
            Total SV (F)     : \(String(format: " %.1f", result.geoComponentsSV.effectiveField)) nT/yr
            North SV (X)     : \(String(format: " %.1f", result.cartesianCompsSV.x)) nT/yr
            East SV (Y)      : \(String(format: " %.1f", result.cartesianCompsSV.y)) nT/yr
            Vertical SV (Z)  : \(String(format: " %.1f", result.cartesianCompsSV.z)) nT/yr
            """

        return contents
    }

    func output(
        fileName: String?,
        input: GeomagneticInput,
        result: MagneticFieldSynthesizerResult,
        igrfGen: Int
    ) {
        let contents = makeContent(input: input, result: result, igrfGen: igrfGen)

        if let fileName = fileName {
            let fileManager = FileManager.default
            let currentDirectory = fileManager.currentDirectoryPath
            let filePath = (currentDirectory as NSString).appendingPathComponent(fileName)

            do {
                try contents.write(toFile: filePath, atomically: true, encoding: .utf8)
                print("\nWritten to file: \(fileName)")
            } catch {
                print("ファイルの書き込みに失敗しました: \(error)")
            }
        } else {
            print("\n" + contents)
        }
    }

    func altitudeVaridation(alt: Double) -> Bool {
        guard alt >= 3485 else {
            print("Alt must be greater then CMB radius (3485 km)")
            return false
        }
        return true
    }

    func dateVaridation(with date: Double) -> Bool {
        guard (1900...2035).contains(date) else {
            print("Invalid input. Please enter a date between 1900 and 2030.")
            return false
        }
        return true
    }

    private func readFormat() -> DegreeFormat {
        while true {
            print("Enter format of latitudes and longitudes:")
            print("1 - in degrees & minutes")
            print("2 - in decimal degrees")
            print("->", terminator: "")

            if let input = readLine(),
                let idm = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)),
                let coordinateSystemType = DegreeFormat(rawValue: idm)
            {
                return coordinateSystemType
            }
            print("Invalid input. Please enter 1 or 2.")
        }
    }

    // 入力タイプを取得する関数
    private func readCoordinateSystem() -> CoordinateSystemType {
        while true {
            print("Enter value for coordinate system:")
            print("1 - geodetic (shape of Earth using the WGS-84 ellipsoid)")
            print("2 - geocentric (shape of Earth is approximated by a sphere)")
            print("->", terminator: "")

            if let input = readLine(),
                let itype = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)),
                let coordinateSystemType = CoordinateSystemType(rawValue: itype)
            {
                return coordinateSystemType
            }
            print("Invalid input. Please enter 1 or 2.")
        }
    }

    private func readLatitudeLongitude(format: DegreeFormat) -> (
        latitude: Double?,
        longitude: Double?,
        colatitude: Double?
    ) {
        switch format {
        case .degreesAndMinutes:
            print("Enter latitude & longitude in degrees & minutes")
            print("(if either latitude or longitude is between -1")
            print("and 0 degrees, enter the minutes as negative).")
            print("Enter integers for degrees, floats for the minutes if needed")
            print("->", terminator: "")

            if let input = readLine() {
                /// input expects 4 numbers. Otherwise, it will result in an error.
                let parts = input.split(separator: " ")
                let latd = Double(parts[0]) ?? 0
                let latm = Double(parts[1]) ?? 0
                let lond = Double(parts[2]) ?? 0
                let lonm = Double(parts[3]) ?? 0

                // IGRFUtilsのcheckLatLonBounds関数を使用して緯度と経度を検証・変換
                let (validLat, validLon) = IGRFUtils.checkLatLonBounds(
                    latd: latd,
                    latm: latm,
                    lond: lond,
                    lonm: lonm
                )

                let colat = 90 - validLat

                return (validLat, validLon, colat)
            }
        case .decimalDegrees:
            print("Enter latitude & longitude in decimal degrees")
            print("->", terminator: "")

            if let input: String = readLine() {
                /// input expects 2 numbers. Otherwise, it will result in an error.
                let parts = input.split(separator: " ")
                let latd = Double(parts[0]) ?? 0
                let lond = Double(parts[1]) ?? 0

                // 緯度と経度の境界チェックは別の関数で行うと仮定
                let (lat, lon) = IGRFUtils.checkLatLonBounds(
                    latd: latd, latm: 0, lond: lond, lonm: 0)
                let colat = 90 - lat

                return (lat, lon, colat)
            }
        }

        return (nil, nil, nil)
    }

    private func readAltitude(coordinateSystem: CoordinateSystemType, colat: Double) -> (
        radius: Double,
        geocentricColat: Double,
        sineDelta: Double,
        cosineDelta: Double
    ) {
        while true {
            switch coordinateSystem {
            case .geodetic:
                print("Enter altitude in km:")
                print("->", terminator: "")

                if let input = readLine(),
                    let alt = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    // 測地座標から地心座標への変換
                    let (radius, geocentricColat, newSd, newCd) = IGRFUtils.ggToGeo(
                        h: alt,
                        gdcolat: colat
                    )
                    return (radius, geocentricColat, newSd, newCd)
                }
            case .geocentric:
                print("Enter radial distance in km (>3485 km): ", terminator: "")
                if let input = readLine(),
                    let alt = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    guard altitudeVaridation(alt: alt) else {
                        continue
                    }
                    return (alt, colat, 0, 0)
                }
            }
            print("Invalid input. Please enter a valid numbe")
            continue
        }
    }

    // 日付を取得する関数
    private func readDate() -> Double {
        while true {
            print("Enter decimal date in years 1900-2030:")
            print("->", terminator: "")
            if let input = readLine(),
                let date = Double(input.trimmingCharacters(in: .whitespacesAndNewlines)),
                dateVaridation(with: date)
            {
                return date
            } else {
                continue
            }
        }
    }
}

struct IOOptions {
    static func option1() -> (
        date: Double, alt: Double, lat: Double, colat: Double, lon: Double, itype: Int, sd: Double,
        cd: Double
    ) {
        // 緯度経度の入力形式を選択
        var idm: Int = 0
        while true {
            print("緯度経度の入力形式を選択してください:")
            print("1 - 度と分で入力")
            print("2 - 10進数の度で入力")
            print("->", terminator: "")
            if let input = readLine(),
                let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)),
                value >= 1 && value <= 2
            {
                idm = value
                break
            }
        }

        // 座標系の選択
        var itype: Int = 0
        while true {
            print("座標系を選択してください:")
            print("1 - 測地座標系 (WGS-84楕円体を使用)")
            print("2 - 地心座標系 (地球を球として近似)")
            print("->", terminator: "")
            if let input = readLine(),
                let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines)),
                value >= 1 && value <= 2
            {
                itype = value
                break
            }
        }

        // 緯度と経度の入力
        var lat: Double = 0
        var lon: Double = 0
        var colat: Double = 0

        if idm == 1 {
            print("緯度と経度を度と分で入力してください")
            print("(緯度または経度が-1度と0度の間にある場合、分を負の値で入力してください)")
            print("度は整数、分は必要に応じて小数で入力してください")
            print("-> ", terminator: "")

            if let input = readLine() {
                let parts = input.split(separator: " ")
                if parts.count == 4 {
                    let latd = Double(parts[0]) ?? 0
                    let latm = Double(parts[1]) ?? 0
                    let lond = Double(parts[2]) ?? 0
                    let lonm = Double(parts[3]) ?? 0

                    // IGRFUtilsのcheckLatLonBounds関数を使用して緯度と経度を検証・変換
                    let (validLat, validLon) = IGRFUtils.checkLatLonBounds(
                        latd: latd,
                        latm: latm,
                        lond: lond,
                        lonm: lonm
                    )

                    lat = validLat
                    lon = validLon
                }
            }

            colat = 90 - lat
        } else {
            print("緯度と経度を10進数の度で入力してください")
            print("-> ", terminator: "")

            if let input = readLine() {
                let parts = input.split(separator: " ")
                if parts.count == 2 {
                    lat = Double(parts[0]) ?? 0
                    lon = Double(parts[1]) ?? 0

                    // IGRFUtilsのcheckLatLonBounds関数を使用して緯度と経度を検証・変換
                    let (validLat, validLon) = IGRFUtils.checkLatLonBounds(
                        latd: lat,
                        latm: 0,
                        lond: lon,
                        lonm: 0
                    )

                    lat = validLat
                    lon = validLon
                }
            }

            colat = 90 - lat
        }

        // 高度または半径の入力
        var alt: Double = 0
        var sd: Double = 0
        var cd: Double = 0

        while true {
            if itype == 1 {
                print("高度をkm単位で入力してください: ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    // 測地座標から地心座標への変換
                    let (radius, geocentricColat, newSd, newCd) = IGRFUtils.ggToGeo(
                        h: alt, gdcolat: colat)
                    alt = radius
                    colat = geocentricColat
                    sd = newSd
                    cd = newCd
                    break
                }
            } else if itype == 2 {
                print("地球中心からの距離をkm単位で入力してください (>3485 km): ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    sd = 0
                    cd = 0

                    if alt < 3485 {
                        print("距離は地球核マントル境界の半径 (3485 km) より大きくなければなりません")
                        continue
                    }
                    break
                }
            } else {
                print("不正な座標系です")
                continue
            }
        }

        // 日付の入力
        var date: Double = 0

        while true {
            print("西暦年を10進数で入力してください (1900-2030): ", terminator: "")
            if let input = readLine(),
                let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                date = value
                if date < 1900 || date > 2035 {
                    print("日付は1900から2030の間である必要があります")
                    continue
                }
                break
            }
        }

        return (date, alt, lat, colat, lon, itype, sd, cd)
    }

    /**
     * オプション2: 単一地点での複数年（2015, 2016, 2017...）の値を計算します
     * 同じ高度で計算します
     */
    static func option2() -> (
        date: [Double],
        alt: [Double],
        lat: [Double],
        colat: [Double],
        lon: [Double],
        itype: Int,
        sd: [Double],
        cd: [Double]
    ) {
        var idm: Int = 0
        var itype: Int = 0
        var lat: Double = 0
        var lon: Double = 0
        var colat: Double = 0
        var alt: Double = 0
        var sd: Double = 0
        var cd: Double = 0

        // 緯度・経度の入力形式を選択
        while true {
            print("緯度・経度の入力形式を選択してください: ")
            print("1 - 度・分で入力")
            print("2 - 10進数の度で入力")
            print("-> ", terminator: "")
            if let input = readLine(),
                let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                idm = value
                if idm < 1 || idm > 2 {
                    continue
                }
                break
            }
        }

        // 座標系の選択
        while true {
            print("座標系を選択してください:")
            print("1 - 測地座標系 (WGS-84楕円体を使用)")
            print("2 - 地心座標系 (地球を球として近似)")
            print("-> ", terminator: "")
            if let input = readLine(),
                let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                itype = value
                if itype < 1 || itype > 2 {
                    continue
                }
                break
            }
        }

        // 緯度・経度の入力
        if idm == 1 {
            print("緯度と経度を度・分で入力してください")
            print("(緯度または経度が-1度から0度の間の場合、分を負の値で入力してください)")
            print("整数で度を、必要に応じて小数で分を入力してください")
            print("４つの整数を入力してください")
            print("-> ", terminator: "")
            if let input = readLine() {
                let components = input.trimmingCharacters(in: .whitespacesAndNewlines).split(
                    separator: " ")
                if components.count == 4,
                    let latd = Int(components[0]),
                    let latm = Double(components[1]),
                    let lond = Int(components[2]),
                    let lonm = Double(components[3])
                {
                    let (latitude, longitude) = IGRFUtils.checkLatLonBounds(
                        latd: Double(latd), latm: latm, lond: Double(lond), lonm: lonm)
                    lat = latitude
                    lon = longitude
                    colat = 90 - lat
                }
            }
        } else {
            print("緯度と経度を10進数の度で入力してください")

            if let input = readLine() {
                let components = input.trimmingCharacters(in: .whitespacesAndNewlines).split(
                    separator: " ")
                if components.count == 2,
                    let latd = Double(components[0]),
                    let lond = Double(components[1])
                {
                    let (latitude, longitude) = IGRFUtils.checkLatLonBounds(
                        latd: latd, latm: 0, lond: lond, lonm: 0)
                    lat = latitude
                    lon = longitude
                    colat = 90 - lat
                }
            }
        }

        // 高度または半径の入力
        while true {
            if itype == 1 {
                print("高度をkm単位で入力してください: ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    let (radius, geocentricColat, newSd, newCd) = IGRFUtils.ggToGeo(
                        h: alt, gdcolat: colat)
                    alt = radius
                    colat = geocentricColat
                    sd = newSd
                    cd = newCd

                    if alt < -3300 {
                        print("高度は地球核マントル境界の半径 (3485 km) より大きくなければなりません")
                        continue
                    }
                    break
                }
            } else if itype == 2 {
                print("地球中心からの距離をkm単位で入力してください (>3485 km): ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    sd = 0
                    cd = 0

                    if alt < 3485 {
                        print("高度は地球核マントル境界の半径 (3485 km) より大きくなければなりません")
                        continue
                    }
                    break
                }
            } else {
                print("不正な座標系です")
                continue
            }
        }

        // 開始日付の入力
        var dates: Double = 0
        while true {
            print("開始年を10進数で入力してください (1900-2030): ", terminator: "")
            if let input = readLine(),
                let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                dates = value
                if dates < 1900 || dates > 2035 {
                    continue
                }
                break
            }
        }

        // 終了日付の入力
        var datee: Double = 0
        while true {
            print("終了年を10進数で入力してください (1900-2030): ", terminator: "")
            if let input = readLine(),
                let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                datee = value
                if datee < 1900 || datee > 2035 {
                    continue
                } else if datee < dates {
                    continue
                }
                break
            }
        }

        // 年の配列を作成
        let date = stride(from: dates, through: datee, by: 1.0).map { $0 }
        let altArray = Array(repeating: alt, count: date.count)
        let latArray = Array(repeating: lat, count: date.count)
        let colatArray = Array(repeating: colat, count: date.count)
        let lonArray = Array(repeating: lon, count: date.count)
        let sdArray = Array(repeating: sd, count: date.count)
        let cdArray = Array(repeating: cd, count: date.count)

        return (date, altArray, latArray, colatArray, lonArray, itype, sdArray, cdArray)
    }
    /**
     * オプション3: 単一時点での緯度・経度のグリッド上の値を計算します
     * 10進数の度のみ受け付けます。増分値は妥当かチェックされます。
     */
    static func option3() -> (
        date: [Double],
        alt: [Double],
        lat: [Double],
        colat: [Double],
        lon: [Double],
        itype: Int,
        sd: [Double],
        cd: [Double]
    ) {
        // 座標系の選択
        var itype: Int = 0
        while true {
            print("座標系を選択してください:")
            print("1 - 測地座標系 (WGS-84楕円体を使用)")
            print("2 - 地心座標系 (地球を球として近似)")
            print("-> ", terminator: "")
            if let input = readLine(),
                let value = Int(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                itype = value
                if itype < 1 || itype > 2 {
                    continue
                }
                break
            }
        }

        // 緯度の開始値、増分値、終了値の入力
        var lats: Double = 0
        var lati: Double = 0
        var late: Double = 0

        while true {
            print("開始緯度、増分値、終了緯度を10進数の度で入力してください（スペース区切り）:")
            print("-> ", terminator: "")
            if let input = readLine() {
                let parts = input.split(separator: " ")
                if parts.count == 3,
                    let startLat = Double(parts[0]),
                    let incLat = Double(parts[1]),
                    let endLat = Double(parts[2])
                {
                    lats = startLat
                    lati = incLat
                    late = endLat

                    if lats < -90 || lats > 90 || late < -90 || late > 90 {
                        print("緯度は-90度から90度の間である必要があります")
                        continue
                    }

                    if abs(lati) > abs(lats - late) {
                        print("増分値が開始点と終了点の間の差よりも大きいです")
                        continue
                    }

                    break
                }
            }
        }

        // 経度の開始値、増分値、終了値の入力
        var lons: Double = 0
        var loni: Double = 0
        var lone: Double = 0

        while true {
            print("開始経度、増分値、終了経度を10進数の度で入力してください（スペース区切り）:")
            print("-> ", terminator: "")
            if let input = readLine() {
                let parts = input.split(separator: " ")
                if parts.count == 3,
                    let startLon = Double(parts[0]),
                    let incLon = Double(parts[1]),
                    let endLon = Double(parts[2])
                {
                    lons = startLon
                    loni = incLon
                    lone = endLon

                    if lons < -180 || lons > 360 || lone < -180 || lone > 360 {
                        print("経度は-180度から360度の間である必要があります")
                        continue
                    }

                    if abs(loni) > abs(lons - lone) {
                        print("増分値が開始点と終了点の間の差よりも大きいです")
                        continue
                    }

                    break
                }
            }
        }

        // 高度または半径の入力
        var alt: Double = 0
        // var sd: Double = 0
        // var cd: Double = 0

        while true {
            if itype == 1 {
                print("高度をkm単位で入力してください: ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    break
                }
            } else {
                print("地球中心からの距離をkm単位で入力してください (>3485 km): ", terminator: "")
                if let input = readLine(),
                    let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
                {
                    alt = value
                    // sd = 0
                    // cd = 0

                    if alt < 3485 {
                        print("距離は地球核マントル境界の半径 (3485 km) より大きくなければなりません")
                        continue
                    }
                    break
                }
            }
        }

        // 日付の入力
        var date: Double = 0

        while true {
            print("西暦年を10進数で入力してください (1900-2030): ", terminator: "")
            if let input = readLine(),
                let value = Double(input.trimmingCharacters(in: .whitespacesAndNewlines))
            {
                date = value
                if date < 1900 || date > 2035 {
                    print("日付は1900から2030の間である必要があります")
                    continue
                }
                break
            }
        }

        // グリッドの作成
        var latValues: [Double] = []
        var lonValues: [Double] = []

        // 緯度の範囲を生成
        var currentLat = lats
        while (lati > 0 && currentLat <= late) || (lati < 0 && currentLat >= late) {
            latValues.append(currentLat)
            currentLat += lati
        }

        // 経度の範囲を生成
        var currentLon = lons
        while (loni > 0 && currentLon <= lone) || (loni < 0 && currentLon >= lone) {
            lonValues.append(currentLon)
            currentLon += loni
        }

        var (colatArray, lonArray, latArray) = makeGridArrays(
            lats: lats, late: late, lati: lati, lons: lons, lone: lone, loni: loni
        )

        // 測地座標から地心座標への変換（必要な場合）
        var altArray = Array(repeating: alt, count: latArray.count)
        var sdArray = Array(repeating: 0.0, count: latArray.count)
        var cdArray = Array(repeating: 0.0, count: latArray.count)

        print("colatArray: \(colatArray)")
        print("lonArray: \(lonArray)")
        print("latArray: \(latArray)")

        if itype == 1 {
            for i in 0..<colatArray.count {
                let (radius, geocentricColat, newSd, newCd) = IGRFUtils.ggToGeo(
                    h: alt, gdcolat: colatArray[i])
                altArray[i] = radius
                colatArray[i] = geocentricColat
                sdArray[i] = newSd
                cdArray[i] = newCd
            }
        }

        let dateArray = Array(repeating: date, count: latArray.count)

        return (dateArray, altArray, latArray, colatArray, lonArray, itype, sdArray, cdArray)
    }

    static func meshgrid(x: [Double], y: [Double]) -> ([[Double]], [[Double]]) {
        var X = [[Double]](repeating: [Double](repeating: 0.0, count: x.count), count: y.count)
        var Y = [[Double]](repeating: [Double](repeating: 0.0, count: x.count), count: y.count)

        for i in 0..<y.count {
            for j in 0..<x.count {
                X[i][j] = x[j]
                Y[i][j] = y[i]
            }
        }

        return (X, Y)
    }

    static func makeGridArrays(
        lats: Double, late: Double, lati: Double, lons: Double, lone: Double, loni: Double
    ) -> (
        colatArray: [Double],
        lonArray: [Double],
        latArray: [Double]
    ) {
        // グリッドポイントの生成
        // 緯度の配列を生成（90から引くことで北緯から南緯へ）
        // to: を使用して終了値を含まないようにする
        let latArrayArange = stride(from: lats, to: late, by: lati).map { 90.0 - $0 }
        // [90, 80, 70, 60, 50, 40, 30, 20, 10]

        // 経度の配列を生成
        // to: を使用して終了値を含まないようにする
        let lonArrayArange = stride(from: lons, to: lone, by: loni).map { $0 }
        // [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 260, 280, 300, 320, 340]

        // meshgridでグリッドを生成
        let (colatGrid, lonGrid) = meshgrid(x: latArrayArange, y: lonArrayArange)

        let colatArray = colatGrid.flatMap { $0 }
        let lonArray = lonGrid.flatMap { $0 }
        // 余緯度から緯度への変換（90度から余緯度を引く）
        let latArray = colatArray.map { 90.0 - $0 }

        return (colatArray, lonArray, latArray)
    }
}
