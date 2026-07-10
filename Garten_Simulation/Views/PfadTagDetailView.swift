import SwiftUI
import Combine

// MARK: - To-Do Item Model (Codable für Persistenz)
struct PfadToDo: Identifiable, Codable {
    let id: UUID
    var text: String
    var isDone: Bool

    init(id: UUID = UUID(), text: String, isDone: Bool = false) {
        self.id = id
        self.text = text
        self.isDone = isDone
    }
}

// MARK: - PfadTagDetailView
struct PfadTagDetailView: View {
    let tag: PfadStrangTag
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showingFocusSession = false
    @State private var todos: [PfadToDo] = []
    @State private var newTodoText: String = ""
    @State private var showAddTodo: Bool = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timerCancellable: AnyCancellable? = nil
    @State private var tagIstErledigt: Bool = false
    @FocusState private var isTodoFieldFocused: Bool

    // Persistenz-Key für To-Dos
    private var todoPersistenceKey: String {
        "pfadTodos_\(tag.strang?.pflanzenID ?? "")_\(tag.tagNummer)"
    }

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

    private var istErledigt: Bool {
        tagIstErledigt || tag.istErledigt
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
        guard !istErledigt else { return false }
        guard let strang = tag.strang else { return true }
        let alleTags = strang.tags.sorted { $0.tagNummer < $1.tagNummer }
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        return tag.id != firstIncomplete.id
    }

    private var isActionable: Bool {
        guard !istErledigt else { return false }
        return isCurrentDay && !isLockedUntilTomorrow
    }

    // 3D-Karten-Farben (passend zu Item3DButton-Look)
    private var cardTopColor: Color {
        colorScheme == .dark ? Color(hex: "#1c2c3e") : Color(hex: "#f0f6ff")
    }
    private var cardShadowColor: Color {
        colorScheme == .dark ? Color(hex: "#0a1520") : Color(hex: "#aabdd0")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection.padding(.top, 12)
                        statusSection.padding(.top, 20).padding(.horizontal, 24)

                        Text(localizedTitle(for: tag))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.top, 16)
                            .padding(.horizontal, 24)

                        Text(localizedDescription(for: tag))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 10)
                            .padding(.horizontal, 32)

                        progressSection.padding(.top, 24).padding(.horizontal, 24)

                        if !todos.isEmpty || isActionable || istErledigt {
                            todoSection.padding(.top, 24).padding(.horizontal, 24)
                        }

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
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .fullScreenCover(isPresented: $showingFocusSession) {
                if let habit = habitModel {
                    FocusSessionView(pflanze: habit)
                }
            }
        }
        .onAppear {
            tagIstErledigt = tag.istErledigt
            loadTodos()
            setupCountdown()
        }
        .onDisappear {
            timerCancellable?.cancel()
            saveTodos()
        }
    }

    // MARK: - Hero Section
    @ViewBuilder
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [themeColor.opacity(0.15), themeColor.opacity(0.0)],
                        center: .center, startRadius: 40, endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)

            if let p = plant, let assetName = p.assetName {
                Image(assetName)
                    .resizable().scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                    .grayscale(istErledigt ? 0 : (isFutureDay ? 0.7 : 0.2))
                    .opacity(isFutureDay ? 0.6 : 1.0)
                    .scaleEffect(istErledigt ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: istErledigt)
            } else {
                Image(tag.igelAsset)
                    .resizable().scaledToFit()
                    .frame(width: 160, height: 160)
                    .opacity(isFutureDay ? 0.5 : 1.0)
            }

            if tag.istMeilenstein {
                VStack {
                    HStack {
                        Spacer()
                        milestoneIcon.offset(x: 10, y: -10)
                    }
                    Spacer()
                }
                .frame(width: 160, height: 160)
            }

            if isFutureDay && !isLockedUntilTomorrow {
                VStack {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Circle().fill(Color(uiColor: .systemGray3)))
                        .shadow(radius: 6)
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
        Image(iconName).resizable().scaledToFit()
            .frame(width: 44, height: 44)
            .background(Circle().fill(.white).shadow(radius: 4))
    }

    // MARK: - Status Badge (als 3D-Karte)
    @ViewBuilder
    private var statusSection: some View {
        if istErledigt {
            card3D(topColor: Color.green.opacity(0.15), shadowColor: Color.green.opacity(0.3), cornerRadius: 50) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .bold)).foregroundStyle(.green)
                    Text(String(localized: "pfad_tag_erledigt_badge", defaultValue: "Erledigt"))
                        .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.green)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }
        } else if isActionable {
            // Countdown Badge mit "Timer empty" Asset
            card3D(topColor: themeColor.opacity(0.12), shadowColor: themeColor.darker(), cornerRadius: 50) {
                HStack(spacing: 8) {
                    Image("Timer empty")
                        .resizable().scaledToFit()
                        .frame(width: 18, height: 18)
                        .colorMultiply(themeColor)
                    Text(countdownString)
                        .font(.system(size: 15, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(themeColor)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }
        } else if isLockedUntilTomorrow {
            let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
            let diffHours = Calendar.current.dateComponents([.hour], from: Date(), to: nextMidnight).hour ?? 0
            card3D(topColor: Color.orange.opacity(0.12), shadowColor: Color.orange.opacity(0.3), cornerRadius: 50) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 15)).foregroundStyle(.orange)
                    Text(String(format: String(localized: "pfad_morgen_verfuegbar", defaultValue: "Verfügbar in %lld Std."), diffHours))
                        .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.orange)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }
        } else if isFutureDay {
            card3D(topColor: Color(uiColor: .systemGray5), shadowColor: Color(uiColor: .systemGray3), cornerRadius: 50) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14)).foregroundStyle(.secondary)
                    Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                        .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
            }
        }
    }

    // MARK: - Progress Section (3D-Karte)
    @ViewBuilder
    private var progressSection: some View {
        card3D(topColor: cardTopColor, shadowColor: cardShadowColor, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(String(format: String(localized: "path.day_progress_format"), String(tag.tagNummer)))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                    Spacer()
                    Text(String(localized: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(tag.phase.farbe)
                }

                // Eingetiefte Progress-Bar (3D-Wanne)
                ZStack(alignment: .leading) {
                    // Wanne (dunklere Ebene = "gedrückt")
                    RoundedRectangle(cornerRadius: 6)
                        .fill(cardShadowColor.opacity(0.4))
                        .frame(height: 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(cardShadowColor.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 2)

                    // Füllstand
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [tag.phase.farbe.opacity(0.85), tag.phase.farbe],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: max(12, geo.size.width * CGFloat(tag.tagNummer) / 90.0))
                            .shadow(color: tag.phase.farbe.opacity(0.4), radius: 4, y: -2)
                    }
                }
                .frame(height: 12)

                Text(String(localized: "pfad_phase_beschreibung_\(tag.phase.rawValue)"))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
    }

    // MARK: - To-Do Section (3D-Karte)
    @ViewBuilder
    private var todoSection: some View {
        card3D(topColor: cardTopColor, shadowColor: cardShadowColor, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Label(
                        String(localized: "challenge.todos.title", defaultValue: "Deine To-Dos"),
                        systemImage: "checklist"
                    )
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    Spacer()
                    if isActionable {
                        Item3DButton(
                            farbe: showAddTodo ? Color(hex: "#CC2222") : themeColor,
                            sekundaerFarbe: showAddTodo ? Color(hex: "#881111") : themeColor.darker(),
                            groesse: 36,
                            aktion: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showAddTodo.toggle()
                                    isTodoFieldFocused = showAddTodo
                                }
                            }
                        ) {
                            Image(systemName: showAddTodo ? "xmark" : "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Todo-Zeilen (weiße 3D-Karten)
                ForEach($todos) { $todo in
                    todoRow(todo: $todo)
                }

                // Add-Input
                if showAddTodo && isActionable {
                    todoInputRow
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func todoRow(todo: Binding<PfadToDo>) -> some View {
        // Jede Todo-Zeile ist eine weiße 3D-Karte
        card3D(
            topColor: todo.wrappedValue.isDone ? themeColor.opacity(0.08) : (colorScheme == .dark ? Color(hex: "#253548") : .white),
            shadowColor: colorScheme == .dark ? Color(hex: "#0a1520") : Color(hex: "#c0d0e0"),
            cornerRadius: 14
        ) {
            HStack(spacing: 12) {
                // Checkbox als Item3DButton
                Item3DButton(
                    farbe: todo.wrappedValue.isDone ? themeColor : Color(uiColor: .systemGray4),
                    sekundaerFarbe: todo.wrappedValue.isDone ? themeColor.darker() : Color(uiColor: .systemGray),
                    groesse: 32,
                    aktion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            todo.isDone.wrappedValue.toggle()
                            saveTodos()
                        }
                    }
                ) {
                    if todo.wrappedValue.isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Text(todo.wrappedValue.text)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(todo.wrappedValue.isDone ? .secondary : .primary)
                    .strikethrough(todo.wrappedValue.isDone, color: .secondary)
                    .animation(.easeInOut(duration: 0.2), value: todo.wrappedValue.isDone)
                Spacer()
                if isActionable {
                    Button {
                        withAnimation {
                            todos.removeAll { $0.id == todo.wrappedValue.id }
                            saveTodos()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(.red.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: todo.wrappedValue.isDone)
    }

    @ViewBuilder
    private var todoInputRow: some View {
        card3D(
            topColor: colorScheme == .dark ? Color(hex: "#253548") : .white,
            shadowColor: themeColor.opacity(0.3),
            cornerRadius: 14
        ) {
            HStack(spacing: 10) {
                TextField(
                    String(localized: "challenge.todos.placeholder", defaultValue: "Neues To-Do hinzufügen..."),
                    text: $newTodoText
                )
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .focused($isTodoFieldFocused)
                .submitLabel(.done)
                .onSubmit { addTodo() }

                if !newTodoText.isEmpty {
                    Item3DButton(
                        farbe: themeColor,
                        sekundaerFarbe: themeColor.darker(),
                        groesse: 34,
                        aktion: { addTodo() }
                    ) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
        }
    }

    // MARK: - Action Section
    @ViewBuilder
    private var actionSection: some View {
        if istErledigt {
            VStack(spacing: 16) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.12)).frame(width: 90, height: 90)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50)).foregroundStyle(Color.green)
                }
                Text(String(localized: "erledigt_status", defaultValue: "Abgeschlossen"))
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 24)

        } else if isActionable {
            VStack(spacing: 14) {
                if habitModel != nil {
                    // Fokus Timer – Item3DButton rectangular mit "Timer full" Asset
                    Item3DButton(
                        farbe: themeColor,
                        sekundaerFarbe: themeColor.darker(),
                        groesse: 56,
                        isRectangular: true,
                        aktion: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showingFocusSession = true
                        }
                    ) {
                        HStack(spacing: 10) {
                            Image("Timer full")
                                .resizable().scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(String(localized: "fokus.starten", defaultValue: "Fokus Timer"))
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                }

                // Jetzt abschließen – grüner Item3DButton, kein Icon
                Item3DButton(
                    farbe: Color(hex: "#58CC02"),
                    sekundaerFarbe: Color(hex: "#3a8000"),
                    groesse: 52,
                    isRectangular: true,
                    aktion: {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            tagIstErledigt = true
                        }
                        pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                    }
                ) {
                    Text(String(localized: "jetzt.abschliessen", defaultValue: "Jetzt abschließen"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
            }

        } else if isLockedUntilTomorrow {
            VStack(spacing: 10) {
                Image(systemName: "moon.stars.fill").font(.system(size: 36)).foregroundStyle(.orange)
                Text(String(localized: "challenge.locked_tomorrow", defaultValue: "Komm morgen wieder!"))
                    .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.secondary)
                Text(String(localized: "challenge.locked_tomorrow_hint", defaultValue: "Der nächste Tag öffnet sich um Mitternacht."))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)

        } else {
            VStack(spacing: 10) {
                Image(systemName: "lock.circle.fill").font(.system(size: 36)).foregroundStyle(Color(uiColor: .systemGray3))
                Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                    .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.secondary)
                Text(String(localized: "challenge.locked_future_hint", defaultValue: "Schließ zuerst den aktuellen Tag ab."))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.tertiary).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)
        }
    }

    // MARK: - Reusable 3D-Karten-Helper
    /// Erzeugt eine einheitliche, gestapelte 3D-Karte (wie Item3DButton, aber für statischen Inhalt)
    @ViewBuilder
    private func card3D<Content: View>(
        topColor: Color,
        shadowColor: Color,
        cornerRadius: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            // Boden-Schicht (Schatten)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(shadowColor)
                .offset(y: 4)
            // Obere Schicht (Inhalt)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(topColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .overlay(content())
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

    // MARK: - To-Do Persistenz
    private func saveTodos() {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: todoPersistenceKey)
        }
    }

    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: todoPersistenceKey),
              let loaded = try? JSONDecoder().decode([PfadToDo].self, from: data)
        else { return }
        todos = loaded
    }

    // MARK: - To-Do Helpers
    private func addTodo() {
        let text = newTodoText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            todos.append(PfadToDo(text: text))
            newTodoText = ""
            isTodoFieldFocused = false
            showAddTodo = false
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        saveTodos()
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
            .scaleEffect(scale).opacity(opacity).position(position)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 4)) {
                    position = CGPoint(x: position.x + CGFloat.random(in: -100...100), y: position.y + CGFloat.random(in: -100...100))
                    opacity = Double.random(in: 0.3...0.7)
                    scale = CGFloat.random(in: 0.4...0.8)
                }
            }
            .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever()) { scale = 0.7 } }
    }
}

struct GrassTuftView: View {
    var body: some View {
        Image("Wildgras").resizable().scaledToFit()
            .frame(width: 20).opacity(0.15).grayscale(0.5)
    }
}

#Preview {
    let tag = PfadStrangTag(
        tagNummer: 5, titelKey: "Starte die Gewohnheit",
        beschreibungKey: "Mach heute deinen ersten Schritt.",
        istErledigt: false, istMeilenstein: false
    )
    let settings = SettingsStore()
    PfadTagDetailView(tag: tag)
        .environmentObject(GartenPfadStore(settings: settings))
        .environmentObject(GardenStore())
        .environmentObject(settings)
}
