import SwiftUI

// MARK: - Data Models (Removed legacy structs)

// MARK: - Duolingo Shop Card

struct DuolingoShopCard<Content: View>: View {
    let action: () -> Void
    let badgeText: String?
    @ViewBuilder let content: Content
    
    init(action: @escaping () -> Void, badgeText: String? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.badgeText = badgeText
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                action()
            }
        }) {
            ZStack(alignment: .topLeading) {
                content
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)

                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 12,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 8,
                                topTrailingRadius: 0
                            )
                            .fill(Color.blauPrimary)
                        )
                }
            }
        }
        .buttonStyle(DuolingoCardButtonStyle())
    }
}

struct DuolingoCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 12

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(
                        color: Color.gray.opacity(0.3),
                        radius: 0,
                        y: isPressed ? 0 : shadowDepth
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .offset(y: isPressed ? shadowDepth : 0)
            .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    @EnvironmentObject var settings: SettingsStore
    let icon: String
    let accentColor: Color
    let shadowColor: Color
    let name: String
    let subtitle: String
    let price: Int
    var badgeText: String? = nil
    let onBuy: () -> Void

    var body: some View {
        DuolingoShopCard(action: onBuy, badgeText: badgeText) {
            VStack(alignment: .center, spacing: 12) {
                Group {
                    if UIImage(named: icon) != nil {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 50))
                            .foregroundStyle(accentColor)
                    }
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .center, spacing: 4) {
                    Text(settings.localizedString(for: name))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Text(settings.localizedString(for: subtitle))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                HStack(spacing: 5) {
                    Image("Coin")
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(price)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.belohnungGoldHighlight)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Main Shop View

struct UnifiedShopView: View {
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @State private var searchText = ""
    @State private var detailPayload: ShopDetailPayload? = nil
    @State private var shopCategory: ShopCategory = .gegenstande
    @State private var selectedHabitCategory: HabitCategory? = nil

    enum ShopCategory: String, CaseIterable {
        case pflanzen    = "shop.tab.plants"
        case gegenstande = "shop.tab.items"
    }

    var coins: Int { gardenStore.coins }
    
    var pflanzen: [Plant] { GameDatabase.allPlants }
    var muellItems: [TrashItem] { GameDatabase.allTrashItems }
    var powerUps: [PowerUpItem] { GameDatabase.allPowerUps }

    var gefiltertePflanzen: [Plant] {
        var base = pflanzen
        if let kat = selectedHabitCategory {
            base = base.filter { $0.habitCategory == kat }
        }
        if !searchText.isEmpty {
            base = base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return base
    }

    private func preis(fuer pflanze: Plant) -> Int {
        let basisPreis = pflanze.xpPerCompletion * 10
        let levelBonus = pflanze.maxLevel > 10 ? 50 : 0
        return basisPreis + levelBonus
    }

    private func preisForPowerUp(_ item: PowerUpItem) -> Int {
        switch item.rarity {
        case .common:    return 50
        case .rare:      return 150
        case .epic:      return 350
        case .legendary: return 800
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appHintergrund.ignoresSafeArea()

                ScrollViewReader { proxy in
                    ZStack {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer().frame(height: 60).id("top")

                                shopSwitcher
                                    .padding(.bottom, 8)

                                // Suche
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.placeholderText))
                                    TextField(settings.localizedString(for: "Suchen..."), text: $searchText)
                                        .font(.system(size: 16))
                                        .submitLabel(.search)
                                    if !searchText.isEmpty {
                                        Button(action: { searchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color(UIColor.placeholderText))
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(UIColor.systemGray6))
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)

                                if shopCategory == .gegenstande {
                                    // Power-Ups
                                    sectionHeader(settings.localizedString(for: "Power-Ups"))
                                    VStack(spacing: 12) {
                                        ForEach(powerUps) { item in
                                            let p = preisForPowerUp(item)
                                            ShopItemCard(
                                                icon: item.symbolName,
                                                accentColor: item.color,
                                                shadowColor: item.color.darker(),
                                                name: item.name,
                                                subtitle: item.description,
                                                price: p,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: item.id,
                                                        title: item.name,
                                                        subtitle: item.rarity.rawValue,
                                                        description: item.description,
                                                        price: p,
                                                        icon: item.symbolName,
                                                        color: item.color,
                                                        symbolColor: item.symbolColor,
                                                        shadowColor: item.color.darker(),
                                                        tag: item.rarity.rawValue,
                                                        itemType: .powerUp,
                                                        habitCategory: nil,
                                                        symbolism: nil,
                                                        howToUse: item.howToUse
                                                    )
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    
                                    Spacer().frame(height: 28)

                                    // Müll
                                    sectionHeader(settings.localizedString(for: "⚠️ MÜLL-ITEMS"))
                                    VStack(spacing: 12) {
                                        ForEach(muellItems) { item in
                                            ShopItemCard(
                                                icon: item.symbolName,
                                                accentColor: .red,
                                                shadowColor: Color(red: 0.6, green: 0.1, blue: 0.1),
                                                name: item.name,
                                                subtitle: item.description,
                                                price: item.cost,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: item.id,
                                                        title: item.name,
                                                        subtitle: "shop.trash_item_subtitle",
                                                        description: item.description,
                                                        price: item.cost,
                                                        icon: item.symbolName,
                                                        color: .red,
                                                        symbolColor: item.symbolColor,
                                                        shadowColor: Color(red: 0.6, green: 0.1, blue: 0.1),
                                                        tag: "MÜLL",
                                                        itemType: .trash,
                                                        habitCategory: item.targetCategory,
                                                        symbolism: nil,
                                                        howToUse: nil
                                                    )
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                } else {
                                    // Pflanzen
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            LiquidGlassFilterPill(title: settings.localizedString(for: "Alle"), isSelected: selectedHabitCategory == nil) {
                                                selectedHabitCategory = nil
                                            }
                                            ForEach(HabitCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: settings.localizedString(for: kat.rawValue), isSelected: selectedHabitCategory == kat) {
                                                    selectedHabitCategory = kat
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 16)

                                    VStack(spacing: 12) {
                                        ForEach(gefiltertePflanzen) { plant in
                                            let p = preis(fuer: plant)
                                            ShopItemCard(
                                                icon: plant.symbolName,
                                                accentColor: plant.color,
                                                shadowColor: plant.color.darker(),
                                                name: plant.name,
                                                subtitle: plant.symbolism,
                                                price: p,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: plant.id,
                                                        title: plant.name,
                                                        subtitle: plant.habitCategory.rawValue,
                                                        description: plant.symbolism,
                                                        price: p,
                                                        icon: plant.symbolName,
                                                        color: plant.color,
                                                        symbolColor: plant.symbolColor,
                                                        shadowColor: plant.color.darker(),
                                                        tag: plant.habitCategory.rawValue,
                                                        itemType: .plant,
                                                        habitCategory: plant.habitCategory,
                                                        symbolism: plant.symbolism,
                                                        howToUse: nil
                                                    )
                                                }
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }

                                Spacer(minLength: 100)
                            }
                        }
                        
                        // Scroll to Top
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ScrollToTopButton {
                                    withAnimation { proxy.scrollTo("top", anchor: .top) }
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }

                shopHeader
            }
            .navigationBarHidden(true)
            .sheet(item: $detailPayload) { payload in
                ShopItemDetailView(payload: payload)
                    .environmentObject(shopStore)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(powerUpStore)
            }
        }
    }

    private var shopSwitcher: some View {
        Picker(settings.localizedString(for: "Kategorie"), selection: $shopCategory) {
            Text(settings.localizedString(for: ShopCategory.gegenstande.rawValue)).tag(ShopCategory.gegenstande)
            Text(settings.localizedString(for: ShopCategory.pflanzen.rawValue)).tag(ShopCategory.pflanzen)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
    }

    private var shopHeader: some View {
        HStack {
            HStack(spacing: 5) {
                Image("Coin")
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                Text("\(coins)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.belohnungGoldHighlight)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color(UIColor.systemBackground)).shadow(radius: 2))

            Spacer()
            Text(settings.localizedString(for: "shop.title")).font(.headline)
            Spacer()
            
            Color.clear.frame(width: 80, height: 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
}
