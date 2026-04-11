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
                    Text("Keine passenden Pflanzen gefunden.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .navigationTitle(settings.localizedString(for: "powerup.picker.title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        LiquidGlassDismissButton { dismiss() }
                    }
                }
            } else {
                List(selectablePlants) { plant in  // gardenStore.pflanzen = [HabitModel]
                    Button {
                    onSelect(plant)
                } label: {
                    HStack(spacing: 12) {
                        // Pflanzenbild (SVG or SF Symbol)
                        if let basePlant = GameDatabase.shared.plant(for: plant.plantID) {
                            PlantIconView(plant: basePlant, seltenheit: plant.seltenheit, size: 28)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(plant.color.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: plant.symbolName)
                                    .foregroundColor(plant.color)
                                    .font(.system(size: 20))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(settings.showHabitInsteadOfName 
                                ? settings.localizedString(for: plant.habitName)
                                : settings.localizedString(for: plant.name))
                                .font(.headline)
                            Text(plant.seltenheit.lokalisiertTitel) // Bronze/Silber/Gold/Diamant
                                .font(.caption)
                                .foregroundColor(plant.seltenheit.farbe)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(settings.localizedString(for: "powerup.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
            } // close else block
        } // close NavigationStack
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
