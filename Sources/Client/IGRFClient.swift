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

public struct IGRFBuilderWithLocation {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation

    init(
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

public struct IGRFBuilderWithGeocentricComponents {
    let igrfGen: IGRFGen
    let coordinateSystem: CoordinateSystemType
    let inputLocation: IGRFLocation
    let degreesLocation: DegreesLocation
    let components: GeocentricCoordinateComponents

    init(
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
