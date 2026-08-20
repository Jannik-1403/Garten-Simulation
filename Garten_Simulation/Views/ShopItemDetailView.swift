import SwiftUI

struct ShopItemDetailView: View {
    let payload: ShopDetailPayload
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    @EnvironmentObject var characterStore: CharacterStore

    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showInsufficientCoins = false
    @State private var showMysticConfirmation = false
    @State private var showPaywallSheet = false
    @State private var showCoinsShopSheet = false
    @State private var selectedGoalWeight: GoalWeight? = nil
    @State private var showGoalLinkInfo = false

    private var isOwned: Bool { shopStore.isPurchased(payload.id) }
    private var canAfford: Bool { shopStore.canAfford(payload.price) }

    var body: some View {
        NavigationStack {
            ZStack {
                    Color.appHintergrund
                        .ignoresSafeArea()            
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
                                        .scaleEffect(payload.itemType == .decoration ? 2.2 : 1.0)
                                }
                            }
                            .frame(width: payload.itemType == .decoration ? 240 : 150, height: payload.itemType == .decoration ? 240 : 150)
                            Spacer()
                        }

                        // Tag + Titel + Subtitle
                        VStack(alignment: .leading, spacing: 8) {
                            if let tag = payload.tag {
                                let displayTag = tag == "mystic" ? "MASTER" : (tag == "legendary" ? "LEGENDÄR" : (tag == "epic" ? "EPISCH" : (tag == "rare" ? "SELTEN" : (tag == "common" ? "GEWÖHNLICH" : NSLocalizedString(tag, comment: "")))))
                                Text(displayTag)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(payload.color)
                                    .kerning(1.4)
                            }
                            let currentTitleKey = (settings.showHabitInsteadOfName && payload.habitTitleKey != nil) ? payload.habitTitleKey! : payload.titleKey
                            Text(NSLocalizedString(currentTitleKey, comment: ""))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                            
                            let currentSubtitleKey = (settings.showHabitInsteadOfName && payload.habitTitleKey != nil) ? payload.titleKey : payload.subtitle
                            if !currentSubtitleKey.isEmpty {
                                Text(NSLocalizedString(currentSubtitleKey, comment: ""))
                                    .font(.system(size: 15))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()


                        // Beschreibung
                        if !payload.descriptionKey.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(localized: "shop.item.description"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .kerning(1.2)
                                Text(NSLocalizedString(payload.descriptionKey, comment: ""))
                                    .font(.system(size: 15))
                                    .lineSpacing(4)
                            }
    
                            Divider()
                        }

                        if let usage = payload.howToUse, !usage.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(String(localized: "shop.item.usage"))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .kerning(1.2)
                                Text(NSLocalizedString(usage, comment: ""))
                                    .font(.system(size: 15))
                                    .lineSpacing(4)
                            }
                            Divider()
                        }

                        if payload.itemType == .plant && payload.id != "plant.seeds" {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .kerning(1.2)
                                    
                                    Button {
                                        FeedbackManager.shared.playTap()
                                        showGoalLinkInfo = true
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.primary)
                                    }
                                }
                                HStack(spacing: 8) {
                                    ForEach([GoalWeight.massive, .bit, .none], id: \.self) { weight in
                                        let baseColor: Color = weight == .massive ? .green : (weight == .bit ? .orange : .red)
                                        let isSelected = selectedGoalWeight == weight
                                        
                                        Item3DButton(
                                            farbe: isSelected ? baseColor : Color(UIColor.systemGray5),
                                            sekundaerFarbe: isSelected ? baseColor.darker() : Color(UIColor.systemGray4),
                                            groesse: 44,
                                            isRectangular: true,
                                            aktion: { selectedGoalWeight = weight }
                                        ) {
                                            Text("\(weight.rawValue) \(String(localized: "common.points.short", defaultValue: "Pkt"))")
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(isSelected ? .white : .primary)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                        }
                                    }
                                }
                            }
                            Divider()
                        }


                            // MARK: Preis + Balance
                            VStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    Image("coin")
                                        .resizable().scaledToFit()
                                        .frame(width: 24, height: 24)
                                    Text(verbatim: "\(payload.price)")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.coinBlue)
                                    Spacer()
                                    HStack(spacing: 3) {
                                        Text(String(localized: "shop.your_balance"))
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                        Image("coin")
                                            .resizable().scaledToFit()
                                            .frame(width: 14, height: 14)
                                        Text(verbatim: "\(gardenStore.coins)")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(canAfford ? Color.coinBlue : .red)
                                            .contentTransition(.numericText(countsDown: true))
                                    }
                                }
                            }
                            .padding(.top, 8)
                            
                            // MARK: Schwierigkeits-Auswahl (Nur für Pflanzen)

                            // MARK: Button — 3 Zustände
                            if isOwned {
                                // Zustand 1: Bereits gekauft + VERKAUFEN Option
                                VStack(spacing: 12) {
                                    Button {
                                        FeedbackManager.shared.playTap()
                                    } label: {
                                        Text(String(localized: "shop.owned"))
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
                                    
                                    let associatedPlant = gardenStore.pflanzen.first(where: { $0.plantID == payload.id })
                                    let isDeadPlant = associatedPlant?.isDead == true
                                    
                                    if !isDeadPlant {
                                        Button {
                                            // Feedback
                                            FeedbackManager.shared.playTap()
                                            
                                            // Aktion
                                            shopStore.sell(id: payload.id, price: payload.price, title: NSLocalizedString(payload.titleKey, comment: ""))
                                            
                                            if payload.itemType == .decoration {
                                                gardenStore.itemEntfernen(id: payload.id)
                                            } else if payload.itemType == .plant {
                                                if let plantToRemove = associatedPlant {
                                                    gardenStore.loeschePflanze(pflanze: plantToRemove)
                                                }
                                            }
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text(String(localized: "shop.item.sell"))
                                                    .font(.system(size: 14, weight: .bold))
                                                HStack(spacing: 4) {
                                                    Image("coin")
                                                        .resizable().scaledToFit().frame(width: 14, height: 14)
                                                    Text(verbatim: "+\(sellPrice)")
                                                        .font(.system(size: 14, weight: .black))
                                                }
                                            }
                                            .foregroundStyle(.red)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 2))
                                    }
                                }
                            } else if !canAfford {
                                // Zustand 2: Zu wenig Coins
                                Button {
                                    FeedbackManager.shared.playError()
                                    if iapStore.isProUser {
                                        showCoinsShopSheet = true
                                    } else {
                                        showPaywallSheet = true
                                    }
                                } label: {
                                    Text(String(localized: "shop.not_enough_coins"))
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
                                let isLocked = payload.itemType == .plant && payload.id != "plant.seeds" && selectedGoalWeight == nil

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
                    itemName: NSLocalizedString(payload.titleKey, comment: ""),
                    price: payload.price,
                    subtitle: nil
                ) {
                    FeedbackManager.shared.playTap()
                    showSuccess = false
                    dismiss()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: showSuccess)
        .alert(String(localized: "shop.not_enough_coins"), isPresented: $showInsufficientCoins) {
            Button(String(localized: "button.ok"), role: .cancel) { FeedbackManager.shared.playTap() }
        } message: {
            Text(String(format: String(localized: "shop.need_more_coins"), payload.price - gardenStore.coins))
        }
        .alert(String(localized: "goal.link.info.title", defaultValue: "Punkte & Ziele"), isPresented: $showGoalLinkInfo) {
            Button(String(localized: "button.ok"), role: .cancel) { }
        } message: {
            Text(String(localized: "goal.link.info.message", defaultValue: "Gewohnheiten bringen Punkte für dein 1-Jahresziel.\n\n20 Pkt: Enormer Fokus\n5 Pkt: Leichter Beitrag\n0 Pkt: Hat nichts mit dem Ziel zu tun"))
        }
        .alert(String(localized: "shop.mystic.confirmation.title", defaultValue: "Ultimatives Luxus-Item!"), isPresented: $showMysticConfirmation) {
            Button(String(localized: "common.cancel"), role: .cancel) { FeedbackManager.shared.playTap() }
            Button(String(format: String(localized: "shop.buy_for_coins_format"), "5.000")) {
                FeedbackManager.shared.playTap()
                executePurchase()
            }
        } message: {
            Text(String(localized: "shop.cheatday.confirm"))
        }
        .sheet(isPresented: $showPaywallSheet) {
            PaywallView()
                .environmentObject(iapStore)
                .environmentObject(gardenStore)
        }
        .sheet(isPresented: $showCoinsShopSheet) {
            CoinsDetailView()
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(characterStore)
                .environmentObject(iapStore)
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
            let newPlant = gardenStore.pflanzHinzufuegen(shopItem: payload)
            
            if let weight = selectedGoalWeight, let goal = GoalStore.shared.activeGoals.first(where: { $0.type == .year }) {
                GoalStore.shared.linkHabitToGoal(habitId: newPlant.id, goalId: goal.id, weight: weight)
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
