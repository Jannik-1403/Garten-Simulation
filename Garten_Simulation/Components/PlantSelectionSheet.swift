import SwiftUI

struct PlantSelectionSheet: View {
    let powerUp: PowerUpItem
    var onSelect: () -> Void  // Callback nach erfolgreicher Aktivierung
    
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(String(localized: "powerup.select_plant_prompt"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                ForEach(gardenStore.pflanzen) { plant in
                    Button {
                        powerUpStore.aktivierePowerUp(powerUp, for: plant.id)
                        onSelect()
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            // Mini Icon
                            ZStack {
                                Circle()
                                    .fill(plant.color.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                Image(systemName: plant.symbolName)
                                    .foregroundStyle(plant.color)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(NSLocalizedString(plant.name, comment: ""))
                                    .font(.headline)
                                Text(plant.seltenheit.lokalisiertTitel)
                                    .font(.caption)
                                    .foregroundStyle(plant.seltenheit.farbe)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(NSLocalizedString(powerUp.name, comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "button.cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}
