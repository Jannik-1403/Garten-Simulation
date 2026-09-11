import SwiftUI

struct AddCleaningTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    
    @State private var taskName = ""
    @State private var frequencyDays = 7
    @State private var selectedIcon = "bed.double.fill"
    @State private var selectedWeekday: Int = 0 // 0 = None, 1 = Sunday, 2 = Monday, etc.
    
    let icons = ["bed.double.fill", "wind", "trash.fill", "tshirt.fill", "squareshape.split.2x2", "shower.fill", "toilet.fill", "sink.fill", "fork.knife", "sparkles"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(String(localized: "cleaning.add.name", defaultValue: "Aufgabe"))) {
                    TextField(String(localized: "cleaning.add.placeholder", defaultValue: "z.B. Küche putzen"), text: $taskName)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            let suggestions = [
                                (nameKey: "cleaning.task.bed", icon: "bed.double.fill", days: 7),
                                (nameKey: "cleaning.task.room", icon: "squareshape.split.2x2", days: 3),
                                (nameKey: "cleaning.task.kitchen", icon: "fork.knife", days: 2)
                            ]
                            ForEach(suggestions, id: \.nameKey) { suggestion in
                                Button(action: {
                                    taskName = String(localized: String.LocalizationValue(suggestion.nameKey))
                                    selectedIcon = suggestion.icon
                                    frequencyDays = suggestion.days
                                }) {
                                    Text(String(localized: String.LocalizationValue(suggestion.nameKey)))
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text(String(localized: "cleaning.add.icon", defaultValue: "Icon"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Item3DPillButton(
                                icon: icon,
                                farbe: selectedIcon == icon ? .blue : Color(UIColor.systemBackground),
                                sekundaerFarbe: selectedIcon == icon ? Color(UIColor.systemBlue).opacity(0.5) : Color(UIColor.systemGray5),
                                groesse: 44
                            ) {
                                selectedIcon = icon
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(String(localized: "cleaning.add.interval", defaultValue: "Intervall (Tage)"))) {
                    HStack {
                        TextField("7", value: $frequencyDays, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text(String(localized: "cleaning.add.days", defaultValue: "Tage"))
                    }
                    
                    Picker(String(localized: "cleaning.add.weekday", defaultValue: "Fester Wochentag"), selection: $selectedWeekday) {
                        Text(String(localized: "cleaning.weekday.none", defaultValue: "Egal")).tag(0)
                        Text(String(localized: "cleaning.weekday.sunday", defaultValue: "Sonntag")).tag(1)
                        Text(String(localized: "cleaning.weekday.monday", defaultValue: "Montag")).tag(2)
                        Text(String(localized: "cleaning.weekday.tuesday", defaultValue: "Dienstag")).tag(3)
                        Text(String(localized: "cleaning.weekday.wednesday", defaultValue: "Mittwoch")).tag(4)
                        Text(String(localized: "cleaning.weekday.thursday", defaultValue: "Donnerstag")).tag(5)
                        Text(String(localized: "cleaning.weekday.friday", defaultValue: "Freitag")).tag(6)
                        Text(String(localized: "cleaning.weekday.saturday", defaultValue: "Samstag")).tag(7)
                    }
                }
            }
            .navigationTitle(String(localized: "cleaning.add.title", defaultValue: "Neue Aufgabe"))
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
                        manager.addTask(nameKey: taskName, iconName: selectedIcon, frequencyDays: frequencyDays, scheduledWeekday: weekdayToSave)
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
