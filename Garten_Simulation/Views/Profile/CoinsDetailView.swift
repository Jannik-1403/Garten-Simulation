import SwiftUI
import StoreKit

struct CoinsDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @StateObject private var iapStore = IAPStore()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Current Balance (Hero)
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            VStack(spacing: 4) {
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                
                                Text("\(gardenStore.coins)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .contentTransition(.numericText())
                                    .animation(.spring(response: 0.4), value: gardenStore.coins)
                            }
                            .foregroundStyle(.primary)
                        }
                        .buttonStyle(Item3DButtonStyle(
                            farbe: Color(UIColor.systemBackground).opacity(0.8),
                            sekundaerFarbe: Color.black.opacity(0.05),
                            groesse: 110
                        ))
                        .disabled(true)

                        Text(settings.localizedString(for: "profile.coins.available"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .opacity(0.8)
                    }
                    .padding(.top, 20)

                    // MARK: - Products Section
                    VStack(spacing: 20) {
                        // Section Header
                        VStack(spacing: 6) {
                            Text(settings.localizedString(for: "coin_shop_title"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text(settings.localizedString(for: "coin_shop_subtitle"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if iapStore.products.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text(settings.localizedString(for: "iap_loading"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(height: 200)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(iapStore.products, id: \.id) { product in
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

                    // MARK: - Error Handling
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

                    // MARK: - Apple Legal Hint
                    Text(settings.localizedString(for: "iap_restore_hint"))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(settings.localizedString(for: "coin_shop_nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LiquidGlassDismissButton {
                    dismiss()
                }
            }
        }
    }
}
