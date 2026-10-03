import SwiftUI

/// Konfiguriert, an welchen Wochentagen eine Gewohnheit fällig ist
/// und wie der Tagesfortschritt erfasst wird (Prozent-Slider oder Zähler).
/// Gestaltet im 3D-Stil der App (Item3D-Container & Pill-Buttons).
struct HabitTrackingSettingsSheet: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDays: Set<Int>
    @State private var mode: HabitTrackingMode
    @State private var target: Int
    @State private var unit: String
    @FocusState private var focusedField: Field?

    private enum Field { case target, unit }

    init(pflanze: HabitModel) {
        self.pflanze = pflanze
        _selectedDays = State(initialValue: pflanze.scheduledWeekdays.isEmpty ? Set(1...7) : pflanze.scheduledWeekdays)
        _mode = State(initialValue: pflanze.trackingMode)
        _target = State(initialValue: max(1, pflanze.counterTarget))
        _unit = State(initialValue: pflanze.counterUnit ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    daysSection
                    modeSection
                    if mode == .counter {
                        counterSection
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) {
                Button(String(localized: "common.save", defaultValue: "Speichern")) { save() }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: .gruenPrimary,
                        shadowColor: Color.gruenPrimary.darker()
                    ))
                    .disabled(selectedDays.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(UIColor.secondarySystemBackground))
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle(String(localized: "tracking.settings.title", defaultValue: "Tracking-Einstellungen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "common.done", defaultValue: "Fertig")) { focusedField = nil }
                }
            }
            .animation(.snappy, value: mode)
        }
    }

    // MARK: - Fällige Tage

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(String(localized: "tracking.settings.days.header", defaultValue: "Fällige Tage"))

            VStack(alignment: .leading, spacing: 16) {
                WeekdayPicker(selection: $selectedDays)

                HStack(spacing: 8) {
                    presetButton(String(localized: "tracking.days.preset.daily", defaultValue: "Täglich"), days: Set(1...7))
                    presetButton(String(localized: "tracking.days.preset.weekdays", defaultValue: "Werktags"), days: Set(1...5))
                    presetButton(String(localized: "tracking.days.preset.weekend", defaultValue: "Wochenende"), days: [6, 7])
                }

                exampleBox(text: daysExampleText)
            }
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        }
    }

    private var daysExampleText: String {
        if selectedDays.count >= 7 {
            return String(localized: "tracking.settings.days.example.daily", defaultValue: "Jeden Tag fällig – ein verpasster Tag beendet deinen Streak.")
        }
        let list = WeekdayPicker.shortList(for: selectedDays)
        return String(format: String(localized: "tracking.settings.days.example", defaultValue: "Fällig am %@. An allen anderen Tagen hast du frei – dein Streak läuft weiter."), list)
    }

    private func presetButton(_ title: String, days: Set<Int>) -> some View {
        let isActive = selectedDays == days
        return Button {
            withAnimation(.snappy) { selectedDays = days }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isActive ? Color.white : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(PillButtonStyle(
            farbe: isActive ? Color.gruenPrimary : Color(UIColor.systemBackground),
            sekundaerFarbe: isActive ? Color.gruenPrimary.darker() : Color(UIColor.systemGray4),
            cornerRadius: 10,
            shadowDepth: 3,
            isPermanentlyPressed: isActive
        ))
    }

    // MARK: - Modus

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(String(localized: "tracking.settings.mode.header", defaultValue: "Fortschritt erfassen"))

            HStack(spacing: 12) {
                modeCard(.slider)
                modeCard(.counter)
            }

            exampleBox(text: modeExampleText)
                .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5), shadowDepth: 4)
        }
    }

    private var exampleUnit: String {
        let trimmed = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: "tracking.settings.unit.default", defaultValue: "Wiederholungen") : trimmed
    }

    private var exampleCount: Int { max(1, Int((Double(target) * 0.4).rounded())) }

    private var modeExampleText: String {
        switch mode {
        case .slider:
            return String(localized: "tracking.mode.slider.example", defaultValue: "Beispiel: Regler auf 60% → die Gewohnheit ist zu 60% erledigt.")
        case .counter:
            let count = exampleCount
            let total = target
            let unitText = exampleUnit
            let percentStr = "\(Int((Double(count) / Double(max(1, total)) * 100).rounded()))%"
            return String(
                format: String(localized: "tracking.mode.counter.example", defaultValue: "Beispiel: %d von %d %@ → %@ erledigt."),
                count, total, unitText, percentStr
            )
        }
    }

    private func modeCard(_ cardMode: HabitTrackingMode) -> some View {
        let isActive = mode == cardMode
        return Button {
            withAnimation(.snappy) { mode = cardMode }
        } label: {
            Text(cardMode.localizedTitle)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 10)
        }
        .buttonStyle(PillButtonStyle(
            farbe: Color(UIColor.systemBackground),
            sekundaerFarbe: Color(UIColor.systemGray4),
            cornerRadius: 16,
            shadowDepth: 5,
            isPermanentlyPressed: isActive
        ))
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }



    // MARK: - Zähler-Ziel

    private var counterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(String(localized: "tracking.settings.target", defaultValue: "Tagesziel"))

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Item3DButton(
                        icon: "minus",
                        farbe: .orangePrimary,
                        sekundaerFarbe: Color.orangePrimary.darker(),
                        groesse: 48,
                        iconSkalierung: 0.4,
                        isDisabled: target <= 1
                    ) { target = max(1, target - 1) }
                    .buttonRepeatBehavior(.enabled)

                    TextField("", value: $target, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .target)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .frame(maxWidth: .infinity)

                    Item3DButton(
                        icon: "plus",
                        farbe: .orangePrimary,
                        sekundaerFarbe: Color.orangePrimary.darker(),
                        groesse: 48,
                        iconSkalierung: 0.4,
                        isDisabled: target >= 10_000
                    ) { target = min(10_000, target + 1) }
                    .buttonRepeatBehavior(.enabled)
                }

                TextField(
                    String(localized: "tracking.settings.unit.placeholder", defaultValue: "Einheit, z. B. Liegestütze"),
                    text: $unit
                )
                .focused($focusedField, equals: .unit)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(UIColor.secondarySystemBackground))
                )

                Text(String(localized: "tracking.settings.counter.footer", defaultValue: "Erreichst du das Tagesziel, gilt die Gewohnheit als erledigt (100 %)."))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        }
    }

    // MARK: - Bausteine

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.leading, 4)
    }

    private func exampleBox(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.orangePrimary)
            Text(text)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Speichern

    private func save() {
        let newTarget = min(max(1, target), 10_000)
        let modeChanged = pflanze.trackingMode != mode
        let targetChanged = pflanze.counterTarget != newTarget

        pflanze.scheduledWeekdays = selectedDays
        pflanze.trackingMode = mode
        pflanze.counterTarget = newTarget
        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
        pflanze.counterUnit = trimmedUnit.isEmpty ? nil : trimmedUnit

        // Laufenden Tagesfortschritt an neuen Modus/Ziel anpassen (nur wenn heute noch offen).
        if !pflanze.wasCompleted(on: Date()), mode == .counter, modeChanged || targetChanged {
            let derived = Int((pflanze.sliderProgress * Double(newTarget)).rounded(.down))
            gardenStore.setCounterProgress(pflanze: pflanze, to: modeChanged ? derived : pflanze.counterProgress)
        } else {
            gardenStore.savePlants()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}

/// Mo–So-Auswahl als 3D-Buttons (Reihenfolge Montag zuerst, 1=Mo … 7=So).
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    /// App-Wochentag (1=Mo … 7=So) → Index in Apples Symbol-Array (0=So … 6=Sa)
    static func symbolIndex(for day: Int) -> Int { day == 7 ? 0 : day }

    /// Lokalisierte Kurzliste, z. B. "Mo, Mi und Fr".
    static func shortList(for days: Set<Int>) -> String {
        let symbols = Calendar.current.shortStandaloneWeekdaySymbols
        return days.sorted()
            .map { symbols[symbolIndex(for: $0)] }
            .formatted(.list(type: .and, width: .standard))
    }

    var body: some View {
        let symbols = Calendar.current.shortStandaloneWeekdaySymbols
        let fullSymbols = Calendar.current.standaloneWeekdaySymbols
        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { day in
                let isOn = selection.contains(day)
                Button {
                    toggle(day)
                } label: {
                    Text(String(symbols[Self.symbolIndex(for: day)].prefix(2)))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(isOn ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(PillButtonStyle(
                    farbe: isOn ? Color.gruenPrimary : Color(UIColor.systemBackground),
                    sekundaerFarbe: isOn ? Color.gruenPrimary.darker() : Color(UIColor.systemGray4),
                    cornerRadius: 12,
                    shadowDepth: 4,
                    isPermanentlyPressed: false
                ))
                .accessibilityLabel(fullSymbols[Self.symbolIndex(for: day)])
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }

    private func toggle(_ day: Int) {
        withAnimation(.snappy) {
            if selection.contains(day) {
                // Mindestens ein Tag muss aktiv bleiben.
                guard selection.count > 1 else { return }
                selection.remove(day)
            } else {
                selection.insert(day)
            }
        }
    }
}

#Preview("Tracking-Einstellungen") {
    let habit = HabitModel(name: "Gym", symbolName: "figure.run", habitCategory: .fitness)
    habit.scheduledWeekdays = [1, 3, 5]
    habit.trackingMode = .counter
    habit.counterTarget = 50
    habit.counterUnit = "Liegestütze"
    return HabitTrackingSettingsSheet(pflanze: habit)
        .environmentObject(GardenStore())
}

#Preview("Wochentage") {
    @Previewable @State var days: Set<Int> = [1, 3]
    WeekdayPicker(selection: $days).padding()
}
