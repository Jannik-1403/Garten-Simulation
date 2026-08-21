import SwiftUI

struct EditRoutineSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    @Binding var routine: RoutineUIData
    
    @State private var tempName: String
    @State private var tempColor: String
    @State private var assignedHabits: [HabitModel] = []
    @State private var habitsToRemoveTimers: [HabitModel] = []
    @State private var showHabitPicker = false
    
    @State private var hasReminder: Bool = false
    @State private var schedule: ReminderSchedule = ReminderSchedule.defaultSchedule(time: Date())
    @State private var overrideIndividualReminders: Bool = true
    @State private var showTimerSheet = false
    @State private var showCustomTodoSheet = false
    
    @State private var habitToEdit: HabitModel?
    @State private var isListEditing = false
    
    let colors: [String] = ["#AF52DE", "#007AFF", "#32ADE6", "#00C7BE", "#34C759", "#FFCC00", "#FF9500", "#FF2D55", "#FF3B30", "#5856D6"]
    
    let availableHabits: [HabitModel]
    
    init(routine: Binding<RoutineUIData>, availableHabits: [HabitModel]) {
        self._routine = routine
        self.availableHabits = availableHabits
        self._tempName = State(initialValue: routine.wrappedValue.titleKey)
        self._tempColor = State(initialValue: routine.wrappedValue.colorHex)
        self._hasReminder = State(initialValue: routine.wrappedValue.reminderSchedule != nil || routine.wrappedValue.reminderTime != nil)
        
        var sched = ReminderSchedule.defaultSchedule(time: Date())
        if let existing = routine.wrappedValue.reminderSchedule {
            sched = existing
        } else if let oldTime = routine.wrappedValue.reminderTime {
            sched = ReminderSchedule.defaultSchedule(time: oldTime)
        }
        self._schedule = State(initialValue: sched)
        self._overrideIndividualReminders = State(initialValue: routine.wrappedValue.overrideIndividualReminders)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                List {
                    // Header Section
                    Section {
                        VStack(alignment: .leading, spacing: 32) {
                            // Name Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "routine.edit.name"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                TextField(String(localized: "routine.edit.name.placeholder"), text: $tempName)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .padding(16)
                                    .background(Color(white: 0.95))
                                    .cornerRadius(16)
                            }
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "routine.edit.color"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(colors, id: \.self) { colorHex in
                                            let isSelected = tempColor == colorHex
                                            let color = Color(hex: colorHex)
                                            Item3DButton(
                                                farbe: color,
                                                sekundaerFarbe: color.darker(),
                                                groesse: 56,
                                                isRectangular: false,
                                                aktion: {
                                                    withAnimation { tempColor = colorHex }
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
                                    .padding(.bottom, 8)
                                    .padding(.top, 4)
                                }
                            }
                            
                            // Reminder Timer Edit Button
                            VStack(alignment: .leading) {
                                Text(String(localized: "routine.edit.reminder"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Button {
                                    showTimerSheet = true
                                } label: {
                                    HStack {
                                        Text(String(localized: String.LocalizationValue(hasReminder ? "routine.edit.timer.edit" : "routine.edit.timer.add")))
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
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    // Habit Reordering Header
                    Section {
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                Item3DButton(
                                    farbe: Color(hex: "#34C759"),
                                    sekundaerFarbe: Color(hex: "#34C759").darker(),
                                    groesse: 44,
                                    isRectangular: true,
                                    aktion: { showCustomTodoSheet = true }
                                ) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text(String(localized: "routine.todo.add.short", defaultValue: "To-do"))
                                            .lineLimit(1)
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                }
                                
                                if !availableHabits.isEmpty {
                                    Item3DButton(
                                        farbe: Color.white,
                                        sekundaerFarbe: Color(white: 0.90),
                                        groesse: 44,
                                        isRectangular: true,
                                        aktion: { showHabitPicker = true }
                                    ) {
                                        HStack {
                                            Image(systemName: "plus")
                                            Text(String(localized: "routine.habit.add.short", defaultValue: "Gewohnheit"))
                                                .lineLimit(1)
                                        }
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.primary)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    // Habits List
                    Section {
                        if assignedHabits.isEmpty {
                            Text(String(localized: "routine.edit.habits.none"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 24)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(assignedHabits) { habit in
                                HStack(spacing: 16) {
                                    Image(habit.plantImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                    
                                    Text(habit.isRoutineOnly ? String(localized: String.LocalizationValue(habit.displayedHabitName)) : (settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(habit.displayedHabitName)) : String(localized: String.LocalizationValue(habit.name))))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .listRowBackground(Color(white: 0.98))
                                .onTapGesture {
                                    if !isListEditing {
                                        habitToEdit = habit
                                    }
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                        withAnimation { isListEditing = true }
                                    }
                                )
                            }
                            .onMove(perform: moveHabits)
                            .onDelete(perform: deleteHabits)
                            .deleteDisabled(!isListEditing)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(isListEditing ? .active : .inactive))
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "common.edit", defaultValue: "Bearbeiten"))
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        routine.titleKey = tempName
                        routine.colorHex = tempColor
                        routine.assignedHabitIDs = assignedHabits.map { $0.id }
                        routine.reminderSchedule = hasReminder ? schedule : nil
                        routine.overrideIndividualReminders = overrideIndividualReminders
                        
                        // Process removed dynamic habits
                        for habit in habitsToRemoveTimers {
                            gardenStore.timerEntfernen(pflanze: habit)
                        }
                        
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .onAppear {
                if tempName.hasPrefix("routine.") {
                    tempName = String(localized: String.LocalizationValue(tempName))
                }
                
                // Populate assigned habits correctly ordered
                if routine.filterType == .custom {
                    assignedHabits = routine.assignedHabitIDs.compactMap { id in
                        gardenStore.pflanzen.first(where: { $0.id == id })
                    }
                } else {
                    assignedHabits = gardenStore.pflanzen.filter { routine.contains(habit: $0) }
                }
            }
            .sheet(isPresented: $showTimerSheet) {
                RoutineTimerEditSheetView(
                    routineName: tempName.isEmpty ? String(localized: "routine.default_name", defaultValue: "Routine") : tempName,
                    schedule: $schedule,
                    overrideIndividualReminders: $overrideIndividualReminders,
                    hasReminder: $hasReminder,
                    assignedHabits: assignedHabits
                )
                .environmentObject(settings)
            }
            .sheet(isPresented: $showHabitPicker) {
                NavigationStack {
                    ZStack {
                        Color.appHintergrund.ignoresSafeArea()
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(availableHabits) { plant in
                                    if !isHabitAssigned(plant) {
                                        Button {
                                            if !isHabitAssigned(plant) {
                                                assignedHabits.append(plant)
                                            }
                                            showHabitPicker = false
                                        } label: {
                                            HStack(spacing: 16) {
                                                Image(plant.plantImageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 48, height: 48)
                                                if settings.showHabitInsteadOfName {
                                                    Text(String(localized: String.LocalizationValue(plant.displayedHabitName)))
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.primary)
                                                } else {
                                                    Text(String(localized: String.LocalizationValue(plant.name)))
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.primary)
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color(white: 0.95))
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }
                            .padding(24)
                        }
                    }
                    .navigationTitle(String(localized: "routine.edit.habit.add_single"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(String(localized: "common.close")) {
                                showHabitPicker = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showCustomTodoSheet) {
                CreateRoutineCustomToDoSheetWrapper(assignedHabits: $assignedHabits)
            }
            .alert(
                String(localized: String.LocalizationValue(habitToEdit?.isRoutineOnly == true ? "routine.edit.task.title" : "routine.edit.habit.title")),
                isPresented: Binding(
                    get: { habitToEdit != nil },
                    set: { if !$0 { habitToEdit = nil } }
                )
            ) {
                TextField(habitToEdit?.isRoutineOnly == true ? String(localized: "routine.edit.task.placeholder", defaultValue: "Aufgabe") : String(localized: "routine.edit.habit.placeholder", defaultValue: "Gewohnheit"), text: Binding(
                    get: { habitToEdit?.customRoutineTaskName ?? "" },
                    set: { newValue in
                        if let h = habitToEdit {
                            h.customRoutineTaskName = newValue
                            if h.isRoutineOnly {
                                h.habitName = newValue
                            }
                        }
                    }
                ))
                
                if habitToEdit?.isRoutineOnly == true {
                    TextField(String(localized: "routine.todo.description.placeholder", defaultValue: "Beschreibung (Optional)"), text: Binding(
                        get: { habitToEdit?.symbolism ?? "" },
                        set: { newValue in
                            if let h = habitToEdit {
                                h.symbolism = newValue
                            }
                        }
                    ))
                }
                
                Button(String(localized: "common.save", defaultValue: "Speichern")) {
                    gardenStore.savePlants()
                    habitToEdit = nil
                }
                Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) {
                    habitToEdit = nil
                }
            } message: {
                Text(habitToEdit?.isRoutineOnly == true ? String(localized: "routine.edit.task.message", defaultValue: "Gib einen neuen Aufgabennamen und optional eine Beschreibung ein.") : String(localized: "routine.edit.habit.message", defaultValue: "Gib der Gewohnheit für diese Routine einen neuen Namen."))
            }
        }
    }
    
    private func isHabitAssigned(_ plant: HabitModel) -> Bool {
        assignedHabits.contains(where: { $0.id == plant.id })
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        assignedHabits.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        if routine.filterType != .custom {
            for index in offsets {
                habitsToRemoveTimers.append(assignedHabits[index])
            }
        }
        assignedHabits.remove(atOffsets: offsets)
    }
}

// Wrapper to sync Set<String> with [HabitModel] for EditRoutineSheet
struct CreateRoutineCustomToDoSheetWrapper: View {
    @Binding var assignedHabits: [HabitModel]
    @State private var tempSelectedHabits: Set<String> = []
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        CreateRoutineCustomToDoSheet(selectedHabits: $tempSelectedHabits)
            .onAppear {
                tempSelectedHabits = Set(assignedHabits.map { $0.id })
            }
            .onChange(of: tempSelectedHabits) { _, newSet in
                // Find newly added habits in gardenStore and append them
                for habitID in newSet {
                    if !assignedHabits.contains(where: { $0.id == habitID }),
                       let newHabit = gardenStore.pflanzen.first(where: { $0.id == habitID }) {
                        assignedHabits.append(newHabit)
                    }
                }
            }
    }
}
