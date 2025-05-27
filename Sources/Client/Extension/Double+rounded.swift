import Foundation

extension Double {
    /// Rounds the decimal places to the specified number of digits
    /// - Parameter places: Number of decimal places
    /// - Returns: Rounded result
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
