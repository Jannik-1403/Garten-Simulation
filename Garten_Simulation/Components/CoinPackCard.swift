import SwiftUI
import StoreKit

// MARK: - CoinPackCard
// Separate component for reuse and clarity

struct CoinPackCard: View {
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void
    @EnvironmentObject var settings: SettingsStore

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
    
    // Determine the tier based on the pack size for different colors
    private var cardTier: SuccessTier {
        switch product.id {
        case "com.jannik.grovy.coins.pack_small": return .bronze
        case "com.jannik.grovy.coins.pack_medium": return .silver
        case "com.jannik.grovy.coins.pack_large": return .gold
        default: return .bronze
        }
    }
    
    private var badgeText: String? {
        if product.id == "com.jannik.grovy.coins.pack_large" {
            return String(localized: "shop.badge.best_value", defaultValue: "Bestes Angebot")
        } else if product.id == "com.jannik.grovy.coins.pack_medium" {
            return String(localized: "shop.badge.popular", defaultValue: "Beliebt")
        }
        return nil
    }

    var body: some View {
        DuolingoCard(action: {
            if !isPurchasing {
                onPurchase()
            }
        }, badgeText: badgeText, badgeColor: .red) {
            HStack(spacing: 16) {
                // MARK: Coin Icon
                Image(packImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)

                // MARK: Info
                VStack(alignment: .leading, spacing: 4) {
                    let titleKey = "shop.item.\(product.id).title"
                    let localizedTitle = NSLocalizedString(titleKey, comment: "")
                    let finalTitle = localizedTitle != titleKey ? localizedTitle : product.displayName

                    let descKey = "shop.item.\(product.id).desc"
                    let localizedDesc = NSLocalizedString(descKey, comment: "")
                    let finalDesc = localizedDesc != descKey ? localizedDesc : product.description

                    Text(finalTitle)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    HStack(spacing: 4) {
                        Text(finalDesc)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                        
                        Text("+\(coinAmount)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(Color.goldPrimary)
                    }
                }

                Spacer(minLength: 0)

                // MARK: Price
                Text(product.displayPrice)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Color.blauPrimary,
                        in: Capsule()
                    )
                    .shadow(color: Color.blauPrimary.opacity(0.3), radius: 5, y: 3)
            }
            .padding(16)
            .opacity(isPurchasing ? 0.6 : 1.0)
        }
    }
}
