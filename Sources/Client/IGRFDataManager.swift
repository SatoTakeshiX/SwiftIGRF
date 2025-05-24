import Foundation
import IGRFCore

public enum DegreeFormat: Int {
    case degreesAndMinutes = 1
    case decimalDegrees = 2
}

/// Represents a location with a specified degree format
public struct IGRFLocation {
    public let latitude: Double
    public let longitude: Double
    public let format: DegreeFormat

    public init(
        latitude: Double,
        longitude: Double,
        format: DegreeFormat
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.format = format
    }
}

public struct IGRFDataManager {
    public static func create(igrfGen: Int) throws -> IGRFBuilder {
        guard (1...14).contains(igrfGen) else {
            throw IGRFError.invalidIGRFGeneration
        }
        return IGRFBuilder(igrfGen: igrfGen)
    }
}

public struct IGRFBuilder {
    private let igrfGen: Int

    init(igrfGen: Int) {
        self.igrfGen = igrfGen
    }

    public func set(system: CoordinateSystemType) -> IGRFBuilderWithCoordinate {
        var builder = IGRFBuilderWithCoordinate(
            igrfGen: igrfGen,
            system: system
        )
        return builder
    }
}

public struct IGRFBuilderWithCoordinate {
    private let igrfGen: Int
    private let coordinateSystem: CoordinateSystemType

    init(
        igrfGen: Int,
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
    private let igrfGen: Int
    private let coordinateSystem: CoordinateSystemType
    private let location: IGRFLocation
    private let altitude: Double

    init(
        igrfGen: Int,
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
        var builder = IGRFBuilderWithDate(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            location: location,
            altitude: altitude,
            date: date
        )
        return builder
    }
}

public struct IGRFBuilderWithDate {
    private let igrfGen: Int
    private let coordinateSystem: CoordinateSystemType
    private let location: IGRFLocation
    private let altitude: Double
    private let date: Date

    init(
        igrfGen: Int,
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

public enum IGRFError: Error {
    case invalidIGRFGeneration
    case failedToLoadSHCFile
}
