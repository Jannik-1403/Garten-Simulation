import SwiftUI
import Combine

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
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var settings: SettingsStore
    
    @State private var state: RoutineSessionState = .intro
    @State private var currentHabitIndex: Int = 0
    @State private var totalCoins: Int = 0
    @State private var totalXP: Int = 0
    
    // Stopwatch
    @State private var elapsedSeconds: Int = 0
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
        }
        .onChange(of: state) {
            if state == .running {
                UIApplication.shared.isIdleTimerDisabled = true
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(routine.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                Image(systemName: routine.icon)
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(routine.color)
            }
            
            VStack(spacing: 12) {
                Text(settings.localizedString(for: routine.titleKey))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("\(habits.count) \(settings.localizedString(for: "routine.session.habits")). \(settings.localizedString(for: "routine.session.ready"))")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Item3DButton(
                farbe: Color.green,
                sekundaerFarbe: Color.green.darker(),
                groesse: 64,
                isRectangular: true,
                aktion: {
                    withAnimation {
                        elapsedSeconds = 0
                        state = .running
                        isTimerRunning = true
                    }
                }
            ) {
                Text(settings.localizedString(for: "routine.session.start"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 32)
            
            Button(settings.localizedString(for: "common.cancel")) {
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
            Text("\(settings.localizedString(for: "routine.session.step")) \(currentHabitIndex + 1) \(settings.localizedString(for: "routine.session.of")) \(habits.count)")
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
                
                Text(settings.showHabitInsteadOfName ? settings.localizedString(for: currentHabit.displayedHabitName) : settings.localizedString(for: currentHabit.name))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, -15) // Moved up to slightly overlap the plant
                    .padding(.horizontal, 32)
                
                if !currentHabit.symbolism.isEmpty {
                    Text(settings.localizedString(for: currentHabit.symbolism))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
            
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
                    Text(currentHabitIndex == habits.count - 1 ? settings.localizedString(for: "routine.session.finish") : settings.localizedString(for: "routine.session.next"))
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
                Text(settings.localizedString(for: "Geschafft!"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                
                let durationMins = max(1, elapsedSeconds / 60)
                Text(String(format: settings.localizedString(for: "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!"), durationMins))
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
                        
                        Text("\(totalCoins)")
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
                        
                        Text("\(totalXP)")
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
    
    // MARK: - Logic
    private func completeCurrentHabit() {
        if currentHabitIndex < habits.count {
            let habit = habits[currentHabitIndex]
            
            // Calculate what giessen will award and add to totals
            let baseCoins = Int(Double(GameConstants.coinsProGiessen) * gardenStore.coinMultiplikator(for: habit))
            let xp = Int(Double(habit.xpPerCompletion) * gardenStore.xpMultiplikator(for: habit))
            
            totalCoins += baseCoins
            totalXP += xp
            
            // Manually add XP without "watering" the plant
            habit.currentXP += xp
            
            // Log XP history
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let key = formatter.string(from: Date())
            habit.xpHistory[key] = (habit.xpHistory[key] ?? 0) + xp
            habit.totalCoinsEarned += baseCoins
            
            gardenStore.xpHinzufuegen(amount: xp)
            gardenStore.savePlants()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                if currentHabitIndex < habits.count - 1 {
                    currentHabitIndex += 1
                } else {
                    finishRoutine()
                }
            }
        }
    }
    
    private func finishRoutine() {
        isTimerRunning = false
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let durationMins = max(1, elapsedSeconds / 60)
        
        // Add duration-based bonus coins, precisely like requested (Focus-like but duration-based)
        // Give coinsProGiessen per minute of duration as a bonus.
        let durationBonusCoins = durationMins * GameConstants.coinsProGiessen
        totalCoins += durationBonusCoins
        
        // Ensure ALL accumulated coins (base + duration bonus) are added to the shop
        gardenStore.coinsGutschreiben(amount: totalCoins, beschreibung: "Routine Abschluss")
        
        // Log as a focus session so it appears in stats
        gardenStore.focusSessions.append(FocusSessionLog(date: Date(), durationMinutes: durationMins, isCompleted: true))
        
        onComplete?()
        
        state = .success
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
