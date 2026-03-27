//  PetSelectionView.swift
//  PetEvolution

import SwiftUI

struct PetConfigurationView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel
    var onMergeTapped: () -> Void = {}

    let styles: [(id: String, label: String, fill: Color, shadow: Color)] = [
        ("gentle", "🌿 Gentle", Color(hex: "#6BCB77"), Color(hex: "#27AE60")),
        ("bold",   "🔥 Bold",   Color(hex: "#FF6B6B"), Color(hex: "#C0392B")),
        ("curious","✨ Curious", Color(hex: "#9B59B6"), Color(hex: "#6C3483"))
    ]

    // Flat ordered list for the swatch grid (same order as category groups)
    let colorPaletteCategories: [(String, [String])] = [
        ("🌅 Warm",         ["sunset orange", "golden sun", "cherry blossom pink", "autumn leaves", "coral reef", "cinnamon spice"]),
        ("❄️ Cool",         ["ocean blue", "forest green", "arctic ice", "lavender dreams", "mint fresh", "slate storm"]),
        ("✨ Vibrant",      ["rainbow bright", "neon electric", "tropical paradise", "berry blast"]),
        ("🌙 Magical/Dark", ["purple magic", "starry night", "midnight galaxy", "mystic moonlight"]),
        ("🌸 Soft/Light",   ["pink princess", "cotton candy", "pastel sunrise", "cream vanilla"]),
        ("🌿 Earthy",       ["mossy woodland", "desert sand", "volcanic ember"])
    ]

    let paletteHex: [String: String] = [
        "sunset orange": "#FF6B35", "golden sun": "#FFD93D",
        "cherry blossom pink": "#FF91A4", "autumn leaves": "#C87941",
        "coral reef": "#FF7F7F", "cinnamon spice": "#C47B3A",
        "ocean blue": "#4D96FF", "forest green": "#6BCB77",
        "arctic ice": "#A8D8EA", "lavender dreams": "#B39DDB",
        "mint fresh": "#00D2D3", "slate storm": "#607D8B",
        "rainbow bright": "#FF4757", "neon electric": "#2ED573",
        "tropical paradise": "#00BFA5", "berry blast": "#E91E8C",
        "purple magic": "#9B59B6", "starry night": "#1A237E",
        "midnight galaxy": "#311B92", "mystic moonlight": "#7B68EE",
        "pink princess": "#F48FB1", "cotton candy": "#FFBCD9",
        "pastel sunrise": "#FFD180", "cream vanilla": "#FFF8E1",
        "mossy woodland": "#558B2F", "desert sand": "#C2956C",
        "volcanic ember": "#BF360C"
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

    private var allPalettes: [String] {
        colorPaletteCategories.flatMap { $0.1 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: Header Banner
                VStack(spacing: 8) {
                    Text("🐾 Create Your Pet!")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
                    Text("Pick traits to summon your unique companion")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { _ in Text("⭐").font(.system(size: 18)) }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#4D96FF"), Color(hex: "#9B59B6")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

                VStack(spacing: 24) {

                    // Server unreachable banner
                    if !viewModel.isServiceReachable && !viewModel.isCheckingHealth {
                        ErrorView(
                            message: "Cannot reach server at \(PetEvolutionService.shared.baseURL)",
                            retryAction: nil
                        )
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }

                    // MARK: Style Picker
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "🎭 Personality Style")
                            .padding(.horizontal)

                        HStack(spacing: 10) {
                            ForEach(styles, id: \.id) { s in
                                let isSelected = viewModel.selectedStyle == s.id
                                Button(action: { viewModel.selectedStyle = s.id }) {
                                    Text(s.label)
                                        .font(.system(size: 14, weight: .black, design: .rounded))
                                        .foregroundColor(isSelected ? .white : Color(.systemGray))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? s.fill : Color(.systemGray5))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "#333333"), lineWidth: 3)
                                        )
                                        .shadow(color: isSelected ? s.shadow : .clear, radius: 0, x: 0, y: 4)
                                        .scaleEffect(isSelected ? 1.05 : 1.0)
                                }
                                .buttonStyle(BounceButtonStyle())
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // MARK: Color Swatch Grid
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(text: "🎨 Color Theme")
                            .padding(.horizontal)

                        let swatchColumns = Array(repeating: GridItem(.fixed(44), spacing: 8), count: 6)
                        LazyVGrid(columns: swatchColumns, spacing: 8) {
                            ForEach(allPalettes, id: \.self) { palette in
                                let isSelected = viewModel.colorPalette == palette
                                let hex = paletteHex[palette] ?? "#CCCCCC"
                                Button(action: { viewModel.colorPalette = palette }) {
                                    ZStack(alignment: .bottomTrailing) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: hex))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        isSelected ? Color(hex: "#333333") : Color.clear,
                                                        lineWidth: 3
                                                    )
                                            )
                                        if isSelected {
                                            Circle()
                                                .fill(Color(hex: "#333333"))
                                                .frame(width: 14, height: 14)
                                                .overlay(
                                                    Text("✓")
                                                        .font(.system(size: 8, weight: .black))
                                                        .foregroundColor(.white)
                                                )
                                                .offset(x: 2, y: 2)
                                        }
                                    }
                                }
                                .buttonStyle(BounceButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Animal Card Grid
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            SectionLabel(text: "🐾 Pick Your Animals")
                            if !viewModel.selectedAnimals.isEmpty {
                                Text("(\(viewModel.selectedAnimals.count) selected)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#9B59B6"))
                            }
                        }
                        .padding(.horizontal)

                        ForEach(animalCategories, id: \.0) { category, animals in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category)
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                                    .padding(.horizontal)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                                    ForEach(animals, id: \.0) { animal, emoji in
                                        let isSelected = viewModel.selectedAnimals.contains(animal)
                                        Button(action: { viewModel.toggleAnimal(animal) }) {
                                            VStack(spacing: 3) {
                                                Text(emoji).font(.system(size: 26))
                                                Text(animal.capitalized)
                                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                                    .foregroundColor(isSelected ? Color(hex: "#B8860B") : Color(.systemGray))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? Color(hex: "#FFF9E0") : Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(
                                                        isSelected ? Color(hex: "#FFD93D") : Color(hex: "#e0e0e0"),
                                                        lineWidth: 3
                                                    )
                                            )
                                            .shadow(
                                                color: isSelected ? Color(hex: "#FFD93D").opacity(0.5) : .clear,
                                                radius: 4, x: 0, y: 3
                                            )
                                        }
                                        .buttonStyle(BounceButtonStyle())
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // MARK: CTA Buttons / Loading / Error
                    VStack(spacing: 12) {
                        if viewModel.isLoading {
                            VStack(spacing: 8) {
                                PawSpinner()
                                Text("Summoning your pet…")
                                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .padding()
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error) {
                                viewModel.errorMessage = nil
                            }
                            .padding(.horizontal)
                        } else {
                            // Primary: Summon
                            let isDisabled = viewModel.selectedAnimals.isEmpty || !viewModel.isServiceReachable
                            SummonButton(isDisabled: isDisabled) {
                                Task { await viewModel.generatePet() }
                            }
                            .padding(.horizontal)

                            // Secondary: Merge
                            Button(action: onMergeTapped) {
                                Text("⚡️ Merge Two Pets")
                                    .font(.system(.headline, design: .rounded).bold())
                                    .foregroundColor(Color(hex: "#9B59B6"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(hex: "#9B59B6"), lineWidth: 3)
                                    )
                                    .shadow(color: Color(hex: "#9B59B6"), radius: 0, x: 0, y: 4)
                            }
                            .buttonStyle(BounceButtonStyle())
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

// Separate view to handle disabled shake animation
private struct SummonButton: View {
    let isDisabled: Bool
    let action: () -> Void
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Button(action: {
            if isDisabled { shake() } else { action() }
        }) {
            Text("🪄 Summon My Pet!")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(isDisabled ? Color(.systemGray) : Color(hex: "#333333"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isDisabled ? Color(.systemGray4) : Color(hex: "#FFD93D"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#333333"), lineWidth: 3)
                )
                .shadow(
                    color: isDisabled ? .clear : Color(hex: "#B8860B"),
                    radius: 0, x: 0, y: 5
                )
                .opacity(isDisabled ? 0.6 : 1.0)
        }
        .buttonStyle(BounceButtonStyle())
        .offset(x: shakeOffset)
    }

    private func shake() {
        withAnimation(.default) { shakeOffset = 8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.default) { shakeOffset = -8 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.default) { shakeOffset = 8 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.default) { shakeOffset = 0 }
                }
            }
        }
    }
}

private struct SectionLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black, design: .rounded))
            .textCase(.uppercase)
            .tracking(1)
            .foregroundColor(Color(.systemGray))
    }
}
