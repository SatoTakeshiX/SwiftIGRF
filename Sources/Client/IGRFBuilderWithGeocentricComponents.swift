import Foundation
import IGRFCore

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
            decimalYear: dateDouble
        )
    }

    public func set(decimalYear: Double) throws -> IGRFBuilderWithDate {
        guard (1900...2035).contains(decimalYear) else {
            throw IGRFError.invalidDate(
                message: "Invalid date. Please enter a date between 1900 and 2035.")
        }
        return IGRFBuilderWithDate(
            igrfGen: igrfGen,
            coordinateSystem: coordinateSystem,
            inputLocation: inputLocation,
            degreesLocation: degreesLocation,
            components: components,
            decimalYear: decimalYear
        )
    }
}
