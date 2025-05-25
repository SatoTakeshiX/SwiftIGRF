import IGRFCore

/// Represents a location with a specified degree format
public enum IGRFLocation: Equatable {
    case degreesAndMinutes(
        latDegrees: Double,
        latMinutes: Double,
        lonDegrees: Double,
        lonMinutes: Double
    )
    case decimalDegrees(
        latitude: Double,
        longitude: Double
    )

    var format: DegreeFormat {
        switch self {
        case .degreesAndMinutes:
            return .degreesAndMinutes
        case .decimalDegrees:
            return .decimalDegrees
        }
    }
}
