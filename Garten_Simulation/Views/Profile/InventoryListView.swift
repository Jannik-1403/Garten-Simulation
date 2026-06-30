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
                let isTrash = deco.id.hasPrefix("trash.")
                return ShopDetailPayload(
                    id: deco.id,
                    titleKey: deco.objectNameKey,
                    subtitle: deco.category.localizationKey,
                    descriptionKey: deco.habitDescriptionKey,
                    price: deco.price,
                    icon: deco.sfSymbol,
                    colorHex: isTrash ? "#7F8C8D" : "#FF991A", // gray vs orangePrimary
                    symbolColor: isTrash ? "gray" : "orange",
                    shadowColorHex: isTrash ? "#2C3E50" : "#D9660D", // dark gray vs orangeSecondary
                    tag: isTrash ? "MÜLL" : "DEKO",
                    itemType: .decoration,
                    habitCategory: nil,
                    symbolism: "",
                    howToUse: "",
                    habitName: "",
                    habitTitleKey: deco.habitNameKey,
                    habitDescriptionKey: deco.habitDescriptionKey
                )
            }
        }
    }
    
    var title: String {
        switch category {
        case .powerUps:
            return String(localized: "profile.inventory.powerups")
        case .decorations:
            return String(localized: "profile.inventory.decorations")
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
                    
                    Text(String(localized: "inventory.empty"))
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
        .standardNavigationX()
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
        let isTrash = item.id.hasPrefix("trash.")
        Button {
            action?()
        } label: {
            VStack(spacing: 12) {
                Item3DButton(
                    icon: item.icon,
                    farbe: item.color,
                    sekundaerFarbe: item.color.darker(),
                    groesse: 90,
                    iconSkalierung: item.itemType == .decoration ? 2.2 : (isTrash ? 0.6 : 0.95),
                    aktion: action
                )
                
                VStack(spacing: 4) {
                    Text(NSLocalizedString(item.titleKey, comment: ""))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    
                    Text(NSLocalizedString(item.subtitle, comment: ""))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: isTrash ? Color(hex: "#FADBD8") : .white, // leicht rötlich/hellgrau für Müll
            sekundaerFarbe: isTrash ? Color(hex: "#E6B0AA") : Color(hex: "#E5E5EA"), // dunklerer rötlicher Schatten
            groesse: 170, // Ungefähre Höhe
            iconSkalierung: 1.0,
            shadowDepthFactor: 0.05,
            isRectangular: true,
            isPermanentlyPressed: false,
            isDisabled: false
        ))
    }
}
