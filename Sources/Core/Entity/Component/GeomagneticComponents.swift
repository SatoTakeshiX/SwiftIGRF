public struct GeomagneticComponents {
    public let declination: Double
    public let horizontalIntensity: Double
    public let inclination: Double
    public let effectiveField: Double

    public init(
        declination: Double,
        horizontalIntensity: Double,
        inclination: Double,
        effectiveField: Double
    ) {
        self.declination = declination
        self.horizontalIntensity = horizontalIntensity
        self.inclination = inclination
        self.effectiveField = effectiveField
    }
}
