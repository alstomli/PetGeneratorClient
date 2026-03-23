//
//  PetSelectionView.swift
//  PetEvolution
//
//  Created by Zihan Li on 1/25/26.
//

import SwiftUI

struct PetConfigurationView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel

    let styles = ["bold", "gentle", "curious"]

    let colorPaletteCategories: [(String, [String])] = [
        ("🌅 Warm",         ["sunset orange", "golden sun", "cherry blossom pink", "autumn leaves", "coral reef", "cinnamon spice"]),
        ("❄️ Cool",         ["ocean blue", "forest green", "arctic ice", "lavender dreams", "mint fresh", "slate storm"]),
        ("✨ Vibrant",      ["rainbow bright", "neon electric", "tropical paradise", "berry blast"]),
        ("🌙 Magical/Dark", ["purple magic", "starry night", "midnight galaxy", "mystic moonlight"]),
        ("🌸 Soft/Light",   ["pink princess", "cotton candy", "pastel sunrise", "cream vanilla"]),
        ("🌿 Earthy",       ["mossy woodland", "desert sand", "volcanic ember"])
    ]

    let animalCategories: [(String, [(String, String)])] = [
        ("🏠 Domestic", [("cat", "🐱"), ("dog", "🐶"), ("bunny", "🐰"), ("hamster", "🐹")]),
        ("🌲 Forest",   [("fox", "🦊"), ("bear", "🐻"), ("deer", "🦌"), ("squirrel", "🐿️"), ("raccoon", "🦝"), ("wolf", "🐺")]),
        ("🌊 Sea & Sky",[("bird", "🐦"), ("butterfly", "🦋"), ("owl", "🦉"), ("eagle", "🦅"),
                         ("dolphin", "🐬"), ("penguin", "🐧"), ("seal", "🦭"), ("stingray", "🐟"),
                         ("crab", "🦀"), ("octopus", "🐙")]),
        ("⚡️ Mythical", [("dragon", "🐉"), ("unicorn", "🦄"), ("phoenix", "🔥"), ("griffin", "⚜️")]),
        ("🌍 Exotic",   [("tiger", "🐯"), ("lion", "🦁"), ("panda", "🐼"), ("elephant", "🐘"),
                         ("giraffe", "🦒"), ("monkey", "🐒"), ("chameleon", "🦎"),
                         ("kangaroo", "🦘"), ("sloth", "🦥"), ("armadillo", "🛡️")])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Configure Your Pet")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                Text("Choose your pet's characteristics to generate a unique creature")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Server unreachable banner
                if !viewModel.isServiceReachable && !viewModel.isCheckingHealth {
                    HStack {
                        Image(systemName: "exclamationmark.wifi")
                        Text("Cannot reach server at \(PetEvolutionService.shared.baseURL)")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // MARK: Style Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Style")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(styles, id: \.self) { style in
                                Button(action: { viewModel.selectedStyle = style }) {
                                    Text(style.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedStyle == style ? Color.purple : Color(.systemGray5))
                                        .foregroundColor(viewModel.selectedStyle == style ? .white : .primary)
                                        .cornerRadius(20)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // MARK: Color Palette Picker (by category)
                VStack(alignment: .leading, spacing: 16) {
                    Text("Color Palette")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(colorPaletteCategories, id: \.0) { category, palettes in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(palettes, id: \.self) { palette in
                                        Button(action: { viewModel.colorPalette = palette }) {
                                            Text(palette.capitalized)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 7)
                                                .background(viewModel.colorPalette == palette ? Color.blue : Color(.systemGray5))
                                                .foregroundColor(viewModel.colorPalette == palette ? .white : .primary)
                                                .cornerRadius(16)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                // MARK: Animal Multi-Select (by category)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Animals")
                            .font(.headline)
                        if !viewModel.selectedAnimals.isEmpty {
                            Text("(\(viewModel.selectedAnimals.count) selected)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    if viewModel.selectedAnimals.isEmpty {
                        Text("Select at least one animal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }

                    ForEach(animalCategories, id: \.0) { category, animals in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(animals, id: \.0) { animal, emoji in
                                    let isSelected = viewModel.selectedAnimals.contains(animal)
                                    Button(action: { viewModel.toggleAnimal(animal) }) {
                                        VStack(spacing: 3) {
                                            Text(emoji)
                                                .font(.title2)
                                            Text(animal.capitalized)
                                                .font(.caption2)
                                                .foregroundColor(isSelected ? .white : .primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? Color.green : Color(.systemGray5))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // MARK: Generate button / loading / error
                if viewModel.isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.3)
                        Text("Generating your pet...")
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
                    Button(action: {
                        Task { await viewModel.generatePet() }
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Generate Pet!")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            viewModel.selectedAnimals.isEmpty || !viewModel.isServiceReachable
                                ? Color.gray : Color.purple
                        )
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedAnimals.isEmpty || !viewModel.isServiceReachable)
                    .padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
        }
    }
}
