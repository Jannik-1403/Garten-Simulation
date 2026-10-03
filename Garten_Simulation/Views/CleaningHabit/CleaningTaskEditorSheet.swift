import SwiftUI

struct CleaningTaskEditorSheet: View {
    @Environment(\.dismiss) var dismiss

    let task: CleaningTask?
    let onSave: (CleaningTask) -> Void
    var onDelete: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var iconName: String = "sparkles"
    @State private var colorKey: String = "gruenPrimary"
    @State private var recurrenceDays: Int = 1
    @State private var startDate: Date = Date()
    @State private var showDeleteConfirmation = false

    let icons = [
        "sparkles", "bed.double.fill", "trash.fill", "tshirt.fill",
        "squareshape.split.2x2", "shower.fill", "toilet.fill", "sink.fill",
        "fork.knife", "house.fill", "leaf.fill", "drop.fill",
        "bubbles.and.sparkles.fill", "dishwasher.fill", "washer.fill", "car.fill"
    ]

    let colorOptions: [(key: String, color: Color)] = [
        ("gruenPrimary", .gruenPrimary), ("blauPrimary", .blauPrimary),
        ("orangePrimary", .orangePrimary), ("rotPrimary", .rotPrimary),
        ("lilaPrimary", .lilaPrimary), ("mint", .mint), ("teal", .teal)
    ]

    init(task: CleaningTask?, onSave: @escaping (CleaningTask) -> Void, onDelete: (() -> Void)? = nil) {
        self.task = task
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: task?.name ?? "")
        _iconName = State(initialValue: task?.iconName ?? "sparkles")
        _colorKey = State(initialValue: task?.colorKey ?? "gruenPrimary")
        _startDate = State(initialValue: task?.startDate ?? Date())
        
        if let recurrence = task?.recurrence {
            switch recurrence {
            case .everyNDays(let days):
                _recurrenceDays = State(initialValue: days)
            case .weekly(_, _):
                // For simplicity in this editor, we'll map weekly back to 7 days
                _recurrenceDays = State(initialValue: 7)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "cleaning.add.name", defaultValue: "Aufgabe"))) {
                    TextField(String(localized: "cleaning.add.placeholder", defaultValue: "z.B. Küche putzen"), text: $name)
                }

                Section(header: Text(String(localized: "cleaning.add.icon", defaultValue: "Icon"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 14) {
                        ForEach(icons, id: \.self) { icon in
                            Item3DButton(
                                farbe: iconName == icon ? AppColors.color(for: colorKey) : Color(UIColor.systemBackground),
                                sekundaerFarbe: iconName == icon ? AppColors.color(for: colorKey).darker() : Color(UIColor.systemGray5),
                                groesse: 52,
                                aktion: { iconName = icon }
                            ) {
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(iconName == icon ? .white : .primary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text(String(localized: "cleaning.add.color", defaultValue: "Farbe"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colorOptions, id: \.key) { option in
                            Item3DButton(
                                farbe: option.color,
                                sekundaerFarbe: option.color.darker(),
                                groesse: 44,
                                aktion: { colorKey = option.key }
                            ) {
                                if colorKey == option.key {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text(String(localized: "cleaning.add.interval", defaultValue: "Intervall"))) {
                    Stepper(value: $recurrenceDays, in: 1...365) {
                        Text("\(recurrenceDays) \(recurrenceDays == 1 ? String(localized: "cleaning.add.day.singular", defaultValue: "Tag") : String(localized: "cleaning.add.days", defaultValue: "Tage"))")
                    }
                    DatePicker(String(localized: "cleaning.add.firstDue", defaultValue: "Startdatum"), selection: $startDate, displayedComponents: .date)
                }

                if task != nil, onDelete != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Text(String(localized: "button.delete", defaultValue: "Löschen"))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? String(localized: "cleaning.add.title.short", defaultValue: "Neue Aufgabe") : String(localized: "cleaning.edit.title", defaultValue: "Aufgabe bearbeiten"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        saveTask()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .confirmationDialog(String(localized: "cleaning.delete.confirm", defaultValue: "Aufgabe löschen?"), isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button(String(localized: "cleaning.delete.action", defaultValue: "Löschen"), role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button(String(localized: "button.cancel"), role: .cancel) {}
            }
        }
    }

    private func saveTask() {
        var updatedTask = task ?? CleaningTask(
            name: name,
            iconName: iconName,
            colorKey: colorKey,
            recurrence: .everyNDays(recurrenceDays),
            startDate: startDate
        )
        
        updatedTask.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedTask.iconName = iconName
        updatedTask.colorKey = colorKey
        updatedTask.recurrence = .everyNDays(recurrenceDays)
        updatedTask.startDate = startDate
        
        onSave(updatedTask)
        dismiss()
    }
}
