import SwiftUI

struct GratitudeJournalView: View {
    @ObservedObject var habit: HabitModel
    @Environment(\.dismiss) var dismiss
    
    @State private var mood: Int = 0 // 1-5
    @State private var thankfulFor: String = ""
    @State private var wentWell: String = ""
    @State private var doDifferently: String = ""
    @State private var improveTomorrow: String = ""
    
    @State private var showFullReflection: Bool = false
    
    let chips = [
        String(localized: "habit.gratitude.chip.family", defaultValue: "Familie"),
        String(localized: "habit.gratitude.chip.health", defaultValue: "Gesundheit"),
        String(localized: "habit.gratitude.chip.work", defaultValue: "Arbeit"),
        String(localized: "habit.gratitude.chip.friends", defaultValue: "Freunde"),
        String(localized: "habit.gratitude.chip.small_things", defaultValue: "Kleinigkeit"),
        String(localized: "habit.gratitude.chip.sport", defaultValue: "Sport"),
        String(localized: "habit.gratitude.chip.nature", defaultValue: "Natur")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Mood Section
                    VStack(spacing: 12) {
                        Item3DText(text: String(localized: "habit.gratitude.mood.title", defaultValue: "Wie hast du dich heute gefühlt?"), size: 20)
                        
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { i in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        mood = i
                                    }
                                }) {
                                    Text(moodEmoji(for: i))
                                        .font(.system(size: mood == i ? 44 : 32))
                                        .shadow(color: .black.opacity(mood == i ? 0.3 : 0.1), radius: mood == i ? 5 : 2, y: mood == i ? 5 : 2)
                                        .scaleEffect(mood == i ? 1.1 : 1.0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(Color("hintergrund").opacity(0.5))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    
                    // Thankful For
                    VStack(alignment: .leading, spacing: 12) {
                        Item3DText(text: String(localized: "habit.gratitude.thankful.title", defaultValue: "Wofür warst du heute dankbar?"), size: 20)
                        
                        TextField(String(localized: "habit.gratitude.thankful.placeholder", defaultValue: "Z.B. für einen Spaziergang in der Sonne..."), text: $thankfulFor, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(chips, id: \.self) { chip in
                                    Button(action: {
                                        if !thankfulFor.isEmpty && !thankfulFor.hasSuffix(" ") {
                                            thankfulFor += ", "
                                        }
                                        thankfulFor += chip
                                    }) {
                                        Text(chip)
                                            .font(.subheadline).bold()
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color("gruenPrimary"))
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                            .shadow(color: Color("gruenPrimary").opacity(0.4), radius: 4, y: 2)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color("hintergrund").opacity(0.5))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
                    
                    // Toggle Full Reflection
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showFullReflection.toggle()
                        }
                    }) {
                        HStack {
                            Item3DText(text: showFullReflection ? String(localized: "habit.gratitude.collapse.title", defaultValue: "Weniger anzeigen") : String(localized: "habit.gratitude.expand.title", defaultValue: "Volle Reflexion"), size: 16, color: Color("blauPrimary"))
                            Image(systemName: showFullReflection ? "chevron.up" : "chevron.down")
                                .font(.headline)
                                .foregroundColor(Color("blauPrimary"))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    }
                    .padding(.horizontal)
                    
                    if showFullReflection {
                        VStack(spacing: 24) {
                            reflectionField(
                                title: String(localized: "habit.gratitude.well_done.title", defaultValue: "Was hast du heute gut gemacht?"),
                                placeholder: String(localized: "habit.gratitude.well_done.placeholder", defaultValue: "Z.B. an meiner Aufgabe drangeblieben..."),
                                text: $wentWell
                            )
                            
                            reflectionField(
                                title: String(localized: "habit.gratitude.differently.title", defaultValue: "Was würdest du rückblickend anders machen?"),
                                placeholder: String(localized: "habit.gratitude.differently.placeholder", defaultValue: "Z.B. mich nicht über Kleinigkeiten ärgern..."),
                                text: $doDifferently
                            )
                            
                            reflectionField(
                                title: String(localized: "habit.gratitude.tomorrow.title", defaultValue: "Was möchtest du morgen besser machen?"),
                                placeholder: String(localized: "habit.gratitude.tomorrow.placeholder", defaultValue: "Z.B. 10 Minuten früher schlafen gehen..."),
                                text: $improveTomorrow
                            )
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Save Button
                    Button(action: saveEntry) {
                        Item3DText(text: String(localized: "habit.gratitude.save_button", defaultValue: "Eintrag speichern"), size: 20, color: .white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mood == 0 ? Color.gray : Color("gruenPrimary"))
                            .cornerRadius(16)
                            .shadow(color: (mood == 0 ? Color.gray : Color("gruenPrimary")).opacity(0.4), radius: 8, y: 4)
                    }
                    .disabled(mood == 0)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(String(localized: "habit.gratitude.fast_mode.title", defaultValue: "Schnell-Tagesreview"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    private func reflectionField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Item3DText(text: title, size: 18)
            TextField(placeholder, text: text, axis: .vertical)
                .lineLimit(2...5)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        }
        .padding()
        .background(Color("hintergrund").opacity(0.5))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
    }
    
    private func moodEmoji(for value: Int) -> String {
        switch value {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "🤩"
        default: return "😶"
        }
    }
    
    private func saveEntry() {
        let entry = GratitudeJournalEntry(
            date: Date(),
            mood: mood,
            thankfulFor: thankfulFor.trimmingCharacters(in: .whitespacesAndNewlines),
            wentWell: wentWell.trimmingCharacters(in: .whitespacesAndNewlines),
            doDifferently: doDifferently.trimmingCharacters(in: .whitespacesAndNewlines),
            improveTomorrow: improveTomorrow.trimmingCharacters(in: .whitespacesAndNewlines),
            habitId: habit.id
        )
        
        habit.journalEntries.append(entry)
        
        dismiss()
    }
}

#Preview {
    GratitudeJournalView(habit: HabitModel(name: "Test", symbolName: "star"))
}
