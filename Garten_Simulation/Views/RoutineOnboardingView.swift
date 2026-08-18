import SwiftUI

struct RoutineOnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @Binding var savedRoutines: [RoutineUIData]
    @Binding var customRoutinesData: Data
    var onFinish: (() -> Void)? = nil
    
    @State private var routines: [RoutineUIData] = [
        RoutineUIData(titleKey: "routine.morning", icon: "sun.max.fill", colorHex: "#FF9500", filterType: .morning),
        RoutineUIData(titleKey: "routine.gym", icon: "figure.run", colorHex: "#FF3B30", filterType: .afternoon),
        RoutineUIData(titleKey: "routine.evening", icon: "moon.stars.fill", colorHex: "#5856D6", filterType: .evening)
    ]
    
    @State private var selectedRoutineIDs: Set<UUID> = []
    @State private var routineToEdit: RoutineUIData? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text(String(localized: "routine.onboarding.title", defaultValue: "Deine Routinen", locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Text(String(localized: "routine.onboarding.subtitle", defaultValue: "Wähle deine bevorzugten Routinen aus und füge direkt Gewohnheiten hinzu.", locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach($routines) { $routine in
                                let isSelected = selectedRoutineIDs.contains(routine.id)
                                
                                Item3DButton(
                                    farbe: .white,
                                    sekundaerFarbe: Color(white: 0.9),
                                    groesse: 80,
                                    isRectangular: true,
                                    aktion: {
                                        if isSelected {
                                            selectedRoutineIDs.remove(routine.id)
                                        } else {
                                            selectedRoutineIDs.insert(routine.id)
                                        }
                                    }
                                ) {
                                    HStack(spacing: 16) {
                                        // Checkbox
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 28))
                                            .foregroundStyle(isSelected ? Color.orange : Color.gray.opacity(0.5))
                                        
                                        // Icon
                                        Group {
                                            if routine.titleKey == "routine.morning" || routine.titleKey.lowercased() == "morgenroutine" {
                                                Image("MorgenRoutine")
                                                    .resizable()
                                                    .scaledToFit()
                                            } else if routine.titleKey == "routine.evening" || routine.titleKey.lowercased() == "abendroutine" {
                                                Image("AbendRoutine")
                                                    .resizable()
                                                    .scaledToFit()
                                            } else if routine.titleKey == "routine.gym" || routine.titleKey.lowercased() == "gymroutine" {
                                                Image("GymRoutine")
                                                    .resizable()
                                                    .scaledToFit()
                                            } else {
                                                Image("allgemeineMorgenroutine")
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                        }
                                        .frame(width: 48, height: 48)
                                        
                                        // Title
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(String(localized: String.LocalizationValue(routine.titleKey), locale: Locale(identifier: settings.appLanguage)))
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundStyle(.primary)
                                            
                                            if !routine.assignedHabitIDs.isEmpty {
                                                Text("\(routine.assignedHabitIDs.count) \(String(localized: "routine.habits", defaultValue: "Gewohnheiten", locale: Locale(identifier: settings.appLanguage)))")
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Edit Button
                                        Image(systemName: "pencil")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.gray)
                                            .padding(10)
                                            .background(Color(white: 0.95))
                                            .clipShape(Circle())
                                            .onTapGesture {
                                                routineToEdit = routine
                                            }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(24)
                    }
                    
                    Item3DButton(
                        farbe: Color.orange,
                        sekundaerFarbe: Color.orange.darker(),
                        groesse: 60,
                        isRectangular: true,
                        aktion: {
                            let finalRoutines = routines.filter { selectedRoutineIDs.contains($0.id) }
                            
                            // No automatic assignment of habits anymore
                            
                            savedRoutines = finalRoutines
                            
                            if let encoded = try? JSONEncoder().encode(savedRoutines) {
                                customRoutinesData = encoded
                            }
                            
                            if let onFinish = onFinish {
                                onFinish()
                            } else {
                                settings.routineOnboardingAbgeschlossen = true
                                dismiss()
                            }
                        }
                    ) {
                        Text(String(localized: "common.done", defaultValue: "Fertig", locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .sheet(item: $routineToEdit) { editableRoutine in
                if let index = routines.firstIndex(where: { $0.id == editableRoutine.id }) {
                    let assignedToOthers = routines.filter { $0.id != editableRoutine.id }.flatMap { $0.assignedHabitIDs }
                    let available = gardenStore.activeHabits.filter { !assignedToOthers.contains($0.id) }
                    
                    EditRoutineSheet(
                        routine: $routines[index],
                        availableHabits: available
                    )
                    .environmentObject(settings)
                    .environmentObject(gardenStore)
                    .onDisappear {
                        // Automatically select it if they edited it
                        selectedRoutineIDs.insert(editableRoutine.id)
                    }
                }
            }
        }
    }
}
