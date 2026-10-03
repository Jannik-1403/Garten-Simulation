import SwiftUI

/// Konfiguriert, an welchen Wochentagen eine Gewohnheit fällig ist
/// und wie der Tagesfortschritt erfasst wird (Prozent-Slider oder Zähler).
struct HabitTrackingSettingsSheet: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDays: Set<Int>
    @State private var mode: HabitTrackingMode
    @State private var target: Int
    @State private var unit: String

    init(pflanze: HabitModel) {
        self.pflanze = pflanze
        _selectedDays = State(initialValue: pflanze.scheduledWeekdays.isEmpty ? Set(1...7) : pflanze.scheduledWeekdays)
        _mode = State(initialValue: pflanze.trackingMode)
        _target = State(initialValue: max(1, pflanze.counterTarget))
        _unit = State(initialValue: pflanze.counterUnit ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    WeekdayPicker(selection: $selectedDays)
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                } header: {
                    Text(String(localized: "tracking.settings.days.header", defaultValue: "Fällige Tage"))
                } footer: {
                    Text(String(localized: "tracking.settings.days.footer", defaultValue: "An freien Tagen wird die Gewohnheit ausgeblendet und dein Streak bleibt erhalten."))
                }

                Section {
                    Picker(String(localized: "tracking.settings.mode.header", defaultValue: "Fortschritt erfassen"), selection: $mode) {
                        ForEach(HabitTrackingMode.allCases) { mode in
                            Text(mode.localizedTitle).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if mode == .counter {
                        Stepper(value: $target, in: 1...10_000) {
                            HStack {
                                Text(String(localized: "tracking.settings.target", defaultValue: "Tagesziel"))
                                Spacer()
                                TextField("", value: $target, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 70)
                                    .font(.body.monospacedDigit().weight(.semibold))
                            }
                        }

                        TextField(
                            String(localized: "tracking.settings.unit.placeholder", defaultValue: "Einheit, z. B. Liegestütze"),
                            text: $unit
                        )
                        .textInputAutocapitalization(.sentences)
                    }
                } header: {
                    Text(String(localized: "tracking.settings.mode.header", defaultValue: "Fortschritt erfassen"))
                } footer: {
                    if mode == .counter {
                        Text(String(localized: "tracking.settings.counter.footer", defaultValue: "Erreichst du das Tagesziel, gilt die Gewohnheit als erledigt (100 %)."))
                    }
                }
            }
            .navigationTitle(String(localized: "tracking.settings.title", defaultValue: "Tracking-Einstellungen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) { save() }
                        .fontWeight(.semibold)
                        .disabled(selectedDays.isEmpty)
                }
            }
            .animation(.snappy, value: mode)
        }
    }

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
        if !pflanze.wasCompleted(on: Date()), modeChanged || targetChanged {
            if mode == .counter {
                let derived = Int((pflanze.sliderProgress * Double(newTarget)).rounded(.down))
                gardenStore.setCounterProgress(pflanze: pflanze, to: modeChanged ? derived : pflanze.counterProgress)
            } else {
                gardenStore.savePlants()
            }
        } else {
            gardenStore.savePlants()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}

/// Mo–So-Auswahl als runde Toggle-Chips (Reihenfolge Montag zuerst, 1=Mo … 7=So).
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    private var symbols: [String] { Calendar.current.veryShortStandaloneWeekdaySymbols }
    private var fullSymbols: [String] { Calendar.current.standaloneWeekdaySymbols }

    /// App-Wochentag (1=Mo … 7=So) → Index in Apples Symbol-Array (0=So … 6=Sa)
    private func symbolIndex(for day: Int) -> Int { day == 7 ? 0 : day }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...7, id: \.self) { day in
                let isOn = selection.contains(day)
                Button {
                    toggle(day)
                } label: {
                    Text(symbols[symbolIndex(for: day)])
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(isOn ? Color.white : Color.primary)
                        .background(
                            Circle().fill(isOn ? Color.gruenPrimary : Color(UIColor.tertiarySystemFill))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(fullSymbols[symbolIndex(for: day)])
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func toggle(_ day: Int) {
        if selection.contains(day) {
            // Mindestens ein Tag muss aktiv bleiben.
            guard selection.count > 1 else { return }
            selection.remove(day)
        } else {
            selection.insert(day)
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
