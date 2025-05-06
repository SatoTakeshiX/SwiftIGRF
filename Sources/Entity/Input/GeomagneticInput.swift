public struct GeomagneticInput: InputResultProtocol {
    let date: Double
    let alt: Double
    let lat: Double
    let colat: Double
    let lon: Double
    let coordinateSystem: CoordinateSystemType
    let sd: Double
    let cd: Double
}
