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
    
    var color: Color {
        Color(hex: colorHex)
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
    
    @AppStorage("customRoutinesData") private var customRoutinesData: Data = Data()
    
    @State private var routines: [RoutineUIData] = []
    
    @State private var showCreateSheet = false
    
    // All scheduled habits
    private var timelinePlants: [HabitModel] {
        gardenStore.pflanzen.filter { $0.hasActiveReminder && $0.nextActiveReminder != nil }
    }

    func habits(for routine: RoutineUIData) -> [HabitModel] {
        switch routine.filterType {
        case .morning:
            return timelinePlants.filter {
                let h = Calendar.current.component(.hour, from: $0.nextActiveReminder!.time)
                return h >= 5 && h < 12
            }
        case .afternoon:
            return timelinePlants.filter {
                let h = Calendar.current.component(.hour, from: $0.nextActiveReminder!.time)
                return h >= 12 && h < 17
            }
        case .evening:
            return timelinePlants.filter {
                let h = Calendar.current.component(.hour, from: $0.nextActiveReminder!.time)
                return h >= 17 || h < 5
            }
        case .custom:
            return gardenStore.pflanzen.filter { routine.assignedHabitIDs.contains($0.id) }
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
        return gardenStore.pflanzen.filter { !displayedIDs.contains($0.id) }
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
                            ForEach(routines) { routine in
                                RoutineExpandableSection(
                                    titleKey: routine.titleKey,
                                    icon: routine.icon,
                                    color: routine.color,
                                    habits: habits(for: routine),
                                    routine: routine,
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
                        }
                        .padding(.top, 24)
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .navigationTitle(settings.localizedString(for: "tab.routines"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showCreateSheet = true
                        } label: {
                            Label(settings.localizedString(for: "routine.create"), systemImage: "plus")
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
                                    Text(settings.localizedString(for: routine.titleKey))
                                    Image(systemName: "trash")
                                }
                            }
                        } label: {
                            Label("Routine löschen", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .padding(8)
                    }
                }
            }
            .standardNavigationX()
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
                    EditRoutineSheet(routine: $routines[idx])
                } else {
                    EmptyView()
                }
            }
            .fullScreenCover(item: $routineToPlay) { item in
                RoutineSessionView(routine: item, habits: habits(for: item))
            }
            .onAppear {
                loadRoutines()
            }
            .onChange(of: routines) { newValue in
                saveRoutines()
            }
        }
    }
    
    private func loadRoutines() {
        if let decoded = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) {
            routines = decoded
        }
        if routines.isEmpty {
            routines = [
                RoutineUIData(titleKey: "routine.morning", icon: "sun.max.fill", colorHex: "#FF9500", filterType: .morning),
                RoutineUIData(titleKey: "routine.gym", icon: "figure.run", colorHex: "#FF3B30", filterType: .afternoon),
                RoutineUIData(titleKey: "routine.evening", icon: "moon.stars.fill", colorHex: "#5856D6", filterType: .evening)
            ]
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
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32)
                    
                    Text(settings.localizedString(for: titleKey))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if !habits.isEmpty {
                        Text("\(habits.count)")
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
                        Text(settings.localizedString(for: "garden.empty.subtitle"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 16)
                    } else {
                        ForEach(habits) { pflanze in
                            RoutineHabitCard(pflanze: pflanze, routineReminderTime: routine?.reminderTime, onTap: {
                                onHabitTap?(pflanze)
                            })
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
                                
                                if let onStart = onStart {
                                    Item3DButton(
                                        farbe: Color.green,
                                        sekundaerFarbe: Color.green.darker(),
                                        groesse: 56,
                                        isRectangular: true,
                                        aktion: onStart
                                    ) {
                                        HStack {
                                            Image(systemName: "play.fill")
                                            Text("Starten")
                                        }
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
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
                // Time indicator (only if exists)
                if let t = timeString {
                    VStack {
                        Text(t)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(white: 0.9))
                            .clipShape(Capsule())
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    
                    Divider()
                        .frame(height: 30)
                }
                
                // Plant Icon
                ZStack {
                    Image(pflanze.plantImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(settings.localizedString(for: pflanze.habitCategory.localizationKey))
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
    
    let colors: [String] = ["#AF52DE", "#007AFF", "#32ADE6", "#00C7BE", "#34C759", "#FFCC00", "#FF9500", "#FF2D55", "#FF3B30", "#5856D6"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Name Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Name der Routine")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            TextField("z.B. Mittagspause", text: $routineName)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .padding(16)
                                .background(Color(white: 0.95))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Farbe")
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
                            Text("Erinnerung")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            Button {
                                showTimerSheet = true
                            } label: {
                                HStack {
                                    Text(hasReminder ? "Timer bearbeiten" : "Timer hinzufügen")
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
                            Text("Gewohnheiten hinzufügen")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                            
                            if availableHabits.isEmpty {
                                Text("Du hast aktuell keine freien Gewohnheiten ohne Routine.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 24)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(availableHabits) { plant in
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
            .navigationTitle("Neue Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        var newRoutine = RoutineUIData(
                            titleKey: routineName.isEmpty ? "Eigene Routine" : routineName,
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
                    routineName: routineName.isEmpty ? "Neue Routine" : routineName,
                    schedule: $schedule,
                    overrideIndividualReminders: $overrideIndividualReminders,
                    hasReminder: $hasReminder
                )
                .environmentObject(settings)
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
    
    @State private var expandedDay: Int? = nil
    @FocusState private var focusedDay: Int?

    let daysKeys = ["days.monday", "days.tuesday", "days.wednesday", "days.thursday", "days.friday", "days.saturday", "days.sunday"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Timer")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        Text(settings.localizedString(for: routineName))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Toggle to turn off timer completely
                Toggle(isOn: $hasReminder.animation()) {
                    Text("Erinnerung aktivieren")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                if hasReminder {
                    // Days List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(1...7, id: \.self) { day in
                                dayRow(for: day)
                            }
                            
                            Toggle(isOn: $overrideIndividualReminders.animation()) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Nur Routine-Erinnerung")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text("Pausiert individuelle Pflanzen-Timer")
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
                ToolbarItem(placement: .topBarTrailing) {
                    if focusedDay != nil {
                        Button {
                            focusedDay = nil
                        } label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text(settings.localizedString(for: "common.done_button"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }
            }
        }
    }
    
    private func dayIndex(for day: Int) -> Int {
        schedule.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
    }
    
    @ViewBuilder
    private func dayRow(for day: Int) -> some View {
        let index = dayIndex(for: day)
        let isEnabled = schedule.weekdays[index].isEnabled
        let isExpanded = expandedDay == day
        
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)) {
                    if !isEnabled {
                        schedule.weekdays[index].isEnabled = true
                        expandedDay = day
                    } else {
                        if expandedDay == day {
                            expandedDay = nil
                            focusedDay = nil
                        } else {
                            expandedDay = day
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(settings.localizedString(for: daysKeys[day-1]))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(isEnabled ? Color.primary : Color.secondary.opacity(0.5))
                    
                    Spacer()
                    
                    if isEnabled {
                        Text(timeFormatted(schedule.weekdays[index].time))
                            .font(.system(size: 16, weight: isExpanded ? .bold : .semibold, design: .rounded))
                            .foregroundStyle(Color.primary)
                        
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14, weight: isExpanded ? .bold : .medium))
                    } else {
                        Text("Ausgeschaltet")
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
            
            if isExpanded {
                expandedContent(for: index, day: day)
            }
        }
    }
    
    @ViewBuilder
    private func expandedContent(for index: Int, day: Int) -> some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.horizontal, 16)
            
            DatePicker(
                "",
                selection: Binding(
                    get: { schedule.weekdays[index].time },
                    set: { newTime in
                        schedule.weekdays[index].time = newTime
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(height: 150)
            .clipped()
            
            // Message Field
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.localizedString(for: "timer.notification.title"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                TextField(String(format: settings.localizedString(for: "timer.preview.body.example"), settings.localizedString(for: routineName)),
                          text: Binding(
                              get: { schedule.weekdays[index].customMessage ?? "" },
                              set: { schedule.weekdays[index].customMessage = $0.isEmpty ? nil : $0 }
                          ))
                    .focused($focusedDay, equals: day)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // Repeat Mode
            VStack(alignment: .leading, spacing: 6) {
                Text(settings.localizedString(for: "timer.repeat.title"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    
                Picker("", selection: $schedule.weekdays[index].repeatMode) {
                    ForEach(ReminderRepeatMode.allCases, id: \.self) { mode in
                        Text(settings.localizedString(for: mode.localizationKey)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Deaktivieren Button
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    schedule.weekdays[index].isEnabled = false
                    if expandedDay == day {
                        expandedDay = nil
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Deaktivieren")
                }
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
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
    
    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
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
                    Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name))
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

