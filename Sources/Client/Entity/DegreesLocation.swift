/// A struct that represents a location in decimal degrees format
/// This struct is used to store latitude and longitude values that have already been converted to decimal degrees
/// The colatitude (90 - latitude) is automatically calculated for convenience
public struct DegreesLocation: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let colatitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.colatitude = 90 - latitude
    }
}
