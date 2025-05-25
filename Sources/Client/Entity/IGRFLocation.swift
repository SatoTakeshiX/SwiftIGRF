import IGRFCore

/// Represents a location with a specified degree format
public struct IGRFLocation: Equatable {
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
