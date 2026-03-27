//  CompletionView.swift
//  PetEvolution

import SwiftUI

struct CompletionView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel
    @State private var showHistory = false

    var body: some View {
        ZStack {
            Color(hex: "#f0f4ff").ignoresSafeArea()

            ConfettiView()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)

                    // MARK: Victory Banner
                    VStack(spacing: 8) {
                        Text("🎉 Evolution Complete!")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
                        Text("Your pet has reached its final form!")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FFD93D"), Color(hex: "#FF6B6B"), Color(hex: "#9B59B6")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color(hex: "#333333"), lineWidth: 3)
                    )
                    .shadow(color: Color(hex: "#333333").opacity(0.3), radius: 0, x: 0, y: 6)
                    .padding(.horizontal)

                    // MARK: Pet Showcase Card
                    if let pet = viewModel.currentPet {
                        let rarity = RarityInfo.from(augments: pet.augments)

                        VStack(spacing: 14) {
                            PetImageView(imageUrl: pet.imageUrl)
                                .frame(width: 180, height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 24))

                            // Rarity Badge
                            Text("\(rarity.emoji) \(rarity.label)")
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundColor(rarity.label == "Mythical" ? Color(hex: "#333333") : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(rarity.color)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color(hex: "#333333"), lineWidth: 2))
                                .shadow(color: rarity.color.opacity(0.4), radius: 4, x: 0, y: 3)

                            // Augment Chips
                            if !pet.augments.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        ForEach(pet.augments, id: \.id) { aug in
                                            Text(aug.name)
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#333333"))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color(hex: "#FFD93D"))
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(Color(hex: "#333333"), lineWidth: 2))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(hex: "#333333"), lineWidth: 3)
                        )
                        .shadow(color: Color(hex: "#333333").opacity(0.3), radius: 0, x: 0, y: 6)
                        .padding(.horizontal)

                        // MARK: Stats Row
                        HStack(spacing: 10) {
                            StatBox(icon: "🏆", value: "Stage \(pet.stage)", label: "Max Level")
                            StatBox(icon: "⚡️", value: (pet.evolutionPath ?? "—").capitalized, label: "Final Path")
                            StatBox(icon: "🎁", value: "\(pet.augments.count)", label: "Augments")
                        }
                        .padding(.horizontal)
                    }

                    // MARK: Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { viewModel.reset() }) {
                            Text("🐾 Start New Evolution")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(hex: "#4D96FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "#333333"), lineWidth: 3)
                                )
                                .shadow(color: Color(hex: "#2563AD"), radius: 0, x: 0, y: 5)
                        }
                        .buttonStyle(BounceButtonStyle())

                        Button(action: { showHistory = true }) {
                            Text("📖 View Pet History")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: "#333333"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "#333333"), lineWidth: 3)
                                )
                                .shadow(color: Color(hex: "#333333").opacity(0.4), radius: 0, x: 0, y: 4)
                        }
                        .buttonStyle(BounceButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            PetHistoryView(viewModel: viewModel)
        }
    }

}

// MARK: - Stat Box
private struct StatBox: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(icon).font(.system(size: 22))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .textCase(.uppercase)
                .tracking(0.5)
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#333333"), lineWidth: 3)
        )
        .shadow(color: Color(hex: "#333333").opacity(0.3), radius: 0, x: 0, y: 4)
    }
}

// MARK: - Confetti Canvas
private struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id: Int
        let x: CGFloat
        let y0: CGFloat
        let speed: CGFloat
        let color: Color
    }

    private let colors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#FFD93D"), Color(hex: "#4D96FF"),
        Color(hex: "#6BCB77"), Color(hex: "#9B59B6"), Color(hex: "#FF9F43")
    ]

    @State private var pieces: [Piece] = []
    @State private var started: Date = .now

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = CGFloat(timeline.date.timeIntervalSince(started))
                    for piece in pieces {
                        let rawY = piece.y0 + t * piece.speed
                        let totalHeight = size.height + 40
                        let wrapped = rawY.truncatingRemainder(dividingBy: totalHeight)
                        let y = wrapped < 0 ? wrapped + totalHeight : wrapped
                        context.fill(
                            Path(CGRect(x: piece.x, y: y, width: 10, height: 10)),
                            with: .color(piece.color)
                        )
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .onAppear {
                started = .now
                pieces = (0..<20).map { i in
                    Piece(
                        id: i,
                        x: CGFloat.random(in: 0...geo.size.width),
                        y0: CGFloat.random(in: -200...(-20)),
                        speed: CGFloat.random(in: 60...120),
                        color: colors[Int.random(in: 0..<colors.count)]
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
