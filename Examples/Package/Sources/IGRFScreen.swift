//
//  ContentView.swift
//  IGRFExample
//
//  Created by satoutakeshi on 2025/05/24.
//

import IGRFClient
import IGRFCore
import SwiftUI

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

public struct IGRFScreen: View {
    @State private var altitude: Double = 0.0
    @State private var selectedDate: Date = Date()
    @State private var result: IGRFDisplayResult?
    @State private var isInputSheetPresented = false
    @State private var selectedPreset: LocationPreset = .tokyo

    public var body: some View {
        NavigationStack {
            content
                .font(.system(.body, design: .monospaced))
                .navigationTitle("Magnetic Field")
                .navigationBarTitleDisplayMode(.automatic)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isInputSheetPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isInputSheetPresented) {
                    inputContent
                        .presentationDetents([.medium, .large])
                }
        }
    }

    private func calculateMagneticField() {
        do {
            let location = selectedPreset
            result = try IGRFClient.create(igrfGen: .igrf14)
                .set(system: .geodetic)
                .set(
                    inputLocation: .decimalDegrees(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
                    )
                .set(alt: 0)
                .set(date: selectedDate)
                .synthesize()
        }
        catch {
            print(error.localizedDescription)
        }
    }

    public init() {}
}

extension IGRFScreen {
    @ViewBuilder
    fileprivate var content: some View {
        if let result {
            List {
                Section(header: Text("Input")) {
                    Text("Latitude: \(String(format: "%.4f", result.input.lat))°")
                    Text("longitude: \(String(format: "%.4f", result.input.lon))°")
                    Text("altitude: \(String(format: "%.1f", result.alt))")
                    Text("date: \(String(format: "%.2f", result.input.date))")
                    Text("IGRF Gen: \(result.igrfGeneration)")
                }
                Section(header: Text("Output")) {
                    Text("Declination (D): \(String(format: " %.3f", result.result.geoComponents.declination))°")
                    Text("Inclination (I): \(String(format: " %.3f", result.result.geoComponents.inclination))°")
                    Text("Horizontal intensity (H): \(String(format: " %.1f", result.result.geoComponents.horizontalIntensity)) nT")
                    Text("Total intensity (F): \(String(format: " %.1f", result.result.geoComponents.effectiveField)) nT")
                    Text("North component (X): \(String(format: " %.1f", result.result.cartesianComps.x)) nT")
                    Text("East component (Y): \(String(format: " %.1f", result.result.cartesianComps.y)) nT")
                    Text("Vertical component (Z): \(String(format: " %.1f", result.result.cartesianComps.z)) nT")
                    Text("Declination SV (D): \(String(format: " %.2f", result.result.geoComponentsSV.declination)) arcmin/yr")
                    Text("Inclination SV (I): \(String(format: " %.2f", result.result.geoComponentsSV.inclination)) arcmin/yr")
                    Text("Horizontal SV (H): \(String(format: " %.1f", result.result.geoComponentsSV.horizontalIntensity)) nT/yr")
                    Text("Total SV (F): \(String(format: " %.1f", result.result.geoComponentsSV.effectiveField)) nT/yr")
                    Text("North SV (X): \(String(format: " %.1f", result.result.cartesianCompsSV.x)) nT/yr")
                    Text("East SV (Y): \(String(format: " %.1f", result.result.cartesianCompsSV.y)) nT/yr")
                    Text("Vertical SV (Z): \(String(format: " %.1f", result.result.cartesianCompsSV.z)) nT/yr")
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

    @ViewBuilder
    fileprivate var inputContent: some View {
        NavigationStack {
            Form {
                Section(header: Text("Preset")) {
                    Picker("Location", selection: $selectedPreset) {
                        ForEach(LocationPreset.allCases, id: \.self) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    .onChange(of: selectedPreset) { newValue in
                        selectedPreset = newValue
                    }
                }

                Section(header: Text("Coordinates")) {
                    HStack {
                        Text("Altitude(km)")
                        TextField("Altitude", value: $altitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Input Parameters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isInputSheetPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Calculate") {
                        calculateMagneticField()
                        isInputSheetPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    IGRFScreen()
}
