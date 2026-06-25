import SwiftUI

struct ShopItemDetailView: View {
    let payload: ShopDetailPayload
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var gartenPfadStore: GartenPfadStore

    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showInsufficientCoins = false
    @State private var showMysticConfirmation = false
    
    @State private var selectedDifficulty: PfadSchwierigkeit? = nil

    private var isOwned: Bool { shopStore.isPurchased(payload.id) }
    private var canAfford: Bool { shopStore.canAfford(payload.price) }

    var body: some View {
        NavigationStack {
            ZStack {
                if payload.itemType == .powerUp, let tag = payload.tag {
                    RarityBackgroundView(tag: tag)
                        .ignoresSafeArea()
                } else {
                    Color.appHintergrund
                        .ignoresSafeArea()
                }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    Spacer().frame(height: 60)
                    
                    // MARK: Inhalt-Karte
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: Hero Icon
                        HStack {
                            Spacer()
                            Group {
                                if payload.id == "plant.seeds" {
                                    Image("Samen")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                } else if payload.itemType == .plant, 
                                   let basePlant = GameDatabase.shared.plant(for: payload.id) {
                                    // Spezial-View für Pflanzen
                                    PlantIconView(plant: basePlant, seltenheit: .bronze, size: 280, alwaysShowFullGrown: true)
                                } else if UIImage(named: payload.icon) != nil {
                                    // Asset vorhanden
                                    Image(payload.icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: payload.itemType == .decoration ? 180 : 150, height: payload.itemType == .decoration ? 180 : 150)
                                }
                            }
                            .frame(width: payload.itemType == .decoration ? 240 : 150, height: payload.itemType == .decoration ? 240 : 150)
                            Spacer()
                        }

                        // Tag + Titel + Subtitle
                        VStack(alignment: .leading, spacing: 8) {
                            if let tag = payload.tag {
                                let displayTag = tag == "mystic" ? "MASTER" : (tag == "legendary" ? "LEGENDÄR" : (tag == "epic" ? "EPISCH" : (tag == "rare" ? "SELTEN" : (tag == "common" ? "GEWÖHNLICH" : settings.localizedString(for: tag)))))
                                Text(displayTag)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(payload.color)
                                    .kerning(1.4)
                            }
                            let currentTitleKey = (settings.showHabitInsteadOfName && payload.habitTitleKey != nil) ? payload.habitTitleKey! : payload.titleKey
                            Text(settings.localizedString(for: currentTitleKey))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            
                            let currentSubtitleKey = (settings.showHabitInsteadOfName && payload.habitTitleKey != nil) ? payload.titleKey : payload.subtitle
                            if !currentSubtitleKey.isEmpty {
                                Text(settings.localizedString(for: currentSubtitleKey))
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()


                        // Beschreibung
                        VStack(alignment: .leading, spacing: 8) {
                            Text(settings.localizedString(for: "shop.item.description"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                                .kerning(1.2)
                            Text(settings.localizedString(for: payload.descriptionKey))
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


                            // MARK: Preis + Balance
                            VStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    Image("coin")
                                        .resizable().scaledToFit()
                                        .frame(width: 24, height: 24)
                                    Text("\(payload.price)")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.coinBlue)
                                    Spacer()
                                    HStack(spacing: 3) {
                                        Text(settings.localizedString(for: "shop.your_balance"))
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                        Image("coin")
                                            .resizable().scaledToFit()
                                            .frame(width: 14, height: 14)
                                        Text("\(gardenStore.coins)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(canAfford ? Color.coinBlue : .red)
                                            .contentTransition(.numericText(countsDown: true))
                                    }
                                }
                            }
                            .padding(.top, 8)
                            
                            // MARK: Schwierigkeits-Auswahl (Nur für Pflanzen)
                            if payload.itemType == .plant && payload.id != "plant.seeds" {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(settings.localizedString(for: "schwierigkeit.titel"))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                        Spacer()
                                        if let diff = selectedDifficulty {
                                            Text(settings.localizedString(for: diff.titelKey))
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(diff.farbe)
                                        }
                                    }
                                    .padding(.top, 8)
                                    
                                    HStack(spacing: 12) {
                                        ForEach(PfadSchwierigkeit.allCases, id: \.self) { diff in
                                            Item3DButton(
                                                farbe: selectedDifficulty == diff ? diff.farbe : Color(uiColor: .systemGray5),
                                                sekundaerFarbe: selectedDifficulty == diff ? diff.farbe.darker() : Color(uiColor: .systemGray3),
                                                groesse: 54, // Etwas flacher
                                                iconSkalierung: 0.9,
                                                isRectangular: true,
                                                isPermanentlyPressed: selectedDifficulty == diff
                                            ) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedDifficulty = diff
                                                    FeedbackManager.shared.playTap()
                                                }
                                            } label: {
                                                Text(settings.localizedString(for: diff.titelKey))
                                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                                    .minimumScaleFactor(0.6)
                                                    .lineLimit(2)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                    .frame(height: 70)
                                    
                                    if let diff = selectedDifficulty {
                                        Text(settings.localizedString(for: diff.beschreibungKey))
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .padding(.horizontal, 4)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    } else {
                                        Text(settings.localizedString(for: "schwierigkeit.waehlen_hinweis"))
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.orange)
                                            .padding(.horizontal, 4)
                                    }
                                }
                                .padding(.bottom, 8)
                                
                                Divider()
                            }
                            

                            // MARK: Button — 3 Zustände
                            if isOwned {
                                // Zustand 1: Bereits gekauft + VERKAUFEN Option
                                VStack(spacing: 12) {
                                    Button {
                                        FeedbackManager.shared.playTap()
                                    } label: {
                                        Text(settings.localizedString(for: "shop.owned"))
                                    }
                                    .buttonStyle(DuolingoButtonStyle(
                                        size: .large,
                                        fillWidth: true,
                                        backgroundColor: Color(uiColor: .systemGray5),
                                        shadowColor: Color(uiColor: .systemGray3),
                                        foregroundColor: .gray,
                                        isPermanentlyPressed: true
                                    ))
                                    .disabled(true)
                                    
                                    // Verkaufs-Button (Minimalismus-Mechanik)
                                    let sellPrice = Int(Double(payload.price) * 0.5)
                                    
                                    Button {
                                        // Feedback
                                        FeedbackManager.shared.playTap()
                                        
                                        // Aktion
                                        shopStore.sell(id: payload.id, price: payload.price, title: settings.localizedString(for: payload.titleKey))
                                        
                                        if payload.itemType == .decoration {
                                            gardenStore.itemEntfernen(id: payload.id)
                                        }
                                    } label: {
                                        VStack(spacing: 2) {
                                            Text(settings.localizedString(for: "shop.item.sell"))
                                                .font(.system(size: 14, weight: .bold))
                                            HStack(spacing: 4) {
                                                Image("coin")
                                                    .resizable().scaledToFit().frame(width: 14, height: 14)
                                                Text("+\(sellPrice)")
                                                    .font(.system(size: 14, weight: .black))
                                            }
                                        }
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 2))
                                    }
                                }
                            } else if !canAfford {
                                // Zustand 2: Zu wenig Coins
                                Button {
                                    // Feedback + Alert
                                    FeedbackManager.shared.playError()
                                    showInsufficientCoins = true
                                } label: {
                                    Text(settings.localizedString(for: "shop.not_enough_coins"))
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
                                let isLocked = payload.itemType == .plant && selectedDifficulty == nil

                                DuolingoKaufButton(
                                    color: isLocked ? Color.gray : payload.color
                                ) {
                                    if isLocked {
                                        FeedbackManager.shared.playError()
                                        return
                                    }
                                    
                                    if payload.tag == "mystic" {
                                        showMysticConfirmation = true
                                    } else {
                                        executePurchase()
                                    }
                                }
                            }
                        }
                        .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: Color(UIColor.systemGray4), radius: 0, x: 0, y: 8)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                    .padding(.bottom, 32)
                }
            }

        }
        .standardNavigationX()
        }
        .overlay {
            // Erfolg-Overlay
            if showSuccess {
                PurchaseSuccessOverlay(
                    itemName: settings.localizedString(for: payload.titleKey),
                    price: payload.price,
                    subtitle: payload.itemType == .powerUp
                        ? settings.localizedString(for: "shop.purchase_success.powerup_hint")
                        : nil
                ) {
                    FeedbackManager.shared.playTap()
                    showSuccess = false
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: showSuccess)
        .alert(settings.localizedString(for: "shop.not_enough_coins"), isPresented: $showInsufficientCoins) {
            Button(settings.localizedString(for: "button.ok"), role: .cancel) { FeedbackManager.shared.playTap() }
        } message: {
            Text(String(format: settings.localizedString(for: "shop.need_more_coins"), payload.price - gardenStore.coins))
        }
        .alert("Ultimatives Luxus-Item!", isPresented: $showMysticConfirmation) {
            Button("Abbrechen", role: .cancel) { FeedbackManager.shared.playTap() }
            Button("Für 5.000 Münzen kaufen") {
                FeedbackManager.shared.playTap()
                executePurchase()
            }
        } message: {
            Text(settings.localizedString(for: "shop.cheatday.confirm"))
        }
    }
    
    private func executePurchase() {
        if payload.id == "plant.seeds" {
            FeedbackManager.shared.playSuccess()
            shopStore.buy(id: payload.id, price: payload.price)
            gardenStore.logPurchase(shopItem: payload)
            gardenStore.seeds += 10
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                showSuccess = true
            }
        } else if payload.itemType == .plant {
            FeedbackManager.shared.playSuccess()
            shopStore.buy(id: payload.id, price: payload.price)
            gardenStore.pflanzHinzufuegen(shopItem: payload)
            
            // Pfad direkt mit der gewählten Schwierigkeit starten
            if let neuePflanze = gardenStore.pflanzen.last(where: { $0.plantID == payload.id }),
               let diff = selectedDifficulty {
                let ziel = settings.ausgewaehltesZiel.isEmpty ? "fit" : settings.ausgewaehltesZiel
                gartenPfadStore.pflanzeHinzufuegen(neuePflanze, ziel: ziel, schwierigkeit: diff)
            }

            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                showSuccess = true
            }
        } else {
            FeedbackManager.shared.playSuccess()
            shopStore.buy(id: payload.id, price: payload.price)
            gardenStore.itemHinzufuegen(shopItem: payload)

            withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                showSuccess = true
            }
        }
    }
    
}
