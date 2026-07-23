import SwiftUI
import StoreKit

struct CoinsDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var characterStore: CharacterStore
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Current Balance (Hero)
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                            
                            Text(verbatim: "\(gardenStore.coins)")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundStyle(Color.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.4), value: gardenStore.coins)
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color(UIColor.systemGray4))
                                    .offset(y: 6)
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color(UIColor.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(Color(UIColor.systemGray5), lineWidth: 2)
                                    )
                            }
                        )
                        .padding(.bottom, 6)

                        Text(String(localized: "profile.coins.available", defaultValue: "Verfügbare Münzen"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)

                    // MARK: - Products Section
                    VStack(spacing: 24) {
                        // Section Header
                        VStack(spacing: 8) {
                            Text(String(localized: "coin_shop_title", defaultValue: "Münz-Shop"))
                                .font(.system(size: 24, weight: .black, design: .rounded))
                            Text(String(localized: "coin_shop_subtitle", defaultValue: "Hol dir mehr Münzen für deinen Garten"))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        if !iapStore.hasLoaded {
                            VStack(spacing: 12) {
                                if let error = iapStore.purchaseError {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.red)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                } else {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                    Text(String(localized: "iap_loading", defaultValue: "Produkte werden geladen..."))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 200)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(iapStore.products.filter { $0.id.contains(".coins.") }, id: \.id) { product in
                                    CoinPackCard(
                                        product: product,
                                        isPurchasing: iapStore.isPurchasing
                                    ) {
                                        Task {
                                            await iapStore.purchase(
                                                product,
                                                gardenStore: gardenStore
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Purchase Error Handling
                    if let error = iapStore.purchaseError {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    }

                }
            }
        }
        .navigationTitle(String(localized: "coin_shop_nav_title", defaultValue: "Shop"))
        .navigationBarTitleDisplayMode(.inline)
        .standardNavigationX()
        .onAppear {
            // Check entitlements on load to handle automatic revoking if refunded
            Task {
                await iapStore.syncEntitlements(characterStore: characterStore)
            }
        }
    }
}
