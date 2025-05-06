public struct GeomagneticInput: InputResultProtocol {
    public let date: Double
    public let alt: Double
    public let lat: Double
    public let colat: Double
    public let lon: Double
    public let coordinateSystem: CoordinateSystemType
    public let sd: Double
    public let cd: Double

    public init(
        date: Double,
        alt: Double,
        lat: Double,
        colat: Double,
        lon: Double,
        coordinateSystem: CoordinateSystemType,
        sd: Double,
        cd: Double
    ) {
        self.date = date
        self.alt = alt
        self.lat = lat
        self.colat = colat
        self.lon = lon
        self.coordinateSystem = coordinateSystem
        self.sd = sd
        self.cd = cd
    }
}
