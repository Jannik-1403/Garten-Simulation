import SwiftUI
import FamilyControls

// MARK: - Main View

struct ScreenTimeSettingsView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isScheduleActive: Bool = false
    @State private var daySchedules: [Int: DaySchedule] = [:]
    @State private var expandedDay: Int? = nil
    
    @State private var isPickerPresented = false
    @State private var blockSelection = FamilyActivitySelection()
    @State private var isPermanentPickerPresented = false
    @State private var permanentBlockSelection = FamilyActivitySelection()
    @State private var isAdultFilterEnabled = false
    
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
            
            if manager.isCurrentlyInBlockWindow {
                blockedStateView
            } else {
                settingsScrollView
            }
        }
        .navigationTitle(String(localized: "screenTime.title", defaultValue: "Bildschirmzeit"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !manager.isCurrentlyInBlockWindow {
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
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isScheduleActive = manager.isScheduleActive
            blockSelection = manager.blockSelection
            permanentBlockSelection = manager.permanentBlockSelection
            isAdultFilterEnabled = manager.isAdultFilterEnabled
            daySchedules = manager.daySchedules
        }
    }
    
    // MARK: - Blocked State
    
    private var blockedStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
            
            Text(String(localized: "screenTime.blocked.title", defaultValue: "Bildschirmzeit blockiert"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(String(localized: "screenTime.blocked.desc", defaultValue: "Du befindest dich gerade in deiner aktiven Block-Zeit."))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                
            Button(role: .destructive) {
                manager.isScheduleActive = false
                isScheduleActive = false
                manager.unblockApps()
            } label: {
                Text(String(localized: "screenTime.emergency.unlock", defaultValue: "Notfall-Entsperrung"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
    }
    
    // MARK: - Settings ScrollView
    
    private var settingsScrollView: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !manager.isAuthorized {
                    authorizationBanner
                }
                
                permanentBlockSection
                scheduleSection
                infoSection
            }
            .padding()
        }
    }
    
    // MARK: - Authorization Banner
    
    private var authorizationBanner: some View {
        Item3DButton(
            farbe: Color.orange,
            sekundaerFarbe: Color.orange.darker(),
            groesse: 56,
            isRectangular: true,
            aktion: {
                Task { await manager.requestAuthorization() }
            }
        ) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
                Text(String(localized: "screenTime.auth.request", defaultValue: "Bildschirmzeit-Zugriff erlauben"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Permanent Block Section
    
    private var permanentBlockSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "screenTime.permanent.title", defaultValue: "Für immer blockieren"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                // Adult Filter as 3D Button
                Item3DButton(
                    farbe: isAdultFilterEnabled ? Color.red : Color(UIColor.secondarySystemGroupedBackground),
                    sekundaerFarbe: isAdultFilterEnabled ? Color.red.darker() : Color(UIColor.tertiarySystemGroupedBackground),
                    groesse: 40,
                    shadowDepthFactor: 0.1,
                    isRectangular: true,
                    aktion: { isAdultFilterEnabled.toggle() }
                ) {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(isAdultFilterEnabled ? .white : .red)
                        Text(String(localized: "screenTime.suggestions.adult.title", defaultValue: "Adult Filter"))
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isAdultFilterEnabled ? .white : .primary)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.horizontal)
            
            // Horizontal scroll – pills + 3D add button
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // + Add Button as 3D rectangular button
                    Item3DButton(
                        farbe: Color.gruenPrimary,
                        sekundaerFarbe: Color.gruenPrimary.darker(),
                        groesse: 44,
                        shadowDepthFactor: 0.1,
                        isRectangular: true,
                        aktion: { isPermanentPickerPresented = true }
                    ) {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text(String(localized: "common.add", defaultValue: "Hinzufügen"))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 4)
                    }
                    .familyActivityPicker(isPresented: $isPermanentPickerPresented, selection: $permanentBlockSelection)
                    
                    // App tokens
                    ForEach(Array(permanentBlockSelection.applicationTokens), id: \.self) { token in
                        BlockPill { Label(token) }
                    }
                    // Category tokens
                    ForEach(Array(permanentBlockSelection.categoryTokens), id: \.self) { token in
                        BlockPill { Label(token) }
                    }
                    // Web domain tokens
                    ForEach(Array(permanentBlockSelection.webDomainTokens), id: \.self) { token in
                        BlockPill { Label(token) }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
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
                    
                    // Block Selection
                    Button {
                        isPickerPresented = true
                    } label: {
                        HStack {
                            Image(systemName: "app.badge.fill")
                                .foregroundStyle(Color.gruenPrimary)
                            Text(String(localized: "screenTime.schedule.select_apps", defaultValue: "Apps & Kategorien für Zeitplan"))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
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
        manager.daySchedules = daySchedules
        manager.permanentBlockSelection = permanentBlockSelection
        manager.isAdultFilterEnabled = isAdultFilterEnabled
        manager.applyPermanentBlocks()
        
        // Register/update DeviceActivity background schedules
        let blockData = try? JSONEncoder().encode(blockSelection)
        manager.scheduleBlockActivities(daySchedules: daySchedules, blockSelectionData: blockData)
    }
    
    @ViewBuilder
    private func quickApplyButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gruenPrimary.opacity(0.15))
                .foregroundStyle(Color.gruenPrimary)
                .cornerRadius(10)
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
        .shadow(
            color: Color(UIColor.secondarySystemGroupedBackground).opacity(0.8),
            radius: 0, x: 0, y: 4
        )
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
        String(format: "%02d:%02d", h, m)
    }
}

// MARK: - Subviews

// MARK: - BlockPill

struct BlockPill<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScreenTimeSettingsView()
    }
}
