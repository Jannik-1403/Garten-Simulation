import SwiftUI

struct GratitudeJournalView: View {
    @ObservedObject var habit: HabitModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    
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
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Mood Section
                        VStack(spacing: 16) {
                            Text(String(localized: "habit.gratitude.mood.title", defaultValue: "Wie hast du dich heute gefühlt?"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { i in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            mood = i
                                        }
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }) {
                                        Image("Powerup")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44, height: 44)
                                            .opacity(i <= mood ? 1.0 : 0.3)
                                            .scaleEffect(i <= mood ? 1.1 : 1.0)
                                            .animation(.spring(), value: mood)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // Thankful For
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "habit.gratitude.thankful.title", defaultValue: "Wofür warst du heute dankbar?"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            
                            TextField(String(localized: "habit.gratitude.thankful.placeholder", defaultValue: "Z.B. für einen Spaziergang in der Sonne..."), text: $thankfulFor, axis: .vertical)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .lineLimit(2...4)
                                .frame(minHeight: 80, alignment: .topLeading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                )
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(chips, id: \.self) { chip in
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            if !thankfulFor.isEmpty && !thankfulFor.hasSuffix(" ") {
                                                thankfulFor += ", "
                                            }
                                            thankfulFor += chip
                                        }) {
                                            Text(chip)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                        }
                                        .background(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gruenPrimary.darker())
                                                    .offset(y: 3)
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.gruenPrimary)
                                            }
                                        )
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.bottom, 6)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // Toggle Full Reflection
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showFullReflection.toggle()
                            }
                        }) {
                            HStack {
                                Text(showFullReflection ? String(localized: "habit.gratitude.collapse.title", defaultValue: "Weniger anzeigen") : String(localized: "habit.gratitude.expand.title", defaultValue: "Volle Reflexion"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.blauPrimary)
                                Image(systemName: showFullReflection ? "chevron.up" : "chevron.down")
                                    .font(.headline)
                                    .foregroundColor(.blauPrimary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        }
                        
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
                            Text(String(localized: "habit.gratitude.save_button", defaultValue: "Eintrag speichern"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 24)
                        }
                        .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: mood == 0 ? .gray : .gruenPrimary, shadowColor: mood == 0 ? .gray.opacity(0.8) : .gruenPrimary.darker(), foregroundColor: .white))
                        .disabled(mood == 0)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(String(localized: "habit.gratitude.fast_mode.title", defaultValue: "Schnell-Tagesreview"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private func reflectionField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            TextField(placeholder, text: text, axis: .vertical)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .lineLimit(2...5)
                .frame(minHeight: 100, alignment: .topLeading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
    
    private func saveEntry() {
        let entry = GratitudeJournalEntry(
            date: Date(),
            mood: mood,
            thankfulFor: thankfulFor.trimmingCharacters(in: .whitespacesAndNewlines),
            wentWell: wentWell.trimmingCharacters(in: .whitespacesAndNewlines),
            doDifferently: doDifferently.trimmingCharacters(in: .whitespacesAndNewlines),
            improveTomorrow: improveTomorrow.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        habit.journalEntries.append(entry)
        gardenStore.savePlants()
        
        dismiss()
    }
}

struct GratitudeJournalDetailView: View {
    let entry: GratitudeJournalEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Mood Section
                        VStack(spacing: 16) {
                            Text(String(localized: "habit.gratitude.mood.title", defaultValue: "Wie hast du dich heute gefühlt?"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { i in
                                    Image("Powerup")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 44, height: 44)
                                        .opacity(i <= entry.mood ? 1.0 : 0.3)
                                        .scaleEffect(i <= entry.mood ? 1.1 : 1.0)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        
                        // Thankful For
                        detailField(
                            title: String(localized: "habit.gratitude.thankful.title", defaultValue: "Wofür warst du heute dankbar?"),
                            text: entry.thankfulFor
                        )
                        
                        // Went well
                        if !entry.wentWell.isEmpty {
                            detailField(
                                title: String(localized: "habit.gratitude.well_done.title", defaultValue: "Was hast du heute gut gemacht?"),
                                text: entry.wentWell
                            )
                        }
                        
                        // Do differently
                        if !entry.doDifferently.isEmpty {
                            detailField(
                                title: String(localized: "habit.gratitude.differently.title", defaultValue: "Was würdest du rückblickend anders machen?"),
                                text: entry.doDifferently
                            )
                        }
                        
                        // Improve tomorrow
                        if !entry.improveTomorrow.isEmpty {
                            detailField(
                                title: String(localized: "habit.gratitude.tomorrow.title", defaultValue: "Was möchtest du morgen besser machen?"),
                                text: entry.improveTomorrow
                            )
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(entry.date.formatted(date: .long, time: .shortened))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private func detailField(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(text.isEmpty ? "-" : text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
    }
}
