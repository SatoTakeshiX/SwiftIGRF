/// Structure for handling IGRF model data
public struct IGRFModel {
    public var time: [Double]
    public var coeffs: [[Double]]
    public var parameters: Parameters

    public init(time: [Double], coeffs: [[Double]], parameters: Parameters) {
        self.time = time
        self.coeffs = coeffs
        self.parameters = parameters
    }
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

    public init(
        shc: String,
        nmin: Int,
        nmax: Int,
        N: Int,
        order: Int,
        step: Int,
        startYear: Int,
        endYear: Int
    ) {
        self.shc = shc
        self.nmin = nmin
        self.nmax = nmax
        self.N = N
        self.order = order
        self.step = step
        self.startYear = startYear
        self.endYear = endYear
    }
}
