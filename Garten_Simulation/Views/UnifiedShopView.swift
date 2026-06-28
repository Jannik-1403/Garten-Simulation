import SwiftUI

// MARK: - Data Models (Removed legacy structs)

// MARK: - Duolingo Shop Card


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
    var rarity: ItemRarity? = nil
    var plant: Plant? = nil
    let onBuy: () -> Void

    var body: some View {
        DuolingoCard(action: onBuy, badgeText: badgeText, badgeColor: badgeText != nil ? accentColor : Color.blauPrimary) {
            VStack(alignment: .center, spacing: 12) {
                Group {
                    if let plant = plant {
                        if plant.id == "plant.seeds" {
                            Image("Samen")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        } else {
                            PlantIconView(plant: plant, seltenheit: .bronze, size: 110, alwaysShowFullGrown: true)
                                .scaleEffect(1.5)
                        }
                    } else {
                        if UIImage(named: icon) != nil {
                            Image(icon)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 80))
                                .foregroundStyle(accentColor)
                        }
                    }
                }
                .frame(width: 110, height: 110)

                VStack(alignment: .center, spacing: 4) {
                    Text(NSLocalizedString(name, comment: ""))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(NSLocalizedString(subtitle, comment: ""))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                if price == 0 {
                    Stat3DTitleView(title: String(localized: "shop.free"), color: .gruenPrimary, size: 16)
                        .padding(.top, 4)
                } else {
                    GemsIcon(wert: price)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(16)
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
    @State private var selectedDecorationCategory: DecorationCategory? = nil
    @State private var showDecorationInfo = false

    enum ShopCategory: String, CaseIterable {
        case pflanzen    = "shop.tab.plants"
        case gegenstande = "shop.tab.items"
    }

    var coins: Int { gardenStore.coins }
    
    var pflanzen: [Plant] { GameDatabase.allPlants }
    var decorationItems: [DecorationItem] { GameDatabase.allDecorations }
    var powerUps: [PowerUpItem] { GameDatabase.allPowerUps }

    var relevantHabitCategories: [HabitCategory] {
        let allUsedCats = Set(GameDatabase.allPlants.map { $0.habitCategory })
        return HabitCategory.allCases.filter { allUsedCats.contains($0) }
    }
    
    var gefiltertePflanzen: [Plant] {
        var base = pflanzen
        if let kat = selectedHabitCategory {
            base = base.filter { $0.habitCategory == kat }
        }
        if !searchText.isEmpty {
            base = base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        // Filter nach Besitz (Level Filter entfernt)
        return base.filter { 
            !shopStore.isPurchased($0.id) 
        }
    }

    var gefilterteDekorationen: [DecorationItem] {
        var base = decorationItems
        if let kat = selectedDecorationCategory {
            base = base.filter { $0.category == kat }
        }
        if !searchText.isEmpty {

            base = base.filter { NSLocalizedString(settings.showHabitInsteadOfName ? $0.habitNameKey : $0.objectNameKey, comment: "").localizedCaseInsensitiveContains(searchText) }
        }
        return base.filter { !shopStore.isPurchased($0.id) }
    }

    var gefiltertePowerUps: [PowerUpItem] {
        var base = powerUps
        if !searchText.isEmpty {
            base = base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        // Filter nach Besitz (Level Filter entfernt)
        return base.filter { 
            !shopStore.isPurchased($0.id) 
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
                                Spacer().frame(height: 16).id("top")

                                shopSwitcher
                                    .padding(.bottom, 8)
                                    .tourAnchor(.shopIntro)

                                // Suche
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.placeholderText))
                                    TextField(String(localized: "shop.search_placeholder"), text: $searchText)
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
                                    sectionHeader(String(localized: "shop.category.powerups"))
                                    VStack(spacing: 12) {
                                        ForEach(gefiltertePowerUps) { item in
                                            let p = item.basePrice
                                            let badge: String? = {
                                                switch item.rarity {
                                                case .mystic: return String(localized: "rarity.mystic", defaultValue: "Mystisch")
                                                case .legendary: return String(localized: "rarity.legendary", defaultValue: "Legendär")
                                                case .epic: return String(localized: "rarity.epic", defaultValue: "Episch")
                                                case .rare: return String(localized: "rarity.rare", defaultValue: "Selten")
                                                case .common: return String(localized: "rarity.common", defaultValue: "Gewöhnlich")
                                                }
                                            }()
                                            ShopItemCard(
                                                icon: item.symbolName,
                                                accentColor: item.color,
                                                shadowColor: item.color.darker(),
                                                name: item.name,
                                                subtitle: item.description,
                                                price: p,
                                                badgeText: badge,
                                                rarity: item.rarity,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: item.id,
                                                        titleKey: item.name,
                                                        subtitle: "",
                                                        descriptionKey: item.description,
                                                        price: p,
                                                        icon: item.symbolName,
                                                        colorHex: "#2BC1F5", // blue
                                                        symbolColor: item.symbolColor,
                                                        shadowColorHex: "#1A7493", // dark blue
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

                                    // Dekorationen
                                    sectionHeader(String(localized: "shop.category.decorations")) {
                                        showDecorationInfo = true
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            LiquidGlassFilterPill(title: String(localized: "shop.filter.all"), isSelected: selectedDecorationCategory == nil) {
                                                selectedDecorationCategory = nil
                                            }
                                            ForEach(DecorationCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: NSLocalizedString(kat.localizationKey, comment: ""), isSelected: selectedDecorationCategory == kat) {
                                                    selectedDecorationCategory = kat
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 16)

                                    VStack(spacing: 12) {
                                        ForEach(gefilterteDekorationen) { item in
                                            let isOwned = gardenStore.placedDecorations.contains(where: { $0.id == item.id })
                                            ShopItemCard(
                                                icon: item.sfSymbol,
                                                accentColor: .orange,
                                                shadowColor: .orange.darker(),
                                                name: settings.showHabitInsteadOfName ? item.habitNameKey : item.objectNameKey,
                                                subtitle: item.habitDescriptionKey,
                                                price: item.price,
                                                badgeText: isOwned ? String(localized: "shop.owned") : nil,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: item.id,
                                                        titleKey: item.objectNameKey,
                                                        subtitle: item.habitNameKey,
                                                        descriptionKey: item.habitDescriptionKey,
                                                        price: item.price,
                                                        icon: item.sfSymbol,
                                                        colorHex: "#FF991A", // orangePrimary
                                                        symbolColor: "orange",
                                                        shadowColorHex: "#D9660D", // orangeSecondary
                                                        tag: "DEKO",
                                                        itemType: .decoration,
                                                        habitTitleKey: item.habitNameKey,
                                                        habitDescriptionKey: item.habitDescriptionKey
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
                                            LiquidGlassFilterPill(title: String(localized: "shop.filter.all"), isSelected: selectedHabitCategory == nil) {
                                                selectedHabitCategory = nil
                                            }
                                            ForEach(HabitCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: NSLocalizedString(kat.localizationKey, comment: ""), isSelected: selectedHabitCategory == kat) {
                                                    selectedHabitCategory = kat
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 16)

                                    VStack(spacing: 12) {
                                        ForEach(gefiltertePflanzen) { plant in
                                            let p = plant.basePrice
                                            let displayName = settings.showHabitInsteadOfName ? plant.habitName : plant.name
                                            let isOwned = shopStore.isPurchased(plant.id)
                                            
                                            ShopItemCard(
                                                icon: plant.symbolName,
                                                accentColor: plant.color,
                                                shadowColor: plant.color.darker(),
                                                name: displayName,
                                                subtitle: plant.symbolism,
                                                price: p,
                                                badgeText: isOwned ? String(localized: "shop.owned") : nil,
                                                plant: plant,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: plant.id,
                                                        titleKey: plant.name,
                                                        subtitle: plant.habitName,
                                                        descriptionKey: plant.symbolism,
                                                        price: p,
                                                        icon: plant.symbolName,
                                                        colorHex: "#59CC33", // green
                                                        symbolColor: plant.symbolColor,
                                                        shadowColorHex: "#3F9922", // dark green
                                                        tag: "PLANT",
                                                        itemType: .plant,
                                                        habitCategory: plant.habitCategory,
                                                        symbolism: plant.symbolism,
                                                        habitName: plant.habitName,
                                                        habitTitleKey: plant.habitName,
                                                        habitDescriptionKey: plant.symbolism
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
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    GemsIcon(wert: coins)
                        .fixedSize()
                }
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "shop.title"))
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .fullScreenCover(item: $detailPayload) { payload in
                ShopItemDetailView(payload: payload)
                    .environmentObject(shopStore)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(powerUpStore)
            }
            .sheet(isPresented: $showDecorationInfo) {
                DecorationInfoSheet()
                    .environmentObject(settings)
            }
        }
    }

    private var shopSwitcher: some View {
        Picker(String(localized: "shop.category.label"), selection: $shopCategory) {
            Text(NSLocalizedString(ShopCategory.gegenstande.rawValue, comment: "")).tag(ShopCategory.gegenstande)
            Text(NSLocalizedString(ShopCategory.pflanzen.rawValue, comment: "")).tag(ShopCategory.pflanzen)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }

    private func sectionHeader(_ title: String, infoAction: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
            
            if let action = infoAction {
                Button(action: action) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
