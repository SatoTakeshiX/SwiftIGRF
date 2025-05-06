public struct CartesianMagneticComponents {
    // North
    public let x: Double
    // East
    public let y: Double
    // Vertical
    public let z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}
