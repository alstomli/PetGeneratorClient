//
//  ContentView.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PetEvolutionViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Main content based on current stage
                Group {
                    switch viewModel.currentStage {
                    case .configuration:
                        PetConfigurationView(viewModel: viewModel)
                    case .firstEvolution:
                        EvolutionView(viewModel: viewModel, isFinalEvolution: false)
                    case .finalEvolution:
                        EvolutionView(viewModel: viewModel, isFinalEvolution: true)
                    case .complete:
                        CompletionView(viewModel: viewModel)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentStage == .configuration {
                        NavigationLink(destination: PetHistoryView(viewModel: viewModel)) {
                            Image(systemName: "clock")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStage != .configuration && viewModel.currentStage != .complete {
                        Button(action: { viewModel.reset() }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.checkHealth()
        }
    }
}

#Preview {
    ContentView()
}
