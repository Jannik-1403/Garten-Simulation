import SwiftUI
import Combine

struct PflanzeDetailSheet: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) private var dismiss
    var onLoeschen: (() -> Void)? = nil
    var dismissEntireFlow: (() -> Void)? = nil

    @State private var zeigeVerkaufenDialog = false
    @State private var zeigeFocusSession = false
    @State private var zeigeNotizSheet = false
    @State private var zeigeTodoSheet = false
    @State private var todoToEditIndex: Int? = nil
    @State private var todoToDeleteIndex: Int? = nil
    @State private var isNotesExpanded = false
    @State private var isTodosExpanded = true
    @State private var isEffectsExpanded = true
    @State private var isRemindersExpanded = true
    @State private var selectedTimerEntry: TimerEntry? = nil
    @State private var zeigeTimerSheet = false
    @State private var zeigeTimerEditSheet = false
    @State private var pulsieren = false
    @State private var zeigeTimerAbbrechenDialog = false
    @State private var noteToEditIndex: Int? = nil
    @State private var showGoalWeightSheet = false
    @ObservedObject private var goalStore = GoalStore.shared
    @State private var noteToDeleteIndex: Int? = nil
    @State private var ausgewaehlterEffekt: PflanzenEffekt? = nil
    // History tab removed – only Overview shown
    @State private var pfadBereit: Bool = false
    @State private var zeigePaywall = false
    @State private var hourlyHealthData: [(Date, Double)] = []
    @State private var weeklyHealthAverage: Double? = nil
    @State private var hourlyAvgData: [(Date, Double)] = []
    @State private var showTargetEdit = false
    @State private var zeigeDeleteTrackerConfirm = false
    @State private var zeigeCustomTrackerAlert = false
    @State private var zeigeTrackerConfirm = false
    @State private var customTrackerInputName = ""
    @ObservedObject private var healthManager = HealthManager.shared
    @FocusState private var isTargetFocused: Bool
    
    @State private var screenTimeHours: Int = 2
    @State private var screenTimeMinutes: Int = 0
    @State private var showScreenTimeConfirm = false
    @State private var isEditingScreenTime = false
    
    @AppStorage("customRoutinesData", store: SharedUserDefaults.suite) private var customRoutinesData: Data = Data()
    
    private var parentRoutineWithReminder: RoutineUIData? {
        guard let routines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) else { return nil }
        return routines.first(where: { routine in
            routine.contains(habit: pflanze) && (routine.reminderSchedule != nil || routine.reminderTime != nil)
        })
    }



    private var activeStateID: String {
        "\(pflanze.id)-\(pflanze.wiederbelebtAm?.description ?? "none")"
    }

    private var aktiveEffekte: [PflanzenEffekt] {
        var effekte: [PflanzenEffekt] = []

        // 1. Status-Effekte (Stable ID)
        if pflanze.isPenaltyActive {
            let expiration = pflanze.wiederbelebtAm?.addingTimeInterval(Double(pflanze.strafTage) * 24 * 3600)
            effekte.append(PflanzenEffekt(
                id: UUID(uuidString: "77777777-7777-7777-7777-000000000001")!,
                typ: .status,
                ikonQuelle: .asset("Schildkröte"),
                titel: String(localized: "effekt.erholung.titel"),
                beschreibung: String(localized: "effekt.erholung.beschreibung"),
                expiresAt: expiration
            ))
        }




        return Array(effekte)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 28) {
                // MARK: - OVERVIEW CONTENT
                Section {


                // MARK: - ACTIONS (Zone 3)
                VStack(spacing: 12) {
                    
                    // Apple Health Integration (Pro Feature)
                    healthKitConfigSection

                    // To-Dos Accordion
                    DisclosureGroup(isExpanded: $isTodosExpanded) {
                        VStack(spacing: 12) {
                            ForEach(pflanze.todos.sorted { $0.priority.sortValue < $1.priority.sortValue }, id: \.id) { todo in
                                TodoRowView(
                                    pflanze: pflanze,
                                    todoId: todo.id,
                                    onEdit: {
                                        if let index = pflanze.todos.firstIndex(where: { $0.id == todo.id }) {
                                            todoToEditIndex = index
                                            zeigeTodoSheet = true
                                        }
                                    }
                                )
                            }
                            
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Text(String(localized: "plant.detail.todos_header", defaultValue: "To-Dos"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Item3DButton(
                                farbe: .gruenPrimary,
                                sekundaerFarbe: .gruenPrimary.darker(),
                                groesse: 36,
                                isRectangular: false,
                                aktion: {
                                    todoToEditIndex = nil
                                    zeigeTodoSheet = true
                                }
                            ) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    .padding(.horizontal, 24)
                    .tint(.gruenPrimary)
                    
                    // Notizen Accordion
                    DisclosureGroup(isExpanded: $isNotesExpanded) {
                        VStack(spacing: 8) {
                            // Snapshot der Notizen – verhindert Index-out-of-range beim Löschen
                            let noteSnapshot = Array(pflanze.notizen.enumerated())
                            ForEach(noteSnapshot, id: \.offset) { (index, noteText) in
                                // Nur rendern wenn Index noch gültig ist
                                if index < pflanze.notizen.count {
                                    NoteRowView(
                                        pflanze: pflanze,
                                        index: index,
                                        onTap: {
                                            noteToEditIndex = index
                                            zeigeNotizSheet = true
                                        },
                                        onDelete: {
                                            noteToDeleteIndex = index
                                        },
                                        deleteConfirmShowing: Binding(
                                            get: { noteToDeleteIndex == index },
                                            set: { if !$0 { noteToDeleteIndex = nil } }
                                        ),
                                        onConfirmDelete: {
                                            guard index < pflanze.notizen.count else { return }
                                            gardenStore.notizEntfernen(pflanze: pflanze, index: index)
                                            noteToDeleteIndex = nil
                                        },
                                        onCancelDelete: {
                                            noteToDeleteIndex = nil
                                        }
                                    )
                                }
                            }
                            
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack {
                            Text(String(localized: "plant.detail.notes_header", defaultValue: "Notizen"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            Item3DButton(
                                farbe: .blauPrimary,
                                sekundaerFarbe: .blauPrimary.darker(),
                                groesse: 36,
                                isRectangular: false,
                                aktion: {
                                    noteToEditIndex = nil
                                    zeigeNotizSheet = true
                                }
                            ) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    .padding(.horizontal, 24)
                    .tint(.blauPrimary)

                    // MARK: - Daily Reminders
                    DisclosureGroup(isExpanded: $isRemindersExpanded) {
                        VStack(spacing: 8) {
                            if let schedule = pflanze.reminderSchedule, !schedule.entries.isEmpty {
                                TimerRowView(
                                    schedule: schedule,
                                    onTap: { 
                                        zeigeTimerEditSheet = true 
                                    },
                                    onConfirmDelete: { gardenStore.timerEntfernen(pflanze: pflanze) }
                                )
                            } else {
                                Text(String(localized: "plant.detail.no_reminders", defaultValue: "Keine Erinnerungen"))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    } label: {
                        HStack {
                            Text(String(localized: "plant.detail.timer", defaultValue: "Daily Reminder"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Spacer()
                            let hatBereitsTimer = !(pflanze.reminderSchedule?.entries.isEmpty ?? true)
                            if !hatBereitsTimer {
                                Item3DButton(
                                    farbe: .blauPrimary,
                                    sekundaerFarbe: .blauPrimary.darker(),
                                    groesse: 36,
                                    isRectangular: false,
                                    aktion: { zeigeTimerEditSheet = true }
                                ) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    .padding(.horizontal, 24)
                    .tint(.blauPrimary)

                    // MARK: - Ziel-Punkte Banner
                    GoalPointsBannerView(pflanze: pflanze, goalStore: goalStore)
                        .padding(.top, 16)

                    HStack(spacing: 40) {
                        // Focus Session Button
                        VStack(spacing: 8) {
                            Item3DButton(
                                farbe: .orangePrimary,
                                sekundaerFarbe: .orangePrimary.darker(),
                                groesse: 54,
                                isRectangular: false,
                                aktion: { zeigeFocusSession = true }
                            ) {
                                Image("Timer full")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                            .tourAnchor(.focusTimer)
                            .id(TourStep.focusTimer)
                            
                            Text(String(localized: "focus.session.start", defaultValue: "Fokus-Session starten"))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .padding(.top, 16)



                    // Verkaufen-Button (Roter Text)
                    Button {
                        zeigeVerkaufenDialog = true
                    } label: {
                        Text(String(localized: "plant.detail.sell"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }

                } // End of Section
            }
            } // End of ScrollView
            .onChange(of: interactiveTourManager.currentStep) { _, newStep in
                withAnimation(.spring()) {
                    if newStep == .focusTimer {
                        proxy.scrollTo(TourStep.focusTimer, anchor: .bottom)
                    }
                }
            }
            } // End of ScrollViewReader
        }
        .navigationTitle(settings.showHabitInsteadOfName ? NSLocalizedString(pflanze.displayedHabitName, comment: "") : NSLocalizedString(pflanze.name, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        // Zeige standard X nur, wenn wir keinen dismissEntireFlow haben
        .standardNavigationX(show: dismissEntireFlow == nil && !isTargetFocused)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let dismissEntireFlow = dismissEntireFlow, !isTargetFocused {
                    Button {
                        dismissEntireFlow()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.tertiary)
                    }
                } else if isTargetFocused {
                    Button {
                        isTargetFocused = false
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            // Wenn linkedHealthMetric noch nil ist (Toggle wurde entfernt), automatisch setzen
            if pflanze.linkedHealthMetric == nil, let autoMetric = pflanze.automaticHealthMetric {
                pflanze.linkedHealthMetric = autoMetric
                gardenStore.savePlants()
            }
            let effectiveMetric = pflanze.linkedHealthMetric
            if let metric = effectiveMetric {
                healthManager.fetchHourlyData(for: metric) { data in
                    self.hourlyHealthData = data
                }
                healthManager.fetchWeeklyAverage(for: metric) { avg in
                    self.weeklyHealthAverage = avg
                }
                healthManager.fetchHourlyWeeklyAverage(for: metric) { avg in
                    self.hourlyAvgData = avg
                }
            }
            
            // Auto-Watering check
            gardenStore.checkHealthTargets(healthManager: healthManager)
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulsieren = true
            }
            if pflanze.habitName == "habit.bildschirmzeit" {
                let totalMins = Int(pflanze.customTrackerTarget ?? 120.0)
                screenTimeHours = totalMins / 60
                screenTimeMinutes = totalMins % 60
            }
        }
        // MARK: - Verkaufen Dialog
        .confirmationDialog(
            String(localized: "plant.detail.sell.confirm"),
            isPresented: $zeigeVerkaufenDialog,
            titleVisibility: .visible
        ) {
            let actualPrice = iapStore.isProUser ? Int(Double(pflanze.basePrice) * GameConstants.proUnlockDiscount) : pflanze.basePrice
            let refund = Int(Double(actualPrice) * 0.5)
            Button("\(String(localized: "plant.detail.sell.action")) (+\(refund) \(String(localized: "common.coins")))", role: .destructive) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                let sellTitle = settings.showHabitInsteadOfName 
                    ? NSLocalizedString(pflanze.habitName, comment: "")
                    : NSLocalizedString(pflanze.name, comment: "")
                shopStore.sell(id: pflanze.id, price: actualPrice, title: sellTitle)
                onLoeschen?()
            }
            Button(String(localized: "button.cancel"), role: .cancel) { }
        }
        // MARK: - Notiz Sheet
        .sheet(isPresented: $zeigeNotizSheet) {
            NotizSheetView(pflanze: pflanze, editIndex: noteToEditIndex)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(Color(UIColor.systemBackground))
        }
        // MARK: - Timer Create Sheet
        .sheet(isPresented: $zeigeTimerSheet, onDismiss: { selectedTimerEntry = nil }) {
            TimerCreateSheetView(pflanze: pflanze, entryToEdit: selectedTimerEntry)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .environmentObject(iapStore)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(Color(UIColor.systemBackground))
        }
        // MARK: - Timer Edit Sheet
        .fullScreenCover(isPresented: $zeigeTimerEditSheet) {
            NavigationStack {
                TimerEditSheetView(pflanze: pflanze)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
            }
        }

        // MARK: - Todo Sheet
        .sheet(isPresented: $zeigeTodoSheet) {
            TodoSheetView(pflanze: pflanze, editIndex: todoToEditIndex)
        }
        
        // MARK: - Notiz Bearbeiten: Direkt Sheet öffnen (kein Dialog mehr)
        .onChange(of: noteToEditIndex) { _, newIndex in
            if newIndex != nil {
                zeigeNotizSheet = true
            }
        }

        // MARK: - Effekt Detail Sheet
        .sheet(item: $ausgewaehlterEffekt) { effekt in
            EffektDetailSheet(effekt: effekt)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $zeigeFocusSession) {
            FocusSessionView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
        }
        .sheet(isPresented: $showTargetEdit) {
            HealthTargetEditSheet(
                target: Binding(
                    get: { pflanze.healthTarget },
                    set: { newVal in
                        pflanze.healthTarget = newVal
                        gardenStore.savePlants()
                    }
                ),
                unitString: {
                    switch pflanze.linkedHealthMetric {
                    case .steps: return String(localized: "health.unit.steps", defaultValue: "Schritte")
                    case .water: return String(localized: "health.unit.water", defaultValue: "ml")
                    default:     return String(localized: "health.unit.hours", defaultValue: "Std")
                    }
                }()
            )
        }
                        }
                        .fullScreenCover(isPresented: $zeigePaywall) {
                            PaywallView()
                                .environmentObject(iapStore)
                        }
                    }
                    @ViewBuilder
                    private var healthKitConfigSection: some View {
                        VStack(spacing: 12) {
                            Group {
                                if iapStore.isProUser {
                                    // --- STATISTIKEN (Pro Feature) ---
                                    if pflanze.automaticHealthMetric == nil && pflanze.linkedHealthMetric == nil {
                                        IntradayProgressChartView(
                                            history: pflanze.intradayProgressHistory,
                                            target: pflanze.healthTarget,
                                            onEditTarget: { showTargetEdit = true }
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 4)
                                    }
                                        
                                    if let autoMetric = pflanze.automaticHealthMetric {
                                        // --- APPLE HEALTH SECTION ---
                                        VStack(spacing: 0) {
                                            // effectiveMetric: linked oder automatic
                                            let effectiveMetric = pflanze.linkedHealthMetric ?? pflanze.automaticHealthMetric
                                            if let metric = effectiveMetric, !hourlyHealthData.isEmpty {
                                                HealthChartView(
                                                    data: hourlyHealthData,
                                                    metric: metric,
                                                    target: pflanze.healthTarget,
                                                    hourlyAverageData: hourlyAvgData,
                                                    onEditTarget: { showTargetEdit = true }
                                                )
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 4)
                                            } else {
                                                // Laden-Indikator
                                                HStack {
                                                    Spacer()
                                                    VStack(spacing: 8) {
                                                        ProgressView()
                                                        Text(String(localized: "health.chart.loading", defaultValue: "Lade Gesundheitsdaten…"))
                                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    Spacer()
                                                }
                                                .padding(40)
                                            }
                                        }
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text(String(localized: "apple.health.title", defaultValue: "Apple Health Kopplung"))
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                            Spacer()
                                        }
                                        .padding(.horizontal, 24)
                                        
                                        Item3DButton(
                                            farbe: Color.goldPrimary,
                                            sekundaerFarbe: Color(red: 0.7, green: 0.5, blue: 0.0), // Dunkelgold
                                            groesse: 56,
                                            isRectangular: true,
                                            aktion: {
                                                zeigePaywall = true
                                            }
                                        ) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "lock.fill")
                                                    .font(.system(size: 18, weight: .bold))
                                                
                                                Text(String(localized: "apple.health.pro_locked", defaultValue: "Grovy Pro Feature"))
                                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 16)
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                        }
                        .padding(.bottom, 8)
                    }
                }

    private func sicherstellenDassPfadExistiert() {
        pfadBereit = true
    }


    



}

// MARK: - Flame Streak Button



// MARK: - Todo Sheet
struct TodoSheetView: View {
    @ObservedObject var pflanze: HabitModel
    var editIndex: Int? = nil

    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) private var dismiss

    @State private var todoText: String = ""

    var isEditing: Bool { editIndex != nil }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEditing ? String(localized: "plant.detail.todo.edit", defaultValue: "To-Do bearbeiten") : String(localized: "plant.detail.todo.add", defaultValue: "To-Do hinzufügen"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text(NSLocalizedString(pflanze.displayedHabitName, comment: ""))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.top, 20)

            // Text Input
            TextField(String(localized: "plant.detail.todo.placeholder", defaultValue: "To-Do eingeben..."), text: $todoText, axis: .vertical)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .frame(minHeight: 140, alignment: .topLeading)
                .contentShape(Rectangle())
                .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))

            Spacer()

            // Save Button
            Button {
                let trimmed = todoText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                if let idx = editIndex {
                    pflanze.todos[idx].text = trimmed
                } else {
                    let newTodo = FocusGoal(text: trimmed)
                    pflanze.todos.append(newTodo)
                }
                gardenStore.savePlants()
                gardenStore.objectWillChange.send()
                dismiss()
            } label: {
                Text(String(localized: "common.save"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
            }
            .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: .gruenPrimary, shadowColor: .gruenPrimary.darker(), foregroundColor: .white))
            .disabled(todoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .onAppear {
            if let idx = editIndex, pflanze.todos.indices.contains(idx) {
                todoText = pflanze.todos[idx].text
            }
        }
    }
}

// MARK: - Notiz Sheet
struct NotizSheetView: View {
    @ObservedObject var pflanze: HabitModel
    var editIndex: Int? = nil // Wenn nil -> Neuanlage, sonst Index zum Bearbeiten

    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var notizText: String = ""

    var isEditing: Bool { editIndex != nil }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString(isEditing ? "plant.detail.note.edit" : "plant.detail.note.add", comment: ""))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        Text(settings.showHabitInsteadOfName 
                             ? NSLocalizedString(pflanze.habitName, comment: "")
                             : NSLocalizedString(pflanze.name, comment: ""))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.blauPrimary)
            }
            .padding(.top, 20)

            // Text Editor
            TextEditor(text: $notizText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .scrollContentBackground(.hidden)
                .padding(16)
                .frame(minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if notizText.isEmpty {
                        Text(String(localized: "plant.detail.note.placeholder"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }

            Spacer()

            // Speichern Button
            Button {
                if let index = editIndex {
                    gardenStore.notizAktualisieren(pflanze: pflanze, index: index, text: notizText)
                } else {
                    gardenStore.notizHinzufuegen(pflanze: pflanze, text: notizText)
                }
                dismiss()
            } label: {
                Text(NSLocalizedString(isEditing ? "plant.detail.note.save" : "plant.detail.note.add.action", comment: ""))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .blauPrimary,
                shadowColor: .blauPrimary.darker()
            ))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .onAppear {
            if let index = editIndex, index >= 0 && index < pflanze.notizen.count {
                notizText = pflanze.notizen[index]
            }
        }
    }
}

// MARK: - Timer Edit Sheet
struct TimerEditSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) private var dismiss

    @State private var schedule: ReminderSchedule = ReminderSchedule.defaultSchedule(time: Date())
    
    // UI States
    @State private var editingDayIndex: Int? = nil
    @State private var isAllDaysEqual: Bool = false
    @State private var isLinkingNotes: Bool = false
    @State private var selectedDaysForLinking: Set<Int> = []
    @State private var selectedNoteForLinking: String? = nil


    let daysKeys = ["days.monday", "days.tuesday", "days.wednesday", "days.thursday", "days.friday", "days.saturday", "days.sunday"]
    
    @AppStorage("customRoutinesData", store: SharedUserDefaults.suite) private var customRoutinesData: Data = Data()
    
    private var parentRoutineWithReminder: RoutineUIData? {
        guard let routines = try? JSONDecoder().decode([RoutineUIData].self, from: customRoutinesData) else { return nil }
        return routines.first(where: { routine in
            routine.contains(habit: pflanze) && (routine.reminderSchedule != nil || routine.reminderTime != nil)
        })
    }
    private var pflanzName: String {
        settings.showHabitInsteadOfName
            ? NSLocalizedString(pflanze.habitName, comment: "")
            : NSLocalizedString(pflanze.name, comment: "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(String(localized: "plant.detail.timer"))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                        Text(pflanzName)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .background(Color.appHintergrund.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isLinkingNotes {
                        Button {
                            // Bestätigen der Verknüpfung
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
                            autoSave()
                            dismiss()
                        } label: {
                            Text(String(localized: "common.done_button"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                }

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
                            if parentRoutineWithReminder == nil {
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
                                        Label(String(localized: "routine.timer.apply_all"), systemImage: "doc.on.doc")
                                    }
                                }
                                
                                // 1. Notizen verknüpfen Sub-Menu
                                Menu {
                                    if pflanze.notizen.isEmpty {
                                        Text(String(localized: "plant.detail.note.empty"))
                                    } else {
                                        ForEach(pflanze.notizen, id: \.self) { notiz in
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
                                
                                // 2. Wiederholung für alle Sub-Menu
                                Menu {
                                    ForEach(ReminderRepeatMode.allCases, id: \.self) { mode in
                                        Button {
                                            withAnimation {
                                                for i in 0..<schedule.weekdays.count {
                                                    if schedule.weekdays[i].isEnabled {
                                                        schedule.weekdays[i].repeatMode = mode
                                                    }
                                                }
                                            }
                                        } label: {
                                            Label(NSLocalizedString(mode.localizationKey, comment: ""), systemImage: mode.sfSymbol)
                                        }
                                    }
                                } label: {
                                    Label(String(localized: "timer.repeat.title"), systemImage: "repeat")
                                }
                            }
                            
                            if parentRoutineWithReminder == nil {
                                // 4. Löschen
                                Button(role: .destructive) {
                                    gardenStore.timerEntfernen(pflanze: pflanze)
                                    dismiss()
                                } label: {
                                    Label(String(localized: "plant.detail.timer.delete"), systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary)
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
                    title: isSingleRow ? String(localized: "timer.notification.title") : NSLocalizedString(daysKeys[schedule.weekdays[index].weekday - 1], comment: ""),
                    exampleMessageName: pflanzName,
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
            if let existing = pflanze.reminderSchedule {
                schedule = existing
            } else if let legacyTime = pflanze.reminderTime {
                schedule = ReminderSchedule.defaultSchedule(time: legacyTime, customMessage: pflanze.customReminderMessage)
            } else {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                components.hour = 8
                components.minute = 0
                let defaultTime = Calendar.current.date(from: components) ?? Date()
                schedule = ReminderSchedule.defaultSchedule(time: defaultTime)
            }
            
            let ref = schedule.weekdays[0]
            isAllDaysEqual = schedule.weekdays.allSatisfy { 
                $0.time == ref.time && 
                $0.customMessage == ref.customMessage && 
                $0.repeatMode == ref.repeatMode &&
                $0.isEnabled == ref.isEnabled
            }
        }
        .onChange(of: schedule) { _, _ in
            autoSave()
        }
    }
    
    private func dayIndex(for day: Int) -> Int {
        schedule.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
    }
    
    private func routineOverrides(day: Int) -> Bool {
        guard let routine = parentRoutineWithReminder, routine.overrideIndividualReminders else {
            return false
        }
        if let sched = routine.reminderSchedule {
            let index = sched.weekdays.firstIndex(where: { $0.weekday == day }) ?? 0
            return sched.weekdays[index].isEnabled
        }
        return true
    }
    
    private func applyToAllDays() {
        let refTime = schedule.weekdays[0].time
        let refMsg = schedule.weekdays[0].customMessage
        let refMode = schedule.weekdays[0].repeatMode
        let refEnabled = schedule.weekdays[0].isEnabled
        
        withAnimation {
            for i in 0..<schedule.weekdays.count {
                schedule.weekdays[i].isEnabled = refEnabled
                schedule.weekdays[i].time = refTime
                schedule.weekdays[i].customMessage = refMsg
                schedule.weekdays[i].repeatMode = refMode
            }
        }
    }
    
    @ViewBuilder
    private func dayRow(for day: Int, isSingleRow: Bool = false) -> some View {
        let index = dayIndex(for: day)
        let isEnabled = schedule.weekdays[index].isEnabled
        let isOverridden = routineOverrides(day: day)
        let isSelectedForLinking = selectedDaysForLinking.contains(day)
        
        VStack(spacing: 12) {
            // Header Row (Tap to expand/link)
            Button {
                if isOverridden { return }
                if isLinkingNotes {
                    if isEnabled {
                        withAnimation {
                            if isSelectedForLinking {
                                selectedDaysForLinking.remove(day)
                            } else {
                                selectedDaysForLinking.insert(day)
                            }
                        }
                    }
                } else {
                    if !isEnabled {
                        withAnimation {
                            schedule.weekdays[index].isEnabled = true
                            if isSingleRow {
                                applyToAllDays()
                            }
                        }
                    } else {
                        editingDayIndex = index
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    if isLinkingNotes {
                        Image(systemName: isSelectedForLinking ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(isSelectedForLinking ? Color.orangePrimary : Color.secondary.opacity(0.3))
                    }
                    
                    Text(isSingleRow ? String(localized: "timer.notification.title") : NSLocalizedString(daysKeys[day-1], comment: ""))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle((isEnabled && !isOverridden) ? Color.primary : Color.secondary.opacity(0.5))
                    
                    Spacer()
                    
                    if isOverridden {
                        HStack(spacing: 4) {
                            if let routineName = parentRoutineWithReminder?.titleKey {
                                Text(NSLocalizedString(routineName, comment: ""))
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: parentRoutineWithReminder!.colorHex))
                            }
                            Text(String(localized: "routine.timer.paused"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary.opacity(0.6))
                        }
                    } else if isEnabled {
                        if !isLinkingNotes {
                            Text(timeFormatted(schedule.weekdays[index].time))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.primary)
                        }
                    } else {
                        Text(String(localized: "routine.timer.off"))
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

    private func autoSave() {
        Task {
            let status = await NotificationManager.shared.checkAuthorizationStatus()
            if status == .denied {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    await UIApplication.shared.open(url)
                }
            } else {
                gardenStore.timerScheduleSetzen(pflanze: pflanze, schedule: schedule)
            }
        }
    }
}

// MARK: - Timer Create Sheet
struct TimerCreateSheetView: View {
    @ObservedObject var pflanze: HabitModel
    var entryToEdit: TimerEntry?
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) private var dismiss

    @State private var showCalendarSheet = false
    @State private var zeigePaywall = false

    @State private var ausgewaehlteZeit: Date

    init(pflanze: HabitModel, entryToEdit: TimerEntry? = nil) {
        self.pflanze = pflanze
        self.entryToEdit = entryToEdit
        
        if let entry = entryToEdit {
            _ausgewaehlteZeit = State(initialValue: entry.time)
        } else {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 8
            components.minute = 0
            _ausgewaehlteZeit = State(initialValue: Calendar.current.date(from: components) ?? Date())
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(String(localized: "plant.detail.timer.set"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Spacer()
                
                Button {
                    if iapStore.isProUser {
                        showCalendarSheet = true
                    } else {
                        zeigePaywall = true
                    }
                } label: {
                    if iapStore.isProUser {
                        Image(systemName: "calendar")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.primary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                            Image(systemName: "calendar")
                                .font(.system(size: 22, weight: .bold))
                        }
                        .foregroundStyle(Color.goldPrimary)
                    }
                }

            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            DatePicker("", selection: $ausgewaehlteZeit, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()

            Button {
                Task {
                    let status = await NotificationManager.shared.checkAuthorizationStatus()
                    if status == .denied {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            await UIApplication.shared.open(url)
                        }
                    } else {
                        if let entryToEdit = entryToEdit {
                            gardenStore.timerEintragEntfernen(pflanze: pflanze, entryID: entryToEdit.id)
                        }
                        gardenStore.timerSetzen(pflanze: pflanze, datum: ausgewaehlteZeit)
                        dismiss()
                    }
                }
            } label: {
                Text(String(localized: "plant.detail.timer.set"))
            }
            .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .orangePrimary, shadowColor: .orangePrimary.darker()))
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.appHintergrund.ignoresSafeArea())
        .dropDestination(for: CalendarEventPayload.self) { items, location in
            guard let first = items.first else { return false }
            ausgewaehlteZeit = first.startDate
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return true
        }
        .sheet(isPresented: $showCalendarSheet) {
            CalendarEventsSheet { event in
                ausgewaehlteZeit = event.startDate
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .fullScreenCover(isPresented: $zeigePaywall) {
            PaywallView()
        }

    }
}



// MARK: - StatLabelView
struct StatLabelView: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 32, weight: .bold))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(1.2)
        }
    }
}

// MARK: - PlantWeeklyStreakView
struct PlantWeeklyStreakView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    private let calendar = Calendar.current
    private var weekdays: [String] {
        [
            String(localized: "common.mon"),
            String(localized: "common.tue"),
            String(localized: "common.wed"),
            String(localized: "common.thu"),
            String(localized: "common.fri"),
            String(localized: "common.sat"),
            String(localized: "common.sun")
        ]
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(weekdays[index])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    let dayXP = getXP(for: index)
                    
                    ZStack {
                        // Schatten/Tiefe (nur wenn aktiv)
                        if dayXP > 0 {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 38, height: 38)
                                .offset(y: 3)
                        }
                        
                        // Haupt-Bubble
                        Circle()
                            .fill(dayXP > 0 ? Color.white : Color.white.opacity(0.15))
                            .frame(width: 38, height: 38)
            
                        if dayXP > 0 {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.orangePrimary)
                        }
                    }
                    .frame(width: 38, height: 41) // Platz für Schatten reservieren
                    
                    Text(dayXP > 0 ? "+\(dayXP) \(String(localized: "common.xp"))" : " ")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(dayXP > 0 ? .white : .clear)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func getXP(for index: Int) -> Int {
        let today = calendar.startOfDay(for: Date())
        let currentWeekday = calendar.component(.weekday, from: today)
        var normalizedToday = currentWeekday - 2
        if normalizedToday < 0 { normalizedToday = 6 } 
        
        let daysToSubtract = normalizedToday - index
        guard let targetDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = formatter.string(from: targetDate)
        
        return pflanze.xpHistory[key] ?? 0
    }
}

// MARK: - List Row 3D Button Style
struct PflanzeDetailListRowButtonStyle: ButtonStyle {
    var isVisualPressed: Bool = false
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.systemGray4))
                        .offset(y: isPressed ? 0 : 4)
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                }
            )
            .offset(y: isPressed ? 4 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
            .sensoryFeedback(trigger: isPressed) { _, newValue in
                (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
            }
    }
}

// MARK: - Note Row (own State for isVisualPressed animation)
struct NoteRowView: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let index: Int
    let onTap: () -> Void
    let onDelete: () -> Void
    let deleteConfirmShowing: Binding<Bool>
    let onConfirmDelete: () -> Void
    let onCancelDelete: () -> Void 

    @State private var isVisualPressed = false
    @State private var deletePressed = false

    var body: some View {
        Item3DButton(
            farbe: Color.white,
            sekundaerFarbe: Color(white: 0.9),
            groesse: 64,
            isRectangular: true,
            aktion: {
                onTap()
            }
        ) {
            HStack(spacing: 12) {
                Image("Notizen")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .scaleEffect(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "\(String(localized: "plant.detail.note")) \(index + 1)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    // Sicherer Zugriff – verhindert Crash bei gleichzeitigem Delete
                    if index < pflanze.notizen.count {
                        Text(pflanze.notizen[index])
                            .lineLimit(2)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                }

                Spacer()

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture().onEnded { onDelete() }
                    )
            }
        }
        .confirmationDialog(
            String(localized: "plant.detail.note.delete.confirm"),
            isPresented: deleteConfirmShowing,
            titleVisibility: .visible
        ) {
            Button(String(localized: "plant.detail.note.delete.action"), role: .destructive) {
                onConfirmDelete()
            }
            Button(String(localized: "button.cancel"), role: .cancel) {
                onCancelDelete()
            }
        }
    }
}

// MARK: - Timer Row (own State for isVisualPressed animation)
struct TimerRowView: View {
    @EnvironmentObject var settings: SettingsStore
    let schedule: ReminderSchedule
    let onTap: () -> Void
    let onConfirmDelete: () -> Void

    @State private var isVisualPressed = false
    @State private var deleteConfirmShowing = false

    var body: some View {
        // The entire row (including X) lives in one Button so everything animates together.
        Button {
            isVisualPressed = true
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isVisualPressed = false
                onTap()
            }
        } label: {
            HStack(spacing: 12) {
                Image("Erinnerung")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .scaleEffect(2.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "plant.detail.timer.active", defaultValue: "Täglicher Reminder"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    if schedule.entries.count > 1 {
                        Text(String(localized: "plant.detail.timer.multiple_times", defaultValue: "Verschiedene Zeiten"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    } else if let firstEntry = schedule.entries.first {
                        Text(firstEntry.time, style: .time)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                }
                Spacer()

                // X delete button — inside the label so it moves with the card.
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture().onEnded { deleteConfirmShowing = true }
                    )
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
        }
        .buttonStyle(PflanzeDetailListRowButtonStyle(isVisualPressed: isVisualPressed))
        .confirmationDialog(
            String(localized: "plant.detail.timer.cancel.confirm"),
            isPresented: $deleteConfirmShowing,
            titleVisibility: .visible
        ) {
            Button(String(localized: "plant.detail.timer.cancel.action"), role: .destructive) {
                onConfirmDelete()
            }
            Button(String(localized: "button.cancel"), role: .cancel) { }
        }
    }
}

// MARK: - Streak Card Button Style
// Mirrors PflanzenCardButtonStyle: responds to BOTH configuration.isPressed (hold)
// and isVisualPressed (quick tap) so the animation is always visible.
struct StreakCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let isVisualPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || isVisualPressed

        ZStack {
            // 3D Shadow
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.orangeSecondary)

            // Main Orange Surface
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.orangePrimary, .orangePrimary.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .overlay(configuration.label)
                .offset(y: isPressed ? 0 : -4)
        }
        .offset(y: isPressed ? 4 : 0)
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}

// MARK: - Timer Day Fullscreen Edit View
struct TimerDayFullscreenEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    
    @State private var showCalendarSheet = false
    @State private var zeigePaywall = false
    
    let title: String
    let exampleMessageName: String
    
    @Binding var time: Date
    @Binding var customMessage: String?
    @Binding var repeatMode: ReminderRepeatMode
    @Binding var isEnabled: Bool
    
    var onDisable: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    DatePicker(
                        "",
                        selection: $time,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 200)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "timer.notification.title"))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        TextField(String(format: String(localized: "timer.preview.body.example"), exampleMessageName),
                                  text: Binding(
                                      get: { customMessage ?? "" },
                                      set: { customMessage = $0.isEmpty ? nil : $0 }
                                  ))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "timer.repeat.title"))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            
                        Picker("", selection: $repeatMode) {
                            ForEach(ReminderRepeatMode.allCases, id: \.self) { mode in
                                Text(NSLocalizedString(mode.localizationKey, comment: "")).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            isEnabled = false
                        }
                        onDisable?()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text(String(localized: "routine.timer.disable"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .padding(.top, 16)
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            if iapStore.isProUser {
                                showCalendarSheet = true
                            } else {
                                zeigePaywall = true
                            }
                        } label: {
                            if iapStore.isProUser {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color.primary)
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 14))
                                    Image(systemName: "calendar")
                                        .font(.system(size: 20, weight: .bold))
                                }
                                .foregroundStyle(Color.goldPrimary)
                            }
                        }
                        
                        Button(String(localized: "common.done_button")) {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
            }
            .dropDestination(for: CalendarEventPayload.self) { items, location in
                guard let first = items.first else { return false }
                
                customMessage = first.title
                time = first.startDate
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                return true
            }
            .sheet(isPresented: $showCalendarSheet) {
                CalendarEventsSheet { event in
                    customMessage = event.title
                    time = event.startDate
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .fullScreenCover(isPresented: $zeigePaywall) {
                PaywallView()
            }

        }
    }
}

// MARK: - Export Notes Selection
struct ExportNotesSelectionSheet: View {
    let currentHabitId: String?
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) private var dismiss
    
    enum SelectionMode {
        case all
        case current
        case custom
    }
    
    @State private var selectionMode: SelectionMode = .current
    @State private var selectedPlantIds: Set<String> = []
    @State private var selectedBadHabitIds: Set<String> = []
    
    // For sharing
    @State private var generatedPDFUrl: URL? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(String(localized: "export.selection.title", defaultValue: "Notizen exportieren"))
                            .font(.system(size: 26, weight: .black, design: .rounded))
                        
                        Text(String(localized: "export.selection.subtitle", defaultValue: "Wähle, welche Notizen exportiert werden sollen."))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    
                    // Options
                    VStack(spacing: 12) {
                        if currentHabitId != nil {
                            optionRow(
                                title: String(localized: "export.selection.only_this", defaultValue: "Nur diese Notizen"),
                                mode: .current
                            )
                        }
                        
                        optionRow(
                            title: String(localized: "export.selection.all", defaultValue: "Alle Notizen"),
                            mode: .all
                        )
                        
                        optionRow(
                            title: String(localized: "export.selection.custom", defaultValue: "Auswahl..."),
                            mode: .custom
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Custom Selection List
                    if selectionMode == .custom {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                let goodHabits = gardenStore.pflanzen.filter { !$0.notizen.isEmpty }
                                if !goodHabits.isEmpty {
                                    Text(String(localized: "pdf.notes.good_habits", defaultValue: "Gute Gewohnheiten"))
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 4)
                                    
                                    ForEach(goodHabits) { plant in
                                        let name = settings.showHabitInsteadOfName ? NSLocalizedString(plant.displayedHabitName, comment: "") : NSLocalizedString(plant.name, comment: "")
                                        toggleRow(
                                            title: name,
                                            icon: "leaf.fill",
                                            iconColor: .gruenPrimary,
                                            isSelected: selectedPlantIds.contains(plant.id),
                                            action: {
                                                if selectedPlantIds.contains(plant.id) {
                                                    selectedPlantIds.remove(plant.id)
                                                } else {
                                                    selectedPlantIds.insert(plant.id)
                                                }
                                            }
                                        )
                                    }
                                }
                                
                                let badHabitsWithNotes = gardenStore.badHabitNotes.filter { !$0.value.isEmpty }.map { $0.key }
                                if !badHabitsWithNotes.isEmpty {
                                    Text(String(localized: "pdf.notes.bad_habits", defaultValue: "Schlechte Gewohnheiten"))
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 4)
                                        .padding(.top, 12)
                                    
                                    ForEach(badHabitsWithNotes, id: \.self) { id in
                                        toggleRow(
                                            title: getBadHabitName(id: id),
                                            icon: "xmark.circle.fill",
                                            iconColor: .red,
                                            isSelected: selectedBadHabitIds.contains(id),
                                            action: {
                                                if selectedBadHabitIds.contains(id) {
                                                    selectedBadHabitIds.remove(id)
                                                } else {
                                                    selectedBadHabitIds.insert(id)
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                        }
                    } else {
                        Spacer()
                    }
                    
                    // Export Button
                    Button {
                        generateAndShare()
                    } label: {
                        Text(String(localized: "export.selection.generate", defaultValue: "PDF Exportieren"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: .blauPrimary,
                        shadowColor: .blauPrimary.darker()
                    ))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .disabled(selectionMode == .custom && selectedPlantIds.isEmpty && selectedBadHabitIds.isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "button.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if currentHabitId == nil {
                    selectionMode = .all
                }
            }
        }
    }
    
    private func optionRow(title: String, mode: SelectionMode) -> some View {
        let isSelected = selectionMode == mode
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectionMode = mode
            }
        } label: {
            ZStack {
                // 3D Schatten-Ebene
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.blauPrimary.darker() : Color(hex: "#C7C7CC"))
                // Top-Ebene
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.blauPrimary : Color.white)
                    .offset(y: -3)
                    .overlay(
                        HStack {
                            Text(title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(isSelected ? .white : .primary)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? .white : .secondary)
                                .font(.system(size: 20))
                        }
                        .padding(.horizontal, 16)
                        .offset(y: -3)
                    )
            }
            .frame(height: 56)
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isSelected)
    }
    
    private func toggleRow(title: String, icon: String, iconColor: Color = .blauPrimary, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                // 3D Schatten-Ebene
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.blauPrimary.opacity(0.4) : Color(hex: "#C7C7CC"))
                // Top-Ebene
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.blauPrimary.opacity(0.12) : Color.white)
                    .offset(y: -2.5)
                    .overlay(
                        HStack(spacing: 12) {
                            Item3DButton(
                                icon: icon,
                                farbe: iconColor,
                                sekundaerFarbe: iconColor.darker(),
                                groesse: 34,
                                iconSkalierung: 0.55
                            )
                            Text(title)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                .foregroundColor(isSelected ? .blauPrimary : .secondary)
                                .font(.system(size: 20))
                        }
                        .padding(.horizontal, 12)
                        .offset(y: -2.5)
                    )
            }
            .frame(height: 52)
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isSelected)
    }
    
    private func getBadHabitName(id: String) -> String {
        let finalName: String
        if let badHabit = gardenStore.placedDecorations.first(where: { $0.id == id }) ?? GameDatabase.allDecorations.first(where: { $0.id == id }) {
            let key = settings.showHabitInsteadOfName ? badHabit.habitNameKey : badHabit.objectNameKey
            finalName = NSLocalizedString(key, comment: "")
        } else {
            finalName = NSLocalizedString(id, comment: "")
        }
        return finalName.hasPrefix("trash.custom_") ? String(localized: "plant.create.preview.bad_habit") : finalName
    }
    
    private func generateAndShare() {
        var pIds: Set<String>? = nil
        var bIds: Set<String>? = nil
        
        switch selectionMode {
        case .all:
            pIds = nil
            bIds = nil
        case .current:
            if let cid = currentHabitId {
                if gardenStore.pflanzen.contains(where: { $0.id == cid }) {
                    pIds = [cid]
                    bIds = []
                } else {
                    pIds = []
                    bIds = [cid]
                }
            }
        case .custom:
            pIds = selectedPlantIds
            bIds = selectedBadHabitIds
        }
        
        if let url = PDFExportManager.shared.generatePDF(
            for: pIds,
            badHabitIds: bIds,
            gardenStore: gardenStore,
            settings: settings,
            streakStore: streakStore,
            assessmentStore: AssessmentStore(),
            includeGoodHabits: true,
            includeNotes: true,
            includeTimer: false,
            includeStatistics: false,
            includeQuizResults: false,
            includeBadHabits: false,
            includeRoutines: false
        ) {
            generatedPDFUrl = url
            PDFExportManager.share(items: [url])
        }
    }
}


struct ScreenTimePickerSheet: View {
    @Binding var screenTimeHours: Int
    @Binding var screenTimeMinutes: Int
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        HStack {
                            Picker(String(localized: "common.hours", defaultValue: "Stunden"), selection: $screenTimeHours) {
                                ForEach(0...23, id: \.self) { h in
                                    Text("\(h) \(String(localized: "common.hours.short", defaultValue: "Std."))").tag(h)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .clipped()
                            
                            Picker(String(localized: "common.minutes", defaultValue: "Minuten"), selection: $screenTimeMinutes) {
                                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { m in
                                    Text("\(m) \(String(localized: "common.minutes.short", defaultValue: "Min."))").tag(m)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .clipped()
                        }
                    } footer: {
                        Text(String(localized: "screentime.tracker.form_footer", defaultValue: "Wähle das tägliche Bildschirmzeit-Ziel aus."))
                    }
                }
                .scrollDisabled(true)
                
                VStack {
                    Button {
                        onSave()
                        isPresented = false
                    } label: {
                        Text(String(localized: "common.save", defaultValue: "Speichern"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(14)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(Item3DButtonStyle(farbe: .orange, sekundaerFarbe: .orange.darker(), groesse: 50, iconSkalierung: 1.0, shadowDepthFactor: 0.08, isRectangular: true, isPermanentlyPressed: false, isDisabled: false))
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
                .padding(.top, 16)
                .background(Color(UIColor.systemGroupedBackground))
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(String(localized: "screentime.tracker.confirm_title", defaultValue: "Limit speichern?"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}
