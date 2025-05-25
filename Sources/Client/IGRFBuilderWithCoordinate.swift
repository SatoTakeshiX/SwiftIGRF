import Foundation
import IGRFCore

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
        inputLocation: IGRFLocation
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
                degreesLocation: degreesLocation
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
                degreesLocation: degreesLocation
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
