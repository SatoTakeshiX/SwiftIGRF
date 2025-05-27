import IGRFCore

/// A type that summarizes IGRF calculation results for UI display
public struct IGRFDisplayResult {
    /// Input parameters
    public let input: GeomagneticInput
    /// Geomagnetic calculation results
    public let result: MagneticFieldSynthesizerResult
    /// Generation of IGRF model used
    public let igrfGeneration: Int

    /// input data
    public let alt: Double

    public init(
        input: GeomagneticInput,
        result: MagneticFieldSynthesizerResult,
        igrfGeneration: Int
    ) {
        self.input = input
        self.result = result
        self.igrfGeneration = igrfGeneration

        switch input.coordinateSystem {
        case .geodetic:
            let (convertedAlt, convertedLat) = IGRFUtils.geoToGg(
                radius: input.alt, theta: input.colat)
            self.alt = convertedAlt

        case .geocentric:
            self.alt = input.alt
        }
    }
}
