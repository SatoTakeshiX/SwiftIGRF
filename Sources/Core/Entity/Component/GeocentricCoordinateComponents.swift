public struct GeocentricCoordinateComponents {
    public let radius: Double
    public let geocentricColat: Double
    public let sineOfDeclination: Double
    public let cosineOfDeclination: Double

    public init(
        radius: Double,
        geocentricColat: Double,
        sineOfDeclination: Double,
        cosineOfDeclination: Double
    ) {
        self.radius = radius
        self.geocentricColat = geocentricColat
        self.sineOfDeclination = sineOfDeclination
        self.cosineOfDeclination = cosineOfDeclination
    }
}
