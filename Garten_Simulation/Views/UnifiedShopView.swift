import SwiftUI

// MARK: - App Colors (Local fallbacks for the preview)

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
    let isLarge: Bool // Permanent vs Consumable
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

// MARK: - Main Shop View

struct UnifiedShopView: View {
    @State private var coins: Int = 1500
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showFilters: Bool = true
    
    private let allTags = ["ALLE", "WERKZEUG", "VERBRAUCH", "UPGRADES"]
    
    // Data
    let essentials = [
        StandardItem(name: "Goldene Gießkanne", subtitle: "Unbegrenzte Kapazität (Permanent)", price: 2500, icon: "drop.fill", accentColor: .blauPrimary, shadowColor: .blauSecondary, tag: "WERKZEUG", isLarge: true),
        StandardItem(name: "Magie-Dünger", subtitle: "10x Wachtsum", price: 50, icon: "wand.and.stars", accentColor: .lilaPrimary, shadowColor: .lilaSecondary, tag: "VERBRAUCH", isLarge: false),
        StandardItem(name: "Mystic Samen", subtitle: "Unbekannt", price: 100, icon: "sparkles", accentColor: .orangePrimary, shadowColor: .orangeSecondary, tag: "VERBRAUCH", isLarge: false)
    ]
    
    let upgrades = [
        UpgradeItem(name: "Premium Slot", description: "Schalte einen dauerhaften Pflanzenslot für seltene Gewächse frei.", price: 5000, icon: "lock.open.fill", color: .goldPrimary, shadowColor: .goldSecondary),
        UpgradeItem(name: "Wetter-Meister", description: "Kontrolliere einmal täglich das Gartenwetter komplett.", price: 8000, icon: "cloud.sun.rain.fill", color: .blauPrimary, shadowColor: .blauSecondary)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Heller Duolingo-Style App-Hintergrund
                Color.appHintergrund.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) { // Klar getrennte Zonen (Visual Anchors)
                        
                        Spacer().frame(height: 70) // Platz für Floating Header
                        
                        // Header Text (Clean iOS iOS Style)
                        Text("Shop")
                            .font(.system(size: 34, weight: .bold)) 
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Filter Pills (iOS Style)
                        if showFilters {
                            filterBar
                                .padding(.bottom, 8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // 1. Limited Power-ups (Daily Deal & Bundles)
                        if searchText.isEmpty && (selectedTag == nil || selectedTag == "ALLE") {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("ANGEBOTE & BUNDLES")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.primary)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 24) {
                                    DailyDealCard()
                                    BundleCard()
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // 2. Garden Essentials (Permanente Items & Verbrauchsmaterial)
                        let essentialsToDisplay = essentials.filter { passesFilter($0) }
                        if !essentialsToDisplay.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("GARTEN ESSENTIALS")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.primary)
                                    .padding(.horizontal, 24)

                                VStack(spacing: 24) {
                                    // Großes permanentes Item
                                    if let tool = essentialsToDisplay.first(where: { $0.isLarge }) {
                                        StandardShopCard(item: tool)
                                    }
                                    
                                    // Kleine Consumer Items in 2er Grid
                                    let consumables = essentialsToDisplay.filter { !$0.isLarge }
                                    if !consumables.isEmpty {
                                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 20) {
                                            ForEach(consumables) { item in
                                                StandardShopCard(item: item)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // 3. Life Upgrades (Gewohnheiten, Unlocks - jetzt auch im Duolingo Style!)
                        let upgradesToDisplay = upgrades.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
                        if (selectedTag == nil || selectedTag == "ALLE" || selectedTag == "UPGRADES") && !upgradesToDisplay.isEmpty {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("UPGRADES")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.primary)
                                    .padding(.horizontal, 24)

                                VStack(spacing: 24) {
                                    ForEach(upgradesToDisplay) { upgrade in
                                        UpgradeCard(item: upgrade)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTag)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: searchText)
                }
                
                // Moderner "iOS 26" Floating Header Layer + Coin Stats
                modernSearchAndCoinHeader
            }
            .navigationBarHidden(true)
        }
    }
    
    // Hilfsfunktion für Filterung
    private func passesFilter(_ item: StandardItem) -> Bool {
        if let tag = selectedTag, tag != "ALLE", item.tag != tag { return false }
        if !searchText.isEmpty && !item.name.localizedCaseInsensitiveContains(searchText) { return false }
        return true
    }
    
    // MARK: - Modern "iOS 26" Search, Coins & Menu Header
    
    var modernSearchAndCoinHeader: some View {
        HStack(spacing: 12) {
            
            // 1. Floating Search Pill (Flexible)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Suchen...", text: $searchText)
                    .font(.system(size: 16, weight: .regular))
                    .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            
            // 2. Coin Stats Pill (iOS Style Container)
            HStack(spacing: 4) {
                Text("🪙")
                    .font(.system(size: 16))
                Text("\(coins)")
                    .font(.system(size: 16, weight: .bold)) 
                    .foregroundStyle(Color.belohnungGoldHighlight) // Solid, ohne Schatten
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )

            // 3. Floating Circle Menu
            Menu {
                Button(action: {
                    withAnimation { showFilters.toggle() }
                }) {
                    Label(showFilters ? "Filter ausblenden" : "Filter anzeigen", systemImage: "line.3.horizontal.decrease")
                }
                
                Button(action: {
                    selectedTag = "ALLE"
                    searchText = ""
                }) {
                    Label("Zurücksetzen", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 44, height: 44) // Höhe passend zur Search Bar
                    .background(
                        Circle()
                            .fill(.regularMaterial)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10) 
    }

    // MARK: - Filter Bar (Flacher iOS Style)

    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags, id: \.self) { tag in
                    Button(action: {
                        withAnimation {
                            selectedTag = tag
                        }
                    }) {
                        Text(tag)
                            .font(.system(size: 14, weight: .semibold)) // Clean
                            .foregroundStyle((selectedTag ?? "ALLE") == tag ? Color.white : Color.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill((selectedTag ?? "ALLE") == tag ? Color.blue : Color(UIColor.systemGray5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - 1. Daily Deal Card (Pure Duolingo Style)

struct DailyDealCard: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Massive roter Duolingo 3D-Block
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.red)
                .offset(y: 6) // Fixer 6px Offset!
            
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.red.opacity(0.4), lineWidth: 2.5)
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("DAILY DEAL")
                            .font(.system(size: 12, weight: .bold)) // Clean Font
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("14:23:09")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color.red)
                    }
                    
                    HStack {
                        ZStack {
                            Circle().fill(Color.orange.opacity(0.15)).frame(width: 70, height: 70)
                            Text("🎁").font(.system(size: 40))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Wunder-Box")
                                .font(.system(size: 24, weight: .bold)) // Clean iOS Font!
                                .foregroundStyle(Color.primary)
                            Text("Enthält 3 garantierte Epische Samen und 500 Dünger.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 8) {
                            Text("🪙").font(.system(size: 18))
                            Text("150").strikethrough().font(.system(size: 18, weight: .bold)).foregroundStyle(.gray)
                            Text("  99").font(.system(size: 24, weight: .bold)).foregroundStyle(Color.red)
                        }
                        Spacer()
                        ModernBuyButton(color: .red, shadowColor: Color(red: 0.7, green: 0, blue: 0), title: "KAUFEN")
                            .frame(width: 120)
                    }
                }
                .padding(24)
            }
            .offset(y: isPressed ? 6 : 0) // Drückt sich mechanisch in den roten Block
        }
        .padding(.bottom, 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = false } }
        }
    }
}

// MARK: - 2. Bundle Card (Pure Duolingo Style)

struct BundleCard: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Lila Duolingo 3D Block
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.lilaSecondary)
                .offset(y: 6)

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.lilaSecondary.opacity(0.4), lineWidth: 2.5))

                HStack(spacing: 16) {
                    // Bundle Icons
                    ZStack {
                        Circle().fill(Color.lilaPrimary.opacity(0.15)).frame(width: 80, height: 80)
                        HStack(spacing: -15) {
                            Text("🌱").font(.system(size: 30)).rotationEffect(.degrees(-15))
                            Text("💧").font(.system(size: 30)).rotationEffect(.degrees(10))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STARTER BUNDLE")
                            .font(.system(size: 12, weight: .bold)) // Clean
                            .foregroundStyle(Color.lilaPrimary)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.lilaPrimary.opacity(0.15))
                            .clipShape(Capsule())

                        Text("Samen + Wasser")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.primary)
                        
                        HStack {
                            Text("🪙 50").font(.system(size: 18, weight: .bold)).foregroundStyle(Color.belohnungGoldHighlight)
                            Text("-20%")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(20)
            }
            .offset(y: isPressed ? 6 : 0)
        }
        .padding(.bottom, 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = false } }
        }
    }
}

// MARK: - 3. Standard Shop Card (Garden Essentials - Duolingo Component)

struct StandardShopCard: View {
    let item: StandardItem
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Farbiger 3D Shadow Block permanent sichtbar unten +6px
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(item.shadowColor)
                .offset(y: 6)

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(item.shadowColor.opacity(0.4), lineWidth: 2.5))
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        if let tag = item.tag {
                            Text(tag)
                                .font(.system(size: 12, weight: .bold)) // Clean
                                .foregroundStyle(item.accentColor)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(item.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(item.accentColor.opacity(0.15)).frame(width: item.isLarge ? 64 : 44, height: item.isLarge ? 64 : 44)
                            Image(systemName: item.icon).font(.system(size: item.isLarge ? 32 : 20, weight: .bold)).foregroundStyle(item.accentColor)
                        }
                    }

                    Spacer(minLength: 16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: item.isLarge ? 24 : 18, weight: .bold)) // Clean
                            .foregroundStyle(Color.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Text(item.subtitle)
                            .font(.system(size: 15, weight: .regular)) // Clean
                            .foregroundStyle(Color.secondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 16)

                    // Price & Auto Layout
                    if item.isLarge {
                        HStack(alignment: .bottom) {
                            Text("🪙 \(item.price)").font(.system(size: 20, weight: .semibold)).foregroundStyle(Color.belohnungGoldHighlight)
                            Spacer()
                            ModernBuyButton(color: item.accentColor, shadowColor: item.shadowColor, title: "KAUFEN")
                                .frame(width: 120)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Text("🪙 \(item.price)").font(.system(size: 20, weight: .semibold)).foregroundStyle(Color.belohnungGoldHighlight)
                            ModernBuyButton(color: item.accentColor, shadowColor: item.shadowColor, title: "KAUFEN")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(20)
            }
            .frame(height: item.isLarge ? 260 : 230) 
            .offset(y: isPressed ? 6 : 0) // Drückt sich beim Tippen herein
        }
        .padding(.bottom, 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = false } }
        }
    }
}

// MARK: - 4. Upgrade Card (Reines Duolingo Style!)

struct UpgradeCard: View {
    let item: UpgradeItem
    @State private var isPressed = false

    var body: some View {
        ZStack {
            // Massiver farbiger 3D Shadow Block
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(item.shadowColor)
                .offset(y: 6)

            // Premium Card Shell (Weiß mit starkem Rahmen)
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(item.color.opacity(0.4), lineWidth: 3)
                    )
                
                HStack(spacing: 20) {
                    // Massive Premium Icon (ohne verrücktes Blur)
                    ZStack {
                        Circle()
                            .fill(item.color.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: item.icon)
                            .font(.system(size: 40, weight: .bold)) // Clean
                            .foregroundStyle(item.color)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("UPGRADE")
                            .font(.system(size: 12, weight: .bold)) // Clean
                            .foregroundStyle(item.color)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(item.color.opacity(0.15))
                            .clipShape(Capsule())

                        Text(item.name)
                            .font(.system(size: 24, weight: .bold)) // Clean
                            .foregroundStyle(Color.primary)
                        
                        Text(item.description)
                            .font(.system(size: 15, weight: .regular)) // Clean
                            .foregroundStyle(Color.secondary)
                            .lineLimit(3)

                        Spacer()

                        HStack {
                            Text("🪙 \(item.price)").font(.system(size: 20, weight: .bold)).foregroundStyle(Color.belohnungGoldHighlight)
                            Spacer()
                            // Reiner Duolingo Buy Button!
                            ModernBuyButton(color: item.color, shadowColor: item.shadowColor, title: "FREISCHALTEN")
                                .frame(width: 140)
                        }
                    }
                }
                .padding(24)
            }
            .frame(height: 220)
            .offset(y: isPressed ? 6 : 0)
        }
        .padding(.bottom, 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = false } }
        }
    }
}

// MARK: - Reusable Modern Buy Button (Duolingo Style 3D Block)

struct ModernBuyButton: View {
    let color: Color
    let shadowColor: Color
    let title: String
    @State private var isPressed = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(shadowColor)
                    .frame(height: proxy.size.height)
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
                    .frame(height: proxy.size.height)
                    .overlay(
                        Text(title)
                            .font(.system(size: 16, weight: .bold)) // Clean iOS Font
                            .foregroundStyle(.white)
                    )
                    .offset(y: isPressed ? 0 : -6)
            }
        }
        .frame(height: 50)
        .onTapGesture {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation(.spring(response: 0.1, dampingFraction: 0.6)) { isPressed = false } }
        }
    }
}

#Preview {
    UnifiedShopView()
}
