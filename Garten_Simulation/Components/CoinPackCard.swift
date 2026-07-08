import SwiftUI
import StoreKit

// MARK: - CoinPackCard
// Separate component for reuse and clarity

struct CoinPackCard: View {
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void
    @EnvironmentObject var settings: SettingsStore

    @State private var isPressed = false

    private var coinAmount: Int {
        IAPStore.coinAmounts[product.id] ?? 0
    }

    private var packImageName: String {
        switch product.id {
        case "com.jannik.grovy.coins.pack_small":  return "coin_100"
        case "com.jannik.grovy.coins.pack_medium": return "coin_500"
        case "com.jannik.grovy.coins.pack_large":  return "coin_1000"
        default: return "coin"
        }
    }

    var body: some View {
        HStack(spacing: 14) {

            // MARK: Coin Icon + Amount
            VStack(spacing: 4) {
                Image(packImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                
                Text(verbatim: "+\(coinAmount)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.goldPrimary)
            }
            .frame(width: 64)

            // MARK: Name & Description
            VStack(alignment: .leading, spacing: 3) {
                let titleKey = "shop.item.\(product.id).title"
                let localizedTitle = NSLocalizedString(titleKey, comment: "")
                let finalTitle = localizedTitle != titleKey ? localizedTitle : product.displayName

                let descKey = "shop.item.\(product.id).desc"
                let localizedDesc = NSLocalizedString(descKey, comment: "")
                let finalDesc = localizedDesc != descKey ? localizedDesc : product.description

                Text(finalTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(finalDesc)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            // MARK: Buy Button
            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                    onPurchase()
                }
            } label: {
                Text(product.displayPrice)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Color.blauPrimary,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
            }
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .disabled(isPurchasing)
            .opacity(isPurchasing ? 0.6 : 1.0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
}
