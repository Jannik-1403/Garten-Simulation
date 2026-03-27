import SwiftUI

// MARK: - Data Models

struct StandardItem: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let price: Int
    let icon: String
    let accentColor: Color
    let shadowColor: Color
    let tag: String?
    let isLarge: Bool
}

struct UpgradeItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Int
    let icon: String
    let color: Color
    let shadowColor: Color
}

struct PlantItem: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let description: String
    let price: Int
    let icon: String          // Asset-Name
    let accentColor: Color
    let shadowColor: Color
    let tag: String?          // "BAUM", "STRAUCH", "BLUME", "KAKTUS"
    let badgeText: String?    // z.B. "NEU", "SELTEN", "-20%"
    let badgeColor: Color?
}

// MARK: - 3D Icon Removed

// MARK: - Duolingo Shop Card (Replaces PlaquCard)

struct DuolingoShopCard<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: Content
    
    @State private var isPressed = false
    @State private var hatAusgeloest = false
    private let shadowDepth: CGFloat = 4
    private let cornerRadius: CGFloat = 12

    var body: some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
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
                // Subtle border to give it crisp edge
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .offset(y: isPressed ? shadowDepth : 0)
            .animation(.bouncy(duration: 0.2), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                        if !hatAusgeloest {
                            hatAusgeloest = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                                action()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                isPressed = false
                                hatAusgeloest = false
                            }
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        hatAusgeloest = false
                    }
            )
            .sensoryFeedback(
                .impact(flexibility: .soft, intensity: 0.75),
                trigger: isPressed
            ) { _, newValue in
                newValue
            }
    }
}

// MARK: - Shop Item Card

struct ShopItemCard: View {
    let icon: String
    let accentColor: Color
    let shadowColor: Color
    let name: String
    let subtitle: String
    let price: Int
    let onBuy: () -> Void

    var body: some View {
        DuolingoShopCard(action: onBuy) {
            VStack(alignment: .center, spacing: 12) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                VStack(alignment: .center, spacing: 4) {
                    Text(name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                // Preis zentriert unten
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

// MARK: - Deal Card

struct DealCard: View {
    let icon: String
    let name: String
    let subtitle: String
    let price: Int
    let badgeText: String
    let accentColor: Color
    let onBuy: () -> Void

    var body: some View {
        DuolingoShopCard(action: onBuy) {
            VStack(alignment: .center, spacing: 12) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                        Text(badgeText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(accentColor))
                    }
                    Text(subtitle)
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

// MARK: - Bundle Card

struct BundleCardRow: View {
    let onBuy: () -> Void

    var body: some View {
        DuolingoShopCard(action: onBuy) {
            VStack(alignment: .center, spacing: 12) {
                Image("bonsai_stufe1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Starter Bundle")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.primary)
                        Text("-20%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Color.green))
                    }
                    Text("Samen + Wasser Bundle")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 5) {
                    Image("Coin")
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("50")
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
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showFilters: Bool = true
    @State private var detailPayload: ShopDetailPayload? = nil
    @State private var shopCategory: ShopCategory = .gegenstande

    enum ShopCategory: String, CaseIterable {
        case pflanzen    = "Pflanzen"
        case gegenstande = "Gegenstände"
    }

    var coins: Int { shopStore.coins }

    private let allTags = ["ALLE", "WERKZEUG", "VERBRAUCH", "UPGRADES"]

    let essentials = [
        StandardItem(name: "Goldene Gießkanne", subtitle: "Unbegrenzte Kapazität · Permanent", price: 2500, icon: "bonsai_stufe2", accentColor: .blauPrimary, shadowColor: .blauSecondary, tag: "WERKZEUG", isLarge: true),
        StandardItem(name: "Magie-Dünger", subtitle: "10× Wachstum", price: 50, icon: "bonsai_stufe3", accentColor: .lilaPrimary, shadowColor: .lilaSecondary, tag: "VERBRAUCH", isLarge: false),
        StandardItem(name: "Mystic Samen", subtitle: "Unbekannter Inhalt", price: 100, icon: "bonsai_stufe1", accentColor: .orangePrimary, shadowColor: .orangeSecondary, tag: "VERBRAUCH", isLarge: false)
    ]

    let upgrades = [
        UpgradeItem(name: "Premium Slot", description: "Dauerhafter Pflanzenslot für seltene Gewächse.", price: 5000, icon: "bonsai_stufe4", color: .goldPrimary, shadowColor: .goldSecondary),
        UpgradeItem(name: "Wetter-Meister", description: "Kontrolliere einmal täglich das Gartenwetter.", price: 8000, icon: "bonsai_stufe5", color: .blauPrimary, shadowColor: .blauSecondary)
    ]

    let baeume: [PlantItem] = [
        PlantItem(
            id: "kirschbaum",
            name: "Kirschbaum",
            subtitle: "Blüht jeden Frühling",
            description: "Ein wunderschöner Kirschbaum der jeden Frühling in zartem Rosa erblüht. Pflegeleicht und langlebig.",
            price: 320,
            icon: "bonsai_stufe4",
            accentColor: .pink,
            shadowColor: Color(red: 0.7, green: 0.2, blue: 0.4),
            tag: "BAUM",
            badgeText: "BELIEBT",
            badgeColor: .pink
        ),
        PlantItem(
            id: "apfelbaum",
            name: "Apfelbaum",
            subtitle: "Trägt im Herbst Früchte",
            description: "Ein klassischer Apfelbaum. Im Herbst kannst du seine Früchte ernten und als Bonus-Coins einlösen.",
            price: 280,
            icon: "bonsai_stufe3",
            accentColor: .green,
            shadowColor: Color(red: 0.1, green: 0.5, blue: 0.15),
            tag: "BAUM",
            badgeText: nil,
            badgeColor: nil
        ),
        PlantItem(
            id: "bonsai-gold",
            name: "Goldener Bonsai",
            subtitle: "Seltene Zierpflanze",
            description: "Ein extrem seltener goldener Bonsai. Gibt täglich 5 Bonus-Coins und wertet deinen Garten massiv auf.",
            price: 1500,
            icon: "bonsai_stufe5",
            accentColor: .goldPrimary,
            shadowColor: .goldSecondary,
            tag: "BAUM",
            badgeText: "SELTEN",
            badgeColor: .goldPrimary
        )
    ]

    let straucher: [PlantItem] = [
        PlantItem(
            id: "lavendel",
            name: "Lavendel",
            subtitle: "Duftend & bienenfreundlich",
            description: "Lavendel bringt nicht nur Duft in deinen Garten, sondern zieht auch Bienen an die deine anderen Pflanzen bestäuben.",
            price: 80,
            icon: "bonsai_stufe1",
            accentColor: .lilaPrimary,
            shadowColor: .lilaSecondary,
            tag: "STRAUCH",
            badgeText: "NEU",
            badgeColor: .lilaPrimary
        ),
        PlantItem(
            id: "rosenstrauch",
            name: "Rosenstrauch",
            subtitle: "Klassische Schönheit",
            description: "Ein prächtiger Rosenstrauch mit leuchtend roten Blüten. Braucht etwas mehr Pflege, aber lohnt sich.",
            price: 150,
            icon: "bonsai_stufe2",
            accentColor: .red,
            shadowColor: Color(red: 0.6, green: 0.1, blue: 0.1),
            tag: "STRAUCH",
            badgeText: nil,
            badgeColor: nil
        )
    ]

    let kakteen: [PlantItem] = [
        PlantItem(
            id: "saguaro",
            name: "Saguaro Kaktus",
            subtitle: "Braucht kaum Wasser",
            description: "Der klassische Wüstenkaktus. Braucht nur einmal pro Woche Wasser — perfekt wenn du mal vergisst zu gießen.",
            price: 120,
            icon: "bonsai_stufe1",
            accentColor: .green,
            shadowColor: Color(red: 0.1, green: 0.45, blue: 0.1),
            tag: "KAKTUS",
            badgeText: "-20%",
            badgeColor: .orange
        )
    ]

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

                        // MARK: Suche + Filter
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.placeholderText))
                                    TextField("Suchen...", text: $searchText)
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

                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        showFilters.toggle()
                                    }
                                }) {
                                    Image(systemName: showFilters
                                          ? "line.3.horizontal.decrease.circle.fill"
                                          : "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 26))
                                    .foregroundStyle(showFilters ? Color.blauPrimary : Color.secondary)
                                }
                            }
                            .padding(.horizontal, 16)

                            if showFilters {
                                filterBar
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: showFilters)

                        if shopCategory == .gegenstande {
                            // MARK: Angebote & Bundles
                            if searchText.isEmpty && (selectedTag == nil || selectedTag == "ALLE") {
                                sectionHeader("Angebote & Bundles")
                                VStack(spacing: 12) {
                                    DealCard(
                                        icon: "bonsai_stufe5",
                                        name: "Wunder-Box",
                                        subtitle: "3 Epische Samen + 500 Dünger",
                                        price: 99,
                                        badgeText: "DEAL",
                                        accentColor: .red,
                                        onBuy: {
                                            detailPayload = ShopDetailPayload(
                                                id: "wunder-box",
                                                title: "Wunder-Box",
                                                subtitle: "Spezial-Angebot",
                                                description: "Enthält 3 garantierte Epische Samen und 500 Magie-Dünger. Perfekt für einen starken Start in die nächste Saison!",
                                                price: 99,
                                                icon: "bonsai_stufe5",
                                                color: .red,
                                                shadowColor: .red,
                                                tag: "DEAL"
                                            )
                                        }
                                    )
                                    BundleCardRow(onBuy: {
                                        detailPayload = ShopDetailPayload(
                                            id: "starter-bundle",
                                            title: "Starter Bundle",
                                            subtitle: "Samen + Wasser Bundle",
                                            description: "Hol dir das Basis-Set für deinen Garten. Beinhaltet 10 Normale Samen und 50 Gießkannen-Ladungen mit einem Rabatt von 20%.",
                                            price: 50,
                                            icon: "bonsai_stufe1",
                                            color: .green,
                                            shadowColor: .green,
                                            tag: "BUNDLE"
                                        )
                                    })
                                }
                                .padding(.horizontal, 16)
                                Spacer().frame(height: 28)
                            }

                            // MARK: Garten Essentials
                            let essentialsToDisplay = essentials.filter { passesFilter($0) }
                            if !essentialsToDisplay.isEmpty {
                                sectionHeader("Garten Essentials")
                                VStack(spacing: 12) {
                                    ForEach(essentialsToDisplay) { item in
                                        ShopItemCard(
                                            icon: item.icon,
                                            accentColor: item.accentColor,
                                            shadowColor: item.shadowColor,
                                            name: item.name,
                                            subtitle: item.subtitle,
                                            price: item.price,
                                            onBuy: {
                                                detailPayload = ShopDetailPayload(
                                                    id: item.name,
                                                    title: item.name,
                                                    subtitle: item.subtitle,
                                                    description: "Ein essenzieller Gegenstand für deinen Garten. Verbessere deine Pflanzen oder erleichtere dir die Pflege.",
                                                    price: item.price,
                                                    icon: item.icon,
                                                    color: item.accentColor,
                                                    shadowColor: item.shadowColor,
                                                    tag: item.tag
                                                )
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                Spacer().frame(height: 28)
                            }

                            // MARK: Upgrades
                            let upgradesToDisplay = upgrades.filter {
                                !shopStore.isPurchased($0.name) &&
                                (searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText))
                            }
                            if (selectedTag == nil || selectedTag == "ALLE" || selectedTag == "UPGRADES") && !upgradesToDisplay.isEmpty {
                                sectionHeader("Upgrades")
                                VStack(spacing: 12) {
                                    ForEach(upgradesToDisplay) { upgrade in
                                        ShopItemCard(
                                            icon: upgrade.icon,
                                            accentColor: upgrade.color,
                                            shadowColor: upgrade.shadowColor,
                                            name: upgrade.name,
                                            subtitle: upgrade.description,
                                            price: upgrade.price,
                                            onBuy: {
                                                detailPayload = ShopDetailPayload(
                                                    id: upgrade.name,
                                                    title: upgrade.name,
                                                    subtitle: "Garten-Upgrade",
                                                    description: upgrade.description,
                                                    price: upgrade.price,
                                                    icon: upgrade.icon,
                                                    color: upgrade.color,
                                                    shadowColor: upgrade.shadowColor,
                                                    tag: "UPGRADE"
                                                )
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                Spacer().frame(height: 28)
                            }
                        } else {
                            // MARK: Pflanzen-Shop

                            // Angebot des Tages
                            sectionHeader("Angebot des Tages")
                            DealCard(
                                icon: "bonsai_stufe5",
                                name: "Goldener Bonsai",
                                subtitle: "Seltene Zierpflanze · Täglich +5 Coins",
                                price: 1200,
                                badgeText: "DEAL",
                                accentColor: .goldPrimary,
                                onBuy: {
                                    detailPayload = ShopDetailPayload(
                                        id: "bonsai-gold-deal",
                                        title: "Goldener Bonsai",
                                        subtitle: "Angebot des Tages",
                                        description: "Ein extrem seltener goldener Bonsai zum Sonderpreis. Gibt täglich 5 Bonus-Coins und wertet deinen Garten massiv auf.",
                                        price: 1200,
                                        icon: "bonsai_stufe5",
                                        color: .goldPrimary,
                                        shadowColor: .goldSecondary,
                                        tag: "DEAL"
                                    )
                                }
                            )
                            .padding(.horizontal, 16)

                            Spacer().frame(height: 28)

                            // Bäume
                            sectionHeader("Bäume")
                            VStack(spacing: 12) {
                                ForEach(baeume) { plant in
                                    plantCard(plant)
                                }
                            }
                            .padding(.horizontal, 16)

                            Spacer().frame(height: 28)

                            // Sträucher
                            sectionHeader("Sträucher")
                            VStack(spacing: 12) {
                                ForEach(straucher) { plant in
                                    plantCard(plant)
                                }
                            }
                            .padding(.horizontal, 16)

                            Spacer().frame(height: 28)

                            // Kakteen
                            sectionHeader("Kakteen & Sukkulenten")
                            VStack(spacing: 12) {
                                ForEach(kakteen) { plant in
                                    plantCard(plant)
                                }
                            }
                            .padding(.horizontal, 16)

                            Spacer().frame(height: 28)
                        }

                        Spacer(minLength: 80)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTag)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: searchText)
                } // Closes ScrollView
                
                // Floating Action Button via ZStack
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ScrollToTopButton {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 10) 
                }
                .zIndex(100)
                    } // closes inner ZStack
                } // closes ScrollViewReader

                // MARK: Fixierter Header (bleibt oben)
                shopHeader
            }
            .navigationBarHidden(true)
            .sheet(item: $detailPayload) { payload in
                ShopItemDetailView(payload: payload)
                    .environmentObject(shopStore)
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
                    .presentationBackground(.clear) // Let detail view's background shine through
            }
        }
    }

    // MARK: - Filter

    private func passesFilter(_ item: StandardItem) -> Bool {
        if shopStore.isPurchased(item.name) { return false }
        if let tag = selectedTag, tag != "ALLE", item.tag != tag { return false }
        if !searchText.isEmpty && !item.name.localizedCaseInsensitiveContains(searchText) { return false }
        return true
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
    }

    private func plantCard(_ plant: PlantItem) -> some View {
        ShopItemCard(
            icon: plant.icon,
            accentColor: plant.accentColor,
            shadowColor: plant.shadowColor,
            name: plant.name,
            subtitle: plant.subtitle,
            price: plant.price,
            onBuy: {
                detailPayload = ShopDetailPayload(
                    id: plant.id,
                    title: plant.name,
                    subtitle: plant.subtitle,
                    description: plant.description,
                    price: plant.price,
                    icon: plant.icon,
                    color: plant.accentColor,
                    shadowColor: plant.shadowColor,
                    tag: plant.tag
                )
            }
        )
    }

    // MARK: - Switcher
    var shopSwitcher: some View {
        Picker("Kategorie", selection: $shopCategory) {
            Text("Gegenstände").tag(ShopCategory.gegenstande)
            Text("Pflanzen").tag(ShopCategory.pflanzen)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Shop Header

    var shopHeader: some View {
        HStack {
            HStack(spacing: 5) {
                Image("Coin")
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                Text("\(shopStore.coins)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.belohnungGoldHighlight)
                    .contentTransition(.numericText(countsDown: true))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.10), radius: 5, x: 0, y: 2)
            )

            Spacer()

            Text("Shop")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)

            Spacer()

            // Invisible placeholder for equal horizontal spacing
            Color.clear
                .frame(width: 80, height: 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(.regularMaterial)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Filter Bar

    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags, id: \.self) { tag in
                    LiquidGlassFilterPill(
                        title: tag,
                        isSelected: (selectedTag ?? "ALLE") == tag
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                            selectedTag = tag
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Preview

#Preview {
    UnifiedShopView()
}

// MARK: - Scroll Offset Preference

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
