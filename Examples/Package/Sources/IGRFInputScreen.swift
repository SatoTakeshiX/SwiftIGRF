import SwiftUI
import IGRFClient

struct IGRFInputScreen: View {
    @Binding var result: IGRFDisplayResult?
    @Binding var isInputSheetPresented: Bool
    @Binding var selectedPreset: LocationPreset
    @Binding var altitude: Double
    @Binding var selectedDate: Date

    var body: some View {
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

    private func calculateMagneticField() {
        do {
            let location = selectedPreset
            result = try IGRFClient.create(igrfGen: .igrf14)
                .set(system: .geodetic)
                .set(
                    inputLocation: .decimalDegrees(
                        latitude: location.coordinates.latitude,
                        longitude: location.coordinates.longitude
                    )
                )
                .set(alt: altitude)
                .set(date: selectedDate)
                .synthesize()
        } catch {
            print(error.localizedDescription)
        }
    }
}
