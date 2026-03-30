import SwiftUI

struct ShopItemDetailView: View {
    let payload: ShopDetailPayload
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var powerUpStore: PowerUpStore

    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showInsufficientCoins = false

    private var isOwned: Bool { shopStore.isPurchased(payload.id) }
    private var canAfford: Bool { shopStore.canAfford(payload.price) }

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: Hero
                    ZStack(alignment: .top) {
                        Circle()
                            .fill(payload.color.opacity(0.12))
                            .frame(width: 220, height: 220)
                            .offset(y: 20)

                        VStack(spacing: 0) {
                            Spacer().frame(height: 60)
                            
                            Group {
                                if UIImage(named: payload.icon) != nil {
                                    // Asset vorhanden
                                    Image(payload.icon)
                                        .resizable()
                                        .scaledToFit()
                                } else {
                                    // SF Symbol fallback
                                    Image(systemName: payload.icon)
                                        .font(.system(size: 100))
                                        .foregroundStyle(payload.color)
                                }
                            }
                            .frame(width: 150, height: 150)
                            .shadow(
                                color: payload.shadowColor.opacity(0.35),
                                radius: 20, x: 0, y: 10
                            )
                            Spacer().frame(height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: Inhalt-Karte
                    VStack(alignment: .leading, spacing: 24) {

                        // Tag + Titel + Subtitle
                        VStack(alignment: .leading, spacing: 8) {
                            if let tag = payload.tag {
                                Text(settings.localizedString(for: tag))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(payload.color)
                                    .kerning(1.4)
                            }
                            Text(settings.localizedString(for: payload.title))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            Text(settings.localizedString(for: payload.subtitle))
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }

                        Divider()

                        // Beschreibung
                        VStack(alignment: .leading, spacing: 8) {
                            Text(settings.localizedString(for: "shop.item.description"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                                .kerning(1.2)
                            Text(settings.localizedString(for: payload.description))
                                .font(.system(size: 15))
                                .lineSpacing(4)
                        }

                        Divider()

                        if let usage = payload.howToUse, !usage.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(settings.localizedString(for: "shop.item.usage"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .kerning(1.2)
                                Text(settings.localizedString(for: usage))
                                    .font(.system(size: 15))
                                    .lineSpacing(4)
                            }
                            Divider()
                        }

                        // MARK: Preis + Button
                        VStack(spacing: 16) {

                            // Preis
                            HStack(spacing: 6) {
                                Image("Coin")
                                    .resizable().scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("\(payload.price)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.belohnungGoldHighlight)
                                Spacer()
                                // Aktueller Kontostand
                                HStack(spacing: 3) {
                                    Text(settings.localizedString(for: "shop.your_balance"))
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                    Image("Coin")
                                        .resizable().scaledToFit()
                                        .frame(width: 14, height: 14)
                                    Text("\(gardenStore.coins)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(
                                            canAfford
                                                ? Color.belohnungGoldHighlight
                                                : .red
                                        )
                                        // Zahl animiert sich beim Abzug
                                        .contentTransition(.numericText(countsDown: true))
                                }
                            }

                            // MARK: Button — 3 Zustände

                            if isOwned {
                                // Zustand 1: Bereits gekauft
                                Button {} label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.seal.fill")
                                        Text(settings.localizedString(for: "shop.already_owned"))
                                    }
                                }
                                .buttonStyle(DuolingoButtonStyle(
                                    size: .large,
                                    fillWidth: true,
                                    backgroundColor: .green,
                                    shadowColor: Color(red: 0.1, green: 0.5, blue: 0.15),
                                    foregroundColor: .white
                                ))
                                .disabled(true)
                                .opacity(0.7)

                            } else if !canAfford {
                                // Zustand 2: Zu wenig Coins
                                Button {
                                    // Haptic + Alert
                                    showInsufficientCoins = true
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                        Text(settings.localizedString(for: "shop.not_enough_coins"))
                                    }
                                }
                                .buttonStyle(DuolingoButtonStyle(
                                    size: .large,
                                    fillWidth: true,
                                    backgroundColor: Color(UIColor.systemGray3),
                                    shadowColor: Color(UIColor.systemGray),
                                    foregroundColor: .white
                                ))

                            } else {
                                // Zustand 3: Kaufen möglich — Animation DANN Aktion
                                DuolingoKaufButton(
                                    color: payload.color
                                ) {
                                    shopStore.buy(id: payload.id, price: payload.price)
                                    
                                    if payload.itemType == .plant {
                                        gardenStore.pflanzHinzufuegen(shopItem: payload)
                                    } else {
                                        // Power-Up oder Müll
                                        gardenStore.itemHinzufuegen(shopItem: payload)
                                    }

                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                                        showSuccess = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                    )
                    .padding(.top, -20)
                }
            }

            // X Button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(.regularMaterial))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // Erfolg-Overlay
            if showSuccess {
                PurchaseSuccessOverlay(
                    itemName: payload.title,
                    price: payload.price
                ) {
                    showSuccess = false
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: showSuccess)
        .alert(settings.localizedString(for: "shop.not_enough_coins"), isPresented: $showInsufficientCoins) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(String(format: settings.localizedString(for: "shop.need_more_coins"), payload.price - gardenStore.coins))
        }
    }
}
