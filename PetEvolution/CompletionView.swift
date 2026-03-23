//
//  CompletionView.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import SwiftUI

struct CompletionView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            // Title
            Text("Evolution Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your pet has reached its final form")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Final Pet Display
            if let pet = viewModel.currentPet {
                VStack(spacing: 16) {
                    PetImageView(imageUrl: pet.imageUrl)
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(radius: 10)

                    // Stage Badge
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Stage \(pet.stage) of \(pet.maxStages)")
                        Image(systemName: "star.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                )
                .padding(.horizontal)
            }

            Spacer()

            // Start Over Button
            Button(action: { viewModel.reset() }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Start New Evolution")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}
