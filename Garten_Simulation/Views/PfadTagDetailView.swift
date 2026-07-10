import SwiftUI
import Combine

struct PfadTagDetailView: View {
    let tag: PfadStrangTag
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @Environment(\.dismiss) var dismiss
    @State private var showingFocusSession = false
    
    private var themeColor: Color {
        Color(hex: tag.strang?.farbe ?? "#58CC02")
    }
    
    var body: some View {
        ZStack {
            // GARDEN BACKGROUND LAYER
            gardenBackground
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        let headerKey = String(localized: "pfad_tag_header")
                        Text(String(format: headerKey, tag.tagNummer))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(tag.phase.farbe)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(uiColor: .systemGray3))
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial.opacity(0.8))
                
                Divider().padding(.horizontal, 24)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 24) {
                        
                        // Hero Plant Display
                        if let s = tag.strang, 
                           let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }),
                           let plant = GameDatabase.shared.plant(for: habit.plantID) {
                            ZStack(alignment: .bottomTrailing) {
                                heroPlantImage(plant: plant, isDone: tag.istErledigt)
                                    .frame(width: 140, height: 140)
                                    
                                if tag.istMeilenstein {
                                    let rewardIcon: String? = {
                                        switch tag.tagNummer {
                                        case 7, 21, 45: return "coin"
                                        case 14: return "Unkraut_Schild"
                                        case 30: return "Powerup-Zeitkapsel"
                                        case 60: return "Powerup-Glückssegen"
                                        case 90: return "Achievment_Gold"
                                        default: return nil
                                        }
                                    }()
                                    
                                    if let icon = rewardIcon {
                                        Image(icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 48, height: 48)
                                            .background(Circle().fill(.white).shadow(radius: 4))
                                            .offset(x: 10, y: 10)
                                    }
                                }
                            }
                            .padding(.top, 24)
                        } else {
                            // Fallback Igel
                            Image(tag.igelAsset)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 140, height: 140)
                                .padding(.top, 24)
                        }

                        // Status Badge
                        if tag.istErledigt {
                            Text(String(format: String(localized: "pfad_done_prefix"), String(localized: "erledigt_status")))
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .clipShape(Capsule())
                        } else if !isToday(tag: tag) {
                            lockedStateView
                                .padding(.top, -8)
                        } else {
                            Text(String(localized: "heute_status"))
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(themeColor.opacity(0.15))
                                .foregroundColor(themeColor)
                                .clipShape(Capsule())
                        }

                        // Task Title
                        Text(localizedTitle(for: tag))
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 24)
                        
                        // Task Description
                        Text(localizedDescription(for: tag))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 24)
                    }
                }
                .padding(.bottom, 40)
                
                // Footer: Unified Completion Button
                if !tag.istErledigt && isToday(tag: tag) {
                    VStack(spacing: 16) {
                        if let s = tag.strang, let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
                            Button {
                                showingFocusSession = true
                            } label: {
                                Text(String(localized: "fokus.starten", defaultValue: "Fokus Timer"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .large,
                                backgroundColor: themeColor,
                                shadowColor: themeColor.darker(),
                                foregroundColor: .white
                            ))
                            .fullScreenCover(isPresented: $showingFocusSession) {
                                FocusSessionView(pflanze: habit)
                            }
                            
                            Button {
                                pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    dismiss()
                                }
                            } label: {
                                Text(String(localized: "jetzt.abschliessen", defaultValue: "Jetzt abschließen"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                        } else {
                            Button {
                                pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    dismiss()
                                }
                            } label: {
                                Text(String(localized: "pfad_tag_erledigen", defaultValue: "Erledigen"))
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .large,
                                backgroundColor: themeColor,
                                shadowColor: themeColor.darker(),
                                foregroundColor: .white
                            ))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    @ViewBuilder
    private var gardenBackground: some View {
        ZStack {
            // Environmental Gradient
            LinearGradient(colors: [Color(uiColor: .systemBackground), themeColor.opacity(0.05)], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
    }



    @ViewBuilder
    private func heroPlantImage(plant: Plant, isDone: Bool) -> some View {
        if let assetName = plant.assetName {
            Image(assetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .grayscale(isDone ? 0 : 0.4)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDone)
        }
    }



    @ViewBuilder
    private var lockedStateView: some View {
        if !tag.istErledigt {
            if let strang = tag.strang {
                let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
                if let firstIncomplete = alleTags.first(where: { !$0.istErledigt }), tag.id == firstIncomplete.id {
                    let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
                    let diffHours = Calendar.current.dateComponents([.hour], from: Date(), to: nextMidnight).hour ?? 0
                    
                    Text(String(localized: "pfad_morgen_verfuegbar", defaultValue: "Verfügbar in \(diffHours) Std."))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                } else {
                    Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                }
            } else {
                Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(.gray)
                    .clipShape(Capsule())
            }
        }
    }

    // Existing helpers remain same...
    private func isToday(tag: PfadStrangTag) -> Bool {
        guard let strang = tag.strang else { return false }
        
        // 1. Tag ist bereits fertig? -> Nicht heute (also nicht anklickbar)
        if tag.istErledigt { return false }
        
        // 2. Finde den ersten NICHT erledigten Tag im Strang
        let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else {
            return false // Alles erledigt
        }
        
        // Es ist nur "heute" (actionable), wenn es dieser ERSTE nicht erledigte Tag ist
        if tag.id != firstIncomplete.id { return false }
        
        // 3. Wenn es nicht Tag 1 ist, prüfen wir den VORHERIGEN Tag.
        if tag.tagNummer > 1 {
            if let prevTag = alleTags.first(where: { $0.tagNummer == tag.tagNummer - 1 }) {
                // Wenn prevTag.datum (Erledigungs-Datum) == HEUTE ist, dann ist Tag "locked" bis morgen.
                if let completionDate = prevTag.datum {
                    if Calendar.current.isDateInToday(completionDate) {
                        return false // Geht erst morgen weiter!
                    }
                }
            }
        }
        
        return true
    }
    
    private func countdownText(for datum: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: settings.appLanguage)
        formatter.unitsStyle = .abbreviated
        return String(format: String(localized: "pfad_tag_verfuegbar_in"), formatter.localizedString(for: datum, relativeTo: Date()))
    }
    
    private func habitName(for t: PfadStrangTag) -> String {
        guard let s = t.strang else { return "" }
        // 1. User habit
        if let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
            return NSLocalizedString(habit.displayedHabitName, comment: "")
        }
        // 2. GameDatabase fallback
        if let plant = GameDatabase.shared.plant(for: s.pflanzenID) {
            return NSLocalizedString(plant.habitCategory.localizationKey, comment: "")
        }
        return NSLocalizedString(s.pflanzenName, comment: "")
    }

    private func localizedTitle(for tag: PfadStrangTag) -> String {
        var raw = NSLocalizedString(tag.titelKey, comment: "")
        
        // Failsafe: Wenn der Key nicht übersetzt wurde (roher Schlüssel)
        if raw == tag.titelKey {
            // Versuche generic fallback
            let fallbackKey = tag.titelKey.replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                                          .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            let fallbackRaw = NSLocalizedString(fallbackKey, comment: "")
            if fallbackRaw != fallbackKey {
                raw = fallbackRaw
            } else if tag.istMeilenstein {
                raw = String(localized: "pfad_meilenstein_titel") // Generic fallback
            } else {
                raw = String(localized: "pfad_aufgabe_titel")
            }
        }
        
        // Bereinigen falls Unterstriche auftauchen, obwohl es kein Key mehr sein sollte
        if raw == tag.titelKey { raw = String(localized: "routine_titel") }
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }

    private func localizedDescription(for tag: PfadStrangTag) -> String {
        let diff: String = {
            if let s = tag.strang, let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
                return habit.individualSchwierigkeit ?? "anfaenger"
            }
            return "anfaenger"
        }()
        
        if let plantID = tag.strang?.pflanzenID,
           let dynamicDesc = HabitProgressionGenerator.generateDescription(for: plantID, dayNum: tag.tagNummer, difficulty: diff, language: settings.appLanguage) {
            return dynamicDesc.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
        }

        var raw = NSLocalizedString(tag.beschreibungKey, comment: "")
        
        // Failsafe: Wenn der Key roh zurückkommt, generischen probieren
        if raw == tag.beschreibungKey {
            let fallbackKey = tag.beschreibungKey.replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                                                 .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            
            let fallbackRaw = NSLocalizedString(fallbackKey, comment: "")
            if fallbackRaw != fallbackKey {
                raw = fallbackRaw
            } else {
                if diff == "fortgeschritten" {
                    raw = String(localized: "pfad_schwierigkeit_fortgeschritten_desc", defaultValue: "Steigere die Intensität und festige deine Routine.")
                } else if diff == "profi" {
                    raw = String(localized: "pfad_schwierigkeit_profi_desc", defaultValue: "Meistere diese Gewohnheit auf höchstem Niveau.")
                } else {
                    raw = String(localized: "pfad_schwierigkeit_anfaenger_desc", defaultValue: "Beginne leicht und lerne die Grundlagen dieser Gewohnheit.")
                }
            }
        }
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }
    
    
    @ViewBuilder
    private var journeyProgressBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(format: String(localized: "pfad_progress_format"), tag.tagNummer))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                let phaseLabel = String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)")
                Text(phaseLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(tag.phase.farbe)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(uiColor: .systemGray6))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tag.phase.farbe.opacity(0.8), tag.phase.farbe],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(tag.tagNummer) / 90.0)
                }
            }
            .frame(height: 8)
            
            Text(journeyPhaseDescription)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var journeyPhaseDescription: String {
        String(localized: "pfad_phase_beschreibung_\(tag.phase.rawValue)")
    }
    

}

// MARK: - Garden Aesthetics Components

struct ButterflyView: View {
    @State private var position = CGPoint(x: CGFloat.random(in: 0...50), y: CGFloat.random(in: 0...50))
    @State private var opacity: Double = 0.5
    @State private var scale: CGFloat = 0.5
    
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image(systemName: "butterfly.fill")
            .font(.system(size: 14))
            .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
            .shadow(color: .black.opacity(0.1), radius: 2)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 4)) {
                    position = CGPoint(
                        x: position.x + CGFloat.random(in: -100...100),
                        y: position.y + CGFloat.random(in: -100...100)
                    )
                    opacity = Double.random(in: 0.3...0.7)
                    scale = CGFloat.random(in: 0.4...0.8)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever()) {
                    scale = 0.7
                }
            }
    }
}

struct GrassTuftView: View {
    var body: some View {
        Image("Wildgras")
            .resizable()
            .scaledToFit()
            .frame(width: 20)
            .opacity(0.15)
            .grayscale(0.5)
    }
}
