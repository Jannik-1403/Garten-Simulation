import SwiftUI

struct AddCleaningTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: CleaningManager
    
    @State private var taskName = ""
    @State private var frequencyDays = 7
    @State private var selectedIcon = "bed.double.fill"
    
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
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                                .foregroundColor(selectedIcon == icon ? .blue : .primary)
                                .onTapGesture {
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
                        // For custom tasks, we use the literal name as the key and let SwiftUI render it (or handle it in a way that just displays the text if no localizable key is found)
                        // Ideally we would add a flag to CleaningTask like `isCustom: Bool` to not translate it, but we can pass the exact string as key. If missing in xcstrings, SwiftUI displays the key itself.
                        manager.addTask(nameKey: taskName, iconName: selectedIcon, frequencyDays: frequencyDays)
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
