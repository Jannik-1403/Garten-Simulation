import SwiftUI

struct PowerUpPlantPickerSheet: View {
    let powerUp: PowerUpItem
    let onSelect: (HabitModel) -> Void
    
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(gardenStore.pflanzen) { plant in  // gardenStore.pflanzen = [HabitModel]
                Button {
                    onSelect(plant)
                } label: {
                    HStack(spacing: 12) {
                        // Pflanzenbild (grüner Kreis wie auf Gartenkarte)
                        ZStack {
                            Circle()
                                .fill(plant.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: plant.symbolName)
                                .foregroundColor(plant.color) // Use plant.color
                                .font(.system(size: 20))
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
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
