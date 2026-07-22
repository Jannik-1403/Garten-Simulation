import SwiftUI
import Combine
import FamilyControls
import ActivityKit

enum RoutineSessionState {
    case intro
    case running
    case success
}

struct RoutineSessionView: View {
    let routine: RoutineUIData
    let habits: [HabitModel]
    var onComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var iapStore: IAPStore
    
    @State private var state: RoutineSessionState = .intro
    @State private var currentHabitIndex: Int = 0
    @State private var totalCoins: Int = 0
    @State private var totalXP: Int = 0
    
    @State private var routineActivity: Activity<FocusTimerActivityAttributes>? = nil
    

    @State private var elapsedSeconds: Int = 0
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Screen Time Integration
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showStrictModeAlert = false
    @State private var showScreenTimePicker = false
    @State private var showSettings = false
    

    @State private var showBlockNotice = false
    
    var timeString: String {
        let min = elapsedSeconds / 60
        let sec = elapsedSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                switch state {
                case .intro:
                    introView
                        .transition(.opacity)
                case .running:
                    runningView
                        .transition(.opacity)
                case .success:
                    successView
                        .transition(.scale)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                elapsedSeconds += 1
            }
        }
        .onDisappear {
            isTimerRunning = false
            UIApplication.shared.isIdleTimerDisabled = false
            FocusAudioManager.shared.stop()
            ScreenTimeManager.shared.unblockApps()
            stopLiveActivity()
        }
        .onChange(of: state) {
            if state == .running {
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                UIApplication.shared.isIdleTimerDisabled = false
                if state == .running {
                    isTimerRunning = false
                }
            } else if newPhase == .active {
                if state == .running {
                    UIApplication.shared.isIdleTimerDisabled = true
                    isTimerRunning = true
                }
            }
        }
        .onReceive(FocusAudioManager.shared.objectWillChange) { _ in
            if routineActivity != nil {
                updateLiveActivity()
            }
        }
        .alert(String(localized: "alert.strict_mode.title"), isPresented: $showStrictModeAlert) {
            Button(String(localized: "alert.strict_mode.no"), role: .destructive) {
                if screenTimeManager.isAuthorized {
                    screenTimeManager.blockAllApps()
                    showBlockNotice = true
                } else {
                    startSession()
                }
            }
            Button(String(localized: "alert.strict_mode.yes")) {
                if screenTimeManager.isAuthorized {
                    if screenTimeManager.allowedSelection.applicationTokens.isEmpty && screenTimeManager.allowedSelection.webDomainTokens.isEmpty && screenTimeManager.allowedSelection.categoryTokens.isEmpty {
                        showScreenTimePicker = true
                    } else {
                        screenTimeManager.blockAllExcept(selection: screenTimeManager.allowedSelection)
                        startSession()
                    }
                } else {
                    // Do nothing, or start session without strict mode
                    startSession()
                }
            }
            Button(String(localized: "button.cancel"), role: .cancel) {
                // Do nothing
            }
        } message: {
            Text(String(localized: "alert.strict_mode.message"))
        }
        .familyActivityPicker(isPresented: $showScreenTimePicker, selection: $screenTimeManager.allowedSelection)
        .onChange(of: showScreenTimePicker) { _, isOpen in
            if !isOpen {
                screenTimeManager.blockAllExcept(selection: screenTimeManager.allowedSelection)
                startSession()
            }
        }
        .alert(String(localized: "routine.strict_mode.blocked.title", defaultValue: "Handy blockiert"), isPresented: $showBlockNotice) {
            Button(String(localized: "routine.strict_mode.blocked.ok", defaultValue: "Verstanden"), role: .cancel) {
                startSession()
            }
        } message: {
            Text(String(localized: "routine.strict_mode.blocked.message", defaultValue: "Alle ablenkenden Apps wurden über Screen Time für die Dauer der Routine blockiert."))
        }
    }
    
    private func startSession() {
        withAnimation {
            elapsedSeconds = 0
            state = .running
            isTimerRunning = true
        }
        startLiveActivity()
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                if routine.titleKey == "routine.morning" || routine.titleKey.lowercased() == "morgenroutine" {
                    Image("MorgenRoutine")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                } else if routine.titleKey == "routine.evening" || routine.titleKey.lowercased() == "abendroutine" {
                    Image("AbendRoutine")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                } else if routine.titleKey == "routine.gym" || routine.titleKey.lowercased() == "gymroutine" {
                    Image("GymRoutine")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                } else {
                    Image("allgemeineMorgenroutine")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
            }
            
            VStack(spacing: 12) {
                Text(LocalizedStringKey(routine.titleKey))
                    .environment(\.locale, Locale(identifier: settings.appLanguage))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                if habits.count == 1 {
                    Text(String(localized: "routine.session.ready.subtitle.singular", defaultValue: "1 Gewohnheit. Bereit?"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                } else {
                    Text(String(localized: "routine.session.ready.subtitle", defaultValue: "\(habits.count) Gewohnheiten. Bereit?"))
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            Item3DButton(
                farbe: Color.green,
                sekundaerFarbe: Color.green.darker(),
                groesse: 64,
                isRectangular: true,
                aktion: {
                    showStrictModeAlert = true
                }
            ) {
                Text(String(localized: "routine.session.start"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
            
            Button(String(localized: "common.cancel")) {
                dismiss()
            }
            .font(.system(size: 18, weight: .semibold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Running View
    private var runningView: some View {
        VStack {
            // Header: Stopwatch
            RoutineTimerRing(elapsedSeconds: elapsedSeconds, color: routine.color)
                .padding(.top, 16)
            
            Spacer()
            
            // Progress
            Text(String(localized: "routine.session.progress", defaultValue: "Schritt \(currentHabitIndex + 1) von \(habits.count)"))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            // Current Habit
            if currentHabitIndex < habits.count {
                let currentHabit = habits[currentHabitIndex]
                
                Image(currentHabit.plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding(.top, -10)
                
                Text(LocalizedStringKey(settings.showHabitInsteadOfName ? currentHabit.displayedHabitName : currentHabit.name))
                    .environment(\.locale, Locale(identifier: settings.appLanguage))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, -15) // Moved up to slightly overlap the plant
                    .padding(.horizontal, 32)
                
                if !currentHabit.symbolism.isEmpty {
                    Text(LocalizedStringKey(currentHabit.symbolism))
                        .environment(\.locale, Locale(identifier: settings.appLanguage))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }
                
                if currentHabit.istBewässert {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(String(localized: "routine.session.alreadyCompleted", defaultValue: "Bereits erledigt - keine Belohnung"))
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .padding(.top, 16)
                    .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            if FeatureFlags.isProVersionEnabled {
                FocusSoundControlView()
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)
            }
            
            Item3DButton(
                farbe: routine.color,
                sekundaerFarbe: routine.color.darker(),
                groesse: 76,
                isRectangular: true,
                aktion: {
                    completeCurrentHabit()
                }
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                    Text(currentHabitIndex == habits.count - 1 ? String(localized: "routine.session.finish") : String(localized: "routine.session.next"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
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
                Text(String(localized: "routine.success.title", defaultValue: "Geschafft!"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                
                let durationMins = max(1, elapsedSeconds / 60)
                Text(String(localized: "routine.success.subtitle", defaultValue: "Du warst \(durationMins) Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!"))
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
                        
                        Text(verbatim: "\(totalCoins)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(String(localized: "common.coins", defaultValue: "Münzen"))
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
                        
                        Text(verbatim: "\(totalXP)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(String(localized: "common.xp"))
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
                Text(String(localized: "common.collect", defaultValue: "Einsammeln"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large, fillWidth: true,
                backgroundColor: .orangePrimary, shadowColor: .orangePrimary.darker(), foregroundColor: .white
            ))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    private func completeCurrentHabit() {
        if currentHabitIndex < habits.count {
            let habit = habits[currentHabitIndex]
            
            let wasWatered = habit.istBewässert
            
            // Actually water the plant (this adds coins and XP to the gardenStore globally)
            gardenStore.giessen(pflanze: habit, powerUpStore: powerUpStore, fromRoutine: true)
            
            if !wasWatered {
                totalCoins += gardenStore.letzteGiessCoins
                totalXP += gardenStore.letzteGiessXP
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if currentHabitIndex < habits.count - 1 {
                    currentHabitIndex += 1
                    updateLiveActivity()
                } else {
                    finishRoutine()
                }
            }
        }
    }
    
    private func finishRoutine() {
        isTimerRunning = false
        FocusAudioManager.shared.stop()
        stopLiveActivity()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let durationMins = max(1, elapsedSeconds / 60)
        
        // Die XP und Münzen basieren rein auf den abgeschlossenen Gewohnheiten
        // (es gibt keinen zusätzlichen Timer-Bonus mehr).
        // gardenStore.giessen hat die Coins und XP bereits global hinzugefügt.
        
        // Log as a focus session so it appears in stats
        let log = FocusSessionLog(
            date: Date(),
            durationMinutes: durationMins,
            isCompleted: true,
            isRoutine: true,
            routineNameKey: routine.titleKey,
            habitId: nil,
            habitName: nil,
            tasks: nil
        )
        gardenStore.focusSessions.append(log)
        
        onComplete?()
        
        state = .success
    }
    
    // MARK: - Live Activity
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let routineName = String(localized: String.LocalizationValue(routine.titleKey))
        let attributes = FocusTimerActivityAttributes(
            habitName: routineName,
            habitId: "routine"
        )
        
        // endTime is used as startTime for counting up when isRoutine is true
        let currentMusic = FocusAudioManager.shared.isPlaying ? FocusAudioManager.shared.currentSound.displayName : nil
        
        // Show remaining habits as tasks
        var tasks: [String]? = nil
        if currentHabitIndex < habits.count {
            let remaining = habits[currentHabitIndex..<habits.count]
            tasks = remaining.map { $0.localizedHabitName }
        }
        
        let state = FocusTimerActivityAttributes.ContentState(
            endTime: Date(), 
            title: String(localized: "routine.session.progress", defaultValue: "Schritt \(currentHabitIndex + 1) von \(habits.count)"),
            musicName: currentMusic,
            tasks: tasks,
            isProUser: iapStore.isProUser,
            isRoutine: true
        )
        
        do {
            routineActivity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            print("Konnte Routine Live Activity nicht starten: \(error)")
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = routineActivity else { return }
        
        let currentMusic = FocusAudioManager.shared.isPlaying ? FocusAudioManager.shared.currentSound.displayName : nil
        
        var tasks: [String]? = nil
        if currentHabitIndex < habits.count {
            let remaining = habits[currentHabitIndex..<habits.count]
            tasks = remaining.map { $0.localizedHabitName }
        }
        
        let state = FocusTimerActivityAttributes.ContentState(
            endTime: Date().addingTimeInterval(TimeInterval(-elapsedSeconds)), // Keep the start time consistent
            title: String(localized: "routine.session.progress", defaultValue: "Schritt \(currentHabitIndex + 1) von \(habits.count)"),
            musicName: currentMusic,
            tasks: tasks,
            isProUser: iapStore.isProUser,
            isRoutine: true
        )
        
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }
    
    private func stopLiveActivity() {
        guard let activity = routineActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            routineActivity = nil
        }
    }
}

struct RoutineTimerRing: View {
    let elapsedSeconds: Int
    let color: Color
    
    var timeString: String {
        let min = elapsedSeconds / 60
        let sec = elapsedSeconds % 60
        return String(format: "%02d:%02d", min, sec)
    }
    
    var body: some View {
        ZStack {
            let currentSecond = elapsedSeconds % 60
            
            // 60 Ticks
            ForEach(0..<60) { i in
                Capsule()
                    .fill(i < currentSecond ? color : Color.gray.opacity(0.3))
                    .frame(width: 4, height: 12)
                    .offset(y: -65)
                    .rotationEffect(.degrees(Double(i) * 6))
            }
            
            // 3D Text Timer
            ZStack {
                // Lower layer (shadow)
                Text(timeString)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(color.opacity(0.35))
                    .offset(y: 4)
                
                // Upper layer
                Text(timeString)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(color)
            }
            .frame(width: 100, height: 100)
        }
        .frame(width: 150, height: 150)
    }
}
