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

// MARK: - 3D Icon (WetterBanner-Stil – nur Icon, keine Änderungen an WetterBanner.swift)

struct Relief3DIcon: View {
    let systemName: String
    let color: Color
    let shadowColor: Color
    var iconSize: CGFloat = 28
    var circleSize: CGFloat = 64

    var body: some View {
        ZStack {
            Circle()
                .fill(shadowColor.opacity(0.45))
                .frame(width: circleSize, height: circleSize)
                .offset(y: 5)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.22), color.opacity(0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.18), lineWidth: 1.5)
                )
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: circleSize, height: circleSize + 5)
    }
}

// MARK: - Embossed Plaque Card (die klickbare weiße Hauptkarte)

struct PlaquCard<Content: View>: View {
    let onBuy: () -> Void
    @ViewBuilder let content: Content
    @State private var isPressed = false
    @State private var hatAusgeloest = false

    var body: some View {
        ZStack {
            // Shadow-Basis – bleibt statisch (WetterBanner-Stil)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray4))
                .frame(maxWidth: .infinity)

            // Haupt-Plaque – schwebt bei -6, drückt auf 0
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemBackground),
                            Color(red: 0.96, green: 0.96, blue: 0.97)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.clear],
                                startPoint: .top,
                                endPoint: .init(x: 0.5, y: 0.45)
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
                .overlay(
                    content
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20),
                    alignment: .center
                )
                .frame(minHeight: 110)
                .padding(.bottom, 6)
                .offset(y: isPressed ? 0 : -6)
        }
        .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 3)
        .animation(.spring(.snappy(duration: 0.02)), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                    if !hatAusgeloest {
                        hatAusgeloest = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            onBuy()
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
        PlaquCard(onBuy: onBuy) {
            HStack(alignment: .top, spacing: 14) {
                Relief3DIcon(
                    systemName: icon,
                    color: accentColor,
                    shadowColor: shadowColor
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)

                    Spacer(minLength: 14)

                    // Preis unten rechts
                    HStack(spacing: 5) {
                        Spacer()
                        Image("Coin")
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("\(price)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.belohnungGoldHighlight)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Deal Card

struct DealCard: View {
    let emoji: String
    let name: String
    let subtitle: String
    let price: Int
    let badgeText: String
    let accentColor: Color
    let onBuy: () -> Void

    var body: some View {
        PlaquCard(onBuy: onBuy) {
            HStack(alignment: .top, spacing: 14) {
                // Emoji 3D Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.22))
                        .frame(width: 64, height: 64)
                        .offset(y: 5)
                    Circle()
                        .fill(accentColor.opacity(0.10))
                        .frame(width: 64, height: 64)
                    Text(emoji)
                        .font(.system(size: 30))
                }
                .frame(width: 64, height: 69)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
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
                        .lineLimit(2)

                    Spacer(minLength: 14)

                    HStack(spacing: 5) {
                        Spacer()
                        Image("Coin")
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("\(price)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.belohnungGoldHighlight)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Bundle Card

struct BundleCardRow: View {
    let onBuy: () -> Void

    var body: some View {
        PlaquCard(onBuy: onBuy) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.lilaPrimary.opacity(0.22))
                        .frame(width: 64, height: 64)
                        .offset(y: 5)
                    Circle()
                        .fill(Color.lilaPrimary.opacity(0.10))
                        .frame(width: 64, height: 64)
                    Text("🌱")
                        .font(.system(size: 30))
                }
                .frame(width: 64, height: 69)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Starter Bundle")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
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

                    Spacer(minLength: 14)

                    HStack(spacing: 5) {
                        Spacer()
                        Image("Coin")
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("50")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.belohnungGoldHighlight)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Main Shop View

struct UnifiedShopView: View {
    @State private var coins: Int = 1500
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var showFilters: Bool = true

    private let allTags = ["ALLE", "WERKZEUG", "VERBRAUCH", "UPGRADES"]

    let essentials = [
        StandardItem(name: "Goldene Gießkanne", subtitle: "Unbegrenzte Kapazität · Permanent", price: 2500, icon: "drop.fill", accentColor: .blauPrimary, shadowColor: .blauSecondary, tag: "WERKZEUG", isLarge: true),
        StandardItem(name: "Magie-Dünger", subtitle: "10× Wachstum", price: 50, icon: "wand.and.stars", accentColor: .lilaPrimary, shadowColor: .lilaSecondary, tag: "VERBRAUCH", isLarge: false),
        StandardItem(name: "Mystic Samen", subtitle: "Unbekannter Inhalt", price: 100, icon: "sparkles", accentColor: .orangePrimary, shadowColor: .orangeSecondary, tag: "VERBRAUCH", isLarge: false)
    ]

    let upgrades = [
        UpgradeItem(name: "Premium Slot", description: "Dauerhafter Pflanzenslot für seltene Gewächse.", price: 5000, icon: "lock.open.fill", color: .goldPrimary, shadowColor: .goldSecondary),
        UpgradeItem(name: "Wetter-Meister", description: "Kontrolliere einmal täglich das Gartenwetter.", price: 8000, icon: "cloud.sun.rain.fill", color: .blauPrimary, shadowColor: .blauSecondary)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appHintergrund.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 60)

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

                        // MARK: Angebote & Bundles
                        if searchText.isEmpty && (selectedTag == nil || selectedTag == "ALLE") {
                            sectionHeader("Angebote & Bundles")
                            VStack(spacing: 12) {
                                DealCard(
                                    emoji: "🎁",
                                    name: "Wunder-Box",
                                    subtitle: "3 Epische Samen + 500 Dünger",
                                    price: 99,
                                    badgeText: "DEAL",
                                    accentColor: .red,
                                    onBuy: {}
                                )
                                BundleCardRow(onBuy: {})
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
                                        onBuy: {}
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            Spacer().frame(height: 28)
                        }

                        // MARK: Upgrades
                        let upgradesToDisplay = upgrades.filter {
                            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
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
                                        onBuy: {}
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            Spacer().frame(height: 28)
                        }

                        Spacer(minLength: 80)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTag)
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: searchText)
                }

                // MARK: Fixierter Header (bleibt oben)
                shopHeader
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Filter

    private func passesFilter(_ item: StandardItem) -> Bool {
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

    // MARK: - Shop Header

    var shopHeader: some View {
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

            Menu {
                Button(action: {
                    withAnimation { showFilters.toggle() }
                }) {
                    Label(showFilters ? "Filter ausblenden" : "Filter anzeigen",
                          systemImage: "line.3.horizontal.decrease")
                }
                Divider()
                Button(role: .destructive, action: {
                    selectedTag = "ALLE"
                    searchText = ""
                }) {
                    Label("Filter zurücksetzen", systemImage: "arrow.counterclockwise")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.primary)
            }
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
                    Button(action: { withAnimation { selectedTag = tag } }) {
                        Text(tag)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle((selectedTag ?? "ALLE") == tag ? .white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill((selectedTag ?? "ALLE") == tag
                                          ? Color.blauPrimary
                                          : Color(UIColor.systemGray5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

#Preview {
    UnifiedShopView()
}
