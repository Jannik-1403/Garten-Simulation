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
    var plant: Plant? = nil
    let onBuy: () -> Void

    var body: some View {
        DuolingoCard(action: onBuy, badgeText: badgeText) {
            VStack(alignment: .center, spacing: 12) {
                Group {
                    if let plant = plant {
                        PlantIconView(plant: plant, seltenheit: .bronze, size: 80, alwaysShowFullGrown: true) // Erhöht von 50
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
                    Text(settings.localizedString(for: name))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(settings.localizedString(for: subtitle))
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                GemsIcon(wert: price)
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
    @State private var selectedDecorationCategory: DecorationCategory? = nil

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
        // Filter nach Level und Besitz
        return base.filter { 
            $0.minGartenLevel <= gardenStore.gartenStufe && 
            !shopStore.isPurchased($0.id) 
        }
    }

    var gefilterteDekorationen: [DecorationItem] {
        var base = decorationItems
        if let kat = selectedDecorationCategory {
            base = base.filter { $0.category == kat }
        }
        if !searchText.isEmpty {
            let lang = settings.appLanguage
            base = base.filter { AppStrings.get($0.nameKey, language: lang).localizedCaseInsensitiveContains(searchText) }
        }
        return base.filter { !shopStore.isPurchased($0.id) }
    }

    var gefiltertePowerUps: [PowerUpItem] {
        var base = powerUps
        if !searchText.isEmpty {
            base = base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        // Filter nach Level und Besitz
        return base.filter { 
            $0.minGartenLevel <= gardenStore.gartenStufe && 
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
                                Spacer().frame(height: 60).id("top")

                                shopSwitcher
                                    .padding(.bottom, 8)

                                // Suche
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.placeholderText))
                                    TextField(settings.localizedString(for: "shop.search_placeholder"), text: $searchText)
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
                                    sectionHeader(settings.localizedString(for: "shop.category.powerups"))
                                    VStack(spacing: 12) {
                                        ForEach(gefiltertePowerUps) { item in
                                            let p = item.basePrice
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
                                    sectionHeader(settings.localizedString(for: "shop.category.decorations"))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            LiquidGlassFilterPill(title: settings.localizedString(for: "shop.filter.all"), isSelected: selectedDecorationCategory == nil) {
                                                selectedDecorationCategory = nil
                                            }
                                            ForEach(DecorationCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: settings.localizedString(for: kat.localizationKey), isSelected: selectedDecorationCategory == kat) {
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
                                                name: item.nameKey,
                                                subtitle: item.descriptionKey,
                                                price: item.price,
                                                badgeText: isOwned ? settings.localizedString(for: "shop.owned") : nil,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: item.id,
                                                        title: item.nameKey,
                                                        subtitle: "shop.trash_item_subtitle",
                                                        description: item.descriptionKey,
                                                        price: item.price,
                                                        icon: item.sfSymbol,
                                                        colorHex: "#FF991A", // orangePrimary
                                                        symbolColor: "orange",
                                                        shadowColorHex: "#D9660D", // orangeSecondary
                                                        tag: "DEKO",
                                                        itemType: .decoration,
                                                        habitCategory: nil,
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
                                            LiquidGlassFilterPill(title: settings.localizedString(for: "shop.filter.all"), isSelected: selectedHabitCategory == nil) {
                                                selectedHabitCategory = nil
                                            }
                                            ForEach(HabitCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: settings.localizedString(for: kat.localizationKey), isSelected: selectedHabitCategory == kat) {
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
                                            let displayName = plant.name
                                            let isOwned = shopStore.isPurchased(plant.id)
                                            
                                            ShopItemCard(
                                                icon: plant.symbolName,
                                                accentColor: plant.color,
                                                shadowColor: plant.color.darker(),
                                                name: displayName,
                                                subtitle: plant.habitName,
                                                price: p,
                                                badgeText: isOwned ? settings.localizedString(for: "shop.owned") : nil,
                                                plant: plant,
                                                onBuy: {
                                                    detailPayload = ShopDetailPayload(
                                                        id: plant.id,
                                                        title: plant.name,
                                                        subtitle: plant.habitName,
                                                        description: plant.symbolism,
                                                        price: p,
                                                        icon: plant.symbolName,
                                                        colorHex: "#59CC33", // green
                                                        symbolColor: plant.symbolColor,
                                                        shadowColorHex: "#3F9922", // dark green
                                                        tag: "PLANT",
                                                        itemType: .plant,
                                                        habitCategory: plant.habitCategory,
                                                        symbolism: plant.symbolism,
                                                        howToUse: nil,
                                                        habitName: plant.habitName
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
            .fullScreenCover(item: $detailPayload) { payload in
                ShopItemDetailView(payload: payload)
                    .environmentObject(shopStore)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(powerUpStore)
            }
        }
    }

    private var shopSwitcher: some View {
        Picker(settings.localizedString(for: "shop.category.label"), selection: $shopCategory) {
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
            GemsIcon(wert: coins)
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
