import SwiftUI

struct RoutineUIData: Identifiable, Equatable, Codable {
    var id = UUID()
    var titleKey: String
    var icon: String
    var colorHex: String
    var filterType: RoutineFilterType
    var assignedHabitIDs: [String] = []
    var reminderTime: Date? = nil // Legacy, keep for backward compatibility
    var reminderSchedule: ReminderSchedule? = nil
    var overrideIndividualReminders: Bool = true
    var lastCompletedDate: Date? = nil
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    func contains(habit: HabitModel) -> Bool {
        if self.assignedHabitIDs.contains(habit.id) { return true }
        
        switch self.filterType {
        case .morning:
            if let reminder = habit.nextActiveReminder {
                let h = Calendar.current.component(.hour, from: reminder.time)
                return h >= 5 && h < 12
            }
            return false
        case .afternoon:
            if let reminder = habit.nextActiveReminder {
                let h = Calendar.current.component(.hour, from: reminder.time)
                return h >= 12 && h < 17
            }
            return false
        case .evening:
            if let reminder = habit.nextActiveReminder {
                let h = Calendar.current.component(.hour, from: reminder.time)
                return h >= 17 || h < 5
            }
            return false
        case .custom:
            return false
        }
    }
}

enum RoutineFilterType: String, Codable {
    case morning
    case afternoon
    case evening
    case custom
}

struct RoutinenView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @AppStorage("customRoutinesData", store: SharedUserDefaults.suite) private var customRoutinesData: Data = Data()
    
    @State private var routines: [RoutineUIData] = []
    
    @State private var showCreateSheet = false
    @State private var showOnboarding = false
    
    // All scheduled habits
    private var timelinePlants: [HabitModel] {
        gardenStore.pflanzen.filter { $0.hasActiveReminder && $0.nextActiveReminder != nil }
    }

    func habits(for routine: RoutineUIData) -> [HabitModel] {
        let unsortedHabits = gardenStore.pflanzen.filter { routine.contains(habit: $0) }
        
        return unsortedHabits.sorted { h1, h2 in
            let index1 = routine.assignedHabitIDs.firstIndex(of: h1.id) ?? Int.max
            let index2 = routine.assignedHabitIDs.firstIndex(of: h2.id) ?? Int.max
            return index1 < index2
        }
    }

    // Without Routine (Other Habits)
    var otherPlants: [HabitModel] {
        var displayedIDs = Set<String>()
        for routine in routines {
            for h in habits(for: routine) {
                displayedIDs.insert(h.id)
            }
        }
        return gardenStore.pflanzen.filter { !displayedIDs.contains($0.id) && !$0.isRoutineOnly }
    }

    private func isRoutineCompleted(_ routine: RoutineUIData) -> Bool {
        if let lastCompleted = routine.lastCompletedDate, Calendar.current.isDateInToday(lastCompleted) {
            return true
        }
        return false
    }
    
    private var uncompletedRoutines: [RoutineUIData] {
        routines.filter { !isRoutineCompleted($0) }
    }
    
    private var completedRoutines: [RoutineUIData] {
        routines.filter { isRoutineCompleted($0) }
    }

    @State private var routineToEdit: RoutineUIData?
    @State private var routineToPlay: RoutineUIData?
    @State private var selectedHabitToView: HabitModel?
    
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // MARK: - Routines (Expandable)
                        VStack(spacing: 0) {
                            if !uncompletedRoutines.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: String.LocalizationValue("routine.pending"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 24)
                                        .padding(.bottom, 8)
                                    
                                    ForEach(uncompletedRoutines) { routine in
                                        RoutineExpandableSection(
                                            titleKey: routine.titleKey,
                                            icon: routine.icon,
                                            color: routine.color,
                                            habits: habits(for: routine),
                                            routine: routine,
                                            isCompleted: false,
                                            onHabitTap: { pflanze in
                                                selectedHabitToView = pflanze
                                            },
                                            onStart: {
                                                routineToPlay = routine
                                            },
                                            onEdit: {
                                                routineToEdit = routine
                                            }
                                        )
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                            
                            // MARK: - Completed Routines
                            if !completedRoutines.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: String.LocalizationValue("routine.completed"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 24)
                                        .padding(.top, 32)
                                        .padding(.bottom, 8)
                                    
                                    ForEach(completedRoutines) { routine in
                                        RoutineExpandableSection(
                                            titleKey: routine.titleKey,
                                            icon: routine.icon,
                                            color: routine.color,
                                            habits: habits(for: routine),
                                            routine: routine,
                                            isCompleted: true,
                                            onHabitTap: { pflanze in
                                                selectedHabitToView = pflanze
                                            },
                                            onStart: {
                                                routineToPlay = routine
                                            },
                                            onEdit: {
                                                routineToEdit = routine
                                            }
                                        )
                                    }
                                }
                            }
                            
                            // Without Routine (Not deletable)
                            RoutineExpandableSection(
                                titleKey: "routine.without",
                                icon: "tray.fill",
                                color: .gray,
                                habits: otherPlants,
                                routine: nil,
                                onHabitTap: { pflanze in
                                    selectedHabitToView = pflanze
                                }
                            )
                            .padding(.top, completedRoutines.isEmpty ? 32 : 16)
                        }
                        .padding(.top, 24)
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationTitle(String(localized: String.LocalizationValue("tab.routines"), locale: Locale(identifier: settings.appLanguage)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    topBarMenu
                }
            }
            .fullScreenCover(item: $selectedHabitToView) { pflanze in
                ZStack {
                    NavigationStack {
                        PflanzeDetailSheet(
                            pflanze: pflanze,
                            wetterEvent: .normal,
                            onLoeschen: {
                                gardenStore.pflanzEntfernen(pflanze: pflanze)
                                selectedHabitToView = nil
                            }
                        )
                    }
                    if interactiveTourManager.isActive {
                        InteractiveTourOverlay()
                            .zIndex(99998)
                    }
                }
                .environmentObject(gardenStore)
                .environmentObject(shopStore)
                .environmentObject(settings)
                .environmentObject(powerUpStore)
                .environmentObject(pfadStore)
                .environmentObject(interactiveTourManager)
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateRoutineSheet(routines: $routines, availableHabits: otherPlants)
            }
            .sheet(item: $routineToEdit) { item in
                if let idx = routines.firstIndex(where: { $0.id == item.id }) {
                    let availableForEdit = otherPlants + habits(for: item)
                    EditRoutineSheet(routine: $routines[idx], availableHabits: availableForEdit)
                } else {
                    EmptyView()
                }
            }
            .fullScreenCover(item: $routineToPlay) { item in
                RoutineSessionView(routine: item, habits: habits(for: item), onComplete: {
                    if let idx = routines.firstIndex(where: { $0.id == item.id }) {
                        routines[idx].lastCompletedDate = Date()
                    }
                })
            }
            .onAppear {
                loadRoutines()
                // Zeige Onboarding wenn noch nicht abgeschlossen und wir auf Tab 4 sind, UND keine Tour aktiv ist
                if !settings.routineOnboardingAbgeschlossen && gardenStore.selectedTab == 4 && !interactiveTourManager.isActive {
                    showOnboarding = true
                }
            }
            .onChange(of: routines) { _, _ in
                saveRoutines()
            }
            .onChange(of: settings.routineOnboardingAbgeschlossen) { _, newValue in
                // Wenn Flag auf false gesetzt wird (z.B. nach Reset), nur Onboarding zeigen wenn auf Tab 4
                if !newValue && gardenStore.selectedTab == 4 && !interactiveTourManager.isActive {
                    showOnboarding = true
                }
            }
            .onChange(of: interactiveTourManager.isActive) { _, isActive in
                // Wenn Tour beendet wird und wir auf Tab 4 sind, Onboarding triggern
                if !isActive && gardenStore.selectedTab == 4 && !settings.routineOnboardingAbgeschlossen {
                    showOnboarding = true
                }
            }
            .onChange(of: gardenStore.selectedTab) { _, newTab in
                // Wenn der Nutzer zu Tab 4 (Routinen) navigiert und Onboarding nötig ist
                if newTab == 4 && !settings.routineOnboardingAbgeschlossen && !interactiveTourManager.isActive {
                    showOnboarding = true
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                RoutineOnboardingView(
                    savedRoutines: $routines,
                    customRoutinesData: $customRoutinesData,
                    onFinish: {
                        settings.routineOnboardingAbgeschlossen = true
                        showOnboarding = false
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var topBarMenu: some View {
        Menu {
            Button {
                showCreateSheet = true
            } label: {
                Label(String(localized: String.LocalizationValue("routine.create"), locale: Locale(identifier: settings.appLanguage)), systemImage: "plus")
            }
            
            Menu {
                ForEach(routines) { routine in
                    Button(role: .destructive) {
                        withAnimation {
                            if let idx = routines.firstIndex(where: { $0.id == routine.id }) {
                                routines.remove(at: idx)
                            }
                        }
                    } label: {
                        Text(LocalizedStringKey(routine.titleKey))
                            .environment(\.locale, Locale(identifier: settings.appLanguage))
                        Image(systemName: "trash")
                    }
                }
            } label: {
                Label(String(localized: String.LocalizationValue("routine.delete"), locale: Locale(identifier: settings.appLanguage)), systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .padding(8)
        }
    }
    
    private func loadRoutines() {
        if let decoded = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) {
            routines = decoded
        }
    }
    
    private func saveRoutines() {
        if let encoded = try? JSONEncoder().encode(routines) {
            customRoutinesData = encoded
        }
    }
}

// MARK: - Subcomponents

struct RoutineExpandableSection: View {
    @EnvironmentObject var settings: SettingsStore
    let titleKey: String
    let icon: String
    let color: Color
    let habits: [HabitModel]
    var routine: RoutineUIData? = nil
    var isCompleted: Bool = false
    var onHabitTap: ((HabitModel) -> Void)? = nil
    var onStart: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Item3DButton(
                farbe: color,
                sekundaerFarbe: color.darker(),
                groesse: 76,
                isRectangular: true,
                aktion: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        isExpanded.toggle()
                    }
                }
            ) {
                HStack(spacing: 16) {
                    // No icon on the left anymore
                    
                    Text(String(localized: String.LocalizationValue(titleKey), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if !habits.isEmpty {
                        Text(verbatim: "\(habits.count)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            
            if isExpanded {
                VStack(spacing: 12) {
                    if habits.isEmpty {
                        Text(String(localized: String.LocalizationValue("garden.empty.subtitle"), locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 16)
                    } else {
                        ForEach(habits) { pflanze in
                            RoutineHabitCard(pflanze: pflanze, routineReminderTime: routine?.reminderTime, onTap: {
                                onHabitTap?(pflanze)
                            })
                        }
                    }
                    
                    if onStart != nil || onEdit != nil {
                        HStack(spacing: 12) {
                            if let onEdit = onEdit {
                                Item3DButton(
                                    farbe: Color(white: 0.8),
                                    sekundaerFarbe: Color(white: 0.7),
                                    groesse: 56,
                                    isRectangular: true,
                                    aktion: onEdit
                                ) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .frame(width: 64)
                            }
                            
                            if let onStart = onStart, !habits.isEmpty {
                                if isCompleted {
                                    let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
                                    Item3DButton(
                                        farbe: Color(white: 0.8),
                                        sekundaerFarbe: Color(white: 0.7),
                                        groesse: 56,
                                        isRectangular: true,
                                        aktion: {}
                                    ) {
                                        HStack {
                                            Image(systemName: "clock.fill")
                                            Text(String(localized: String.LocalizationValue("routine.available_in"), locale: Locale(identifier: settings.appLanguage))) + Text(verbatim: " ") + Text(timerInterval: Date()...midnight)
                                        }
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    }
                                    .disabled(true)
                                } else {
                                    Item3DButton(
                                        farbe: Color.green,
                                        sekundaerFarbe: Color.green.darker(),
                                        groesse: 56,
                                        isRectangular: true,
                                        aktion: onStart
                                    ) {
                                        HStack {
                                            Image(systemName: "play.fill")
                                            Text(String(localized: String.LocalizationValue("routine.start"), locale: Locale(identifier: settings.appLanguage)))
                                        }
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

struct RoutineHabitCard: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    var routineReminderTime: Date? = nil
    var onTap: (() -> Void)? = nil
    
    var timeString: String? {
        let timeToShow = routineReminderTime ?? pflanze.nextActiveReminder?.time ?? pflanze.reminderTime
        guard let time = timeToShow else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var body: some View {
        Item3DButton(
            farbe: Color(white: 0.95),
            sekundaerFarbe: Color(white: 0.85),
            groesse: 76,
            isRectangular: true,
            aktion: {
                onTap?()
            }
        ) {
            HStack(spacing: 16) {

                
                // Plant Icon
                ZStack {
                    Image(pflanze.plantImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(pflanze.displayedHabitName), locale: Locale(identifier: settings.appLanguage)) : String(localized: String.LocalizationValue(pflanze.name), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(String(localized: String.LocalizationValue(pflanze.habitCategory.localizationKey), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Create Routine Sheet

struct CreateRoutineSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @Binding var routines: [RoutineUIData]
    let availableHabits: [HabitModel]
    
    @State private var routineName: String = ""
    @State private var selectedHabits: Set<String> = []
    @State private var selectedColor: String = "#AF52DE"
    @State private var selectedIcon: String = "star.fill"
    
    @State private var hasReminder: Bool = false
    @State private var schedule: ReminderSchedule = ReminderSchedule.defaultSchedule(time: Date())
    @State private var overrideIndividualReminders: Bool = true
    
    @State private var showTimerSheet = false
    @State private var showCustomTodoSheet = false
    
    let colors: [String] = ["#AF52DE", "#007AFF", "#32ADE6", "#00C7BE", "#34C759", "#FFCC00", "#FF9500", "#FF2D55", "#FF3B30", "#5856D6"]
    
    var displayedHabits: [HabitModel] {
        let newlyCreated = gardenStore.pflanzen.filter { $0.isRoutineOnly && selectedHabits.contains($0.id) }
        var all = availableHabits + newlyCreated
        var seen = Set<String>()
        return all.filter { if seen.contains($0.id) { return false } else { seen.insert($0.id); return true } }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 0) {
                            Text(String(localized: String.LocalizationValue("routine.pending"), locale: Locale(identifier: settings.appLanguage)))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            TextField(String(localized: String.LocalizationValue("routine.edit.name.placeholder"), locale: Locale(identifier: settings.appLanguage)), text: $routineName)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .padding(16)
                                .background(Color(white: 0.95))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(localized: String.LocalizationValue("routine.edit.color"), locale: Locale(identifier: settings.appLanguage)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(colors, id: \.self) { colorHex in
                                        let isSelected = selectedColor == colorHex
                                        let color = Color(hex: colorHex)
                                        Item3DButton(
                                            farbe: color,
                                            sekundaerFarbe: color.darker(),
                                            groesse: 56,
                                            isRectangular: false,
                                            aktion: {
                                                withAnimation { selectedColor = colorHex }
                                            }
                                        ) {
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundStyle(.white)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 8)
                                .padding(.top, 4)
                            }
                        }
                        
                        // Reminder Timer Edit Button
                        VStack(alignment: .leading) {
                            Text(String(localized: String.LocalizationValue("routine.edit.reminder"), locale: Locale(identifier: settings.appLanguage)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Button {
                                showTimerSheet = true
                            } label: {
                                HStack {
                                    Text(String(localized: String.LocalizationValue(hasReminder ? "routine.edit.timer.edit" : "routine.edit.timer.add"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(white: 0.95))
                                .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        
                        // Habit Selection
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(String(localized: String.LocalizationValue("routine.edit.habits.add"), locale: Locale(identifier: settings.appLanguage)))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Item3DButton(
                                    farbe: Color(hex: "#34C759"),
                                    sekundaerFarbe: Color(hex: "#34C759").darker(),
                                    groesse: 36,
                                    isRectangular: true,
                                    aktion: { showCustomTodoSheet = true }
                                ) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text(String(localized: "routine.todo.add", defaultValue: "Eigenes To-Do"))
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            if displayedHabits.isEmpty {
                                Text(String(localized: String.LocalizationValue("routine.edit.habits.empty"), locale: Locale(identifier: settings.appLanguage)))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 24)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(displayedHabits) { plant in
                                        SelectableHabitCard(
                                            pflanze: plant,
                                            isSelected: selectedHabits.contains(plant.id)
                                        ) {
                                            if selectedHabits.contains(plant.id) {
                                                selectedHabits.remove(plant.id)
                                            } else {
                                                selectedHabits.insert(plant.id)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle(String(localized: String.LocalizationValue("routine.create.title"), locale: Locale(identifier: settings.appLanguage)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: String.LocalizationValue("common.cancel"), locale: Locale(identifier: settings.appLanguage))) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: String.LocalizationValue("common.save"), locale: Locale(identifier: settings.appLanguage))) {
                        var newRoutine = RoutineUIData(
                            titleKey: routineName.isEmpty ? "routine.custom.default_name" : routineName,
                            icon: selectedIcon,
                            colorHex: selectedColor,
                            filterType: .custom,
                            assignedHabitIDs: Array(selectedHabits)
                        )
                        newRoutine.reminderSchedule = hasReminder ? schedule : nil
                        newRoutine.overrideIndividualReminders = overrideIndividualReminders
                        
                        withAnimation {
                            routines.append(newRoutine)
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(routineName.isEmpty ? .secondary : .primary)
                    .disabled(routineName.isEmpty)
                }
            }
            .sheet(isPresented: $showTimerSheet) {
                RoutineTimerEditSheetView(
                    routineName: routineName.isEmpty ? String(localized: String.LocalizationValue("routine.create.title"), locale: Locale(identifier: settings.appLanguage)) : routineName,
                    schedule: $schedule,
                    overrideIndividualReminders: $overrideIndividualReminders,
                    hasReminder: $hasReminder,
                    assignedHabits: availableHabits.filter { selectedHabits.contains($0.id) }
                )
                .environmentObject(settings)
            }
            .sheet(isPresented: $showCustomTodoSheet) {
                CreateRoutineCustomToDoSheet(selectedHabits: $selectedHabits)
            }
        }
    }
}

// MARK: - Routine Timer Edit Sheet
struct RoutineTimerEditSheetView: View {
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    let routineName: String
    @Binding var schedule: ReminderSchedule
    @Binding var overrideIndividualReminders: Bool
    @Binding var hasReminder: Bool
    var assignedHabits: [HabitModel]
    
    @State private var editingDayIndex: Int? = nil
    @State private var isAllDaysEqual: Bool = false
    
    @State private var isLinkingNotes: Bool = false
    @State private var selectedNoteForLinking: String? = nil
    @State private var selectedDaysForLinking: Set<Int> = []

    let daysKeys = ["days.monday", "days.tuesday", "days.wednesday", "days.thursday", "days.friday", "days.saturday", "days.sunday"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(String(localized: String.LocalizationValue("routine.timer"), locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text(String(localized: String.LocalizationValue(routineName), locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                if isLinkingNotes, let note = selectedNoteForLinking {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: "\(String(localized: "routine.note.assign")) \(note)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        Text(String(localized: "routine.note.assign.desc"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.orangePrimary.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
                
                // Toggle to turn off timer completely
                Toggle(isOn: $hasReminder.animation()) {
                    Text(String(localized: String.LocalizationValue("routine.reminder.activate"), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                if hasReminder {
                    // Days List
                    ScrollView {
                        VStack(spacing: 16) {
                            if isAllDaysEqual {
                                dayRow(for: 1, isSingleRow: true)
                            } else {
                                ForEach(1...7, id: \.self) { day in
                                    dayRow(for: day, isSingleRow: false)
                                }
                            }
                            
                            Toggle(isOn: $overrideIndividualReminders.animation()) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: String.LocalizationValue("routine.reminder.only_routine"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text(String(localized: String.LocalizationValue("routine.reminder.pause_individual"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.systemGray4))
                                        .offset(y: 4)
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                    }
                    .scrollDismissesKeyboard(.interactively)
                } else {
                    Spacer()
                }
            }
            .background(Color.appHintergrund.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isLinkingNotes {
                        Button {
                            withAnimation {
                                isLinkingNotes = false
                                selectedDaysForLinking.removeAll()
                                selectedNoteForLinking = nil
                            }
                        } label: {
                            Text(String(localized: "common.cancel"))
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.red)
                        }
                    } else {
                        Menu {
                            Button {
                                withAnimation {
                                    isAllDaysEqual.toggle()
                                    if isAllDaysEqual {
                                        applyToAllDays()
                                    }
                                }
                            } label: {
                                if isAllDaysEqual {
                                    Label(String(localized: "routine.timer.edit_individual", defaultValue: "Tage einzeln bearbeiten"), systemImage: "list.bullet")
                                } else {
                                    Label(String(localized: String.LocalizationValue("routine.timer.apply_all"), locale: Locale(identifier: settings.appLanguage)), systemImage: "doc.on.doc")
                                }
                            }
                            
                            let allNotes = Array(Set(assignedHabits.flatMap { $0.notizen })).sorted()
                            Menu {
                                if allNotes.isEmpty {
                                    Text(String(localized: "plant.detail.note.empty"))
                                } else {
                                    ForEach(allNotes, id: \.self) { notiz in
                                        Button(notiz) {
                                            withAnimation {
                                                selectedNoteForLinking = notiz
                                                isLinkingNotes = true
                                                editingDayIndex = nil
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Label(String(localized: "timer.note.link"), systemImage: "link")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isLinkingNotes {
                        Button {
                            withAnimation {
                                for day in selectedDaysForLinking {
                                    schedule.weekdays[dayIndex(for: day)].customMessage = selectedNoteForLinking
                                }
                                isLinkingNotes = false
                                selectedDaysForLinking.removeAll()
                                selectedNoteForLinking = nil
                            }
                        } label: {
                            Text(String(localized: "common.done_button"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .disabled(selectedDaysForLinking.isEmpty)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: String.LocalizationValue("common.done_button"), locale: Locale(identifier: settings.appLanguage)))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { editingDayIndex != nil },
            set: { if !$0 { editingDayIndex = nil } }
        )) {
            if let index = editingDayIndex {
                let isSingleRow = isAllDaysEqual
                TimerDayFullscreenEditView(
                    title: isSingleRow ? String(localized: "timer.notification.title") : String(localized: String.LocalizationValue(daysKeys[schedule.weekdays[index].weekday - 1]), locale: Locale(identifier: settings.appLanguage)),
                    exampleMessageName: String(localized: String.LocalizationValue(routineName), locale: Locale(identifier: settings.appLanguage)),
                    time: $schedule.weekdays[index].time,
                    customMessage: $schedule.weekdays[index].customMessage,
                    repeatMode: $schedule.weekdays[index].repeatMode,
                    isEnabled: $schedule.weekdays[index].isEnabled,
                    onDisable: {
                        if isSingleRow {
                            applyToAllDays()
                        }
                    }
                )
                .onDisappear {
                    if isSingleRow {
                        applyToAllDays()
                    }
                }
            }
        }
        .onAppear {
            let ref = schedule.weekdays[0]
            isAllDaysEqual = schedule.weekdays.allSatisfy { 
                $0.time == ref.time && 
                $0.customMessage == ref.customMessage && 
                $0.repeatMode == ref.repeatMode &&
                $0.isEnabled == ref.isEnabled
            }
        }
    }
    
    private func dayIndex(for day: Int) -> Int {
        schedule.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
    }
    
    @ViewBuilder
    private func dayRow(for day: Int, isSingleRow: Bool = false) -> some View {
        let index = dayIndex(for: day)
        let isEnabled = schedule.weekdays[index].isEnabled
        let isSelectedForLinking = selectedDaysForLinking.contains(day)
        
        VStack(spacing: 12) {
            Button {
                if isLinkingNotes {
                    if isEnabled {
                        withAnimation {
                            if selectedDaysForLinking.contains(day) {
                                selectedDaysForLinking.remove(day)
                            } else {
                                selectedDaysForLinking.insert(day)
                            }
                        }
                    }
                } else if !isEnabled {
                    withAnimation {
                        schedule.weekdays[index].isEnabled = true
                        if isSingleRow {
                            applyToAllDays()
                        }
                    }
                } else {
                    editingDayIndex = index
                }
            } label: {
                HStack(spacing: 12) {
                    if isLinkingNotes {
                        Image(systemName: isSelectedForLinking ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(isSelectedForLinking ? .orange : .secondary.opacity(0.3))
                    }
                    
                    Text(isSingleRow ? String(localized: "timer.notification.title") : String(localized: String.LocalizationValue(daysKeys[day-1]), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(isEnabled ? Color.primary : Color.secondary.opacity(0.5))
                    
                    Spacer()
                    
                    if isEnabled {
                        if !isLinkingNotes {
                            Text(timeFormatted(schedule.weekdays[index].time))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.primary)
                        }
                    } else {
                        Text(String(localized: String.LocalizationValue("routine.timer.off"), locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.6))
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.secondary.opacity(0.3))
                            .font(.system(size: 18))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PflanzeDetailListRowButtonStyle(isVisualPressed: false))
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(
            isLinkingNotes && isSelectedForLinking
                ? Color.orangePrimary.opacity(0.1)
                : nil
        )
    }
    
    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
    
    private func applyToAllDays() {
        let referenceDayIndex = 0
        let refTime = schedule.weekdays[referenceDayIndex].time
        let refMsg = schedule.weekdays[referenceDayIndex].customMessage
        let refMode = schedule.weekdays[referenceDayIndex].repeatMode
        let refEnabled = schedule.weekdays[referenceDayIndex].isEnabled
        
        withAnimation {
            for i in 0..<schedule.weekdays.count {
                schedule.weekdays[i].isEnabled = refEnabled
                schedule.weekdays[i].time = refTime
                schedule.weekdays[i].customMessage = refMsg
                schedule.weekdays[i].repeatMode = refMode
            }
        }
    }
}

struct SelectableHabitCard: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Item3DButton(
            farbe: Color(white: 0.98),
            sekundaerFarbe: Color(white: 0.90),
            groesse: 76,
            isRectangular: true,
            isPermanentlyPressed: isSelected,
            aktion: {
                // Haptic feedback for selection
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    action()
                }
            }
        ) {
            HStack(spacing: 16) {
                // Checkmark Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                    }
                }
                
                // Icon
                Image(pflanze.plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(pflanze.displayedHabitName), locale: Locale(identifier: settings.appLanguage)) : String(localized: String.LocalizationValue(pflanze.name), locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }
}

