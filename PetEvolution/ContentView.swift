//  ContentView.swift
//  PetEvolution

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PetEvolutionViewModel()
    @State private var showMerge = false

    var body: some View {
        NavigationView {
            ZStack {
                // Flat background
                Color(hex: "#f0f4ff")
                    .ignoresSafeArea()

                // Floating stars layer
                FloatingStarsBackground()

                // Main content based on current stage
                Group {
                    switch viewModel.currentStage {
                    case .configuration:
                        PetConfigurationView(viewModel: viewModel, onMergeTapped: { showMerge = true })
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
                            ToolbarChip(systemName: "clock")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.currentStage != .configuration && viewModel.currentStage != .complete {
                        Button(action: { viewModel.reset() }) {
                            ToolbarChip(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showMerge) {
            MergeView(
                onDismiss: { showMerge = false },
                onMergeComplete: { mergedPet in
                    showMerge = false
                    viewModel.currentPet = mergedPet
                    viewModel.currentStage = .firstEvolution
                }
            )
        }
        .task {
            await viewModel.checkHealth()
        }
    }
}

#Preview {
    ContentView()
}
