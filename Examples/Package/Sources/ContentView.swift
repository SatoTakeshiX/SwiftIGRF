//
//  ContentView.swift
//  IGRFExample
//
//  Created by satoutakeshi on 2025/05/24.
//

import SwiftUI
import IGRFCore
import IGRFClient

public struct ContentView: View {
    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }

    public init() {}
}

#Preview {
    ContentView()
}
