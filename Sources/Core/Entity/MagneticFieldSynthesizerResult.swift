public struct MagneticFieldSynthesizerResult {
    public let geoComponents: GeomagneticComponents
    public let geoComponentsSV: GeomagneticComponents
    public let cartesianComps: CartesianMagneticComponents
    public let cartesianCompsSV: CartesianMagneticComponents
    public let cartesianCompsMain: CartesianMagneticComponents

    public init(
        geoComponents: GeomagneticComponents,
        geoComponentsSV: GeomagneticComponents,
        cartesianComps: CartesianMagneticComponents,
        cartesianCompsSV: CartesianMagneticComponents,
        cartesianCompsMain: CartesianMagneticComponents
    ) {
        self.geoComponents = geoComponents
        self.geoComponentsSV = geoComponentsSV
        self.cartesianComps = cartesianComps
        self.cartesianCompsSV = cartesianCompsSV
        self.cartesianCompsMain = cartesianCompsMain
    }
}
