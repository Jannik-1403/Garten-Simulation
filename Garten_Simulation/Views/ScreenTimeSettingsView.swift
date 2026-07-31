import SwiftUI
import FamilyControls

// MARK: - Main View

struct ScreenTimeSettingsView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var iapStore: IAPStore
    
    @AppStorage("hasRequestedScreenTimeAuth") private var hasRequestedAuth: Bool = false
    
    @State private var showPaywall = false
    
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
    
    @State private var walkOfShameContext: Int? = nil
    
    @State private var isEbene1Expanded: Bool = false
    @State private var isEbene2Expanded: Bool = false
    
    @State private var showConfirmAlert = false
    @State private var pendingLimitAction: (() -> Void)? = nil
    
    @State private var showInfoAlert = false
    @State private var infoAlertTitle = ""
    @State private var infoAlertMessage = ""
    
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
                    do {
                        try await manager.requestAuthorization()
                        hasRequestedAuth = true
                    } catch {
                        print("Authorization failed in settings view: \(error.localizedDescription)")
                    }
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
        .onChange(of: dailyLimitSelection) { _, newValue in
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
        .onChange(of: blockSelection) { _, newValue in
            var filteredValue = newValue
            
            // Apps that are in layer 1 (permanentBlockSelection) or layer 0 (dailyLimitSelection)
            // should not be selectable in layer 2 (blockSelection).
            filteredValue.applicationTokens.subtract(dailyLimitSelection.applicationTokens)
            filteredValue.categoryTokens.subtract(dailyLimitSelection.categoryTokens)
            filteredValue.webDomainTokens.subtract(dailyLimitSelection.webDomainTokens)
            
            filteredValue.applicationTokens.subtract(permanentBlockSelection.applicationTokens)
            filteredValue.categoryTokens.subtract(permanentBlockSelection.categoryTokens)
            filteredValue.webDomainTokens.subtract(permanentBlockSelection.webDomainTokens)
            
            if filteredValue != blockSelection {
                DispatchQueue.main.async {
                    blockSelection = filteredValue
                    oldBlockSelection = filteredValue
                }
            } else {
                oldBlockSelection = filteredValue
            }
        }
        .onChange(of: permanentBlockSelection) { _, newValue in
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
        .fullScreenCover(isPresented: Binding<Bool>(
            get: { walkOfShameContext != nil },
            set: { if !$0 { walkOfShameContext = nil } }
        )) {
            if let context = walkOfShameContext {
                WalkOfShameView(
                    onConfirmGiveUp: {
                        if context == 1 || context == 2 {
                            // Unblock layer 1 & 2
                            permanentBlockSelection = FamilyActivitySelection()
                            oldPermanentBlockSelection = FamilyActivitySelection()
                            manager.permanentBlockSelection = FamilyActivitySelection()
                            
                            dailyLimitSelection = FamilyActivitySelection()
                            oldDailyLimitSelection = FamilyActivitySelection()
                            manager.dailyLimitSelection = FamilyActivitySelection()
                        } else if context == 3 {
                            isAdultFilterEnabled = false
                        } else if context == 4 {
                            isScheduleActive = false
                        }
                        walkOfShameContext = nil
                        saveSettings()
                    },
                    onCancel: {
                        walkOfShameContext = nil
                    },
                    level: context
                )
            } else {
                Color.clear
            }
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                saveSettings()
            }
        }
        .onChange(of: isPermanentPickerPresented) { _, isOpen in
            if !isOpen { saveSettings() }
        }
        .onChange(of: isDailyLimitPickerPresented) { _, isOpen in
            if !isOpen { saveSettings() }
        }
        .onChange(of: isPickerPresented) { _, isOpen in
            if !isOpen { saveSettings() }
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
        .alert(infoAlertTitle, isPresented: $showInfoAlert) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) { }
        } message: {
            Text(infoAlertMessage)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - Settings ScrollView
    
    private var settingsScrollView: some View {
        ScrollView {
            VStack(spacing: 32) {
                ebene1Section
                ebene2Section
                ebene3Section
                ebene4Section
                
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
            .padding(.vertical)
        }
    }
    
    private func sectionHeader3D(level: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(level.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Button {
                    infoAlertTitle = title
                    infoAlertMessage = description
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            ZStack(alignment: .topLeading) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.15))
                    .offset(y: 3)
                
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Ebene 1: Zeitlimit
    private var ebene1Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer1.level", defaultValue: "Ebene 1"),
                title: String(localized: "screenTime.layer1.title", defaultValue: "Tägliches Limit"),
                description: String(localized: "screenTime.layer1.desc", defaultValue: "Nach Ablauf dieser Zeit werden die ausgewählten Apps für den Rest des Tages blockiert.")
            )
            
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
                        aktion: { walkOfShameContext = 1 }
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
            .padding(.top, 4)
            
            if !dailyLimitSelection.applicationTokens.isEmpty || !dailyLimitSelection.categoryTokens.isEmpty || !dailyLimitSelection.webDomainTokens.isEmpty {
                let count = dailyLimitSelection.applicationTokens.count + dailyLimitSelection.categoryTokens.count + dailyLimitSelection.webDomainTokens.count
                DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbene1Expanded) {
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
                    .padding(.top, 8)
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .accentColor(.gruenPrimary)
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
    
    // MARK: - Ebene 4: Permanent Block Section
    private var ebene4Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer4.level", defaultValue: "Ebene 4"),
                title: String(localized: "screenTime.layer4.title", defaultValue: "Immer blockiert"),
                description: String(localized: "screenTime.layer4.desc", defaultValue: "Diese Apps und Webseiten sind immer blockiert und können nur durch den Notfall-Unlock entsperrt werden.")
            )
            
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
                        aktion: { walkOfShameContext = 2 }
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
            .padding(.top, 4)
            
            if !permanentBlockSelection.applicationTokens.isEmpty ||
               !permanentBlockSelection.categoryTokens.isEmpty ||
               !permanentBlockSelection.webDomainTokens.isEmpty {
                let count = permanentBlockSelection.applicationTokens.count + permanentBlockSelection.categoryTokens.count + permanentBlockSelection.webDomainTokens.count
                DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbene2Expanded) {
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
                    .padding(.top, 8)
                }
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .accentColor(.gruenPrimary)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Ebene 3: Adult Filter Section
    @ViewBuilder
    private var ebene3Section: some View {
        if FeatureFlags.isProVersionEnabled {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader3D(
                    level: String(localized: "screenTime.layer3.level", defaultValue: "Ebene 3"),
                    title: String(localized: "screenTime.safariFilter.title", defaultValue: "Systemweiter Erwachsenen-Filter"),
                    description: String(localized: "screenTime.safariFilter.desc", defaultValue: "Blockiert pornografische Webseiten systemweit in allen Browsern.")
                )
                
                let isActive = isAdultFilterEnabled
                
                HStack {
                    Item3DButton(
                        farbe: isActive ? Color.orange : Color.gruenPrimary,
                        sekundaerFarbe: isActive ? Color.orange.darker() : Color.gruenPrimary.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: {
                            if isActive {
                                walkOfShameContext = 3
                            } else {
                                if iapStore.isProUser {
                                    isAdultFilterEnabled = true
                                } else {
                                    showPaywall = true
                                }
                            }
                        }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: isActive ? "lock.open.fill" : "lock.fill")
                            Text(isActive ? String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren") : String(localized: "common.activate", defaultValue: "Aktivieren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Ebene 2: Schedule Section
    
    @State private var isEbeneScheduleExpanded: Bool = false
    
    /// Wahr, wenn der Zeitplan gerade läuft – dann ist alles read-only
    private var isScheduleLocked: Bool {
        manager.isCurrentlyInBlockWindow
    }

    private var ebene2Section: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer2.level", defaultValue: "Ebene 2"),
                title: String(localized: "screenTime.schedule.title", defaultValue: "Block-Zeitplan"),
                description: String(localized: "screenTime.schedule.desc", defaultValue: "Erzwinge Fokus zu bestimmten Zeiten.")
            )
            
            HStack {
                let isActive = isScheduleActive
                Item3DButton(
                    farbe: isActive ? Color.orange : Color.gruenPrimary,
                    sekundaerFarbe: isActive ? Color.orange.darker() : Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    aktion: {
                        if isActive {
                            walkOfShameContext = 4
                        } else {
                            isScheduleActive = true
                        }
                    }
                ) {
                    HStack(spacing: 4) {
                        Image(systemName: isActive ? "lock.open.fill" : "lock.fill")
                        Text(isActive ? String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren") : String(localized: "common.activate", defaultValue: "Aktivieren"))
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, -4)

            if isScheduleActive {
                VStack(spacing: 8) {

                    // Lock-Banner wenn Zeitplan gerade aktiv
                    if isScheduleLocked {
                        Item3DButton(
                            farbe: Color(UIColor.secondarySystemGroupedBackground),
                            sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground),
                            groesse: 64,
                            shadowDepthFactor: 0.05,
                            isRectangular: true,
                            isDisabled: true
                        ) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "screenTime.schedule.locked.title", defaultValue: "Zeitplan läuft gerade"))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "screenTime.schedule.locked.info", defaultValue: "Während der aktiven Zeit können keine Änderungen vorgenommen werden."))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                    } else {
                        // Quick Copy Buttons – nur wenn nicht gesperrt
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
                    }

                    // Per-Day Rows
                    ForEach(allWeekdays, id: \.0) { (dayInt, short, full) in
                        DayScheduleRow(
                            dayName: full,
                            shortName: short,
                            schedule: binding(for: dayInt),
                            isExpanded: expandedDay == dayInt && !isScheduleLocked,
                            isLocked: isScheduleLocked,
                            onToggleExpand: {
                                guard !isScheduleLocked else { return }
                                withAnimation(.spring(response: 0.3)) {
                                    expandedDay = expandedDay == dayInt ? nil : dayInt
                                }
                            }
                        )
                        .padding(.horizontal)
                    }

                    // App-Picker – nur wenn nicht gesperrt
                    if !isScheduleLocked {
                        HStack {
                            Item3DButton(
                                farbe: Color.gruenPrimary,
                                sekundaerFarbe: Color.gruenPrimary.darker(),
                                groesse: 36,
                                shadowDepthFactor: 0.15,
                                isRectangular: true,
                                aktion: { isPickerPresented = true }
                            ) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                            }
                            .familyActivityPicker(isPresented: $isPickerPresented, selection: $blockSelection)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }

                    // Liste der ausgewählten Apps
                    if !blockSelection.applicationTokens.isEmpty ||
                       !blockSelection.categoryTokens.isEmpty ||
                       !blockSelection.webDomainTokens.isEmpty {
                        let count = blockSelection.applicationTokens.count + blockSelection.categoryTokens.count + blockSelection.webDomainTokens.count
                        DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbeneScheduleExpanded) {
                            VStack(spacing: 8) {
                                ForEach(Array(blockSelection.applicationTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                                ForEach(Array(blockSelection.categoryTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                                ForEach(Array(blockSelection.webDomainTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .accentColor(.gruenPrimary)
                        .padding(.horizontal)
                    }
                }
            }
        }
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
    var isLocked: Bool = false
    let onToggleExpand: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            Button(action: onToggleExpand) {
                HStack {
                    // Active Toggle – bei Sperre nicht bedienbar
                    Toggle("", isOn: $schedule.isActive)
                        .labelsHidden()
                        .tint(Color.gruenPrimary)
                        .disabled(isLocked)
                        .onTapGesture {} // Prevent row expansion on toggle tap

                    Text(dayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isLocked ? .secondary : .primary)

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

                    // Kein Expand-Pfeil wenn gesperrt
                    if !isLocked {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .buttonStyle(.plain)
            .disabled(isLocked)

            // Expanded Time Pickers – nur wenn nicht gesperrt
            if isExpanded && schedule.isActive && !isLocked {
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
        .opacity(isLocked ? 0.7 : 1.0)
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

// MARK: - ScheduleBlockRow (für Zeitleisten-Apps, Clock-Icon)

struct ScheduleBlockRow<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .font(.system(size: 12))
                .foregroundStyle(.blue)
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
