//  Components.swift
//  PetEvolution

import SwiftUI

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Pet Image View (decodes base64 data URLs)
struct PetImageView: View {
    let imageUrl: String

    private var uiImage: UIImage? {
        guard imageUrl.hasPrefix("data:") else { return nil }
        guard let commaIndex = imageUrl.firstIndex(of: ",") else { return nil }
        let base64String = String(imageUrl[imageUrl.index(after: commaIndex)...])
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
        }
    }
}

// MARK: - Paw Spinner (replaces ProgressView)
struct PawSpinner: View {
    @State private var scale: CGFloat = 0.8

    var body: some View {
        Text("🐾")
            .font(.system(size: 44))
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }
    }
}

// MARK: - Error View (game card style)
struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Text("⚠️")
                .font(.system(size: 32))

            Text(message)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            if let retry = retryAction {
                Button(action: retry) {
                    Text("Try Again")
                        .font(.system(.subheadline, design: .rounded).bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FF6B6B"))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(hex: "#333333"), lineWidth: 2))
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FF6B6B"), lineWidth: 3)
        )
    }
}

// MARK: - Bounce Button Style
struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Toolbar Chip Button Wrapper
struct ToolbarChip: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(hex: "#333333"))
            .frame(width: 32, height: 32)
            .background(Color(hex: "#f0f4ff"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "#333333"), lineWidth: 2)
            )
    }
}

// MARK: - Floating Stars Background
struct FloatingStarsBackground: View {
    private let count = 8
    @State private var offsets: [CGFloat] = Array(repeating: 0, count: 8)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    Text("⭐")
                        .font(.system(size: 14))
                        .opacity(0.5)
                        .position(
                            x: (CGFloat(i) / CGFloat(count)) * geo.size.width + 24,
                            y: geo.size.height * 0.75 + offsets[i]
                        )
                }
            }
            .onAppear {
                offsets = Array(repeating: 0, count: count)
                for i in 0..<count {
                    let delay = Double(i) * 0.9
                    let duration = 7.0 + Double(i % 4) * 1.5
                    withAnimation(
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                    ) {
                        offsets[i] = -geo.size.height * 0.55
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Rarity Helper (shared across CompletionView, MergeView, PetHistoryView)
struct RarityInfo {
    let label: String
    let emoji: String
    let color: Color

    static func from(augments: [Augment]) -> RarityInfo {
        let total = augments.reduce(0) { $0 + ($1.weight ?? 0) }
        switch total {
        case 0:     return RarityInfo(label: "Common",    emoji: "⚪️", color: Color(hex: "#9E9E9E"))
        case 1...2: return RarityInfo(label: "Uncommon",  emoji: "🟢", color: Color(hex: "#6BCB77"))
        case 3...4: return RarityInfo(label: "Rare",      emoji: "🔵", color: Color(hex: "#4D96FF"))
        case 5...6: return RarityInfo(label: "Legendary", emoji: "💜", color: Color(hex: "#9B59B6"))
        default:    return RarityInfo(label: "Mythical",  emoji: "⭐", color: Color(hex: "#FFD93D"))
        }
    }
}
