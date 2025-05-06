public struct GridTimeSeriesInput: InputResultProtocol {
    let date: [Double]
    let alt: [Double]
    let lat: [Double]
    let colat: [Double]
    let lon: [Double]
    let itype: CoordinateSystemType
    let sd: [Double]
    let cd: [Double]
}
