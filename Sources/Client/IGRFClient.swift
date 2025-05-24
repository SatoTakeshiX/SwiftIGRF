import Foundation
import IGRFCore

public struct IGRFClient {
    public static func create(igrfGen: IGRFGen) throws -> IGRFBuilder {
        return IGRFBuilder(igrfGen: igrfGen)
    }
}

public struct IGRFBuilder {
    private let igrfGen: IGRFGen

    init(igrfGen: IGRFGen) {
        self.igrfGen = igrfGen
    }

    public func set(system: CoordinateSystemType) -> IGRFBuilderWithCoordinate {
        return IGRFBuilderWithCoordinate(
            igrfGen: igrfGen,
            system: system
        )
    }
}

public struct IGRFBuilderWithCoordinate {
    private let igrfGen: IGRFGen
    private let coordinateSystem: CoordinateSystemType

    init(
        igrfGen: IGRFGen,
        system: CoordinateSystemType
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = system
    }

    /// Sets the location parameters for IGRF calculation
    /// - Parameters:
    ///   - latitude: Latitude value whose representation varies based on DegreeFormat
    ///   - longitude: Longitude value whose representation varies based on DegreeFormat
    ///   - altitude: Altitude in kilometers
    /// - Returns: IGRFBuilderWithLocation instance with the specified location parameters

    public func set(
        location: IGRFLocation,
        altitude: Double
    )
        -> IGRFBuilderWithLocation
    {
        return IGRFBuilderWithLocation(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            location: location,
            altitude: altitude
        )
    }
}

public struct IGRFBuilderWithLocation {
    private let igrfGen: IGRFGen
    private let coordinateSystem: CoordinateSystemType
    private let location: IGRFLocation
    private let altitude: Double

    init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        location: IGRFLocation,
        altitude: Double
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.location = location
        self.altitude = altitude
    }

    public func set(date: Date) -> IGRFBuilderWithDate {
        return IGRFBuilderWithDate(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            location: location,
            altitude: altitude,
            date: date
        )
    }
}

public struct IGRFBuilderWithDate {
    private let igrfGen: IGRFGen
    private let coordinateSystem: CoordinateSystemType
    private let location: IGRFLocation
    private let altitude: Double
    private let date: Date

    init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        location: IGRFLocation,
        altitude: Double,
        date: Date
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.location = location
        self.altitude = altitude
        self.date = date
    }

    public func synthesize() throws -> MagneticFieldSynthesizerResult {
        let shcURL = Bundle.loadSHCFile(igrfGen: igrfGen)
        guard let igrfData = IGRFUtils.loadSHCFile(filepath: shcURL.path) else {
            throw IGRFError.failedToLoadSHCFile
        }

        let input = GeomagneticInput(
            date: date.timeIntervalSince1970,
            alt: altitude,
            lat: location.latitude,
            colat: 90 - location.latitude,
            lon: location.longitude,
            coordinateSystem: coordinateSystem,
            sd: 0,
            cd: 0
        )

        let synthesizer = MagneticFieldSynthesizer()
        let result = synthesizer.synthesize(input: input, igrfData: igrfData)
        return result
    }
}
