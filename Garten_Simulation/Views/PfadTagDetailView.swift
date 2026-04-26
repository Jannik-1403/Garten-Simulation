import SwiftUI
import Combine

struct PfadTagDetailView: View {
    let tag: PfadStrangTag
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @Environment(\.dismiss) var dismiss
    
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
                        let headerKey = settings.localizedString(for: "pfad_tag_header")
                        Text(String(format: headerKey, tag.tagNummer))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Text(settings.localizedString(for: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(tag.phase.farbe)
                    }
                    Spacer()
                    LiquidGlassDismissButton { dismiss() }
                }
                .padding(24)
                .background(.ultraThinMaterial.opacity(0.8))
                
                Divider().padding(.horizontal, 24)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 24) {
                        
                        // Hero Plant Display
                        if let s = tag.strang, let plant = GameDatabase.allPlants.first(where: { $0.id == s.pflanzenID }) {
                            heroPlantImage(plant: plant, isDone: tag.istErledigt)
                                .frame(width: 140, height: 140)
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
                            Text("✓ " + settings.localizedString(for: "erledigt_status"))
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
                            Text(settings.localizedString(for: "heute_status"))
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
                            
                        // Journey Progress Bar
                        journeyProgressBar
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)
                    }
                }
                .padding(.bottom, 40)
                
                // Footer: Unified Completion Button
                if isToday(tag: tag) && !tag.istErledigt {
                    Button {
                        pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dismiss()
                        }
                    } label: {
                        Text(settings.localizedString(for: "pfad_tag_erledigen"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: themeColor,
                        shadowColor: themeColor.darker(),
                        foregroundColor: .white
                    ))
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
                .frame(width: 70, height: 70)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .grayscale(isDone ? 0 : 0.4)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDone)
        }
    }



    @ViewBuilder
    private var lockedStateView: some View {
        if !tag.istErledigt {
            // Finde heraus, ob es wegen eines ZUKÜNFTIGEN Datums (Datum von Gestern ist HEUTE) gesperrt ist
            if let strang = tag.strang {
                let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
                if let firstIncomplete = alleTags.first(where: { !$0.istErledigt }), tag.id == firstIncomplete.id {
                    // Es ist der erste unfertige Tag. Warum ist er gesperrt? Weil Vorgänger heute erledigt wurde!
                    Text(settings.localizedString(for: "pfad_morgen_verfuegbar"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 40)
                } else {
                    // Komplett in der Zukunft
                    Text(settings.localizedString(for: "pfad_tag_gesperrt"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 40)
                }
            } else {
                Text(settings.localizedString(for: "pfad_tag_gesperrt"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 40)
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
        return String(format: settings.localizedString(for: "pfad_tag_verfuegbar_in"), formatter.localizedString(for: datum, relativeTo: Date()))
    }
    
    private func habitName(for t: PfadStrangTag) -> String {
        guard let s = t.strang else { return "" }
        // 1. User habit
        if let habit = gardenStore.pflanzen.first(where: { $0.plantID == s.pflanzenID }) {
            return settings.localizedString(for: habit.displayedHabitName)
        }
        // 2. GameDatabase fallback
        if let plant = GameDatabase.allPlants.first(where: { $0.id == s.pflanzenID }) {
            if let catKey = plant.habitCategories.first?.localizationKey {
                return settings.localizedString(for: catKey)
            }
            if !plant.habitName.isEmpty {
                return settings.localizedString(for: plant.habitName)
            }
        }
        return settings.localizedString(for: s.pflanzenName)
    }

    private func localizedTitle(for tag: PfadStrangTag) -> String {
        var raw = settings.localizedString(for: tag.titelKey)
        
        // Failsafe: Wenn der Key nicht übersetzt wurde (roher Schlüssel)
        if raw == tag.titelKey {
            // Versuche generic fallback
            let fallbackKey = tag.titelKey.replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                                          .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            let fallbackRaw = settings.localizedString(for: fallbackKey)
            if fallbackRaw != fallbackKey {
                raw = fallbackRaw
            } else if tag.istMeilenstein {
                raw = settings.localizedString(for: "pfad_meilenstein_titel") // Generic fallback
            } else {
                raw = settings.localizedString(for: "pfad_aufgabe_titel")
            }
        }
        
        // Bereinigen falls Unterstriche auftauchen, obwohl es kein Key mehr sein sollte
        if raw == tag.titelKey { raw = settings.localizedString(for: "routine_titel") }
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }

    private func localizedDescription(for tag: PfadStrangTag) -> String {
        var raw = settings.localizedString(for: tag.beschreibungKey)
        
        // Failsafe: Wenn der Key roh zurückkommt, generischen probieren
        if raw == tag.beschreibungKey {
            let fallbackKey = tag.beschreibungKey.replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                                                 .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            
            let fallbackRaw = settings.localizedString(for: fallbackKey)
            if fallbackRaw != fallbackKey {
                raw = fallbackRaw
            } else {
                // Letzter Ausweg: generische Beschreibung
                raw = settings.localizedString(for: "Bleib konzentriert auf deine Aufgabe: [HABIT]. Jeder Tag zählt auf deiner Reise.")
            }
        }
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }
    
    
    @ViewBuilder
    private var journeyProgressBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(format: settings.localizedString(for: "Tag %d / 90"), tag.tagNummer))
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                let phaseLabel = settings.localizedString(for: "pfad_phase_tag_titel_\(tag.phase.rawValue)")
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
        NSLocalizedString("pfad_phase_beschreibung_\(tag.phase.rawValue)", comment: "")
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
