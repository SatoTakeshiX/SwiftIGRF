/// Structure for handling IGRF model data
public struct IGRFModel {
    public var time: [Double]
    public var coeffs: [[Double]]
    public var parameters: Parameters
}

public struct Parameters {
    public var shc: String
    public var nmin: Int
    public var nmax: Int
    public var N: Int
    public var order: Int
    public var step: Int
    public var startYear: Int
    public var endYear: Int
}
