import SwiftUI

struct PurchaseSuccessOverlay: View {
    let itemName: String
    let price: Int
    var subtitle: String? = nil
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
                    VStack(spacing: 6) {
                        Text(settings.localizedString(for: "shop.purchase_success.title"))
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(settings.localizedString(for: "shop.purchase_success.subtitle"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(settings.localizedString(for: itemName))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
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
            .background(
                ZStack(alignment: .bottom) {
                    // 3D Shadow Layer (Base)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(hex: "#E0E0E0"))
                        .offset(y: 8)
                    
                    // Main White Surface
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                        )
                }
            )
            .padding(.horizontal, 32)
            .opacity(contentOpacity)
        }
        .onAppear {
            // Popup einblenden
            withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                contentOpacity = 1.0
                checkScale = 1.0
            }
        }
    }
}
