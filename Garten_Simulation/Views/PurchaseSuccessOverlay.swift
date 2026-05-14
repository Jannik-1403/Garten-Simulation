import SwiftUI

struct PurchaseSuccessOverlay: View {
    let itemName: String
    let price: Int
    let onDismiss: () -> Void
    @EnvironmentObject var settings: SettingsStore

    @State private var checkScale: CGFloat = 0.2
    @State private var checkRotation: Double = -25
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dunkler Hintergrund
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            // Popup-Karte
            VStack(spacing: 32) {

                // Text
                VStack(spacing: 12) {
                    ZStack {
                        // 3D Shadow (Secondary green)
                        Text(settings.localizedString(for: "shop.purchase_success.title").uppercased())
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenSecondary)
                            .offset(y: 6)

                        // Main Text (Primary green)
                        Text(settings.localizedString(for: "shop.purchase_success.title").uppercased())
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(Color.gruenPrimary)
                    }
                    .scaleEffect(checkScale)
                    
                    Text(settings.localizedString(for: itemName))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }

                // Coin-Abzug
                HStack(spacing: 8) {
                    Image("coin")
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(String(format: settings.localizedString(for: "purchase.coins_deducted_format"), price))
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.coinBlue)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.coinBlue.opacity(0.1))
                )

                // Super-Button — DuolingoButtonStyle
                Button(action: onDismiss) {
                    Text(settings.localizedString(for: "shop.purchase_success.awesome"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    fillWidth: true,
                    backgroundColor: .gruenPrimary,
                    shadowColor: .gruenSecondary,
                    foregroundColor: .white
                ))
            }
            .padding(28)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            // Popup einblenden
            withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                contentOpacity = 1.0
            }
            // Text-Pop-Animation
            withAnimation(.spring(response: 0.48, dampingFraction: 0.52).delay(0.1)) {
                checkScale = 1.1 // Leichtes Übersteuern für 3D-Effekt
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.25)) {
                checkScale = 1.0
            }
        }
    }
}
