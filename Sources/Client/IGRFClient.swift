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

public struct IGRFBuilderWithDate {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation
    let components: GeocentricCoordinateComponents
    let decimalYear: Double

    init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        inputLocation: IGRFLocation,
        degreesLocation: DegreesLocation,
        components: GeocentricCoordinateComponents,
        decimalYear: Double
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.inputLocation = inputLocation
        self.degreesLocation = degreesLocation
        self.components = components
        self.decimalYear = decimalYear
    }

    public func synthesize() throws -> IGRFDisplayResult {
        let shcURL = Bundle.loadSHCFile(igrfGen: igrfGen)
        guard let igrfData = IGRFUtils.loadSHCFile(filepath: shcURL.path) else {
            throw IGRFError.failedToLoadSHCFile
        }

        let input = GeomagneticInput(
            decimalYear: decimalYear,
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
