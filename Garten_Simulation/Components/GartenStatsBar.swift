import SwiftUI

struct GartenStatsBar: View {
    let streak: Int
    let coins: Int
    let leben: Int

    private let streakFarbe = Color(hex: "#D95F00")
    private let coinsFarbe  = Color.coinBlue
    private let lebenFarbe  = Color(hex: "#C0213A")

    var body: some View {
        HStack(spacing: 0) {
            statSektion(
                assetName: "streak",
                wert: "\(streak)",
                farbe: streakFarbe
            )
            glasseDivider
            statSektion(
                assetName: "coin",
                wert: coins.formatted(),
                farbe: Color.coinBlue
            )
            glasseDivider
            statSektion(
                assetName: leben <= 0 ? "Heart death" : (leben <= 3 ? "Heart half" : "Heart"),
                wert: "\(leben)",
                farbe: leben <= 0 ? .gray : lebenFarbe
            )
        }
    }


    private func statSektion(
        assetName: String,
        wert: String,
        farbe: Color
    ) -> some View {
        HStack(spacing: 5) {
            Image(assetName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
            Text(wert)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(farbe)
                .contentTransition(.numericText())
                .animation(.spring(), value: wert)
        }
        .frame(maxWidth: .infinity)
    }

    private var glasseDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.5))
            .frame(width: 0.5, height: 20)
    }
}

#Preview {
    ZStack {
        Color.gruenPrimary.ignoresSafeArea()
        GartenStatsBar(streak: 12, coins: 1250, leben: 5)
            .padding()
    }
}
