import SwiftUI
import Combine
import ActivityKit
import FamilyControls
import UniformTypeIdentifiers

enum FocusSessionState: Int, Codable {
    case intro
    case step1
    case step2
    case timer
    case success
}

struct FocusSessionView: View {
    @ObservedObject var pflanze: HabitModel
    var initialGoals: [String] = []
    var onSessionCompleted: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    
    @State private var state: FocusSessionState = .intro
    @State private var currentGoalInput: String = ""
    @State private var sessionGoals: [FocusGoal] = []
    
    @State private var draggedGoal: FocusGoal?
    @State private var newGoalText: String = ""
    
    // Live Activity
    @State private var focusActivity: Activity<FocusTimerActivityAttributes>? = nil
    
    // Strict Mode Tracking
    @State private var isStrictMode: Bool = true
    @State private var showStrictModeAlert: Bool = false
    @State private var backgroundStartTime: Date? = nil
    @State private var showFailAlert: Bool = false
    
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showScreenTimePicker = false
    @State private var showBlockNotice = false
    
    enum FocusSelectionMode {
        case full
        case partial
    }
    @State private var currentFocusMode: FocusSelectionMode = .full
    // Math Challenge
    @State private var showMathChallenge: Bool = false
    @State private var cancelMathProblem: String = ""
    @State private var cancelMathAnswer: Int = 0
    
    // Timer default 25 mins
    @State private var selectedMinutes: Int = 25
    @State private var remainingSeconds: Int = 25 * 60
    @State private var isTimerRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                switch state {
                case .intro:
                    introView
                        .transition(.opacity)
                case .step1:
                    FocusSessionPreparationStep(
                        iconName: "Handy",
                        title: String(localized: "focus.prep.step1.title", defaultValue: "Ablenkungen weg"),
                        description: String(localized: "focus.session.dnd_hint", defaultValue: "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite."),
                        buttonText: String(localized: "focus.prep.step1.button", defaultValue: "Erledigt"),
                        isLastStep: false,
                        textInput: $currentGoalInput,
                        goals: $sessionGoals
                    ) {
                        showStrictModeAlert = true
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .step2:
                    FocusSessionPreparationStep(
                        iconName: "Goal",
                        title: String(localized: "focus.prep.step2.title", defaultValue: "Klares Ziel"),
                        description: String(localized: "focus.session.goal_hint", defaultValue: "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren."),
                        buttonText: String(localized: "focus.prep.step2.button", defaultValue: "Timer starten"),
                        isLastStep: true,
                        showTextInput: true,
                        habitCategory: pflanze.habitCategory,
                        textInput: $currentGoalInput,
                        goals: $sessionGoals
                    ) {
                        // Keyboard schließen
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation {
                            // Nach Priorität sortieren: Hoch -> Mittel -> Niedrig
                            sessionGoals.sort {
                                let pOrder: [GoalPriority: Int] = [.high: 3, .medium: 2, .low: 1]
                                return pOrder[$0.priority]! > pOrder[$1.priority]!
                            }
                            remainingSeconds = selectedMinutes * 60
                            
                            let endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
                            FocusTimerRecovery.shared.saveState(endTime: endTime, totalSeconds: remainingSeconds, plantId: pflanze.id, goals: sessionGoals, genericHabit: pflanze.isGenericFocus ? pflanze : nil)
                            
                            state = .timer
                            isTimerRunning = true
                            // Blocking already applied in step 1 via FocusScreenTimePickerView
                            startLiveActivity()
                        }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                case .timer:
                    timerView
                        .transition(.opacity)
                case .success:
                    successView
                        .transition(.scale)
                }
            }
            .standardNavigationX(show: state != .timer && state != .success)
        }
        .onReceive(timer) { _ in
            if isTimerRunning && remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds == 0 {
                    isTimerRunning = false
                    UIApplication.shared.isIdleTimerDisabled = false
                    withAnimation {
                        finishSession()
                    }
                }
            }
        }
        .onChange(of: sessionGoals) { _, newGoals in
            if isTimerRunning && FocusTimerRecovery.shared.isActive {
                let savedEndTime = Date(timeIntervalSince1970: FocusTimerRecovery.shared.endTime)
                FocusTimerRecovery.shared.saveState(endTime: savedEndTime, totalSeconds: FocusTimerRecovery.shared.totalSeconds, plantId: pflanze.id, goals: newGoals, genericHabit: pflanze.isGenericFocus ? pflanze : nil)
            }
        }
        .onAppear {
            if FocusTimerRecovery.shared.isActive && (FocusTimerRecovery.shared.plantId == pflanze.id || (FocusTimerRecovery.shared.isGeneric && pflanze.isGenericFocus)) {
                let endTime = Date(timeIntervalSince1970: FocusTimerRecovery.shared.endTime)
                let now = Date()
                
                self.selectedMinutes = FocusTimerRecovery.shared.totalSeconds / 60
                self.sessionGoals = FocusTimerRecovery.shared.getGoals()
                
                if now < endTime {
                    self.remainingSeconds = Int(endTime.timeIntervalSince(now))
                    self.state = .timer
                    self.isTimerRunning = true
                } else {
                    self.remainingSeconds = 0
                    self.isTimerRunning = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        finishSession()
                    }
                }
            } else {
                if FocusTimerRecovery.shared.isActive {
                    FocusTimerRecovery.shared.clearState()
                }
                
                if sessionGoals.isEmpty {
                    if !pflanze.isGenericFocus && !pflanze.todos.isEmpty {
                        sessionGoals = pflanze.todos
                    } else if !initialGoals.isEmpty {
                        sessionGoals = initialGoals.map { FocusGoal(text: $0) }
                    }
                }
            }
        }
        .onDisappear {
            isTimerRunning = false
            UIApplication.shared.isIdleTimerDisabled = false
            stopLiveActivity()
            FocusAudioManager.shared.stop()
            ScreenTimeManager.shared.unblockApps()
        }
        .onChange(of: state) {
            if state == .timer {
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        .onChange(of: showMathChallenge) {
            if showMathChallenge && cancelMathProblem.isEmpty {
                generateHardMathProblem()
            }
        }
        .onChange(of: scenePhase) {
            guard state == .timer && isTimerRunning else { return }
            
            if scenePhase == .background || scenePhase == .inactive {
                if backgroundStartTime == nil {
                    backgroundStartTime = Date()
                }
            } else if scenePhase == .active {
                if let startTime = backgroundStartTime {
                    let timeAway = Date().timeIntervalSince(startTime)
                    backgroundStartTime = nil
                    
                    // Subtract the time away from remainingSeconds
                    let remaining = max(0, remainingSeconds - Int(timeAway))
                    remainingSeconds = remaining
                    if remainingSeconds == 0 {
                        finishSession()
                    }
                }
            }
        }
        .alert(String(localized: "focus.strict_mode.prompt.title", defaultValue: "Willst du Apps während deiner Fokus-Zeit sperren?"), isPresented: $showStrictModeAlert) {
            Button(String(localized: "common.yes", defaultValue: "Ja")) {
                isStrictMode = true
                currentFocusMode = .full
                if screenTimeManager.isAuthorized {
                    showScreenTimePicker = true
                } else {
                    Task {
                        await screenTimeManager.requestAuthorization()
                        if screenTimeManager.isAuthorized {
                            showScreenTimePicker = true
                        } else {
                            withAnimation { state = .step2 }
                        }
                    }
                }
            }
            Button(String(localized: "common.no", defaultValue: "Nein")) {
                isStrictMode = false
                withAnimation { state = .step2 }
            }
            Button(String(localized: "common.cancel", defaultValue: "Abbrechen"), role: .cancel) {
                // Do nothing, stay on step 1
            }
        }
        .familyActivityPicker(isPresented: $showScreenTimePicker, selection: Binding(
            get: {
                currentFocusMode == .full ? screenTimeManager.focusFullBlockSelection : screenTimeManager.focusPartialBlockSelection
            },
            set: { newValue in
                if currentFocusMode == .full {
                    screenTimeManager.focusFullBlockSelection = newValue
                } else {
                    screenTimeManager.focusPartialBlockSelection = newValue
                }
            }
        ))
        .onChange(of: sessionGoals) {
            if focusActivity != nil {
                updateLiveActivity()
            }
        }
        .onReceive(FocusAudioManager.shared.objectWillChange) { _ in
            if focusActivity != nil {
                updateLiveActivity()
            }
        }
        .onChange(of: showScreenTimePicker) { _, isOpen in
            if !isOpen {
                let selection = currentFocusMode == .full ? screenTimeManager.focusFullBlockSelection : screenTimeManager.focusPartialBlockSelection
                screenTimeManager.applyFocusBlock(selection: selection)
                withAnimation { state = .step2 }
            }
        }
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("Timer full")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            VStack(spacing: 8) {
                Text(String(localized: "focus.session.title", defaultValue: "Fokus-Session"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                
                Text(settings.showHabitInsteadOfName ? pflanze.localizedHabitName : pflanze.localizedName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.goldPrimary)
            }
            
            VStack(spacing: 12) {
                Text(String(format: String(localized: "focus.session.duration.format", defaultValue: "Dauer: %lld Minuten"), Int64(selectedMinutes)))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Slider(value: Binding<Double>(
                    get: { Double(selectedMinutes) },
                    set: { selectedMinutes = Int($0) }
                ), in: 5...120, step: 5)
                .tint(.goldPrimary)
                .padding(.horizontal, 40)
            }
            .padding(.top, 20)
            
            Spacer()
            
            Button {
                withAnimation { state = .step1 }
            } label: {
                Text(String(localized: "focus.session.start_prep", defaultValue: "Vorbereitung starten"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large, fillWidth: true,
                backgroundColor: .goldPrimary, shadowColor: .goldPrimary.darker(), foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Timer View
    private var timerView: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 40)
                    
                    ZStack {
                let totalSeconds = Double(selectedMinutes * 60)
                let progress = 1.0 - (Double(remainingSeconds) / totalSeconds)
                
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 20)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(Color.goldPrimary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: progress)
                
                VStack(spacing: 8) {
                    Text(timeString(from: remainingSeconds))
                        .font(.system(size: 64, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.primary)
                    
                    Text(settings.showHabitInsteadOfName ? pflanze.localizedHabitName : pflanze.localizedName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .center, spacing: 20) {
                if let activeIndex = sessionGoals.firstIndex(where: { !$0.isCompleted }) {
                    Text(String(localized: "focus.session.current_goal", defaultValue: "AKTUELLES ZIEL"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(2)

                    Text(sessionGoals[activeIndex].text)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 24)
                        .id(sessionGoals[activeIndex].id)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

                    Button {
                        if isHapticEnabled {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            sessionGoals[activeIndex].isCompleted = true
                            sortSessionGoals()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(String(localized: "focus.session.goal_done", defaultValue: "Erledigt"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color.gruenPrimary, in: Capsule())
                        .foregroundStyle(.white)
                        .shadow(color: Color.gruenPrimary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.top, 16)

                    let completedCount = sessionGoals.filter { $0.isCompleted }.count
                    let totalCount = sessionGoals.count
                    Text("\(completedCount) / \(totalCount)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(.top, 8)

                } else if !sessionGoals.isEmpty {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.gruenPrimary)
                        .padding(.bottom, 8)
                    Text(String(localized: "focus.session.all_done", defaultValue: "Alles erledigt!"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.gruenPrimary)
                    Text(String(localized: "focus.session.all_done.desc", defaultValue: "Bleib im Fokus oder beende die Session frühzeitig."))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else {
                    // Falls keine Ziele gesetzt wurden
                    Text(String(localized: "focus.session.no_goals", defaultValue: "Laser-Fokus aktiv"))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.top, 40)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)
            
            Spacer()
            
            if FeatureFlags.isProVersionEnabled {
                FocusSoundControlView()
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
            
            Button {
                showMathChallenge = true
            } label: {
                Text(String(localized: "button.cancel"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
        }
        }
        .fullScreenCover(isPresented: $showMathChallenge) {
            MathChallengeView(problemString: cancelMathProblem, correctAnswer: cancelMathAnswer) {
                showMathChallenge = false
                isTimerRunning = false
                UIApplication.shared.isIdleTimerDisabled = false
                stopLiveActivity()
                dismiss()
                
                let completedSeconds = selectedMinutes * 60 - remainingSeconds
                FocusTimerRecovery.shared.clearState()
                    let durationMinutes = completedSeconds / 60
                    if durationMinutes > 0 {
                        let log = FocusSessionLog(
                            date: Date(),
                            durationMinutes: durationMinutes,
                            isCompleted: false,
                            isRoutine: false,
                            habitId: pflanze.id,
                            habitName: pflanze.name,
                            tasks: sessionGoals.map { $0.text }
                        )
                        gardenStore.focusSessions.append(log)
                    }
            }
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("Timer empty")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
            
            VStack(spacing: 12) {
                Text(String(localized: "focus.session.done", defaultValue: "Geschafft!"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                Text(String(format: String(localized: "focus.session.completed.proud", defaultValue: "Du warst %lld Minuten lang extrem fokussiert. Deine Pflanze ist stolz auf dich!"), selectedMinutes))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                    .opacity(pflanze.isGenericFocus ? 0 : 1) // Hide the text about the plant being proud
                
                // Belohnung anzeigen
                HStack(spacing: 60) {
                    // Coins (Left)
                    VStack(spacing: 4) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        let baseCoins = selectedMinutes
                        let coins = Int(Double(baseCoins) * gardenStore.focusCoinMultiplikator())
                        Text(verbatim: "\(coins)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(String(localized: "focus.session.coins", defaultValue: "Münzen"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        if gardenStore.isProUser {
                            Stat3DTitleView(title: "pro Bonus", color: .goldPrimary, size: 12)
                                .padding(.top, 2)
                        }
                    }
                    
                    // XP (Right)
                    VStack(spacing: 4) {
                        Image("XP")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        let xp = Int(Double(pflanze.xpPerCompletion) * gardenStore.xpMultiplikator(for: pflanze))
                        Text(verbatim: "\(xp)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(String(localized: "common.xp"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .opacity(pflanze.isGenericFocus ? 0 : 1)
                }
                .padding(.top, 24)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(String(localized: "focus.session.collect", defaultValue: "Einsammeln"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large, fillWidth: true,
                backgroundColor: .orangePrimary, shadowColor: .orangePrimary.darker(), foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func finishSession() {
        state = .success
        stopLiveActivity()
        FocusAudioManager.shared.stop()
        FocusTimerRecovery.shared.clearState()
        
        let baseCoins = selectedMinutes
        let coinsEarned = Int(Double(baseCoins) * gardenStore.focusCoinMultiplikator())
        
        gardenStore.coins += coinsEarned
        gardenStore.gesamtVerdient += coinsEarned
        
        let transaction = CoinTransaction(
            datum: Date(),
            beschreibung: String(localized: "focus.generic.reward", defaultValue: "Fokus-Session: \(pflanze.name)"),
            betrag: coinsEarned,
            icon: "timer",
            farbeHex: "#FF9500" // orange
        )
        gardenStore.transactions.insert(transaction, at: 0)
        
        if !pflanze.isGenericFocus {
            let xpGained = Int(Double(pflanze.xpPerCompletion) * gardenStore.xpMultiplikator(for: pflanze))
            
            // Triggert den Habit-Abschluss
            gardenStore.giessen(pflanze: pflanze)
            
            // XP von der spezifischen Pflanze abziehen und auf alle aufteilen
            if !gardenStore.pflanzen.isEmpty {
                pflanze.currentXP -= xpGained
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let key = formatter.string(from: Date())
                if let currentHistory = pflanze.xpHistory[key] {
                    pflanze.xpHistory[key] = max(0, currentHistory - xpGained)
                }
                
                let share = max(1, xpGained / gardenStore.pflanzen.count)
                let remainder = xpGained % gardenStore.pflanzen.count
                
                for (index, p) in gardenStore.pflanzen.enumerated() {
                    let amount = share + (index == 0 ? remainder : 0)
                    p.currentXP += amount
                    p.xpHistory[key] = (p.xpHistory[key] ?? 0) + amount
                }
            }
        }
        
        gardenStore.saveTransactions()
        gardenStore.saveStats()
        
        let log = FocusSessionLog(
            date: Date(),
            durationMinutes: selectedMinutes,
            isCompleted: true,
            isRoutine: false,
            habitId: pflanze.id,
            habitName: pflanze.name,
            tasks: sessionGoals.map { $0.text }
        )
        gardenStore.focusSessions.append(log)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        onSessionCompleted?()
    }
    private func generateHardMathProblem() {
        // Harder math problems! e.g. (A * B) + C or A - (B * C)
        let operations = ["+", "-"]
        let op = operations.randomElement()!
        
        let num1 = Int.random(in: 12...35)
        let num2 = Int.random(in: 3...15)
        let product = num1 * num2
        
        let num3 = Int.random(in: 50...500)
        
        var result = 0
        var problem = ""
        
        if op == "+" {
            result = product + num3
            problem = "(\(num1) × \(num2)) + \(num3)"
        } else {
            if product > num3 {
                result = product - num3
                problem = "(\(num1) × \(num2)) - \(num3)"
            } else {
                result = num3 - product
                problem = "\(num3) - (\(num1) × \(num2))"
            }
        }
        
        self.cancelMathProblem = problem
        self.cancelMathAnswer = result
    }
    
    // MARK: - Live Activity Management
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        let goalTitle = sessionGoals.first(where: { $0.priority == .high })?.text ?? 
                        sessionGoals.first?.text ?? 
                        "Focus Session"
        let currentMusic = FocusAudioManager.shared.isPlaying ? FocusAudioManager.shared.currentSound.displayName : nil
        let tasks = sessionGoals.isEmpty ? nil : sessionGoals.map { $0.text }
        let isPro = iapStore.isProUser
        
        let attributes = FocusTimerActivityAttributes(
            habitName: settings.showHabitInsteadOfName ? pflanze.localizedHabitName : pflanze.localizedName,
            habitId: pflanze.id
        )
        let state = FocusTimerActivityAttributes.ContentState(
            endTime: endTime,
            title: goalTitle,
            musicName: currentMusic,
            tasks: tasks,
            isProUser: isPro,
            isRoutine: false
        )
        
        do {
            focusActivity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            print("Konnte Focus Live Activity nicht starten: \(error)")
        }
    }
    
    private func stopLiveActivity() {
        guard let activity = focusActivity else { return }
        
        Task {
            // Dismissal immediately because the session is over or aborted
            await activity.end(nil, dismissalPolicy: .immediate)
            focusActivity = nil
        }
    }
    
    private func sortSessionGoals() {
        withAnimation {
            sessionGoals.sort {
                if $0.isCompleted != $1.isCompleted {
                    return !$0.isCompleted && $1.isCompleted
                }
                let pOrder: [GoalPriority: Int] = [.high: 3, .medium: 2, .low: 1]
                return pOrder[$0.priority]! > pOrder[$1.priority]!
            }
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = focusActivity else { return }
        
        let endTime = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        let openGoals = sessionGoals.filter { !$0.isCompleted }
        let sortedOpenGoals = openGoals.sorted {
            let pOrder: [GoalPriority: Int] = [.high: 3, .medium: 2, .low: 1]
            return pOrder[$0.priority]! > pOrder[$1.priority]!
        }
        
        let goalTitle = sortedOpenGoals.first?.text ?? "Focus Session"
                        
        let currentMusic = FocusAudioManager.shared.isPlaying ? FocusAudioManager.shared.currentSound.displayName : nil
        let tasks = sessionGoals.isEmpty ? nil : sessionGoals.map { $0.text }
        let isPro = iapStore.isProUser
        
        let state = FocusTimerActivityAttributes.ContentState(
            endTime: endTime,
            title: goalTitle,
            musicName: currentMusic,
            tasks: tasks,
            isProUser: isPro,
            isRoutine: false
        )
        
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
}

struct FocusGoalRow: View {
    @Binding var goal: FocusGoal
    @Binding var draggedGoal: FocusGoal?
    @Binding var sessionGoals: [FocusGoal]
    var onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button {
                    withAnimation {
                        if goal.subtasks.isEmpty {
                            goal._isCompleted.toggle()
                            onToggle()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                } label: {
                    Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(goal.isCompleted ? Color.orangePrimary : Color.gray)
                }
                .disabled(!goal.subtasks.isEmpty)
                .buttonStyle(.plain)
                
                Button {
                    withAnimation {
                        goal.cyclePriority()
                        onToggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(goal.priority.displayName)
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(goal.priority.color)
                    .background(goal.priority.color.opacity(0.15))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Text(goal.text)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .strikethrough(goal.isCompleted)
                    .foregroundStyle(goal.isCompleted ? .secondary : .primary)
                Spacer()
            }
            
            if !goal.subtasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach($goal.subtasks) { $subtask in
                        Button {
                            withAnimation {
                                subtask.isCompleted.toggle()
                                onToggle()
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.turn.down.right")
                                    .foregroundStyle(.secondary)
                                
                                Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(subtask.isCompleted ? Color.orangePrimary : Color.gray)
                                
                                Text(subtask.text)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .strikethrough(subtask.isCompleted)
                                    .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 32)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .onDrag {
            self.draggedGoal = goal
            return NSItemProvider(object: goal.id.uuidString as NSString)
        }
        .onDrop(of: [.text], delegate: GoalDropDelegate(item: goal, items: $sessionGoals, draggedItem: $draggedGoal))
    }
}
