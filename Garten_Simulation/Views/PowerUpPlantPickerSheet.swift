import SwiftUI

struct PowerUpPlantPickerSheet: View {
    let powerUp: PowerUpItem
    let onSelect: (HabitModel) -> Void
    
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var selectablePlants: [HabitModel] {
        if powerUp.id == "powerup.wunder_wasser" {
            return gardenStore.pflanzen.filter { $0.isDead }
        }
        return gardenStore.pflanzen
    }

    var body: some View {
        NavigationStack {
            if selectablePlants.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "leaf.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text(settings.localizedString(for: "powerup.picker.no_plants"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle(settings.localizedString(for: "powerup.picker.title"))
                .navigationBarTitleDisplayMode(.inline)
                .standardNavigationX()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(selectablePlants) { plant in
                            Item3DButton(
                                farbe: Color(UIColor.secondarySystemGroupedBackground),
                                sekundaerFarbe: Color(UIColor.systemGray4),
                                groesse: 76,
                                isRectangular: true,
                                aktion: { onSelect(plant) }
                            ) {
                                HStack(spacing: 16) {
                                    // Pflanzenbild (SVG or SF Symbol)
                                    if let basePlant = GameDatabase.shared.plant(for: plant.plantID) {
                                        PlantIconView(plant: basePlant, seltenheit: plant.seltenheit, size: 36)
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(plant.color.opacity(0.15))
                                                .frame(width: 48, height: 48)
                                            Image(systemName: plant.symbolName)
                                                .foregroundColor(plant.color)
                                                .font(.system(size: 22))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(settings.showHabitInsteadOfName 
                                            ? settings.localizedString(for: plant.habitName)
                                            : settings.localizedString(for: plant.name))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                            
                                        Text(plant.seltenheit.lokalisiertTitel) // Bronze/Silber/Gold/Diamant
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundColor(plant.seltenheit.farbe)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(UIColor.tertiaryLabel))
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(.bottom, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            .navigationTitle(settings.localizedString(for: "powerup.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            } // close else block
        } // close NavigationStack
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
