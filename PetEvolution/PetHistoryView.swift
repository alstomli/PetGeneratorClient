//
//  PetHistoryView.swift
//  PetEvolution
//

import SwiftUI

struct PetHistoryView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Group {
            if viewModel.petHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No pets yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Generated and evolved pets will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.petHistory) { pet in
                            NavigationLink(destination: PetDetailView(pet: pet)) {
                                PetThumbnail(pet: pet)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Pet History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadHistory()
        }
    }
}

private struct PetThumbnail: View {
    let pet: Pet

    var body: some View {
        PetImageView(imageUrl: pet.imageUrl)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(PetRarityHelper.rarityInfo(for: pet).color.opacity(0.7), lineWidth: 2)
            )
    }
}

// MARK: - PetDetailView

struct PetDetailView: View {
    let pet: Pet

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PetImageView(imageUrl: pet.imageUrl)
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 12) {
                    // Rarity
                    let rarity = PetRarityHelper.rarityInfo(for: pet)
                    HStack {
                        Text(rarity.label)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(rarity.color)
                            .clipShape(Capsule())
                        Spacer()
                    }

                    Divider()

                    // Stage
                    DetailRow(label: "Stage", value: "Stage \(pet.stage) / \(pet.maxStages)")
                        .foregroundColor(PetRarityHelper.stageBadgeColor(pet.stage))

                    // Style / Evolution Path
                    if let path = pet.evolutionPath ?? pet.style {
                        DetailRow(label: "Style", value: path.capitalized)
                    }

                    // Color Palette
                    if let palette = pet.colorPalette {
                        DetailRow(label: "Colors", value: palette.capitalized)
                    }

                    // Animals
                    if let animals = pet.animals, !animals.isEmpty {
                        DetailRow(label: "Animals", value: animals.joined(separator: ", "))
                    }

                    // Augments
                    if !pet.augments.isEmpty {
                        Divider()
                        Text("Augments")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(pet.augments, id: \.id) { augment in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(PetRarityHelper.augmentColor(augment.category))
                                        .frame(width: 8, height: 8)
                                    Text(augment.name)
                                        .font(.subheadline)
                                    if let category = augment.category {
                                        Text(category.capitalized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Pet Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var foregroundColor: Color = .primary

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(foregroundColor)
            Spacer()
        }
    }
}

// MARK: - PetRarityHelper

private enum PetRarityHelper {
    static func rarityInfo(for pet: Pet) -> (label: String, color: Color) {
        let total = pet.augments.compactMap { $0.weight }.reduce(0, +)
        switch total {
        case 0:     return ("Common", .gray)
        case 1...2: return ("Uncommon", .green)
        case 3...4: return ("Rare", .blue)
        case 5...6: return ("Legendary", .purple)
        default:    return ("Mythical", .orange)
        }
    }

    static func augmentColor(_ category: String?) -> Color {
        switch category?.lowercased() {
        case "elemental": return .orange
        case "celestial": return .purple
        case "nature":    return .green
        case "spirit":    return .pink
        case "arcane":    return .blue
        default:          return .gray
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
