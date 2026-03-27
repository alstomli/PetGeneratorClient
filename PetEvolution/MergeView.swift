//
//  MergeView.swift
//  PetEvolution
//

import SwiftUI

struct MergeView: View {
    @StateObject private var viewModel = MergeViewModel()
    let onDismiss: () -> Void
    let onMergeComplete: (Pet) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            MergeSelectionView(viewModel: viewModel, columns: columns, onDismiss: onDismiss, onMergeComplete: onMergeComplete)

            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                PawSpinner()
            }
        }
        .onAppear { viewModel.loadHistory() }
    }
}

// MARK: - Selection View

private struct MergeSelectionView: View {
    @ObservedObject var viewModel: MergeViewModel
    let columns: [GridItem]
    let onDismiss: () -> Void
    let onMergeComplete: (Pet) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("Merge Pets")
                    .font(.headline)
                Spacer()
                // Balance the xmark
                Image(systemName: "xmark").opacity(0)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Pet slots
            HStack(spacing: 16) {
                PetSlot(pet: viewModel.pet1, slotLabel: "Pet 1") {
                    viewModel.deselectPet(slot: 1)
                }
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.secondary)
                PetSlot(pet: viewModel.pet2, slotLabel: "Pet 2") {
                    viewModel.deselectPet(slot: 2)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Merge button
            Button(action: {
                Task {
                    await viewModel.performMerge()
                    if let result = viewModel.mergeResult {
                        onMergeComplete(result.pet)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Merge!")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(viewModel.canMerge ? Color.purple : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canMerge)
            .padding(.bottom, 8)

            if let error = viewModel.errorMessage {
                ErrorView(message: error) { viewModel.errorMessage = nil }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            Divider()

            // History grid
            if viewModel.allPets.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No pets yet — evolve some first!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.allPets) { pet in
                            MergeGridCell(
                                pet: pet,
                                slotNumber: viewModel.slotNumber(for: pet),
                                isDisabled: !viewModel.canSelect(pet) && viewModel.slotNumber(for: pet) == nil
                            ) {
                                viewModel.selectPet(pet)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Pet Slot

private struct PetSlot: View {
    let pet: Pet?
    let slotLabel: String
    let onDeselect: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if let pet = pet {
                        PetImageView(imageUrl: pet.imageUrl)
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(MergeRarityHelper.rarityColor(for: pet).opacity(0.7), lineWidth: 2)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .frame(width: 110, height: 110)

                if pet != nil {
                    Button(action: onDeselect) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Color.gray.opacity(0.8), in: Circle())
                    }
                    .offset(x: 6, y: -6)
                }
            }

            Text(pet.flatMap { $0.animals?.first?.capitalized } ?? slotLabel)
                .font(.caption)
                .foregroundColor(pet != nil ? .primary : .secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Grid Cell

private struct MergeGridCell: View {
    let pet: Pet
    let slotNumber: Int?
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            PetImageView(imageUrl: pet.imageUrl)
                .aspectRatio(1, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(MergeRarityHelper.rarityColor(for: pet).opacity(0.7), lineWidth: 2)
                )
                .opacity(isDisabled ? 0.35 : 1.0)

            if let slot = slotNumber {
                Text(slot == 1 ? "①" : "②")
                    .font(.title3)
                    .padding(3)
            }
        }
        .onTapGesture {
            guard !isDisabled else { return }
            onTap()
        }
    }
}

// MARK: - Rarity Helper (local, mirrors PetHistoryView logic)

enum MergeRarityHelper {
    static func rarityColor(for pet: Pet) -> Color {
        let total = pet.augments.compactMap { $0.weight }.reduce(0, +)
        switch total {
        case 0:     return .gray
        case 1...2: return .green
        case 3...4: return .blue
        case 5...6: return .purple
        default:    return .orange
        }
    }

    static func stageBadgeColor(_ stage: Int) -> Color {
        switch stage {
        case 1: return .blue
        case 2: return .purple
        default: return .orange
        }
    }
}
