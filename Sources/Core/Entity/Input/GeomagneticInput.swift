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

    func makeDate(withDecimalYear decimalYear: Double) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let year = Int(decimalYear)
        let month = 1
        let day = 1
        return calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
