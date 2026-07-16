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
    
    private var badgeText: String? {
        if product.id == "com.jannik.grovy.coins.pack_large" {
            return String(localized: "shop.badge.best_value", defaultValue: "Bestes Angebot")
        } else if product.id == "com.jannik.grovy.coins.pack_medium" {
            return String(localized: "shop.badge.popular", defaultValue: "Beliebt")
        }
        return nil
    }

    private var productTitle: String {
        switch product.id {
        case "com.jannik.grovy.coins.pack_small":
            return String(localized: "shop.item.coins_small.title", defaultValue: "Kleine Münztruhe")
        case "com.jannik.grovy.coins.pack_medium":
            return String(localized: "shop.item.coins_medium.title", defaultValue: "Mittlerer Münzbeutel")
        case "com.jannik.grovy.coins.pack_large":
            return String(localized: "shop.item.coins_large.title", defaultValue: "Großer Münzschatz")
        default:
            return product.displayName
        }
    }
    
    private var productDescription: String {
        switch product.id {
        case "com.jannik.grovy.coins.pack_small":
            return String(localized: "shop.item.coins_small.desc", defaultValue: "Ein kleiner Vorrat an Münzen.")
        case "com.jannik.grovy.coins.pack_medium":
            return String(localized: "shop.item.coins_medium.desc", defaultValue: "Ein ordentlicher Haufen Münzen.")
        case "com.jannik.grovy.coins.pack_large":
            return String(localized: "shop.item.coins_large.desc", defaultValue: "Ein riesiger Schatz voller Münzen!")
        default:
            return product.description
        }
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
                    Text(productTitle)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(alignment: .top, spacing: 4) {
                        Text(productDescription)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("+\(coinAmount)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundStyle(Color.goldPrimary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(1)
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
                        ZStack {
                            Capsule()
                                .fill(Color.blauPrimary.darker())
                                .offset(y: 4)
                            Capsule()
                                .fill(Color.blauPrimary)
                        }
                    )
                    .padding(.bottom, 4)
            }
            .padding(16)
            .opacity(isPurchasing ? 0.6 : 1.0)
        }
    }
}
