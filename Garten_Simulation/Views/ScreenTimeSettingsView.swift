import SwiftUI
import FamilyControls

// MARK: - Main View

struct ScreenTimeSettingsView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("hasRequestedScreenTimeAuth") private var hasRequestedAuth: Bool = false
    
    @State private var isScheduleActive: Bool = false
    @State private var daySchedules: [Int: DaySchedule] = [:]
    @State private var expandedDay: Int? = nil
    
    @State private var isPickerPresented = false
    @State private var blockSelection = FamilyActivitySelection()
    @State private var oldBlockSelection = FamilyActivitySelection()
    
    @State private var isDailyLimitPickerPresented = false
    @State private var dailyLimitSelection = FamilyActivitySelection()
    @State private var oldDailyLimitSelection = FamilyActivitySelection()
    
    @State private var showEbene2ConfirmAlert: Bool = false
    @State private var pendingEbene2Selection: FamilyActivitySelection? = nil
    
    @State private var isPermanentPickerPresented = false
    @State private var permanentBlockSelection = FamilyActivitySelection()
    @State private var oldPermanentBlockSelection = FamilyActivitySelection()
    @State private var isAdultFilterEnabled = false
    
    @State private var showWalkOfShame = false
    
    @State private var showConfirmAlert = false
    @State private var pendingLimitAction: (() -> Void)? = nil
    
    // Weekday data: (weekdayInt, shortName, fullName)
    let allWeekdays: [(Int, String, String)] = [
        (2, "Mo", String(localized: "weekday.monday", defaultValue: "Montag")),
        (3, "Di", String(localized: "weekday.tuesday", defaultValue: "Dienstag")),
        (4, "Mi", String(localized: "weekday.wednesday", defaultValue: "Mittwoch")),
        (5, "Do", String(localized: "weekday.thursday", defaultValue: "Donnerstag")),
        (6, "Fr", String(localized: "weekday.friday", defaultValue: "Freitag")),
        (7, "Sa", String(localized: "weekday.saturday", defaultValue: "Samstag")),
        (1, "So", String(localized: "weekday.sunday", defaultValue: "Sonntag"))
    ]
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            settingsScrollView
        }
        .navigationTitle(String(localized: "screenTime.title.short", defaultValue: "Zeit"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "common.done", defaultValue: "Fertig")) {
                    saveSettings()
                    dismiss()
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.gruenPrimary)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                    dismiss()
                }
                .font(.system(size: 16, weight: .regular, design: .rounded))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !hasRequestedAuth {
                Task {
                    await manager.requestAuthorization()
                    hasRequestedAuth = true
                }
            }
            isScheduleActive = manager.isScheduleActive
            blockSelection = manager.blockSelection
            oldBlockSelection = manager.blockSelection
            
            dailyLimitSelection = manager.dailyLimitSelection
            oldDailyLimitSelection = manager.dailyLimitSelection
            permanentBlockSelection = manager.permanentBlockSelection
            oldPermanentBlockSelection = manager.permanentBlockSelection
            
            isAdultFilterEnabled = manager.isAdultFilterEnabled
            daySchedules = manager.daySchedules
        }
        .onChange(of: dailyLimitSelection) { newValue in
            var enforcedSelection = newValue
            
            // Verhindern, dass etwas abgewählt wird (Wegklicken)
            enforcedSelection.applicationTokens.formUnion(oldDailyLimitSelection.applicationTokens)
            enforcedSelection.categoryTokens.formUnion(oldDailyLimitSelection.categoryTokens)
            enforcedSelection.webDomainTokens.formUnion(oldDailyLimitSelection.webDomainTokens)
            
            // Wenn in Ebene 1 ausgewählt, aus Ebene 2 entfernen
            var newPermanent = permanentBlockSelection
            newPermanent.applicationTokens.subtract(enforcedSelection.applicationTokens)
            newPermanent.categoryTokens.subtract(enforcedSelection.categoryTokens)
            newPermanent.webDomainTokens.subtract(enforcedSelection.webDomainTokens)
            if newPermanent != permanentBlockSelection {
                permanentBlockSelection = newPermanent
                oldPermanentBlockSelection = newPermanent
            }
            
            if dailyLimitSelection != enforcedSelection {
                dailyLimitSelection = enforcedSelection
            }
            oldDailyLimitSelection = enforcedSelection
            
            // Sync limitSelections AFTER the picker changes so new tokens
            // get properly initialized. Uses same token instances → no mismatch.
            manager.syncLimitsAfterPickerChange()
        }
        .onChange(of: blockSelection) { newValue in
            var enforcedSelection = newValue
            
            // Wenn wir in der aktiven Block-Zeit sind, darf man nichts abwählen (wegmachen)
            if manager.isCurrentlyInBlockWindow {
                enforcedSelection.applicationTokens.formUnion(oldBlockSelection.applicationTokens)
                enforcedSelection.categoryTokens.formUnion(oldBlockSelection.categoryTokens)
                enforcedSelection.webDomainTokens.formUnion(oldBlockSelection.webDomainTokens)
            }
            
            // Wenn in Zeitleiste ausgewählt, aus Ebene 2 (permanentBlockSelection) entfernen
            var newPermanent = permanentBlockSelection
            newPermanent.applicationTokens.subtract(enforcedSelection.applicationTokens)
            newPermanent.categoryTokens.subtract(enforcedSelection.categoryTokens)
            newPermanent.webDomainTokens.subtract(enforcedSelection.webDomainTokens)
            if newPermanent != permanentBlockSelection {
                permanentBlockSelection = newPermanent
                oldPermanentBlockSelection = newPermanent
            }
            
            if blockSelection != enforcedSelection {
                blockSelection = enforcedSelection
            }
            oldBlockSelection = enforcedSelection
        }
        .onChange(of: permanentBlockSelection) { newValue in
            var enforcedSelection = newValue
            
            // Verhindern, dass etwas abgewählt wird (Wegklicken)
            enforcedSelection.applicationTokens.formUnion(oldPermanentBlockSelection.applicationTokens)
            enforcedSelection.categoryTokens.formUnion(oldPermanentBlockSelection.categoryTokens)
            enforcedSelection.webDomainTokens.formUnion(oldPermanentBlockSelection.webDomainTokens)
            
            let hasNewItems = !enforcedSelection.applicationTokens.isSubset(of: oldPermanentBlockSelection.applicationTokens) ||
                              !enforcedSelection.categoryTokens.isSubset(of: oldPermanentBlockSelection.categoryTokens) ||
                              !enforcedSelection.webDomainTokens.isSubset(of: oldPermanentBlockSelection.webDomainTokens)
                              
            if hasNewItems {
                pendingEbene2Selection = enforcedSelection
                showEbene2ConfirmAlert = true
                
                if permanentBlockSelection != oldPermanentBlockSelection {
                    permanentBlockSelection = oldPermanentBlockSelection
                }
                return
            }
            
            // Wenn in Ebene 2 ausgewählt, aus Ebene 1 entfernen (da Ebene 2 stärker ist)
            var newDaily = dailyLimitSelection
            newDaily.applicationTokens.subtract(enforcedSelection.applicationTokens)
            newDaily.categoryTokens.subtract(enforcedSelection.categoryTokens)
            newDaily.webDomainTokens.subtract(enforcedSelection.webDomainTokens)
            if newDaily != dailyLimitSelection {
                dailyLimitSelection = newDaily
                oldDailyLimitSelection = newDaily
            }
            
            // Auch aus Zeitleiste (blockSelection) entfernen
            var newBlock = blockSelection
            newBlock.applicationTokens.subtract(enforcedSelection.applicationTokens)
            newBlock.categoryTokens.subtract(enforcedSelection.categoryTokens)
            newBlock.webDomainTokens.subtract(enforcedSelection.webDomainTokens)
            if newBlock != blockSelection {
                blockSelection = newBlock
                oldBlockSelection = newBlock
            }
            
            if permanentBlockSelection != enforcedSelection {
                permanentBlockSelection = enforcedSelection
            }
            oldPermanentBlockSelection = enforcedSelection
        }
        .fullScreenCover(isPresented: $showWalkOfShame) {
            WalkOfShameView(
                onConfirmGiveUp: {
                    // Unblock everything
                    permanentBlockSelection = FamilyActivitySelection()
                    oldPermanentBlockSelection = FamilyActivitySelection()
                    manager.permanentBlockSelection = FamilyActivitySelection()
                    
                    dailyLimitSelection = FamilyActivitySelection()
                    oldDailyLimitSelection = FamilyActivitySelection()
                    manager.dailyLimitSelection = FamilyActivitySelection()
                    
                    showWalkOfShame = false
                },
                onCancel: {
                    showWalkOfShame = false
                }
            )
        }
        .alert(String(localized: "screenTime.layer2.confirm.title", defaultValue: "Bist du sicher?"), isPresented: $showEbene2ConfirmAlert) {
            Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) {
                pendingEbene2Selection = nil
            }
            Button(String(localized: "common.confirm", defaultValue: "Bestätigen")) {
                if let pending = pendingEbene2Selection {
                    permanentBlockSelection = pending
                    oldPermanentBlockSelection = pending
                    
                    var newDaily = dailyLimitSelection
                    newDaily.applicationTokens.subtract(pending.applicationTokens)
                    newDaily.categoryTokens.subtract(pending.categoryTokens)
                    newDaily.webDomainTokens.subtract(pending.webDomainTokens)
                    dailyLimitSelection = newDaily
                    oldDailyLimitSelection = newDaily
                    
                    pendingEbene2Selection = nil
                }
            }
        } message: {
            Text(String(localized: "screenTime.layer2.confirm.message", defaultValue: "Wenn du dies bestätigst, kann es nicht mehr rückgängig gemacht werden, außer du entsperrst es mühsam."))
        }
        .onDisappear {
            saveSettings()
        }
        .alert(String(localized: "screenTime.limit.confirm.title", defaultValue: "Bist du dir sicher?"), isPresented: $showConfirmAlert) {
            Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) {
                pendingLimitAction = nil
            }
            Button(String(localized: "common.confirm", defaultValue: "Bestätigen")) {
                pendingLimitAction?()
                pendingLimitAction = nil
            }
        } message: {
            Text(String(localized: "screenTime.limit.confirm.message", defaultValue: "Sobald das Limit festgelegt ist, kannst du es heute nicht mehr erhöhen!"))
        }
    }
    
    // MARK: - Settings ScrollView
    
    private var settingsScrollView: some View {
        ScrollView {
            VStack(spacing: 24) {

                
                dailyLimitSection
                permanentBlockSection
                scheduleSection
                infoSection
                
                // Bottom Authorization Link
                if !manager.isAuthorized {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(String(localized: "screenTime.auth.request", defaultValue: "Bildschirmzeit-Zugriff erlauben"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                            .underline()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .padding()
        }
    }
    

    
    // MARK: - Ebene 1: Zeitlimit
    private var dailyLimitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "screenTime.layer1.title", defaultValue: "Ebene 1: Tägliches Zeitlimit"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .padding(.horizontal)
            
            Text(String(localized: "screenTime.layer1.desc", defaultValue: "Nach Ablauf dieser Zeit werden die ausgewählten Apps für den Rest des Tages blockiert."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            HStack {
                Item3DButton(
                    farbe: Color.gruenPrimary,
                    sekundaerFarbe: Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    aktion: { isDailyLimitPickerPresented = true }
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                }
                .familyActivityPicker(isPresented: $isDailyLimitPickerPresented, selection: $dailyLimitSelection)
                
                Spacer()
                
                if !dailyLimitSelection.applicationTokens.isEmpty || !dailyLimitSelection.categoryTokens.isEmpty || !dailyLimitSelection.webDomainTokens.isEmpty {
                    Item3DButton(
                        farbe: Color.orange,
                        sekundaerFarbe: Color.orange.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: { showWalkOfShame = true }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                            Text(String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal)
            
            if !dailyLimitSelection.applicationTokens.isEmpty || !dailyLimitSelection.categoryTokens.isEmpty || !dailyLimitSelection.webDomainTokens.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(dailyLimitSelection.applicationTokens), id: \.self) { token in
                        BlockRow {
                            HStack {
                                Label(token)
                                Spacer()
                                limitMenu(for: Binding(
                                    get: { manager.getLimit(for: token) },
                                    set: { manager.setLimit(for: token, limit: $0) }
                                ))
                            }
                        }
                    }
                    ForEach(Array(dailyLimitSelection.categoryTokens), id: \.self) { token in
                        BlockRow {
                            HStack {
                                Label(token)
                                Spacer()
                                limitMenu(for: Binding(
                                    get: { manager.getLimit(for: token) },
                                    set: { manager.setLimit(for: token, limit: $0) }
                                ))
                            }
                        }
                    }
                    ForEach(Array(dailyLimitSelection.webDomainTokens), id: \.self) { token in
                        BlockRow {
                            HStack {
                                Label(token)
                                Spacer()
                                limitMenu(for: Binding(
                                    get: { manager.getLimit(for: token) },
                                    set: { manager.setLimit(for: token, limit: $0) }
                                ))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func limitMenu(for minutesBinding: Binding<Int>) -> some View {
        Menu {
            ForEach([0, 5, 10, 15, 30, 45, 60, 90, 120, 180], id: \.self) { min in
                Button(action: {
                    if minutesBinding.wrappedValue == 0 && min > 0 {
                        pendingLimitAction = { minutesBinding.wrappedValue = min }
                        showConfirmAlert = true
                    } else {
                        minutesBinding.wrappedValue = min
                    }
                }) {
                    Text(min == 0 ? String(localized: "common.off", defaultValue: "Aus") : "\(min) \(String(localized: "common.minutes.short", defaultValue: "Min"))")
                }
                .disabled(minutesBinding.wrappedValue != 0 && min > minutesBinding.wrappedValue)
            }
        } label: {
            HStack {
                Text(minutesBinding.wrappedValue == 0 ? String(localized: "common.off", defaultValue: "Aus") : "\(minutesBinding.wrappedValue) \(String(localized: "common.minutes.short", defaultValue: "Min"))")
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Ebene 2: Permanent Block Section
    
    private var permanentBlockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "screenTime.layer2.title", defaultValue: "Ebene 2: Immer blockiert"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .padding(.horizontal)
            
            Text(String(localized: "screenTime.layer2.desc", defaultValue: "Diese Apps und Webseiten sind immer blockiert und können nur durch den Notfall-Unlock entsperrt werden."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            HStack {
                Item3DButton(
                    farbe: Color.gruenPrimary,
                    sekundaerFarbe: Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    aktion: { isPermanentPickerPresented = true }
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                }
                .familyActivityPicker(isPresented: $isPermanentPickerPresented, selection: $permanentBlockSelection)
                
                Spacer()
                
                if !permanentBlockSelection.applicationTokens.isEmpty || !permanentBlockSelection.categoryTokens.isEmpty || !permanentBlockSelection.webDomainTokens.isEmpty {
                    Item3DButton(
                        farbe: Color.orange,
                        sekundaerFarbe: Color.orange.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: { showWalkOfShame = true }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                            Text(String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal)
            
            // Blocked items – vertical list
            if !permanentBlockSelection.applicationTokens.isEmpty ||
               !permanentBlockSelection.categoryTokens.isEmpty ||
               !permanentBlockSelection.webDomainTokens.isEmpty {
                VStack(spacing: 8) {
                    ForEach(Array(permanentBlockSelection.applicationTokens), id: \.self) { token in
                        BlockRow { Label(token) }
                    }
                    ForEach(Array(permanentBlockSelection.categoryTokens), id: \.self) { token in
                        BlockRow { Label(token) }
                    }
                    ForEach(Array(permanentBlockSelection.webDomainTokens), id: \.self) { token in
                        BlockRow { Label(token) }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    

    
    // MARK: - Schedule Section
    
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "screenTime.schedule.title", defaultValue: "Block-Zeitplan"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal)
                
                Toggle(isOn: $isScheduleActive) {
                    Text(String(localized: "screenTime.schedule.active", defaultValue: "Zeitplan aktivieren"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .tint(Color.gruenPrimary)
                .padding(.horizontal)
            }
            
            if isScheduleActive {
                VStack(spacing: 8) {
                    // Quick Copy Buttons
                    HStack(spacing: 8) {
                        quickApplyButton(
                            label: String(localized: "screenTime.schedule.applyWeekdays", defaultValue: "Mo–Fr gleich"),
                            action: applyWeekdaysToAll
                        )
                        quickApplyButton(
                            label: String(localized: "screenTime.schedule.applyWeekend", defaultValue: "Sa–So gleich"),
                            action: applyWeekendToAll
                        )
                    }
                    .padding(.horizontal)
                    
                    // Per-Day Rows
                    ForEach(allWeekdays, id: \.0) { (dayInt, short, full) in
                        DayScheduleRow(
                            dayName: full,
                            shortName: short,
                            schedule: binding(for: dayInt),
                            isExpanded: expandedDay == dayInt,
                            onToggleExpand: {
                                withAnimation(.spring(response: 0.3)) {
                                    expandedDay = expandedDay == dayInt ? nil : dayInt
                                }
                            }
                        )
                        .padding(.horizontal)
                    }
                    
                    if manager.isCurrentlyInBlockWindow {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(.red)
                            Text(String(localized: "screenTime.schedule.locked.info", defaultValue: "Die Zeitleiste ist gerade aktiv. Du kannst Apps hinzufügen, aber keine entfernen."))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                    
                    // Block Selection – 3D Button
                    Item3DButton(
                        farbe: Color(UIColor.secondarySystemGroupedBackground),
                        sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground),
                        groesse: 56,
                        shadowDepthFactor: 0.07,
                        isRectangular: true,
                        aktion: { isPickerPresented = true }
                    ) {
                        HStack {
                            Image(systemName: "app.badge.fill")
                                .foregroundStyle(.blue)
                                .font(.system(size: 16))
                            Text(String(localized: "screenTime.schedule.select_apps", defaultValue: "Apps & Kategorien für Zeitplan"))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 13))
                        }
                        .padding(.horizontal, 8)
                    }
                    .familyActivityPicker(isPresented: $isPickerPresented, selection: $blockSelection)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                String(localized: "screenTime.info.title", defaultValue: "Wie funktioniert das?"),
                systemImage: "info.circle"
            )
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            
            Text(String(localized: "screenTime.info.desc", defaultValue: "Der Shield-Block zeigt einen Warn-Overlay über Apps. Die betroffenen Apps werden nicht gelöscht und können vom Nutzer weiterhin geöffnet werden (mit Bestätigung). Der Erwachsenen-Filter gilt nur in Safari."))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Helpers
    
    private func binding(for dayInt: Int) -> Binding<DaySchedule> {
        Binding(
            get: { daySchedules[dayInt] ?? .defaultWeekday },
            set: { daySchedules[dayInt] = $0 }
        )
    }
    
    private func applyWeekdaysToAll() {
        guard let monday = daySchedules[2] else { return }
        for day in [3, 4, 5, 6] {
            daySchedules[day] = monday
        }
    }
    
    private func applyWeekendToAll() {
        guard let saturday = daySchedules[7] else { return }
        daySchedules[1] = saturday
    }
    
    private func saveSettings() {
        manager.isScheduleActive = isScheduleActive
        manager.blockSelection = blockSelection
        // Assign dailyLimitSelection directly on the manager so it's saved.
        // limitSelections are already saved live via manager.setLimit().
        // We do NOT reassign manager.dailyLimitSelection here to avoid triggering
        // syncIndividualLimits with potentially mismatched tokens.
        manager.saveDailyLimitSelectionPublic(dailyLimitSelection)
        manager.daySchedules = daySchedules
        manager.permanentBlockSelection = permanentBlockSelection
        manager.isAdultFilterEnabled = isAdultFilterEnabled
        manager.applyPermanentBlocks()
        
        let blockData = try? JSONEncoder().encode(blockSelection)
        manager.scheduleBlockActivities(daySchedules: daySchedules, blockSelectionData: blockData)
    }
    
    @ViewBuilder
    private func quickApplyButton(label: String, action: @escaping () -> Void) -> some View {
        Item3DButton(
            farbe: Color.gruenPrimary,
            sekundaerFarbe: Color.gruenPrimary.darker(),
            groesse: 42,
            shadowDepthFactor: 0.1,
            isRectangular: true,
            aktion: action
        ) {
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
        }
    }
}

// MARK: - DayScheduleRow

struct DayScheduleRow: View {
    let dayName: String
    let shortName: String
    @Binding var schedule: DaySchedule
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            Button(action: onToggleExpand) {
                HStack {
                    // Active Toggle
                    Toggle("", isOn: $schedule.isActive)
                        .labelsHidden()
                        .tint(Color.gruenPrimary)
                        .onTapGesture {} // Prevent row expansion on toggle tap
                    
                    Text(dayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    
                    Spacer()
                    
                    if schedule.isActive {
                        Text(timeString(h: schedule.startHour, m: schedule.startMinute) + " – " + timeString(h: schedule.endHour, m: schedule.endMinute))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "screenTime.schedule.day.inactive", defaultValue: "Inaktiv"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            // Expanded Time Pickers
            if isExpanded && schedule.isActive {
                Divider().padding(.horizontal)
                
                VStack(spacing: 0) {
                    DatePicker(
                        String(localized: "screenTime.schedule.start", defaultValue: "Startzeit"),
                        selection: startTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Divider().padding(.horizontal)
                    
                    DatePicker(
                        String(localized: "screenTime.schedule.end", defaultValue: "Endzeit"),
                        selection: endTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 0, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
        .animation(.spring(response: 0.3), value: isExpanded)
    }
    
    private var startTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: schedule.startHour, minute: schedule.startMinute, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                schedule.startHour = Calendar.current.component(.hour, from: date)
                schedule.startMinute = Calendar.current.component(.minute, from: date)
            }
        )
    }
    
    private var endTimeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: schedule.endHour, minute: schedule.endMinute, second: 0, of: Date()) ?? Date()
            },
            set: { date in
                schedule.endHour = Calendar.current.component(.hour, from: date)
                schedule.endMinute = Calendar.current.component(.minute, from: date)
            }
        )
    }
    
    private func timeString(h: Int, m: Int) -> String {
        guard let date = Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date()) else {
            return String(format: "%02d:%02d", h, m)
        }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Subviews

// MARK: - BlockRow (vertical, full-width)

struct BlockRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundStyle(.red)
            content
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 0, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScreenTimeSettingsView()
    }
}
