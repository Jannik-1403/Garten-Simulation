import SwiftUI
import Combine

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
    
    @State private var state: FocusSessionState = .intro
    @State private var currentGoalInput: String = ""
    @State private var sessionGoals: [FocusGoal] = []
    
    // Timer default 25 mins
    @State private var selectedMinutes: Int = 25
    @State private var remainingSeconds: Int = 25 * 60
    @State private var isTimerRunning = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            switch state {
            case .intro:
                introView
                    .transition(.opacity)
            case .step1:
                FocusSessionPreparationStep(
                    iconName: "iphone.slash",
                    title: "Ablenkungen weg",
                    description: "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.",
                    buttonText: "Erledigt",
                    isLastStep: false
                ) {
                    withAnimation { state = .step2 }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .step2:
                FocusSessionPreparationStep(
                    iconName: "target",
                    title: "Klares Ziel",
                    description: "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.",
                    buttonText: "Timer starten",
                    isLastStep: true,
                    showTextInput: true,
                    textInput: $currentGoalInput,
                    goals: $sessionGoals
                ) {
                    // Keyboard schließen
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        remainingSeconds = selectedMinutes * 60
                        state = .timer
                        isTimerRunning = true
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
            
            // Schließen Button oben rechts (außer beim Timer, da ist abbrechen anders)
            if state != .timer {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(Color.gray.opacity(0.5))
                        }
                        .padding()
                    }
                    Spacer()
                }
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning && remainingSeconds > 0 {
                remainingSeconds -= 1
                if remainingSeconds == 0 {
                    isTimerRunning = false
                    withAnimation {
                        finishSession()
                    }
                }
            }
        }
        // Damit der Timer nicht weiterläuft, wenn man das Sheet schließt
        .onDisappear {
            isTimerRunning = false
        }
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(Color.goldPrimary)
            
            VStack(spacing: 8) {
                Text("Fokus-Session")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                
                Text(settings.showHabitInsteadOfName ? settings.localizedString(for: pflanze.habitName) : settings.localizedString(for: pflanze.name))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(pflanze.color)
            }
            
            VStack(spacing: 12) {
                Text("Dauer: \(selectedMinutes) Minuten")
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
                Text("Vorbereitung starten")
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
        VStack {
            Spacer()
            
            ZStack {
                let totalSeconds = Double(selectedMinutes * 60)
                let progress = 1.0 - (Double(remainingSeconds) / totalSeconds)
                
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 20)
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(pflanze.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Deine Ziele")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.bottom, 4)
                        
                        ForEach($sessionGoals) { $goal in
                            Button {
                                withAnimation {
                                    goal.isCompleted.toggle()
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundStyle(goal.isCompleted ? Color.orangePrimary : Color.gray)
                                    
                                    Text(goal.text)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .strikethrough(goal.isCompleted)
                                        .foregroundStyle(goal.isCompleted ? .secondary : .primary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .frame(maxHeight: 200)
                .padding(.top, 20)
            }
            
            Spacer()
            
            Button {
                isTimerRunning = false
                dismiss()
            } label: {
                Text("Abbrechen")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle().fill(Color.orangePrimary.opacity(0.1))
                    .frame(width: 140, height: 140)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(Color.orangePrimary)
            }
            
            VStack(spacing: 12) {
                Text("Geschafft!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                Text("Du warst \(selectedMinutes) Minuten lang extrem fokussiert. Deine Pflanze ist stolz auf dich!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Einsammeln")
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
        // Triggert den Habit-Abschluss
        gardenStore.giessen(pflanze: pflanze, powerUpStore: powerUpStore)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
