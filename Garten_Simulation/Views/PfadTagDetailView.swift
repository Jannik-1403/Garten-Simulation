import SwiftUI
import Combine

// MARK: - To-Do Item Model
struct PfadToDo: Identifiable {
    let id = UUID()
    var text: String
    var isDone: Bool = false
}

// MARK: - PfadTagDetailView (iOS-Native Sheet Design)
struct PfadTagDetailView: View {
    let tag: PfadStrangTag
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    @Environment(\.dismiss) var dismiss
    @State private var showingFocusSession = false
    @State private var todos: [PfadToDo] = []
    @State private var newTodoText: String = ""
    @State private var showAddTodo: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable? = nil
    @FocusState private var isTodoFieldFocused: Bool

    private var themeColor: Color {
        Color(hex: tag.strang?.farbe ?? "#58CC02")
    }

    private var plant: Plant? {
        guard let s = tag.strang,
              let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID })
        else { return nil }
        return GameDatabase.shared.plant(for: habit.plantID)
    }

    private var habitModel: HabitModel? {
        guard let s = tag.strang else { return nil }
        return gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID })
    }

    private var isActionable: Bool {
        guard !tag.istErledigt else { return false }
        return isCurrentDay && !isLockedUntilTomorrow
    }

    private var isCurrentDay: Bool {
        guard let strang = tag.strang else { return false }
        let alleTags = strang.tags.sorted { $0.tagNummer < $1.tagNummer }
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        return tag.id == firstIncomplete.id
    }

    private var isLockedUntilTomorrow: Bool {
        guard tag.tagNummer > 1, let strang = tag.strang else { return false }
        let alleTags = strang.tags.sorted { $0.tagNummer < $1.tagNummer }
        if let prevTag = alleTags.first(where: { $0.tagNummer == tag.tagNummer - 1 }),
           let completionDate = prevTag.datum {
            return Calendar.current.isDateInToday(completionDate)
        }
        return false
    }

    private var isFutureDay: Bool {
        guard !tag.istErledigt else { return false }
        guard let strang = tag.strang else { return true }
        let alleTags = strang.tags.sorted { $0.tagNummer < $1.tagNummer }
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        return tag.id != firstIncomplete.id
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Section
                        heroSection
                            .padding(.top, 12)

                        // Countdown / Status Badge
                        statusSection
                            .padding(.top, 20)
                            .padding(.horizontal, 24)

                        // Title
                        Text(localizedTitle(for: tag))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.top, 16)
                            .padding(.horizontal, 24)

                        // Description
                        Text(localizedDescription(for: tag))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 10)
                            .padding(.horizontal, 32)

                        // Progress Bar
                        progressSection
                            .padding(.top, 24)
                            .padding(.horizontal, 24)

                        // To-Do List
                        if !todos.isEmpty || isActionable {
                            todoSection
                                .padding(.top, 24)
                                .padding(.horizontal, 24)
                        }

                        // Action Buttons
                        actionSection
                            .padding(.top, 28)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(format: String(localized: "pfad_tag_header"), tag.tagNummer))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color(uiColor: .systemGray3))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .fullScreenCover(isPresented: $showingFocusSession) {
                if let habit = habitModel {
                    FocusSessionView(pflanze: habit)
                }
            }
        }
        .onAppear {
            setupCountdown()
        }
        .onDisappear {
            timerCancellable?.cancel()
        }
    }

    // MARK: - Hero Section
    @ViewBuilder
    private var heroSection: some View {
        ZStack {
            // Subtle gradient bg
            Circle()
                .fill(
                    RadialGradient(
                        colors: [themeColor.opacity(0.15), themeColor.opacity(0.0)],
                        center: .center,
                        startRadius: 40,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)

            if let p = plant, let assetName = p.assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                    .grayscale(tag.istErledigt ? 0 : (isFutureDay ? 0.7 : 0.2))
                    .opacity(isFutureDay ? 0.6 : 1.0)
                    .scaleEffect(tag.istErledigt ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: tag.istErledigt)
            } else {
                Image(tag.igelAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .opacity(isFutureDay ? 0.5 : 1.0)
            }

            // Milestone badge
            if tag.istMeilenstein {
                VStack {
                    HStack {
                        Spacer()
                        milestoneIcon
                            .offset(x: 10, y: -10)
                    }
                    Spacer()
                }
                .frame(width: 160, height: 160)
            }

            // Lock overlay
            if isFutureDay && !isLockedUntilTomorrow {
                VStack {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(
                            Circle().fill(Color(uiColor: .systemGray3))
                        )
                        .shadow(radius: 8)
                }
                .frame(height: 160)
            }
        }
    }

    @ViewBuilder
    private var milestoneIcon: some View {
        let iconName: String = {
            switch tag.tagNummer {
            case 7, 21, 45: return "coin"
            case 14: return "Unkraut_Schild"
            case 30: return "Powerup-Zeitkapsel"
            case 60: return "Powerup-Glückssegen"
            case 90: return "Achievment_Gold"
            default: return "coin"
            }
        }()
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .background(Circle().fill(.white).shadow(radius: 4))
    }

    // MARK: - Status Section
    @ViewBuilder
    private var statusSection: some View {
        if tag.istErledigt {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.green)
                Text(String(localized: "pfad_tag_erledigt_badge", defaultValue: "Erledigt"))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green.opacity(0.12), in: Capsule())
        } else if isActionable {
            // Countdown until midnight
            countdownBadge
        } else if isLockedUntilTomorrow {
            morgenBadge
        } else if isFutureDay {
            lockedBadge
        }
    }

    @ViewBuilder
    private var countdownBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 15))
                .foregroundStyle(themeColor)
            Text(countdownString)
                .font(.system(size: 15, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(themeColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(themeColor.opacity(0.12), in: Capsule())
    }

    @ViewBuilder
    private var morgenBadge: some View {
        let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let diffHours = Calendar.current.dateComponents([.hour], from: Date(), to: nextMidnight).hour ?? 0
        HStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 15))
                .foregroundStyle(.orange)
            Text(String(format: String(localized: "pfad_morgen_verfuegbar", defaultValue: "Verfügbar in %lld Std."), diffHours))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.12), in: Capsule())
    }

    @ViewBuilder
    private var lockedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(uiColor: .systemGray5), in: Capsule())
    }

    // MARK: - Progress Section
    @ViewBuilder
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(format: String(localized: "path.day_progress_format"), String(tag.tagNummer)))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                Spacer()
                Text(String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(tag.phase.farbe)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .systemGray5))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tag.phase.farbe.opacity(0.8), tag.phase.farbe],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(tag.tagNummer) / 90.0)
                }
            }
            .frame(height: 8)

            Text(String(localized: "pfad_phase_beschreibung_\(tag.phase.rawValue)"))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - To-Do Section
    @ViewBuilder
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(
                    String(localized: "challenge.todos.title", defaultValue: "Deine To-Dos"),
                    systemImage: "checklist"
                )
                .font(.system(size: 15, weight: .black, design: .rounded))
                Spacer()
                if isActionable {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showAddTodo.toggle()
                            isTodoFieldFocused = showAddTodo
                        }
                    } label: {
                        Image(systemName: showAddTodo ? "xmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(showAddTodo ? Color.red.opacity(0.7) : themeColor)
                    }
                }
            }

            // Existing todos
            ForEach($todos) { $todo in
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            todo.isDone.toggle()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    } label: {
                        Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundStyle(todo.isDone ? themeColor : Color(uiColor: .systemGray3))
                    }
                    Text(todo.text)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(todo.isDone ? .secondary : .primary)
                        .strikethrough(todo.isDone, color: .secondary)
                        .animation(.easeInOut(duration: 0.2), value: todo.isDone)
                    Spacer()
                    if isActionable {
                        Button {
                            withAnimation {
                                todos.removeAll { $0.id == todo.id }
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(.red.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(todo.isDone ? themeColor.opacity(0.06) : Color(uiColor: .tertiarySystemBackground))
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: todo.isDone)
            }

            // Add new todo field
            if showAddTodo && isActionable {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(themeColor)
                    TextField(
                        String(localized: "challenge.todos.placeholder", defaultValue: "Neues To-Do hinzufügen..."),
                        text: $newTodoText
                    )
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .focused($isTodoFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        addTodo()
                    }
                    if !newTodoText.isEmpty {
                        Button {
                            addTodo()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(themeColor)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(uiColor: .tertiarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(themeColor.opacity(0.4), lineWidth: 1.5)
                        )
                )
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Action Section
    @ViewBuilder
    private var actionSection: some View {
        if tag.istErledigt {
            // Already done
            VStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(themeColor)
                Text(String(localized: "erledigt_status", defaultValue: "Abgeschlossen"))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(themeColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else if isActionable {
            VStack(spacing: 12) {
                // Focus Timer Button (primary)
                if habitModel != nil {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingFocusSession = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "timer")
                                .font(.system(size: 18, weight: .bold))
                            Text(String(localized: "fokus.starten", defaultValue: "Fokus Timer"))
                                .font(.system(size: 17, weight: .black, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: themeColor,
                        shadowColor: themeColor.darker(),
                        foregroundColor: .white
                    ))
                }

                // Complete Button (secondary)
                Button {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(String(localized: "jetzt.abschliessen", defaultValue: "Jetzt abschließen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(themeColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(themeColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        } else if isLockedUntilTomorrow {
            // Next day locked until midnight
            VStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)
                Text(String(localized: "challenge.locked_tomorrow", defaultValue: "Komm morgen wieder!"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(String(localized: "challenge.locked_tomorrow_hint", defaultValue: "Der nächste Tag öffnet sich um Mitternacht."))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else {
            // Future day – just locked
            VStack(spacing: 8) {
                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(uiColor: .systemGray3))
                Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(String(localized: "challenge.locked_future_hint", defaultValue: "Schließ zuerst den aktuellen Tag ab."))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Countdown Timer
    private var countdownString: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        let timeStr = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return String(format: String(localized: "challenge.countdown_label", defaultValue: "Noch %@"), timeStr)
    }

    private func setupCountdown() {
        let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        timeRemaining = nextMidnight.timeIntervalSince(Date())
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                let remaining = nextMidnight.timeIntervalSince(Date())
                timeRemaining = max(0, remaining)
            }
    }

    // MARK: - To-Do Helpers
    private func addTodo() {
        let text = newTodoText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            todos.append(PfadToDo(text: text))
            newTodoText = ""
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Localization Helpers
    private func habitName(for t: PfadStrangTag) -> String {
        guard let s = t.strang else { return "" }
        if let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
            return NSLocalizedString(habit.displayedHabitName, comment: "")
        }
        if let plant = GameDatabase.shared.plant(for: s.pflanzenID) {
            return NSLocalizedString(plant.habitCategory.localizationKey, comment: "")
        }
        return NSLocalizedString(s.pflanzenName, comment: "")
    }

    private func localizedTitle(for tag: PfadStrangTag) -> String {
        var raw = NSLocalizedString(tag.titelKey, comment: "")
        if raw == tag.titelKey {
            let fallbackKey = tag.titelKey
                .replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            let fallbackRaw = NSLocalizedString(fallbackKey, comment: "")
            if fallbackRaw != fallbackKey {
                raw = fallbackRaw
            } else if tag.istMeilenstein {
                raw = String(localized: "pfad_meilenstein_titel")
            } else {
                raw = String(localized: "pfad_aufgabe_titel")
            }
        }
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
        if raw == tag.beschreibungKey {
            let fallbackKey = tag.beschreibungKey
                .replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
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
}

// MARK: - Garden Aesthetics Components (kept for backward compat)

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

#Preview {
    let tag = PfadStrangTag(
        tagNummer: 5,
        titelKey: "Starte die Gewohnheit",
        beschreibungKey: "Mach heute deinen ersten Schritt.",
        istErledigt: false,
        istMeilenstein: false
    )
    let settings = SettingsStore()
    PfadTagDetailView(tag: tag)
        .environmentObject(GartenPfadStore(settings: settings))
        .environmentObject(GardenStore())
        .environmentObject(settings)
}
