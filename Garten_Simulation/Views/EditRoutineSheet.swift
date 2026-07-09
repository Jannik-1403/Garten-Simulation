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
                
                VStack(spacing: 0) {
                    ScrollView {
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
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text(String(localized: "routine.edit.color"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 24)
                                
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
                                    .padding(.horizontal, 24)
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
                            
                            // Habit Reordering (List)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(String(localized: String.LocalizationValue(routine.filterType == .custom ? "routine.edit.habits.reorder" : "routine.edit.habits.included"), locale: Locale(identifier: settings.appLanguage)))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Button {
                                        showCustomTodoSheet = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text(String(localized: "routine.todo.add", defaultValue: "Eigenes To-Do"))
                                        }
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.green)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.15))
                                        .clipShape(Capsule())
                                    }
                                    if !availableHabits.isEmpty {
                                        Button {
                                            showHabitPicker = true
                                        } label: {
                                            Image(systemName: "list.bullet.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundStyle(Color.green)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                
                                if assignedHabits.isEmpty {
                                    Text(String(localized: "routine.edit.habits.none"))
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 24)
                                } else {
                                    List {
                                        if routine.filterType == .custom {
                                            ForEach(assignedHabits) { habit in
                                                HStack(spacing: 16) {
                                                    Image(habit.plantImageName)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 32, height: 32)
                                                    
                                                    Text(settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(habit.displayedHabitName), locale: Locale(identifier: settings.appLanguage)) : String(localized: String.LocalizationValue(habit.name), locale: Locale(identifier: settings.appLanguage)))
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                }
                                                .padding(.vertical, 4)
                                                .listRowBackground(Color(white: 0.98))
                                            }
                                            .onMove(perform: moveHabits)
                                            .onDelete(perform: deleteHabits)
                                        } else {
                                            ForEach(assignedHabits) { habit in
                                                HStack(spacing: 16) {
                                                    Image(habit.plantImageName)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 32, height: 32)
                                                    
                                                    Text(settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(habit.displayedHabitName), locale: Locale(identifier: settings.appLanguage)) : String(localized: String.LocalizationValue(habit.name), locale: Locale(identifier: settings.appLanguage)))
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                }
                                                .padding(.vertical, 4)
                                                .listRowBackground(Color(white: 0.98))
                                            }
                                            .onMove(perform: moveHabits)
                                            .onDelete(perform: deleteHabits)
                                        }
                                    }
                                    .frame(height: max(200, CGFloat(assignedHabits.count * 60 + 40))) // Dynamic height approximation
                                    .listStyle(.plain)
                                    .scrollDisabled(true)
                                    .environment(\.editMode, .constant(.active))
                                }
                            }
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "routine.edit.title"))
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
                    tempName = String(localized: String.LocalizationValue(tempName), locale: Locale(identifier: settings.appLanguage))
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
                    routineName: tempName.isEmpty ? "Routine" : tempName,
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
                                                    Text(String(localized: String.LocalizationValue(plant.displayedHabitName), locale: Locale(identifier: settings.appLanguage)))
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                        .foregroundStyle(.primary)
                                                } else {
                                                    Text(String(localized: String.LocalizationValue(plant.name), locale: Locale(identifier: settings.appLanguage)))
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
                // Here we need to map the Set<String> of selected habits back to [HabitModel] 
                // but since assignedHabits is an array of HabitModels in this view, 
                // we'll pass a binding to a temporary set, and then sync it.
                CreateRoutineCustomToDoSheetWrapper(assignedHabits: $assignedHabits)
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
