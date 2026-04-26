import SwiftUI

struct RitualPlantPickerSheet: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    let alreadyInRitual: [String]
    let onSelect: (HabitModel) -> Void
    
    // ALLE Pflanzen aus der Datenbank, gefiltert nach Dopplungen
    var filteredHabits: [Plant] {
        GameDatabase.allPlants.filter { plant in
            let isIdInRitual = alreadyInRitual.contains(plant.id)
            let isLockedIdInRitual = alreadyInRitual.contains("locked.\(plant.id)")
            return !isIdInRitual && !isLockedIdInRitual
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredHabits) { plant in
                            let isOwned = gardenStore.pflanzen.contains { $0.plantID == plant.id }
                            
                            Button {
                                if isOwned {
                                    if let ownedHabit = gardenStore.pflanzen.first(where: { $0.plantID == plant.id }) {
                                        onSelect(ownedHabit)
                                    }
                                } else {
                                    let dummy = HabitModel(
                                        id: "locked.\(plant.id)",
                                        name: plant.name,
                                        symbolName: plant.symbolName,
                                        symbolColor: plant.symbolColor,
                                        habitName: plant.habitName,
                                        plantID: plant.id
                                    )
                                    onSelect(dummy)
                                }
                                dismiss()
                            } label: {
                                HStack(spacing: 16) {
                                    Item3DButton(
                                        icon: plant.symbolName,
                                        farbe: isOwned ? plant.color : .gray,
                                        sekundaerFarbe: isOwned ? plant.color.darker() : .gray.darker(),
                                        groesse: 48,
                                        iconSkalierung: 0.5
                                    )
                                    .opacity(isOwned ? 1.0 : 0.4)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        // HABIT NAME ALS TITEL
                                        Text(settings.localizedString(for: plant.habitName))
                                            .font(.system(size: 16, weight: .black, design: .rounded))
                                            .foregroundColor(isOwned ? .primary : .secondary)
                                        
                                        // PFLANZE ALS UNTERTITEL
                                        Text(settings.localizedString(for: plant.name))
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                        
                                        if !isOwned {
                                            HStack(spacing: 4) {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 10))
                                                Text(settings.localizedString(for: "pfad_tag_gesperrt").uppercased())
                                                    .font(.system(size: 10, weight: .black))
                                            }
                                            .foregroundColor(.gray)
                                            .padding(.top, 2)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // GOLDENES PLUS ÜBERALL (Egal ob owned oder locked)
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.goldPrimary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                        .shadow(color: .black.opacity(0.04), radius: 5, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(settings.localizedString(for: "ritual_config_add_habit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(settings.localizedString(for: "button.done")) { dismiss() }
                        .fontWeight(.black)
                        .font(.system(size: 16, design: .rounded))
                }
            }
        }
    }
}
