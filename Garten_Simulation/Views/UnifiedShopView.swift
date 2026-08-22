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
    var originalPrice: Int? = nil
    var badgeText: String? = nil
    var rarity: ItemRarity? = nil
    var plant: Plant? = nil
    var iconScale: CGFloat = 1.0
    let onBuy: () -> Void

    var body: some View {
        DuolingoCard(action: onBuy, badgeText: badgeText, badgeColor: badgeText != nil ? Color.gruenPrimary : Color.blauPrimary) {
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
                                .scaleEffect(iconScale)
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 80))
                                .foregroundStyle(accentColor)
                                .scaleEffect(iconScale)
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
                    if !subtitle.isEmpty {
                        Text(NSLocalizedString(subtitle, comment: ""))
                            .font(.system(size: 14))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }

                if price == 0 {
                    Stat3DTitleView(title: String(localized: "shop.free"), color: .gruenPrimary, size: 16)
                        .padding(.top, 4)
                } else {
                    HStack(alignment: .center, spacing: 6) {
                        if let original = originalPrice, original != price {
                            HStack(spacing: 2) {
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text(verbatim: "\(original)")
                                    .strikethrough()
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.trailing, 4)
                            
                            Stat3DTitleView(title: "↓", color: .orange, size: 20)
                                .padding(.trailing, 4)
                        }
                        GemsIcon(wert: price)
                    }
                    .padding(.top, 4)
                }
            }
            .scaleEffect((plant != nil && plant?.id != "plant.seeds") ? 1.15 : 1.0)
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
    @EnvironmentObject var iapStore: IAPStore
    @EnvironmentObject var characterStore: CharacterStore
    @State private var searchText = ""
    @State private var detailPayload: ShopDetailPayload? = nil
    @State private var shopCategory: ShopCategory = .gegenstande
    @State private var selectedHabitCategory: HabitCategory? = nil
    @State private var selectedDecorationCategory: DecorationCategory? = nil
    @State private var showCoinsDetail = false


    enum ShopCategory: String, CaseIterable {
        case pflanzen    = "shop.tab.plants"
        case gegenstande = "shop.tab.items"
    }

    var coins: Int { gardenStore.coins }
    
    var pflanzen: [Plant] { GameDatabase.allPlants }
    var decorationItems: [DecorationItem] { GameDatabase.allDecorations }

    var relevantHabitCategories: [HabitCategory] {
        let allUsedCats = Set(GameDatabase.allPlants.map { $0.habitCategory })
        return HabitCategory.allCases.filter { allUsedCats.contains($0) && $0 != .seeds }
    }
    
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

    var gefilterteDekorationen: [DecorationItem] {
        var base = decorationItems
        if let kat = selectedDecorationCategory {
            base = base.filter { $0.category == kat }
        }
        if !searchText.isEmpty {

            base = base.filter { NSLocalizedString(settings.showHabitInsteadOfName ? $0.habitNameKey : $0.objectNameKey, comment: "").localizedCaseInsensitiveContains(searchText) }
        }
        return base
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
                                    if gardenStore.isDailySpinAvailable {
                                        sectionHeader(String(localized: "dailyspin.title", defaultValue: "Glücksrad"))
                                        VStack(spacing: 12) {
                                            ShopItemCard(
                                                icon: "Spin",
                                                accentColor: .belohnungGoldMid,
                                                shadowColor: .belohnungGoldSchatten,
                                                name: "dailyspin.title",
                                                subtitle: "dailyspin.subtitle",
                                                price: 0,
                                                iconScale: 2.2,
                                                onBuy: {
                                                    gardenStore.checkDailySpin()
                                                }
                                            )
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 16)
                                    }



                                    // Dekorationen
                                    sectionHeader(String(localized: "shop.category.decorations"))
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            LiquidGlassFilterPill(title: String(localized: "shop.filter.all"), isSelected: selectedDecorationCategory == nil) {
                                                selectedDecorationCategory = nil
                                            }
                                            ForEach(DecorationCategory.allCases, id: \.self) { kat in
                                                LiquidGlassFilterPill(title: kat.localizedName, isSelected: selectedDecorationCategory == kat) {
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
                                                iconScale: 2.2,
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
                                                LiquidGlassFilterPill(title: kat.localizedName, isSelected: selectedHabitCategory == kat) {
                                                    selectedHabitCategory = kat
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                    .padding(.bottom, 16)

                                    VStack(spacing: 12) {
                                        ForEach(gefiltertePflanzen) { plant in
                                            let originalP = plant.basePrice
                                            let p = iapStore.isProUser ? Int(Double(originalP) * GameConstants.proUnlockDiscount) : originalP
                                            let displayName = settings.showHabitInsteadOfName ? plant.habitName : plant.name
                                            let isOwned = shopStore.isPurchased(plant.id)
                                            
                                            ShopItemCard(
                                                icon: plant.symbolName,
                                                accentColor: plant.color,
                                                shadowColor: plant.color.darker(),
                                                name: displayName,
                                                subtitle: plant.symbolism,
                                                price: p,
                                                originalPrice: originalP,
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
                    Button(action: {
                        showCoinsDetail = true
                    }) {
                        GemsIcon(wert: coins)
                            .fixedSize()
                    }
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
                    .environmentObject(iapStore)
                    .environmentObject(characterStore)
            }
            .sheet(isPresented: $showCoinsDetail) {
                CoinsDetailView()
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .environmentObject(characterStore)
                    .environmentObject(iapStore)
            }
        }
    }

    private var shopSwitcher: some View {
        VStack(spacing: 4) {
            Text(String(localized: "shop.tab.header", defaultValue: "Gewohnheiten"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Picker(String(localized: "shop.category.label", defaultValue: "Kategorie"), selection: $shopCategory) {
                Text(String(localized: "shop.tab.items.short", defaultValue: "Schlechte")).tag(ShopCategory.gegenstande)
                Text(String(localized: "shop.tab.plants.short", defaultValue: "Gute")).tag(ShopCategory.pflanzen)
            }
            .pickerStyle(.segmented)
        }
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
