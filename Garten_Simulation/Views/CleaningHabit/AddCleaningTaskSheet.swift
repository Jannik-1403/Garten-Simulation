import SwiftUI

struct AddCleaningTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    
    @State private var taskName = ""
    @State private var frequencyDays = 7
    @State private var selectedIcon = "bed.double.fill"
    @State private var selectedWeekday: Int = 0
    @State private var selectedColorKey = "gruenPrimary"
    
    let icons = [
        "bed.double.fill", "wind", "trash.fill", "tshirt.fill",
        "squareshape.split.2x2", "shower.fill", "toilet.fill", "sink.fill",
        "fork.knife", "sparkles", "house.fill", "leaf.fill",
        "drop.fill", "bubbles.and.sparkles.fill", "dishwasher.fill", "washer.fill",
        "car.fill", "pawprint.fill", "desktopcomputer", "books.vertical.fill"
    ]
    
    let colorOptions: [(key: String, color: Color)] = [
        ("gruenPrimary", .gruenPrimary),
        ("blauPrimary", .blauPrimary),
        ("orangePrimary", .orangePrimary),
        ("rotPrimary", .rotPrimary),
        ("lilaPrimary", .lilaPrimary),
        ("mint", .mint),
        ("teal", .teal),
        ("cyan", .cyan),
        ("pink", .pink),
        ("indigo", .indigo),
        ("yellow", .yellow),
        ("brown", .brown),
    ]
    
    var selectedColor: Color { AppColors.color(for: selectedColorKey) }
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Name + Suggestions
                Section(header: Text(String(localized: "cleaning.add.name", defaultValue: "Aufgabe"))) {
                    TextField(String(localized: "cleaning.add.placeholder", defaultValue: "z.B. Küche putzen"), text: $taskName)
                    
                    // Suggestions – extra .padding(.top) um Clipping zu verhindern
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            let suggestions = [
                                (nameKey: "cleaning.task.bed", icon: "bed.double.fill", days: 7),
                                (nameKey: "cleaning.task.room", icon: "squareshape.split.2x2", days: 3),
                                (nameKey: "cleaning.task.kitchen", icon: "fork.knife", days: 2)
                            ]
                            ForEach(suggestions, id: \.nameKey) { s in
                                Item3DPillButton(
                                    farbe: Color(UIColor.systemBackground),
                                    sekundaerFarbe: Color(UIColor.systemGray5),
                                    groesse: 44
                                ) {
                                    taskName = String(localized: String.LocalizationValue(s.nameKey))
                                    selectedIcon = s.icon
                                    frequencyDays = s.days
                                } label: {
                                    Text(String(localized: String.LocalizationValue(s.nameKey)))
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                        .padding(.vertical, 8) // prevents top clipping of 3D shadow
                        .padding(.horizontal, 2)
                    }
                }
                
                // MARK: - Icon
                Section(header: Text(String(localized: "cleaning.add.icon", defaultValue: "Icon"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 14) {
                        ForEach(icons, id: \.self) { icon in
                            Item3DButton(
                                farbe: selectedIcon == icon ? selectedColor : Color(UIColor.systemBackground),
                                sekundaerFarbe: selectedIcon == icon ? selectedColor.darker(by: 0.15) : Color(UIColor.systemGray5),
                                groesse: 52,
                                aktion: { selectedIcon = icon }
                            ) {
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Farbe
                Section(header: Text(String(localized: "cleaning.add.color", defaultValue: "Farbe"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colorOptions, id: \.key) { option in
                            Item3DButton(
                                farbe: option.color,
                                sekundaerFarbe: option.color.darker(by: 0.15),
                                groesse: 44,
                                aktion: { selectedColorKey = option.key }
                            ) {
                                if selectedColorKey == option.key {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Intervall
                Section(header: Text(String(localized: "cleaning.add.interval", defaultValue: "Intervall (Tage)"))) {
                    // iOS Wheel-Picker
                    Picker(String(localized: "cleaning.add.days", defaultValue: "Tage"), selection: $frequencyDays) {
                        ForEach(1...90, id: \.self) { day in
                            Text("\(day) \(day == 1 ? String(localized: "cleaning.add.day.singular", defaultValue: "Tag") : String(localized: "cleaning.add.days", defaultValue: "Tage"))")
                                .tag(day)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 130)
                    
                    Picker(String(localized: "cleaning.add.weekday", defaultValue: "Fester Wochentag"), selection: $selectedWeekday) {
                        Text(String(localized: "cleaning.weekday.none", defaultValue: "Egal")).tag(0)
                        Text(String(localized: "cleaning.weekday.monday", defaultValue: "Montag")).tag(2)
                        Text(String(localized: "cleaning.weekday.tuesday", defaultValue: "Dienstag")).tag(3)
                        Text(String(localized: "cleaning.weekday.wednesday", defaultValue: "Mittwoch")).tag(4)
                        Text(String(localized: "cleaning.weekday.thursday", defaultValue: "Donnerstag")).tag(5)
                        Text(String(localized: "cleaning.weekday.friday", defaultValue: "Freitag")).tag(6)
                        Text(String(localized: "cleaning.weekday.saturday", defaultValue: "Samstag")).tag(7)
                        Text(String(localized: "cleaning.weekday.sunday", defaultValue: "Sonntag")).tag(1)
                    }
                }
            }
            .navigationTitle(String(localized: "cleaning.add.title.short", defaultValue: "Neu"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "common.save", defaultValue: "Speichern")) {
                        let weekdayToSave = selectedWeekday == 0 ? nil : selectedWeekday
                        manager.addTask(
                            nameKey: taskName,
                            iconName: selectedIcon,
                            frequencyDays: frequencyDays,
                            scheduledWeekday: weekdayToSave,
                            colorHex: selectedColorKey
                        )
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
