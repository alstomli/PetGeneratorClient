//
//  EvolutionView.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import SwiftUI

struct EvolutionView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel
    let isFinalEvolution: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text(isFinalEvolution ? "Final Evolution" : "First Evolution")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)

            // Current Pet Display
            if let pet = viewModel.currentPet {
                VStack(spacing: 12) {
                    Text("Stage \(pet.stage) of \(pet.maxStages)")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    PetImageView(imageUrl: pet.imageUrl)
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Augments (if any)
                    if !pet.augments.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Augments")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(pet.augments.map { $0.name }.joined(separator: ", "))
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }

            Divider()

            // Evolution button / loading / error
            if viewModel.isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(1.3)
                    Text("Evolving your pet...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else if let error = viewModel.errorMessage {
                ErrorView(message: error) {
                    viewModel.errorMessage = nil
                }
                .padding(.horizontal)
            } else {
                // Evolution Path Picker
                VStack(spacing: 8) {
                    Text("Choose Evolution Path")
                        .font(.headline)

                    HStack(spacing: 12) {
                        ForEach([("gentle", "Gentle", "leaf.fill", Color.green),
                                 ("bold", "Bold", "flame.fill", Color.orange),
                                 ("curious", "Curious", "sparkles", Color.purple)], id: \.0) { path, label, icon, color in
                            Button(action: {
                                viewModel.selectedEvolutionPath = path
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                    Text(label)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(viewModel.selectedEvolutionPath == path ? .white : color)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedEvolutionPath == path ? color : color.opacity(0.12))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)

                Button(action: {
                    Task { await viewModel.evolvePet() }
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text(isFinalEvolution ? "Final Evolve!" : "Evolve!")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isFinalEvolution ? Color.orange : Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}
