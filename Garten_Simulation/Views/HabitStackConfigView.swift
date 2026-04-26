import SwiftUI

struct HabitStackConfigView: View {
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settingsStore: SettingsStore
    
    @State private var orderedHabits: [HabitModel] = []
    @State private var selectedHabitIDs: Set<String> = []
    @State private var showAddPicker = false
    @State private var isEditing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 24)
                    
                    if orderedHabits.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(orderedHabits) { habit in
                                    Ritual3DCard(
                                        habit: habit,
                                        isEditing: isEditing,
                                        onDelete: { removeHabitFromRitual(habit) },
                                        onTimeChange: { 
                                            // REAKTIVES SORTIEREN
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                sortHabitsByTime()
                                            }
                                        }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                                }
                            }
                            .padding(24)
                        }
                    }
                    
                    Spacer()
                    
                    // Main Action Button (GROSS & RECHTECKIG)
                    startRitualButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
            .navigationTitle(settingsStore.localizedString(for: "ritual_config_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ABBRECHEN (Links)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(settingsStore.localizedString(for: "button.cancel")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                
                // GLOBAL MENU (Rechts - FIX LOKALISIERUNG)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showAddPicker = true
                        } label: {
                            Label(settingsStore.localizedString(for: "ritual_config_add_habit"), systemImage: "plus")
                        }
                        
                        Button {
                            withAnimation { isEditing.toggle() }
                        } label: {
                            Label(
                                isEditing ? settingsStore.localizedString(for: "button.done") : settingsStore.localizedString(for: "button.edit"),
                                systemImage: isEditing ? "checkmark.circle" : "pencil"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.goldPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .sheet(isPresented: $showAddPicker) {
                RitualPlantPickerSheet(
                    alreadyInRitual: Array(selectedHabitIDs),
                    onSelect: { newHabit in
                        addHabitToRitual(newHabit)
                    }
                )
            }
            .onAppear(perform: initializeFromSettings)
        }
    }
    
    // MARK: - Logic
    
    private func initializeFromSettings() {
        let savedIDs = settingsStore.ritualReihenfolgeIDs
        
        if !savedIDs.isEmpty {
            var ritualItems: [HabitModel] = []
            for id in savedIDs {
                if let habit = gardenStore.pflanzen.first(where: { $0.id == id }) {
                    ritualItems.append(habit)
                } else if id.hasPrefix("locked.") {
                    let realID = id.replacingOccurrences(of: "locked.", with: "")
                    if let plant = GameDatabase.allPlants.first(where: { $0.id == realID }) {
                        ritualItems.append(createDummyHabit(from: plant))
                    }
                }
            }
            orderedHabits = ritualItems
            selectedHabitIDs = Set(savedIDs)
        } else {
            orderedHabits = gardenStore.pflanzen
            selectedHabitIDs = Set(gardenStore.pflanzen.map { $0.id })
            sortHabitsByTime()
        }
    }
    
    private func createDummyHabit(from plant: Plant) -> HabitModel {
        HabitModel(
            id: "locked.\(plant.id)",
            name: plant.name,
            symbolName: plant.symbolName,
            symbolColor: plant.symbolColor,
            habitName: plant.habitName,
            plantID: plant.id
        )
    }
    
    private func sortHabitsByTime() {
        orderedHabits.sort { h1, h2 in
            let t1 = h1.reminderTime ?? Date(timeIntervalSince1970: 0)
            let t2 = h2.reminderTime ?? Date(timeIntervalSince1970: 0)
            return t1 < t2
        }
    }
    
    private func addHabitToRitual(_ habit: HabitModel) {
        if !selectedHabitIDs.contains(habit.id) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                orderedHabits.append(habit)
                selectedHabitIDs.insert(habit.id)
                sortHabitsByTime()
            }
        }
    }
    
    private func removeHabitFromRitual(_ habit: HabitModel) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            orderedHabits.removeAll(where: { $0.id == habit.id })
            selectedHabitIDs.remove(habit.id)
        }
    }
    
    private func saveAndStart() {
        settingsStore.ritualReihenfolgeIDs = orderedHabits.map { $0.id }
        pfadStore.pfadStarten(
            ziel: settingsStore.ausgewaehltesZiel.isEmpty ? "fit" : settingsStore.ausgewaehltesZiel,
            pflanzen: orderedHabits
        )
        pfadStore.zeigeRitualAnpassen = false
        dismiss()
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("⚙️")
                .font(.system(size: 40))
                .shadow(radius: 4)
            Text(settingsStore.localizedString(for: "ritual_config_headline"))
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text(settingsStore.localizedString(for: "ritual_config_subheadline"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Button {
                showAddPicker = true
            } label: {
                Item3DButton(
                    icon: "plus",
                    farbe: .goldPrimary,
                    sekundaerFarbe: .goldPrimary.darker(),
                    groesse: 64,
                    aktion: { showAddPicker = true }
                )
            }
            Text(settingsStore.localizedString(for: "garden.empty.title"))
                .font(.system(.headline, design: .rounded))
            Spacer()
        }
    }
    
    private var startRitualButton: some View {
        Item3DButton(
            farbe: .goldPrimary,
            sekundaerFarbe: Color.goldPrimary.darker(),
            groesse: 64,
            isRectangular: true, // VIERECKIG
            aktion: saveAndStart
        ) {
            Text(settingsStore.localizedString(for: "ritual_config_start"))
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 64)
    }
}

// MARK: - Ritual3DCard (MINUS LINKS)

struct Ritual3DCard: View {
    @ObservedObject var habit: HabitModel
    let isEditing: Bool
    let onDelete: () -> Void
    let onTimeChange: () -> Void
    
    @EnvironmentObject var settings: SettingsStore
    @State private var isPressed = false
    
    private let depth: CGFloat = 8
    
    private var isLocked: Bool {
        habit.id.hasPrefix("locked.")
    }
    
    var body: some View {
        ZStack {
            // UNTERE EBENE (TIEFE)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.systemGray5))
                .offset(y: depth)
            
            // OBERE EBENE (KARTE)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
                .overlay {
                    cardContent
                }
                .offset(y: isPressed ? depth : 0)
        }
        .frame(height: 86)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cardContent: some View {
        HStack(spacing: 12) {
            // MINUS NUR LINKS
            if isEditing {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            // 3D Icon
            Item3DButton(
                icon: habit.symbolName,
                farbe: isLocked ? .gray : habit.color,
                sekundaerFarbe: isLocked ? .gray.darker() : habit.color.darker(),
                groesse: 48,
                iconSkalierung: 0.55
            )
            .opacity(isLocked ? 0.4 : 1.0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(settings.localizedString(for: habit.habitName))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(isLocked ? .secondary : .primary)
                
                if !isLocked {
                    difficultyLabel
                } else {
                    lockedLabel
                }
            }
            
            Spacer()
            
            // Time-Picker (JETZT AUCH FÜR GESPERRTE)
            DatePicker("", selection: Binding(
                get: { habit.reminderTime ?? Date() },
                set: { 
                    habit.reminderTime = $0
                    onTimeChange()
                }
            ), displayedComponents: .hourAndMinute)
            .labelsHidden()
            .scaleEffect(0.9)
            .tint(habit.color)
        }
        .padding(.horizontal, 16)
    }
    
    private var difficultyLabel: some View {
        Menu {
            ForEach(PfadSchwierigkeit.allCases, id: \.self) { diff in
                Button {
                    habit.individualSchwierigkeit = diff.rawValue
                } label: {
                    Label(
                        settings.localizedString(for: "pfad_schwierigkeit_\(diff.rawValue)"),
                        systemImage: diff == (PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger) ? "checkmark.circle.fill" : "circle"
                    )
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(difficultyColor)
                    .frame(width: 8, height: 8)
                let diff = PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger
                Text(settings.localizedString(for: "pfad_schwierigkeit_\(diff.rawValue)"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundColor(difficultyColor)
        }
    }
    
    private var lockedLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10))
            Text(settings.localizedString(for: "pfad_tag_gesperrt").uppercased())
                .font(.system(size: 10, weight: .black))
        }
        .foregroundColor(.gray)
    }
    
    // MARK: - Helpers
    
    private var difficultyColor: Color {
        let diff = PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger
        switch diff {
        case .anfaenger: return .gruenPrimary
        case .fortgeschritten: return .orangePrimary
        case .experte: return .rotPrimary
        }
    }
}
