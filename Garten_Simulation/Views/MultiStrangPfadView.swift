import SwiftUI

struct MultiStrangPfadView: View {
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    /// When set, filtered to one habit
    var filterHabit: HabitModel? = nil

    @State private var selectedPage: Int = 0
    @State private var initialized = false
    @State private var pathCheckAttempts = 0
    @State private var showDayPicker = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if !initialized && pfadStore.straenge.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TabView(selection: $selectedPage) {
                        ForEach(1...90, id: \.self) { day in
                            if let taskTag = findTag(for: day) {
                                DailyTaskCardView(tag: taskTag)
                                    .tag(day - 1)
                            } else {
                                // Fallback if no tag found for this day
                                VStack {
                                    Text(String(format: String(localized: "common.day_format"), String(day)))
                                    Text(String(localized: "path.no_task"))
                                        .foregroundStyle(.secondary)
                                }
                                .tag(day - 1)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            
            // Orange Calendar Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Item3DButton(
                        icon: "calendar",
                        farbe: .orangePrimary,
                        sekundaerFarbe: .orangeSecondary,
                        groesse: 44,
                        iconSkalierung: 0.55
                    ) {
                        showDayPicker = true
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showDayPicker) {
            DayPickerView(selectedDay: $selectedPage, heute: pfadStore.tagHeute())
        }
        .onAppear {
            calculateInitialPage()
            initialized = true
            attemptPathEnsure()
        }
    }

    private func findTag(for day: Int) -> PfadStrangTag? {
        let straenge = pfadStore.straenge
        let alleTags = pfadStore.alleTags
        
        // If filtering, only look at that habit's strand
        if let filter = filterHabit {
            if let strang = straenge.first(where: { $0.pflanzenID == filter.id }) {
                return alleTags.first(where: { $0.strang?.id == strang.id && $0.tagNummer == day })
            }
        } else {
            // Global mode: maybe show the first active habit's task?
            // Usually the user enters from a specific plant, but for the global tab we pick the first one
            if let firstStrang = straenge.first {
                return alleTags.first(where: { $0.strang?.id == firstStrang.id && $0.tagNummer == day })
            }
        }
        return nil
    }

    private func calculateInitialPage() {
        // Find current day based on progress
        let heute = pfadStore.tagHeute()
        selectedPage = max(0, heute - 1)
    }

    private func attemptPathEnsure() {
        guard let garden = pfadStore.gardenStore else {
            if pathCheckAttempts < 5 {
                pathCheckAttempts += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    attemptPathEnsure()
                }
            }
            return
        }
        pfadStore.ensureEveryPlantHasPath(gardenStore: garden)
    }
}

// MARK: - Daily Task Card View (The actual UI from the screenshot)
struct DailyTaskCardView: View {
    let tag: PfadStrangTag
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (TAG X / Phase)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: String(localized: "common.day_format"), String(tag.tagNummer)).uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(tag.phase.farbe)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // 2. Hero Image
                    if let s = tag.strang, 
                       let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }),
                       let plant = GameDatabase.shared.plant(for: habit.plantID) {
                        if let asset = plant.assetName {
                            Image(asset)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .shadow(color: .black.opacity(0.1), radius: 15, y: 10)
                                .padding(.top, 20)
                        }
                    }
                    
                    // 3. Status Badge
                    statusBadge
                    
                    // 4. Task Title & Description
                    VStack(spacing: 12) {
                        Text(localizedTitle)
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text(localizedDescription)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 30)
                    }
                    
                    // 5. Progress Box
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(format: String(localized: "path.day_progress_format"), String(tag.tagNummer)))
                                .font(.system(size: 14, weight: .black, design: .rounded))
                            Spacer()
                            Text(String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(tag.phase.farbe)
                        }
                        
                        // Mini Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.primary.opacity(0.05))
                                Capsule()
                                    .fill(tag.phase.farbe)
                                    .frame(width: geo.size.width * CGFloat(tag.tagNummer) / 90.0)
                            }
                        }
                        .frame(height: 8)
                        
                        Text(String(localized: "pfad_phase_beschreibung_\(tag.phase.rawValue)"))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color.primary.opacity(0.03), in: RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 32)
                    
                    // 6. Action Button (Inside ScrollView now)
                    if isActionable && !tag.istErledigt {
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                        } label: {
                            Text(String(localized: "pfad_tag_erledigen").uppercased())
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .medium,
                            fillWidth: true,
                            backgroundColor: tag.phase.farbe,
                            shadowColor: tag.phase.farbe.darker()
                        ))
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    } else if tag.istErledigt {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.green)
                            Text(String(localized: "erledigt_status").uppercased())
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(.bottom, 40)
                    } else if isLockedUntilTomorrow {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                            Text(String(localized: "pfad_morgen_verfuegbar"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 40)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var isActionable: Bool {
        guard let strang = tag.strang else { return false }
        let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        
        // It must be the first incomplete day
        if tag.id != firstIncomplete.id { return false }
        
        // AND it must not be locked until tomorrow
        if isLockedUntilTomorrow { return false }
        
        return true
    }
    
    private var isLockedUntilTomorrow: Bool {
        return false
    }
    
    private var isToday: Bool {
        guard let strang = tag.strang else { return false }
        let alleTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        return tag.id == firstIncomplete.id
    }

    private var statusBadge: some View {
        Group {
            if isToday && !tag.istErledigt {
                Text(String(localized: "heute_status"))
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            } else if tag.istErledigt {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var localizedTitle: String {
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
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName)
    }

    private var localizedDescription: String {
        let diff: String = {
            if let s = tag.strang, let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
                return habit.individualSchwierigkeit ?? "anfaenger"
            }
            return "anfaenger"
        }()
        
        let h = tag.strang.flatMap { s in gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) }
        if let plantID = h?.plantID,
           let dyn = HabitProgressionGenerator.generateProgression(for: plantID, dayNum: tag.tagNummer, difficulty: diff, language: settings.appLanguage) {
            return dyn.dailyDescription.replacingOccurrences(of: "[HABIT]", with: habitName)
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
                raw = String(localized: "pfad_schwierigkeit_\(diff)_desc")
            }
        }
        
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName)
    }
    
    private var habitName: String {
        guard let s = tag.strang else { return "" }
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
}
