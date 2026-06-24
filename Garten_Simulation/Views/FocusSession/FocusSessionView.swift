import SwiftUI
import Combine
import ActivityKit

enum FocusSessionState {
    case intro
    case step1
    case step2
    case timer
    case success
}

struct FocusSessionView: View {
    @ObservedObject var pflanze: HabitModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.scenePhase) var scenePhase
    
    @State private var state: FocusSessionState = .intro
    @State private var currentGoalInput: String = ""
    @State private var sessionGoals: [FocusGoal] = []
    
    // Live Activity
    @State private var focusActivity: Activity<FocusTimerActivityAttributes>? = nil
    
    // Strict Mode Tracking
    @State private var isStrictMode: Bool = true
    @State private var showStrictModeAlert: Bool = false
    @State private var backgroundStartTime: Date? = nil
    @State private var showFailAlert: Bool = false
    
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
                        title: "Ablenkungen weg",
                        description: "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.",
                        buttonText: "Erledigt",
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
                        title: "Klares Ziel",
                        description: "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.",
                        buttonText: "Timer starten",
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
                            state = .timer
                            isTimerRunning = true
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
        // Damit der Timer nicht weiterläuft, wenn man das Sheet schließt
        .onDisappear {
            isTimerRunning = false
            UIApplication.shared.isIdleTimerDisabled = false
            stopLiveActivity()
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
                generateCancelMathProblem()
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
                    
                    if isStrictMode && timeAway > 10 {
                        // Fail the session
                        isTimerRunning = false
                        UIApplication.shared.isIdleTimerDisabled = false
                        stopLiveActivity()
                        showFailAlert = true
                        
                        let completedSeconds = selectedMinutes * 60 - remainingSeconds
                        let durationMinutes = completedSeconds / 60
                        if durationMinutes > 0 {
                            gardenStore.focusSessions.append(FocusSessionLog(date: Date(), durationMinutes: durationMinutes, isCompleted: false))
                        }
                    }
                }
            }
        }
        .alert(settings.localizedString(for: "Fokus abgebrochen"), isPresented: $showFailAlert) {
            Button(settings.localizedString(for: "Schließen"), role: .cancel) {
                dismiss()
            }
        } message: {
            Text(settings.localizedString(for: "Du hast die App zu lange verlassen. Dein Fokus-Timer wurde abgebrochen."))
        }
        .alert(settings.localizedString(for: "alert.strict_mode.title"), isPresented: $showStrictModeAlert) {
            Button(settings.localizedString(for: "alert.strict_mode.no"), role: .destructive) {
                isStrictMode = true
                withAnimation { state = .step2 }
            }
            Button(settings.localizedString(for: "alert.strict_mode.yes")) {
                isStrictMode = false
                withAnimation { state = .step2 }
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) {
                // Do nothing, stay on step 1
            }
        } message: {
            Text(settings.localizedString(for: "alert.strict_mode.message"))
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
                Text(settings.localizedString(for: "Fokus-Session"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                
                Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.habitName) : settings.localizedString(for: pflanze.name))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.goldPrimary)
            }
            
            VStack(spacing: 12) {
                Text(String(format: settings.localizedString(for: "Dauer: %lld Minuten"), selectedMinutes))
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
                Text(settings.localizedString(for: "Vorbereitung starten"))
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
                    
                    Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.habitName) : settings.localizedString(for: pflanze.name))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            
            if !sessionGoals.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                        Text(settings.localizedString(for: "Deine Ziele"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.bottom, 4)
                        
                        ForEach($sessionGoals) { $goal in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Button {
                                        withAnimation {
                                            if goal.subtasks.isEmpty {
                                                goal._isCompleted.toggle()
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
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                        Text(LocalizedStringKey(goal.priority.rawValue))
                                    }
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .foregroundStyle(goal.priority.color)
                                    
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
                        }
                    }
                .padding(.horizontal, 32)
                .padding(.top, 20)
            }
            
            Spacer(minLength: 40)
            
            Button {
                showMathChallenge = true
            } label: {
                Text(settings.localizedString(for: "button.cancel"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
        }
        }
        .fullScreenCover(isPresented: $showMathChallenge) {
            MathChallengeView(problemString: cancelMathProblem, correctAnswer: cancelMathAnswer) {
                isTimerRunning = false
                UIApplication.shared.isIdleTimerDisabled = false
                dismiss()
                
                let completedSeconds = selectedMinutes * 60 - remainingSeconds
                let durationMinutes = completedSeconds / 60
                if durationMinutes > 0 {
                    gardenStore.focusSessions.append(FocusSessionLog(date: Date(), durationMinutes: durationMinutes, isCompleted: false))
                }
            }
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("Timer full")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
            
            VStack(spacing: 12) {
                Text(settings.localizedString(for: "Geschafft!"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                Text(String(format: settings.localizedString(for: "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!"), selectedMinutes))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                
                // Belohnung anzeigen
                HStack(spacing: 60) {
                    // Coins (Left)
                    VStack(spacing: 4) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        let coins = Int(Double(GameConstants.coinsProGiessen) * gardenStore.coinMultiplikator(for: pflanze))
                        Text("\(coins)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(settings.localizedString(for: "Münzen"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    
                    // XP (Right)
                    VStack(spacing: 4) {
                        Image("XP")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        let xp = Int(Double(pflanze.xpPerCompletion) * gardenStore.xpMultiplikator(for: pflanze))
                        Text("\(xp)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text("XP")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 24)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text(settings.localizedString(for: "Einsammeln"))
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
        
        let xpGained = Int(Double(pflanze.xpPerCompletion) * gardenStore.xpMultiplikator(for: pflanze))
        
        // Triggert den Habit-Abschluss
        gardenStore.giessen(pflanze: pflanze, powerUpStore: powerUpStore)
        
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
        
        gardenStore.focusSessions.append(FocusSessionLog(date: Date(), durationMinutes: selectedMinutes, isCompleted: true))
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
    
    private func generateCancelMathProblem() {
        let isThreeNumbers = Int.random(in: 1...5) == 1 // 20% chance
        let operations = ["+", "-", "*"]
        let op1 = operations.randomElement()!
        
        var num1 = 0
        var num2 = 0
        var result = 0
        var problem = ""
        
        if op1 == "*" {
            num1 = Int.random(in: 0...10)
            num2 = Int.random(in: 0...10)
            result = num1 * num2
            problem = "\(num1) × \(num2)"
        } else {
            num1 = Int.random(in: 0...1000)
            num2 = Int.random(in: 0...1000)
            if op1 == "-" {
                if num1 < num2 { swap(&num1, &num2) }
                result = num1 - num2
                problem = "\(num1) - \(num2)"
            } else {
                result = num1 + num2
                problem = "\(num1) + \(num2)"
            }
        }
        
        if isThreeNumbers {
            let op2 = ["+", "-"].randomElement()!
            let num3 = Int.random(in: 0...100)
            if op2 == "+" {
                result += num3
                problem += " + \(num3)"
            } else {
                if result < num3 {
                    result += num3
                    problem += " + \(num3)"
                } else {
                    result -= num3
                    problem += " - \(num3)"
                }
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
                        
        let attributes = FocusTimerActivityAttributes(
            habitName: settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.displayedHabitName) : settings.localizedString(for: pflanze.name)
        )
        let state = FocusTimerActivityAttributes.ContentState(
            endTime: endTime,
            title: goalTitle
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
}
