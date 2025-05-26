import Foundation

public struct GeomagneticInput: InputResultProtocol {
    public let decimalYear: Double
    public let alt: Double
    public let lat: Double
    public let colat: Double
    public let lon: Double
    public let coordinateSystem: CoordinateSystemType
    public let sd: Double
    public let cd: Double

    public init(
        decimalYear: Double,
        alt: Double,
        lat: Double,
        colat: Double,
        lon: Double,
        coordinateSystem: CoordinateSystemType,
        sd: Double,
        cd: Double
    ) {
        self.decimalYear = decimalYear
        self.alt = alt
        self.lat = lat
        self.colat = colat
        self.lon = lon
        self.coordinateSystem = coordinateSystem
        self.sd = sd
        self.cd = cd
    }

    var date: Date? {
        let calendar = Calendar(identifier: .gregorian)
        let year = Int(decimalYear)
        let fraction = decimalYear - Double(year)
        print("fraction: \(fraction)")
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
            let startOfNextYear = calendar.date(
                from: DateComponents(year: year + 1, month: 1, day: 1))
        else {
            return nil
        }

        print("startOfYear: \(startOfYear)")
        print("startOfNextYear: \(startOfNextYear)")

        let yearLength = startOfNextYear.timeIntervalSince(startOfYear)
        let elapsedSeconds = yearLength * fraction
        print("elapsedSeconds: \(elapsedSeconds)")
        print("yearLength: \(yearLength)")
        return startOfYear.addingTimeInterval(elapsedSeconds)
    }
}
