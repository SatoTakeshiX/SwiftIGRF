import Foundation
import IGRFCore

public struct IGRFClient {
    public static func create(igrfGen: IGRFGen) -> IGRFBuilder {
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
            let (latd, latm) = splitUsingModf(inputLocation.latitude)
            print("inputLocation.latitude: \(inputLocation.latitude)")
            print("latd: \(latd), latm: \(latm)")
            let (lond, lonm) = splitUsingModf(inputLocation.longitude)

            print("latd: \(latd), latm: \(latm), lond: \(lond), lonm: \(lonm)")

            let (lat, lon) = IGRFUtils.checkLatLonBounds(
                latd: latd,
                latm: latm,
                lond: lond,
                lonm: lonm
            )
            print("lat: \(lat), lon: \(lon)")
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

    /// Splits a value into degrees and minutes
    /// - Parameter value: The Double value to split
    /// - Returns: (degrees, minutes)
    func splitUsingModf(_ degreeMinuts: Double) -> (degrees: Double, minutes: Double) {
        var intPart: Double = 0
        let fracPart = modf(degreeMinuts, &intPart)
        let minutesRounded = fracPart.rounded(toPlaces: 6) * 100
        return (degrees: intPart, minutes: minutesRounded)
    }
}

extension Double {
    /// 小数点以下を指定桁まで丸める
    /// - Parameter places: 小数点以下の桁数
    /// - Returns: 丸めた結果
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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
