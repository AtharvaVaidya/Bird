//
//  ContentView.swift
//  BirdSampleApp
//
//  Created by Atharva Vaidya on 19/05/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Text("Bird")
        }
        .onAppear {
            viewModel.startCapturingLocation()
        }
    }
}

#Preview {
    ContentView()
}
