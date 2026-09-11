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
                }
                
                Section(header: Text(String(localized: "cleaning.add.icon", defaultValue: "Icon"))) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                                .foregroundColor(selectedIcon == icon ? .blue : .white)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(String(localized: "cleaning.add.interval", defaultValue: "Intervall (Tage)"))) {
                    Stepper(value: $frequencyDays, in: 1...365) {
                        Text("\(frequencyDays) " + String(localized: "cleaning.add.days", defaultValue: "Tage"))
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
            .preferredColorScheme(.dark)
        }
    }
}
