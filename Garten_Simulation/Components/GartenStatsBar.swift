import SwiftUI

struct GartenStatsBar: View {
    let streak: Int
    let coins: Int
    let leben: Int
    var onStreakTap: (() -> Void)? = nil
    var onCoinsTap: (() -> Void)? = nil
    var onLebenTap: (() -> Void)? = nil
    
    // Positionen für Fly-in Animationen
    @State private var streakIconCenter: CGPoint = .zero
    @State private var coinIconCenter: CGPoint = .zero

    private let streakFarbe = Color(hex: "#D95F00")
    private let coinsFarbe  = Color.coinBlue
    private let lebenFarbe  = Color(hex: "#C0213A")
    
    @EnvironmentObject var gardenStore: GardenStore
    @State private var coinPopScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 16) {
            // Coins
            statSektion(
                assetName: "coin",
                wert: coins.formatted(),
                farbe: .primary,
                tourStep: .coinsIntro
            )
            .scaleEffect(coinPopScale)
            .contentShape(Rectangle())
            .onTapGesture {
                onCoinsTap?()
            }
            
            // Streak
            statSektion(
                assetName: "streak",
                wert: "\(streak)",
                farbe: .primary,
                tourStep: .streakHeaderIntro
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onStreakTap?()
            }
            .accessibilityIdentifier("button_streak")
            
            // Leben
            statSektion(
                assetName: leben <= 0 ? "Heart death" : (leben <= 3 ? "Heart half" : "Heart"),
                wert: "\(leben)",
                farbe: .primary,
                tourStep: .livesIntro
            )
            .contentShape(Rectangle())
            .onTapGesture {
                onLebenTap?()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1))
        )
    }


    @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 22

    private func statSektion(
        assetName: String,
        wert: String,
        farbe: Color,
        tourStep: TourStep? = nil
    ) -> some View {
        HStack(spacing: 5) {
            Image(assetName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: HeaderPositionPreferenceKey.self, value: [
                        HeaderPositionData(id: assetName == "coin" ? "coins" : (assetName == "streak" ? "streak" : "other"), center: geo.frame(in: .global).center)
                    ])
                }
            )
            .onChange(of: gardenStore.coinPopTrigger) { _, _ in
                if assetName == "coin" {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        coinPopScale = 1.4
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            coinPopScale = 1.0
                        }
                    }
                }
            }
            Text(wert)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(farbe)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .animation(.spring(), value: wert)
        }
        .tourAnchor(tourStep ?? .done, condition: tourStep != nil)
        .id(tourStep ?? .done)
        .frame(maxWidth: .infinity)
    }

    private var glasseDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.5))
            .frame(width: 0.5, height: 20)
    }
}

// MARK: - Header Position Preference
struct HeaderPositionData: Equatable {
    let id: String
    let center: CGPoint
}

struct HeaderPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [HeaderPositionData] = []
    static func reduce(value: inout [HeaderPositionData], nextValue: () -> [HeaderPositionData]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    ZStack {
        Color.gruenPrimary.ignoresSafeArea()
        GartenStatsBar(streak: 12, coins: 1250, leben: 5)
            .padding()
    }
}
