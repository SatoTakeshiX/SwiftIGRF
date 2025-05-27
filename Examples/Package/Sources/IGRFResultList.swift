import IGRFClient
import SwiftUI

struct IGRFResultList: View {
    let result: IGRFDisplayResult?

    var body: some View {
        if let result {
            List {
                Section(header: Text("Input")) {
                    Text("Latitude: \(String(format: "%.4f", result.input.lat))°")
                    Text("longitude: \(String(format: "%.4f", result.input.lon))°")
                    Text("altitude: \(String(format: "%.1f", result.alt))")
                    Text("date: \(formattedDay)")
                    Text("IGRF Gen: \(result.igrfGeneration)")
                }
                Section(header: Text("Output")) {
                    Text(
                        "Declination (D): \(String(format: " %.3f", result.result.geoComponents.declination))°"
                    )
                    Text(
                        "Inclination (I): \(String(format: " %.3f", result.result.geoComponents.inclination))°"
                    )
                    Text(
                        "Horizontal intensity (H): \(String(format: " %.1f", result.result.geoComponents.horizontalIntensity)) nT"
                    )
                    Text(
                        "Total intensity (F): \(String(format: " %.1f", result.result.geoComponents.effectiveField)) nT"
                    )
                    Text(
                        "North component (X): \(String(format: " %.1f", result.result.cartesianComps.x)) nT"
                    )
                    Text(
                        "East component (Y): \(String(format: " %.1f", result.result.cartesianComps.y)) nT"
                    )
                    Text(
                        "Vertical component (Z): \(String(format: " %.1f", result.result.cartesianComps.z)) nT"
                    )
                    Text(
                        "Declination SV (D): \(String(format: " %.2f", result.result.geoComponentsSV.declination)) arcmin/yr"
                    )
                    Text(
                        "Inclination SV (I): \(String(format: " %.2f", result.result.geoComponentsSV.inclination)) arcmin/yr"
                    )
                    Text(
                        "Horizontal SV (H): \(String(format: " %.1f", result.result.geoComponentsSV.horizontalIntensity)) nT/yr"
                    )
                    Text(
                        "Total SV (F): \(String(format: " %.1f", result.result.geoComponentsSV.effectiveField)) nT/yr"
                    )
                    Text(
                        "North SV (X): \(String(format: " %.1f", result.result.cartesianCompsSV.x)) nT/yr"
                    )
                    Text(
                        "East SV (Y): \(String(format: " %.1f", result.result.cartesianCompsSV.y)) nT/yr"
                    )
                    Text(
                        "Vertical SV (Z): \(String(format: " %.1f", result.result.cartesianCompsSV.z)) nT/yr"
                    )
                }
            }
            .font(.system(.body, design: .monospaced))
        } else {
            ContentUnavailableView(
                "No Data",
                systemImage: "magnet",
                description: Text("Tap the button below to calculate magnetic field")
            )
        }
    }

    private var formattedDay: String {
        guard let date = result?.input.date
        else {
            return ""
        }
        return date.formatted(
            .dateTime
                .year()
                .month()
                .day()
        )
    }
}
