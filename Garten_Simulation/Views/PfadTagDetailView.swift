import SwiftUI
import SwiftData
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
    @EnvironmentObject var powerUpStore: PowerUpStore

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var showingFocusSession = false
    @State private var progressionData: ProgressionData? = nil
    @State private var todos: [PfadToDo] = []
    @State private var newTodoText: String = ""
    @State private var showAddTodo: Bool = false
    @State private var tagIstErledigt: Bool = false
    @FocusState private var isTodoFieldFocused: Bool

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

    private var istErledigt: Bool { tagIstErledigt || tag.istErledigt }

    private var isCurrentDay: Bool {
        guard let strang = tag.strang else { return false }
        let alleTags = strang.tags.sorted { $0.tagNummer < $1.tagNummer }
        guard let firstIncomplete = alleTags.first(where: { !$0.istErledigt }) else { return false }
        return tag.id == firstIncomplete.id
    }

    private var isLockedUntilTomorrow: Bool {
        if let habit = habitModel {
            if let lastDate = habit.letzteBewaesserung {
                return Calendar.current.isDateInToday(lastDate)
            }
            return false
        }
        
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
        !istErledigt && isCurrentDay && !isLockedUntilTomorrow
    }

    // Kartenfarben
    private var cardTop: Color {
        colorScheme == .dark ? Color(hex: "#1c2c3e") : Color(hex: "#f0f6ff")
    }
    private var cardShadow: Color {
        colorScheme == .dark ? Color(hex: "#0a1520") : Color(hex: "#a0b8cc")
    }
    private var rowTop: Color {
        colorScheme == .dark ? Color(hex: "#243548") : .white
    }
    private var rowShadow: Color {
        colorScheme == .dark ? Color(hex: "#0a1520") : Color(hex: "#bcd0e0")
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Hero ──────────────────────────────────────────
                    heroSection
                        .padding(.top, 12)

                    // ── Status Badge (kompakt, zentriert) ─────────────
                    statusBadge
                        .padding(.top, 18)

                    // ── Titel ─────────────────────────────────────────
                    Text(progressionData?.dailyTitle ?? localizedTitle(for: tag))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.top, 14)
                        .padding(.horizontal, 28)

                    // ── Beschreibung ──────────────────────────────────
                    let descText = progressionData?.dailyDescription ?? localizedDescription(for: tag)
                    if let attrString = try? AttributedString(markdown: descText, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
                        Text(attrString)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 8)
                            .padding(.horizontal, 32)
                    } else {
                        Text(descText)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 8)
                            .padding(.horizontal, 32)
                    }

                    // ── Progress-Karte ────────────────────────────────
                    progressCard
                        .padding(.top, 22)
                        .padding(.horizontal, 20)

                    // ── To-Do-Karte ───────────────────────────────────
                    todoCard
                        .padding(.top, 16)
                        .padding(.horizontal, 20)

                    // ── Aktions-Buttons ───────────────────────────────
                    actionButtons
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 52)
                }
            }
            .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(format: String(localized: "pfad_tag_header"), tag.tagNummer))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(.regularMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .fullScreenCover(isPresented: $showingFocusSession) {
                if let habit = habitModel { 
                    let uncompletedTodos = todos.filter { !$0.isDone }.map { $0.text }
                    FocusSessionView(pflanze: habit, initialGoals: uncompletedTodos) 
                }
            }
        }
        .onAppear {
            tagIstErledigt = tag.istErledigt
            loadTodos()
            loadProgressionData()
        }
        .onDisappear {
            saveTodos()
        }
    }

    // MARK: - Hero
    @ViewBuilder
    private var heroSection: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [themeColor.opacity(0.18), .clear],
                    center: .center, startRadius: 30, endRadius: 120
                ))
                .frame(width: 240, height: 240)

            if let p = plant, let assetName = p.assetName {
                Image(assetName)
                    .resizable().scaledToFit()
                    .frame(width: 150, height: 150)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .grayscale(isFutureDay ? 0.8 : 0)
                    .opacity(isFutureDay ? 0.55 : 1.0)
                    .scaleEffect(istErledigt ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: istErledigt)
            } else {
                Image(tag.igelAsset)
                    .resizable().scaledToFit()
                    .frame(width: 150, height: 150)
                    .opacity(isFutureDay ? 0.5 : 1.0)
            }

            if tag.istMeilenstein {
                VStack { HStack { Spacer(); milestoneIcon.offset(x: 10, y: -10) }; Spacer() }
                    .frame(width: 150, height: 150)
            }

            if isFutureDay && !isLockedUntilTomorrow {
                VStack {
                    Spacer()
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32, weight: .bold)).foregroundStyle(.white)
                        .padding(12)
                        .background(Circle().fill(Color(uiColor: .systemGray3)))
                }
                .frame(height: 150)
            }
        }
    }

    @ViewBuilder
    private var milestoneIcon: some View {
        let name: String = {
            switch tag.tagNummer {
            case 14: return "Unkraut_Schild"
            case 30: return "Powerup-Zeitkapsel"
            case 60: return "Powerup-Glückssegen"
            case 90: return "Achievment_Gold"
            default: return "coin"
            }
        }()
        Image(name).resizable().scaledToFit()
            .frame(width: 40, height: 40)
            .background(Circle().fill(.white).shadow(radius: 4))
    }

    // MARK: - Status Badge (kompakt, nie full-width)
    @ViewBuilder
    private var statusBadge: some View {
        Group {
            if istErledigt {
                badge(color: .green) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        Text(String(localized: "pfad_tag_erledigt_badge", defaultValue: "Erledigt"))
                            .foregroundStyle(.green)
                    }
                }
            } else if isActionable {
                badge(color: themeColor) {
                    Image("Timer empty")
                        .resizable().scaledToFit()
                        .frame(width: 16, height: 16)
                        .colorMultiply(themeColor)
                }
            } else if isLockedUntilTomorrow {
                let h = Calendar.current.dateComponents([.hour], from: Date(), to: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)).hour ?? 0
                badge(color: .orange) {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill").foregroundStyle(.orange)
                        Text(String(format: String(localized: "pfad_morgen_verfuegbar", defaultValue: "Verfügbar in %lld Std."), h))
                            .foregroundStyle(.orange)
                    }
                }
            } else if isFutureDay {
                badge(color: Color(uiColor: .systemGray4)) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill").foregroundStyle(.secondary)
                        Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    /// Generischer Badge-Wrapper: kompakt, zentriert, 3D-Stil
    @ViewBuilder
    private func badge<Content: View>(color: Color, @ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Capsule()
                .fill(color.opacity(0.18))
                .offset(y: 3)
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 1))
                .overlay(
                    content()
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                )
        }
        .fixedSize() // ← KEY: verhindert full-width stretch!
    }

    // MARK: - Progress Card (3D)
    @ViewBuilder
    private var progressCard: some View {
        card3D(top: cardTop, shadow: cardShadow, radius: 20) {
            VStack(alignment: .leading, spacing: 12) {

                // Phase-Label + Tageszähler
                HStack(alignment: .firstTextBaseline) {
                    Text(String(format: String(localized: "path.day_progress_format"), String(tag.tagNummer)))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(progressionData?.phaseTitle ?? tag.phase.localizedTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(tag.phase.farbe)
                }

                // Eingetiefte 3D-Wanne
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Wanne
                        RoundedRectangle(cornerRadius: 8)
                            .fill(cardShadow.opacity(0.5))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(cardShadow, lineWidth: 1))
                            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                        // Füllung
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [tag.phase.farbe.opacity(0.8), tag.phase.farbe],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: max(16, geo.size.width * CGFloat(tag.tagNummer) / 90.0))
                            .shadow(color: tag.phase.farbe.opacity(0.5), radius: 4, y: -1)
                    }
                }
                .frame(height: 12)

                // Phase-Beschreibung
                Text(progressionData?.phaseDescription ?? tag.phase.localizedDescription)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
    }

    // MARK: - To-Do Card (3D)
    @ViewBuilder
    private var todoCard: some View {
        card3D(top: cardTop, shadow: cardShadow, radius: 20) {
            VStack(alignment: .leading, spacing: 10) {

                // Header-Zeile
                HStack {
                    Label(
                        String(localized: "challenge.todos.title", defaultValue: "Deine To-Dos"),
                        systemImage: "checklist"
                    )
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    Spacer()
                    Item3DButton(
                        farbe: showAddTodo ? Color(hex: "#CC2222") : themeColor,
                        sekundaerFarbe: showAddTodo ? Color(hex: "#881111") : themeColor.darker(),
                        groesse: 34,
                        aktion: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showAddTodo.toggle()
                                isTodoFieldFocused = showAddTodo
                            }
                        }
                    ) {
                        Image(systemName: showAddTodo ? "xmark" : "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Trennlinie
                if !todos.isEmpty {
                    Divider().opacity(0.4)
                }

                // Todo-Zeilen
                ForEach($todos) { $todo in
                    todoRow(todo: $todo)
                }

                // Input-Zeile
                if showAddTodo {
                    Divider().opacity(0.4)
                    todoInput
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func todoRow(todo: Binding<PfadToDo>) -> some View {
        HStack(spacing: 10) {
            // Checkbox
            Item3DButton(
                farbe: todo.wrappedValue.isDone ? themeColor : Color(uiColor: .systemGray4),
                sekundaerFarbe: todo.wrappedValue.isDone ? themeColor.darker() : Color(uiColor: .systemGray2),
                groesse: 30,
                shadowDepthFactor: 0.20,
                aktion: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        todo.isDone.wrappedValue.toggle()
                        saveTodos()
                    }
                }
            ) {
                if todo.wrappedValue.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            Text(todo.wrappedValue.text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(todo.wrappedValue.isDone ? .tertiary : .primary)
                .strikethrough(todo.wrappedValue.isDone, color: .secondary)
                .lineLimit(2)

            Spacer()

            Button {
                withAnimation {
                    todos.removeAll { $0.id == todo.wrappedValue.id }
                    saveTodos()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color(uiColor: .systemGray5)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(todo.wrappedValue.isDone
                      ? themeColor.opacity(0.06)
                      : rowTop)
                .shadow(color: rowShadow.opacity(0.6), radius: 2, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rowShadow.opacity(0.4), lineWidth: 0.8)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: todo.wrappedValue.isDone)
    }

    @ViewBuilder
    private var todoInput: some View {
        HStack(spacing: 8) {
            TextField(
                String(localized: "challenge.todos.placeholder", defaultValue: "Neues To-Do..."),
                text: $newTodoText
            )
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .focused($isTodoFieldFocused)
            .submitLabel(.done)
            .onSubmit { addTodo() }

            if !newTodoText.isEmpty {
                Item3DButton(
                    farbe: themeColor,
                    sekundaerFarbe: themeColor.darker(),
                    groesse: 32,
                    aktion: { addTodo() }
                ) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        if istErledigt {
            // Abgeschlossen-State
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.green.opacity(0.12)).frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44)).foregroundStyle(.green)
                }
                Text(String(localized: "erledigt_status", defaultValue: "Abgeschlossen"))
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 20)

        } else if isActionable {
            VStack(spacing: 12) {
                // Fokus Timer
                if habitModel != nil {
                    Item3DButton(
                        farbe: themeColor,
                        sekundaerFarbe: themeColor.darker(),
                        groesse: 54,
                        isRectangular: true,
                        aktion: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showingFocusSession = true
                        }
                    ) {
                        HStack(spacing: 8) {
                            Image("Timer full")
                                .resizable().scaledToFit()
                                .frame(width: 22, height: 22)
                            Text(String(localized: "fokus.starten", defaultValue: "Fokus Timer"))
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Jetzt abschließen
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
                        
                        if let h = habitModel {
                            gardenStore.giessen(pflanze: h, powerUpStore: powerUpStore)
                            
                            let today = Calendar.current.startOfDay(for: Date())
                            if !h.pfadCheckedDates.contains(today) {
                                h.pfadCheckedDates.append(today)
                                gardenStore.savePlants()
                            }
                        }
                        
                        if tag.modelContext != nil {
                            pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                        }
                    }
                ) {
                    Text(String(localized: "jetzt.abschliessen", defaultValue: "Jetzt abschließen"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }

        } else if isLockedUntilTomorrow {
            Item3DButton(
                farbe: colorScheme == .dark ? Color(hex: "#2a3d58") : Color(hex: "#b8cce0"),
                sekundaerFarbe: colorScheme == .dark ? Color(hex: "#0a1220") : Color(hex: "#8090a8"),
                groesse: 52,
                isRectangular: true,
                aktion: { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                    Text(String(localized: "challenge.locked_tomorrow", defaultValue: "Komm morgen wieder!"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)

        } else {
            Item3DButton(
                farbe: colorScheme == .dark ? Color(hex: "#2a3d58") : Color(hex: "#b8cce0"),
                sekundaerFarbe: colorScheme == .dark ? Color(hex: "#0a1220") : Color(hex: "#8090a8"),
                groesse: 52,
                isRectangular: true,
                aktion: { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
            ) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.7))
                    Text(String(localized: "pfad_tag_gesperrt", defaultValue: "Gesperrt"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 3D Karten-Helper (statischer Inhalt)
    @ViewBuilder
    private func card3D<Content: View>(
        top topColor: Color,
        shadow shadowColor: Color,
        radius: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Boden (Schatten-Schicht)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(shadowColor)
                        .offset(y: 4)
                    // Oben (Inhalt-Schicht)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(topColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .stroke(Color.black.opacity(0.07), lineWidth: 1)
                        )
                }
            )
    }

    // MARK: - Persistenz
    private func saveTodos() {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: todoPersistenceKey)
        }
    }

    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: todoPersistenceKey),
              let loaded = try? JSONDecoder().decode([PfadToDo].self, from: data) else { return }
        todos = loaded
    }
    
    private func loadProgressionData() {
        let h = tag.strang.flatMap { s in gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) }
        let diff = h?.individualSchwierigkeit ?? "anfaenger"
        
        if let plantID = h?.plantID,
           let data = HabitProgressionGenerator.generateProgression(for: plantID, dayNum: tag.tagNummer, difficulty: diff, language: settings.appLanguage) {
            
            var mutatedData = data
            mutatedData.dailyTitle = mutatedData.dailyTitle.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
            mutatedData.dailyDescription = mutatedData.dailyDescription.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
            self.progressionData = mutatedData
            
            // Auto-populate todos if first run and empty
            let hasLoadedKey = "hasLoadedTodos_\(todoPersistenceKey)"
            if !UserDefaults.standard.bool(forKey: hasLoadedKey) {
                UserDefaults.standard.set(true, forKey: hasLoadedKey)
                if todos.isEmpty && !mutatedData.dailyTodos.isEmpty {
                    todos = mutatedData.dailyTodos.map { PfadToDo(text: $0) }
                    saveTodos()
                }
            }
        }
    }

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

    // MARK: - Lokalisierungshelfer
    private func habitName(for t: PfadStrangTag) -> String {
        guard let s = t.strang else { return "" }
        if let habit = gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) {
            return NSLocalizedString(habit.displayedHabitName, comment: "")
        }
        if let p = GameDatabase.shared.plant(for: s.pflanzenID) {
            return NSLocalizedString(p.habitCategory.localizationKey, comment: "")
        }
        return NSLocalizedString(s.pflanzenName, comment: "")
    }

    private func localizedTitle(for tag: PfadStrangTag) -> String {
        var raw = NSLocalizedString(tag.titelKey, comment: "")
        if raw == tag.titelKey {
            let fb = tag.titelKey
                .replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            let fbRaw = NSLocalizedString(fb, comment: "")
            raw = fbRaw != fb ? fbRaw : (tag.istMeilenstein
                ? String(localized: "pfad_meilenstein_titel")
                : String(localized: "pfad_aufgabe_titel"))
        }
        if raw == tag.titelKey { raw = String(localized: "routine_titel") }
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }

    private func localizedDescription(for tag: PfadStrangTag) -> String {
        let h = tag.strang.flatMap { s in gardenStore.pflanzen.first(where: { $0.id == s.pflanzenID }) }
        let diff = h?.individualSchwierigkeit ?? "anfaenger"
        
        if let plantID = h?.plantID,
           let dyn = HabitProgressionGenerator.generateProgression(for: plantID, dayNum: tag.tagNummer, difficulty: diff, language: settings.appLanguage) {
            return dyn.dailyDescription.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
        }
        var raw = NSLocalizedString(tag.beschreibungKey, comment: "")
        if raw == tag.beschreibungKey {
            let fb = tag.beschreibungKey
                .replacingOccurrences(of: #"pfad_.*_day_"#, with: "pfad_generic_day_", options: .regularExpression)
                .replacingOccurrences(of: #"pfad_.*_phase_"#, with: "pfad_generic_phase_", options: .regularExpression)
            let fbRaw = NSLocalizedString(fb, comment: "")
            if fbRaw != fb {
                raw = fbRaw
            } else {
                raw = diff == "fortgeschritten"
                    ? String(localized: "pfad_schwierigkeit_fortgeschritten_desc", defaultValue: "Steigere die Intensität und festige deine Routine.")
                    : diff == "profi"
                        ? String(localized: "pfad_schwierigkeit_profi_desc", defaultValue: "Meistere diese Gewohnheit auf höchstem Niveau.")
                        : String(localized: "pfad_schwierigkeit_anfaenger_desc", defaultValue: "Beginne leicht und lerne die Grundlagen dieser Gewohnheit.")
            }
        }
        return raw.replacingOccurrences(of: "[HABIT]", with: habitName(for: tag))
    }
}

// MARK: - Legacy compatibility stubs
struct ButterflyView: View {
    @State private var pos = CGPoint(x: 25, y: 25)
    @State private var scale: CGFloat = 0.5
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    var body: some View {
        Image(systemName: "butterfly.fill")
            .font(.system(size: 14))
            .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
            .scaleEffect(scale).position(pos)
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 4)) {
                    pos = CGPoint(x: pos.x + CGFloat.random(in: -100...100), y: pos.y + CGFloat.random(in: -100...100))
                    scale = CGFloat.random(in: 0.4...0.8)
                }
            }
            .onAppear { withAnimation(.easeInOut(duration: 2).repeatForever()) { scale = 0.7 } }
    }
}

struct GrassTuftView: View {
    var body: some View {
        Image("Wildgras").resizable().scaledToFit().frame(width: 20).opacity(0.15).grayscale(0.5)
    }
}

#Preview {
    let tag = PfadStrangTag(tagNummer: 1, titelKey: "Start", beschreibungKey: "Beschreibung", istErledigt: false, istMeilenstein: false)
    let settings = SettingsStore()
    PfadTagDetailView(tag: tag)
        .environmentObject(GartenPfadStore(settings: settings))
        .environmentObject(GardenStore())
        .environmentObject(settings)
}
