import SwiftUI

struct BadHabitCard: View {
    let deko: DecorationItem
    let onTap: () -> Void
    let onLongPress: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var isLocked = false
    @State private var position: CGPoint = .zero
    @State private var wobble: CGFloat = 1.0

    // Long-Press Logik
    @State private var longPressProgress: CGFloat = 0.0
    @State private var longPressTimer: Timer? = nil
    @State private var isLongPressing: Bool = false
    @State private var idlePulse: CGFloat = 1.0

    private var executionsToday: Int {
        guard let executions = gardenStore.badHabitExecutions[deko.id] else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return executions.filter { Calendar.current.startOfDay(for: $0.date) == startOfDay }.count
    }

    var body: some View {
        Button {
            guard !isLocked else { return }
            isLocked = true
            isVisualPressed = true
            FeedbackManager.shared.playTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isVisualPressed = false
                onTap()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isLocked = false
            }
        } label: {
            // MARK: - Interactive Card Content
            HStack(spacing: 24) {
                
                // MARK: Left Column - 3D Button
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        let scale: CGFloat = 0.8


                        ZStack {
                            // Long-Press Fortschritts-Ring (Rot)
                            if longPressProgress > 0 {
                                Circle()
                                    .trim(from: 0, to: longPressProgress)
                                    .stroke(
                                        Color.red,
                                        style: StrokeStyle(lineWidth: 6 * scale, lineCap: .round)
                                    )
                                    .frame(width: 85 * scale * 1.18, height: 85 * scale * 1.18)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: Color.red.opacity(0.5), radius: 4)
                                    .allowsHitTesting(false)
                            }
                            
                            // Radar Ping for hint
                            if !isLongPressing {
                                Circle()
                                    .stroke(Color.red.opacity(0.5), lineWidth: 3 * scale)
                                    .frame(width: 85 * scale, height: 85 * scale)
                                    .scaleEffect(idlePulse)
                                    .opacity(1.5 - Double(idlePulse))
                                    .allowsHitTesting(false)
                            }

                            // 3D-Button
                            Item3DButton(
                                farbe: .red,
                                sekundaerFarbe: .red.darker(by: 0.2),
                                groesse: 85 * scale,
                                aktion: {
                                    FeedbackManager.shared.playTap()
                                    onTap()
                                }
                            ) {
                                Group {
                                    if UIImage(named: deko.sfSymbol) != nil {
                                        Image(deko.sfSymbol)
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(1.6)
                                    } else {
                                        Image(systemName: deko.sfSymbol)
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(1.6)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .gesture(longPressGesture())

                            // Badge Zähler
                            if executionsToday > 0 {
                                Text(verbatim: "\(executionsToday)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .offset(x: (85 * scale) / 2.5, y: -(85 * scale) / 2.5)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: 90, height: 90)
                    .scaleEffect(wobble)
                    .animation(.spring(response: 0.3, dampingFraction: 0.4), value: wobble)
                    
                    Text(String(localized: "bad_habit.label", defaultValue: "Schlechte Gewohnheit"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orangePrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orangePrimary.opacity(0.12)))
                }
                .frame(width: 100)

                // MARK: Middle Column - Info (Centered)
                VStack(alignment: .center, spacing: 8) {
                    let titleKey = settings.showHabitInsteadOfName ? deko.habitNameKey : deko.objectNameKey
                    Text(NSLocalizedString(titleKey, comment: ""))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        
                    let streakDays = calculateBadHabitStreak()
                    HStack(spacing: 4) {
                        Image("streak")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        
                        Text(verbatim: "\(String(localized: "streak.label", defaultValue: "Streak")): \(streakDays)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(Color(hex: "#D95F00"))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
            .contentShape(Rectangle())
        }
        .buttonStyle(PflanzenCardHorizontalButtonStyle(isVisualPressed: isVisualPressed, isDead: false))
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: BadHabitPositionPreferenceKey.self, value: [
                        CardPositionData(id: deko.id, center: proxy.frame(in: .global).center, frame: proxy.frame(in: .global))
                    ])
            }
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                idlePulse = 1.5
            }
        }
    }

    private func calculateBadHabitStreak() -> Int {
        guard let executions = gardenStore.badHabitExecutions[deko.id], !executions.isEmpty else {
            return 0
        }
        
        if let lastDate = executions.max(by: { $0.date < $1.date })?.date {
            return max(0, Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0)
        }
        return 0
    }

    // MARK: - Long-Press Logik
    private func longPressGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !isLongPressing else { return }
                startLongPress()
            }
            .onEnded { _ in
                cancelLongPress()
            }
    }

    private func startLongPress() {
        guard longPressTimer == nil else { return }
        isLongPressing = true
        longPressProgress = 0
        
        let totalDuration: Double = 2.5
        let tickInterval: Double = 0.016
        let tickIncrement = tickInterval / totalDuration
        var lastHapticProgress: Double = 0.0
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
            DispatchQueue.main.async {
                withAnimation(.linear(duration: tickInterval)) {
                    longPressProgress = min(longPressProgress + tickIncrement, 1.0)
                }
                
                if longPressProgress - lastHapticProgress >= 0.25 {
                    lastHapticProgress = longPressProgress
                    if isHapticEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                
                if longPressProgress >= 1.0 {
                    timer.invalidate()
                    longPressTimer = nil
                    triggerAction()
                }
            }
        }
    }

    private func cancelLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        isLongPressing = false
        withAnimation(.easeOut(duration: 0.25)) {
            longPressProgress = 0
        }
    }

    private func triggerAction() {
        isLongPressing = false
        withAnimation(.easeOut(duration: 0.3)) {
            longPressProgress = 0
        }
        if isHapticEnabled {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        onLongPress()
    }
}

#Preview {
    BadHabitCard(
        deko: DecorationItem(
            id: "trash.1",
            objectNameKey: "Trash 1",
            objectDescriptionKey: "Desc",
            habitNameKey: "Habit 1",
            habitDescriptionKey: "Desc",
            sfSymbol: "trash",
            price: 100,
            category: .deko
        ),
        onTap: {},
        onLongPress: {}
    )
    .background(Color.appHintergrund)
    .environmentObject(GardenStore(isMock: true))
    .environmentObject(SettingsStore())
}
