import Foundation
import IGRFCore

public struct IGRFBuilderWithLocation {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation

    public init(
        igrfGen: IGRFGen,
        coordinateSystem: CoordinateSystemType,
        inputLocation: IGRFLocation,
        degreesLocation: DegreesLocation
    ) {
        self.igrfGen = igrfGen
        self.coordinateSystem = coordinateSystem
        self.inputLocation = inputLocation
        self.degreesLocation = degreesLocation
    }

    public func set(alt: Double) throws -> IGRFBuilderWithGeocentricComponents {
        switch coordinateSystem {
        case .geodetic:
            let (radius, geocentricColat, newSd, newCd) = IGRFUtils.ggToGeo(
                h: alt,
                gdcolat: degreesLocation.colatitude
            )
            let components = GeocentricCoordinateComponents(
                radius: radius,
                geocentricColat: geocentricColat,
                sineOfDeclination: newSd,
                cosineOfDeclination: newCd
            )
            return IGRFBuilderWithGeocentricComponents(
                igrfGen: igrfGen,
                coordinateSystem: coordinateSystem,
                inputLocation: inputLocation,
                degreesLocation: degreesLocation,
                components: components
            )
        case .geocentric:
            guard alt >= 3485 else {
                throw IGRFError.invalidAltitude(
                    message: "Invalid altitude. Alt must be greater then CMB radius (3485 km)"
                )
            }
            return IGRFBuilderWithGeocentricComponents(
                igrfGen: igrfGen,
                coordinateSystem: coordinateSystem,
                inputLocation: inputLocation,
                degreesLocation: degreesLocation,
                components: GeocentricCoordinateComponents(
                    radius: alt,
                    geocentricColat: degreesLocation.colatitude,
                    sineOfDeclination: 0,
                    cosineOfDeclination: 0
                )
            )
        }
    }
}
