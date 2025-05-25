import Foundation
import IGRFCore

public struct IGRFClient {
    public static func create(igrfGen: IGRFGen) -> IGRFBuilder {
        return IGRFBuilder(igrfGen: igrfGen)
    }
}

public struct IGRFBuilder {
    let igrfGen: IGRFGen

    public init(igrfGen: IGRFGen) {
        self.igrfGen = igrfGen
    }

    public func set(system: CoordinateSystemType) -> IGRFBuilderWithCoordinate {
        return IGRFBuilderWithCoordinate(
            igrfGen: igrfGen,
            system: system
        )
    }
}

public struct IGRFBuilderWithGeocentricComponents {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation
    let components: GeocentricCoordinateComponents

    public init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        inputLocation: IGRFLocation,
        degreesLocation: DegreesLocation,
        components: GeocentricCoordinateComponents
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.inputLocation = inputLocation
        self.degreesLocation = degreesLocation
        self.components = components
    }

    public func set(date: Date) throws -> IGRFBuilderWithDate {
        let dateDouble = date.decimalYear()

        guard (1900...2035).contains(dateDouble) else {
            throw IGRFError.invalidDate(
                message: "Invalid date. Please enter a date between 1900 and 2035.")
        }
        return IGRFBuilderWithDate(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            inputLocation: inputLocation,
            degreesLocation: degreesLocation,
            components: components,
            date: dateDouble
        )
    }
}

public struct IGRFBuilderWithDate {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation
    let components: GeocentricCoordinateComponents
    let date: Double

    init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        inputLocation: IGRFLocation,
        degreesLocation: DegreesLocation,
        components: GeocentricCoordinateComponents,
        date: Double
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.inputLocation = inputLocation
        self.degreesLocation = degreesLocation
        self.components = components
        self.date = date
    }

    public func synthesize() throws -> IGRFDisplayResult {
        let shcURL = Bundle.loadSHCFile(igrfGen: igrfGen)
        guard let igrfData = IGRFUtils.loadSHCFile(filepath: shcURL.path) else {
            throw IGRFError.failedToLoadSHCFile
        }

        let input = GeomagneticInput(
            date: date,
            alt: components.radius,
            lat: degreesLocation.latitude,
            colat: components.geocentricColat,
            lon: degreesLocation.longitude,
            coordinateSystem: coordinateSystem,
            sd: components.sineOfDeclination,
            cd: components.cosineOfDeclination
        )

        let synthesizer = MagneticFieldSynthesizer()
        let result = synthesizer.synthesize(input: input, igrfData: igrfData)
        let displayResult = IGRFDisplayResult(
            input: input,
            result: result,
            igrfGeneration: igrfGen.rawValue
        )
        return displayResult
    }
}

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
    public let lat: Double

    public init(
        input: GeomagneticInput,
        result: MagneticFieldSynthesizerResult,
        igrfGeneration: Int
    ) {
        self.input = input
        self.result = result
        self.igrfGeneration = igrfGeneration

        let (convertedAlt, convertedLat) = IGRFUtils.geoToGg(
            radius: input.alt, theta: input.colat)
        self.alt = convertedAlt
        self.lat = convertedLat
    }
}
