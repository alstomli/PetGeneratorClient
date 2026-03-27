//  EvolutionView.swift
//  PetEvolution

import SwiftUI

struct EvolutionView: View {
    @ObservedObject var viewModel: PetEvolutionViewModel
    let isFinalEvolution: Bool

    @State private var showOverlay = false
    @State private var loadingStart: Date = .now
    @State private var sparkleRotation: Double = 0
    @State private var sparkleScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Header Banner
                    VStack(spacing: 12) {
                        Text(isFinalEvolution ? "🌟 Final Evolution!" : "⚡️ Time to Evolve!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)

                        // Stage progress dots
                        StageDots(isFinal: isFinalEvolution)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F43"), Color(hex: "#FF6B6B")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                    VStack(spacing: 20) {

                        // MARK: Pet Display Card
                        if let pet = viewModel.currentPet {
                            VStack(spacing: 12) {
                                PetImageView(imageUrl: pet.imageUrl)
                                    .frame(width: 160, height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                Text("Stage \(pet.stage) of \(pet.maxStages)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.systemGray))

                                if !pet.augments.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(pet.augments, id: \.id) { aug in
                                                Text(aug.name)
                                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color(hex: "#9B59B6"))
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
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(hex: "#333333"), lineWidth: 3)
                            )
                            .shadow(color: Color(hex: "#333333").opacity(0.3), radius: 0, x: 0, y: 6)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        } else {
                            // Empty state
                            VStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "#cccccc"), style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "pawprint")
                                            .font(.system(size: 36))
                                            .foregroundColor(Color(.systemGray4))
                                    )
                                Text("Your pet will appear here")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.systemGray))
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color(hex: "#333333"), lineWidth: 3)
                            )
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }

                        // MARK: Evolution Path Picker or Loading/Error
                        if viewModel.isLoading {
                            // handled by overlay
                            Color.clear.frame(height: 40)
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error) {
                                viewModel.errorMessage = nil
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                Text("Choose Evolution Path")
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .textCase(.uppercase)
                                    .tracking(1)
                                    .foregroundColor(Color(.systemGray))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)

                                HStack(spacing: 10) {
                                    ForEach(pathData, id: \.id) { p in
                                        let isSelected = viewModel.selectedEvolutionPath == p.id
                                        Button(action: { viewModel.selectedEvolutionPath = p.id }) {
                                            VStack(spacing: 4) {
                                                Text(p.emoji).font(.system(size: 28))
                                                Text(p.name)
                                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                                    .foregroundColor(.primary)
                                                Text(p.desc)
                                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                                    .foregroundColor(Color(.systemGray))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .stroke(
                                                        isSelected ? p.borderColor : Color(hex: "#e0e0e0"),
                                                        lineWidth: 3
                                                    )
                                            )
                                            .shadow(
                                                color: isSelected ? p.borderColor : .clear,
                                                radius: 0, x: 0, y: isSelected ? 4 : 0
                                            )
                                            .offset(y: isSelected ? -2 : 0)
                                        }
                                        .buttonStyle(BounceButtonStyle())
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                                    }
                                }
                                .padding(.horizontal)

                                // Evolve Button
                                Button(action: {
                                    showOverlay = true
                                    loadingStart = .now
                                    Task {
                                        await viewModel.evolvePet()
                                        let elapsed = Date.now.timeIntervalSince(loadingStart)
                                        let remaining = max(0, 1.5 - elapsed)
                                        if remaining > 0 {
                                            try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                                        }
                                        showOverlay = false
                                    }
                                }) {
                                    Text(isFinalEvolution ? "🌟 Final Evolve!" : "⚡️ Evolve!")
                                        .font(.system(size: 20, weight: .black, design: .rounded))
                                        .foregroundColor(isFinalEvolution ? Color(hex: "#333333") : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(isFinalEvolution ? Color(hex: "#FFD93D") : Color(hex: "#FF6B6B"))
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color(hex: "#333333"), lineWidth: 3)
                                        )
                                        .shadow(
                                            color: isFinalEvolution ? Color(hex: "#B8860B") : Color(hex: "#C0392B"),
                                            radius: 0, x: 0, y: 5
                                        )
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

            // MARK: Loading Overlay (min 1.5s)
            if showOverlay {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("✨")
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(sparkleRotation))
                        .scaleEffect(sparkleScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                sparkleScale = 1.3
                            }
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                sparkleRotation = 360
                            }
                        }
                        .onDisappear {
                            sparkleRotation = 0
                            sparkleScale = 0.8
                        }

                    TimelineView(.periodic(from: .now, by: 0.5)) { ctx in
                        let dots = Int(ctx.date.timeIntervalSinceReferenceDate / 0.5) % 3 + 1
                        Text("Your pet is evolving" + String(repeating: ".", count: dots))
                            .font(.system(.title3, design: .rounded).bold())
                            .foregroundColor(.primary)
                    }
                }
                .padding(32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(40)
            }
        }
    }

    private let pathData: [(id: String, emoji: String, name: String, desc: String, borderColor: Color)] = [
        ("gentle", "🌿", "Gentle",  "Calm & Wise",     Color(hex: "#6BCB77")),
        ("bold",   "🔥", "Bold",    "Fierce & Strong", Color(hex: "#FF9F43")),
        ("curious","✨", "Curious", "Clever & Wild",   Color(hex: "#9B59B6"))
    ]
}

// MARK: - Stage Progress Dots
private struct StageDots: View {
    let isFinal: Bool

    enum DotState { case done, active, future }

    var dot1: DotState { .done }
    var dot2: DotState { isFinal ? .done : .active }
    var dot3: DotState { isFinal ? .active : .future }

    var body: some View {
        HStack(spacing: 0) {
            DotView(state: dot1, label: "Baby")
            ConnectorLine(done: true)
            DotView(state: dot2, label: "Juvenile")
            ConnectorLine(done: isFinal)
            DotView(state: dot3, label: "Adult")
        }
    }
}

private struct DotView: View {
    let state: StageDots.DotState
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(dotFill)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(
                            state == .active ? Color(hex: "#333333") : Color.clear,
                            lineWidth: 3
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: state == .active ? 4 : 0)
                            .scaleEffect(1.3)
                    )

                if state == .done {
                    Text("✓")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(Color(hex: "#FF9F43"))
                } else if state == .active {
                    Text("★")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.black)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
    }

    var dotFill: Color {
        switch state {
        case .done:   return .white
        case .active: return Color(hex: "#FFD93D")
        case .future: return Color.white.opacity(0.3)
        }
    }
}

private struct ConnectorLine: View {
    let done: Bool
    var body: some View {
        Rectangle()
            .fill(done ? Color.white : Color.white.opacity(0.35))
            .frame(width: 40, height: 3)
    }
}
