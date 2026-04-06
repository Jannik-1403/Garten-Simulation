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
            VStack(spacing: 22) {

                // Animierter Checkmark
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                        .scaleEffect(checkScale)
                        .rotationEffect(.degrees(checkRotation))
                }

                // Text
                VStack(spacing: 6) {
                    Text(settings.localizedString(for: "shop.purchase_success.title"))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(settings.localizedString(for: itemName))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }

                // Coin-Abzug
                HStack(spacing: 5) {
                    Image("coin")
                        .resizable().scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("−\(price) Coins")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.coinBlue)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color(UIColor.secondarySystemBackground))
                )

                // Super-Button — DuolingoButtonStyle
                Button(action: onDismiss) {
                    Text(settings.localizedString(for: "shop.purchase_success.awesome"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    fillWidth: true,
                    backgroundColor: .green,
                    shadowColor: Color.green.darker(),
                    foregroundColor: .white
                ))
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 12)
            )
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            // Popup einblenden
            withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                contentOpacity = 1.0
            }
            // Checkmark mit Federdrehung
            withAnimation(.spring(response: 0.48, dampingFraction: 0.52).delay(0.14)) {
                checkScale = 1.0
                checkRotation = 0
            }
        }
    }
}
