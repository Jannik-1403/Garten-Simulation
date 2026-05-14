import SwiftUI

enum InventoryCategory {
    case powerUps
    case decorations
}

struct InventoryListView: View {
    let category: InventoryCategory
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedItem: ShopDetailPayload?
    
    var items: [ShopDetailPayload] {
        switch category {
        case .powerUps:
            return gardenStore.gekauftePowerUps
        case .decorations:
            // Convert DecorationItem to ShopDetailPayload for display
            return gardenStore.placedDecorations.map { deco in
                ShopDetailPayload(
                    id: deco.id,
                    title: deco.nameKey,
                    subtitle: deco.category.localizationKey,
                    description: deco.descriptionKey,
                    price: deco.price,
                    icon: deco.sfSymbol,
                    colorHex: "#FF991A", // orangePrimary
                    symbolColor: "orange",
                    shadowColorHex: "#D9660D", // orangeSecondary
                    tag: "DEKO",
                    itemType: .decoration,
                    habitCategory: nil,
                    symbolism: "",
                    howToUse: ""
                )
            }
        }
    }
    
    var title: String {
        switch category {
        case .powerUps:
            return settings.localizedString(for: "profile.inventory.powerups")
        case .decorations:
            return settings.localizedString(for: "profile.inventory.decorations")
        }
    }
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            if items.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: category == .powerUps ? "bolt.slash.fill" : "square.dashed")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    Text(settings.localizedString(for: "inventory.empty"))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(items) { item in
                            InventoryItemCard(item: item) {
                                selectedItem = item
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            InventoryItemDetailSheet(item: item)
                .environmentObject(gardenStore)
                .environmentObject(settings)
        }
    }
}

struct InventoryItemCard: View {
    let item: ShopDetailPayload
    var action: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 12) {
            Item3DButton(
                icon: item.icon,
                farbe: item.color,
                sekundaerFarbe: item.color.darker(),
                groesse: 90,
                iconSkalierung: 0.6,
                aktion: action
            )
            
            VStack(spacing: 4) {
                Text(settings.localizedString(for: item.title))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                Text(settings.localizedString(for: item.subtitle))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(1)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
