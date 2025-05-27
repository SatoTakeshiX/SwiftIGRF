import IGRFClient
import SwiftUI

public struct IGRFScreen: View {
    @State private var altitude: Double = 0.0
    @State private var selectedDate: Date = Date()
    @State private var result: IGRFDisplayResult?
    @State private var isInputSheetPresented = false
    @State private var selectedPreset: LocationPreset = .tokyo

    public var body: some View {
        NavigationStack {
            IGRFResultList(result: result)
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
                    IGRFInputScreen(
                        result: $result,
                        isInputSheetPresented: $isInputSheetPresented,
                        selectedPreset: $selectedPreset,
                        altitude: $altitude,
                        selectedDate: $selectedDate
                    )
                    .presentationDetents([.medium, .large])
                }
        }
    }

    public init() {}
}

#Preview {
    IGRFScreen()
}
