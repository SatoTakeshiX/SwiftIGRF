//
//  ContentView.swift
//  IGRFExample
//
//  Created by satoutakeshi on 2025/05/24.
//

import IGRFClient
import IGRFCore
import SwiftUI

public struct IGRFScreen: View {
    @State private var latitude: Double = 35.0
    @State private var longitude: Double = 139.0
    @State private var altitude: Double = 0.0
    @State private var date: Date = Date()
    @State private var result: String = ""
    @State private var isInputSheetPresented = false
    @State private var selectedPreset: LocationPreset = .tokyo

    enum LocationPreset: String, CaseIterable {
        case tokyo = "Tokyo"
        case hongKong = "Hong Kong"
        case newYork = "New York"
        case london = "London"
        case custom = "Custom"

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
            case .custom:
                return (0, 0)
            }
        }
    }

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
        result = "some"
    }

    public init() {}
}

extension IGRFScreen {
    @ViewBuilder
    fileprivate var content: some View {
        if !result.isEmpty {
            List {
                Section(header: Text("Input")) {
                    Text("kkk")
                }
                Section(header: Text("Output")) {
                    Text("Declination (D): 0.000°")
                    Text("Inclination (I): 0.000°")
                    Text("Horizontal intensity (H): 0.0 nT")
                    Text("Total intensity (F): 0.0 nT")
                    Text("North component (X): 0.0 nT")
                    Text("East component (Y): 0.0 nT")
                    Text("Vertical component (Z): 0.0 nT")
                    Text("Declination SV (D): 0.00 arcmin/yr")
                    Text("Inclination SV (I): 0.00 arcmin/yr")
                    Text("Horizontal SV (H): 0.0 nT/yr")
                    Text("Total SV (F): 0.0 nT/yr")
                    Text("North SV (X): 0.0 nT/yr")
                    Text("East SV (Y): 0.0 nT/yr")
                    Text("Vertical SV (Z): 0.0 nT/yr")
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
                        if newValue != .custom {
                            latitude = newValue.coordinates.latitude
                            longitude = newValue.coordinates.longitude
                        }
                    }
                }

                Section(header: Text("Coordinates")) {
                    HStack {
                        Text("Latitude")
                        TextField("Latitude", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                            .disabled(selectedPreset != .custom)
                    }
                    HStack {
                        Text("Longitude")
                        TextField("Longitude", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                            .disabled(selectedPreset != .custom)
                    }
                    HStack {
                        Text("Altitude(km)")
                        TextField("Altitude", value: $altitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
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
