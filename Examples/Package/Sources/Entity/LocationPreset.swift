enum LocationPreset: String, CaseIterable {
    case tokyo = "Tokyo"
    case hongKong = "Hong Kong"
    case newYork = "New York"
    case london = "London"

    var coordinates: (latitude: Double, longitude: Double) {
        switch self {
        case .tokyo:
            return (35.6762, 139.6503)
        case .hongKong:
            return (22.3193, 114.1694)
        case .newYork:
            return (40.7128, -74.0060)
        case .london:
            return (51.5074, -0.1278)
        }
    }
}
