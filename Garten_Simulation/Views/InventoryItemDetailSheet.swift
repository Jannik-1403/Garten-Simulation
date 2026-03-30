import SwiftUI

struct InventoryItemDetailSheet: View {
    let item: ShopDetailPayload
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @Environment(\.dismiss) private var dismiss
    @State private var animateIcon = false
    @State private var showPlantSelection = false

    var body: some View {
        VStack(spacing: 32) {
            // Icon Area
            Group {
                if UIImage(named: item.icon) != nil {
                    Image(item.icon)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: item.icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(item.color)
                }
            }
            .frame(width: 120, height: 120)
            .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text(settings.localizedString(for: item.title))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text(settings.localizedString(for: item.description))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Duolingo Style Button
            Button {
                if item.itemType == .powerUp {
                    if let powerUp = GameDatabase.allPowerUps.first(where: { $0.id == item.id }) {
                        if powerUp.target == .plant {
                            showPlantSelection = true
                        } else {
                            powerUpStore.aktivierePowerUp(powerUp)
                            gardenStore.itemVerbrauchen(shopItem: item)
                            dismiss()
                        }
                    } else {
                        dismiss()
                    }
                } else {
                    dismiss()
                }
            } label: {
                Text(item.itemType == .powerUp ? settings.localizedString(for: "button.use") : settings.localizedString(for: "button.ok"))
            }
            .buttonStyle(DuolingoButtonStyle(
                backgroundColor: item.color,
                shadowColor: item.color.darker()
            ))
            .sheet(isPresented: $showPlantSelection) {
                if let powerUp = GameDatabase.allPowerUps.first(where: { $0.id == item.id }) {
                    PlantSelectionSheet(powerUp: powerUp) {
                        gardenStore.itemVerbrauchen(shopItem: item)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
        }
    }
}

#Preview {
    InventoryItemDetailSheet(
        item: ShopDetailPayload(
            id: "test",
            title: "Super-Dünger",
            subtitle: "Wachstums-Boost",
            description: "Beschleunigt das Wachstum deiner Pflanzen um 50% für die nächsten 24 Stunden.",
            price: 500,
            icon: "bolt.fill",
            color: .orange,
            symbolColor: "orange",
            shadowColor: .orange.opacity(0.3),
            tag: "POWER-UP",
            itemType: .powerUp,
            habitCategory: .fitness,
            symbolism: "Energie und schnelles Vorankommen.",
            howToUse: "item.duenger_blitz.usage"
        )
    )
}
