import Foundation
import IGRFCore

public struct IGRFClient {
    public static func create(igrfGen: IGRFGen) throws -> IGRFBuilder {
        return IGRFBuilder(igrfGen: igrfGen)
    }
}

public struct IGRFBuilder {
    let igrfGen: IGRFGen

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

/// A struct that represents a location in decimal degrees format
/// This struct is used to store latitude and longitude values that have already been converted to decimal degrees
/// The colatitude (90 - latitude) is automatically calculated for convenience
public struct DegreesLocation {
    public let latitude: Double
    public let longitude: Double
    public let colatitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.colatitude = 90 - latitude
    }
}

public struct IGRFBuilderWithCoordinate {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType

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
        inputLocation: IGRFLocation,
        altitude: Double
    )
        -> IGRFBuilderWithLocation
    {
        switch inputLocation.format {
        case .degreesAndMinutes:
            let latd = floor(inputLocation.latitude)
            let latm = inputLocation.latitude - latd
            let lond = floor(inputLocation.longitude)
            let lonm = inputLocation.longitude - lond

            let (lat, lon) = IGRFUtils.checkLatLonBounds(
                latd: latd,
                latm: latm,
                lond: lond,
                lonm: lonm
            )
            let degreesLocation = DegreesLocation(latitude: lat, longitude: lon)
            return IGRFBuilderWithLocation(
                igrfGen: igrfGen,
                coordinateSystem: coordinateSystem,
                inputLocation: inputLocation,
                degreesLocation: degreesLocation,
                altitude: altitude
            )

        case .decimalDegrees:
            let (lat, lon) = IGRFUtils.checkLatLonBounds(
                latd: inputLocation.latitude,
                latm: 0,
                lond: inputLocation.longitude,
                lonm: 0
            )
            let degreesLocation = DegreesLocation(latitude: lat, longitude: lon)
            return IGRFBuilderWithLocation(
                igrfGen: igrfGen,
                coordinateSystem: coordinateSystem,
                inputLocation: inputLocation,
                degreesLocation: degreesLocation,
                altitude: altitude
            )
        }
    }
}

public struct IGRFBuilderWithLocation {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation
    let altitude: Double

    init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        inputLocation: IGRFLocation,
        degreesLocation: DegreesLocation,
        altitude: Double
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.inputLocation = inputLocation
        self.degreesLocation = degreesLocation
        self.altitude = altitude
    }

    public func set(date: Date) -> IGRFBuilderWithDate {
        return IGRFBuilderWithDate(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            location: inputLocation,
            altitude: altitude,
            date: date
        )
    }
}

public struct IGRFBuilderWithDate {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let location: IGRFLocation
    let altitude: Double
    let date: Date

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
