public struct MagneticFieldComponents {
    public let radial: Double  // B_radius
    public let theta: Double  // B_theta
    public let phi: Double  // B_phi

    public init(radial: Double, theta: Double, phi: Double) {
        self.radial = radial
        self.theta = theta
        self.phi = phi
    }
}
