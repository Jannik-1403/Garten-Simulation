import SwiftUI

struct BadHabitCard: View {
    let deko: DecorationItem
    let onCrossApplied: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var position: CGPoint = .zero
    @State private var wobble: CGFloat = 1.0

    /// true wenn das X über dem Button schwebt → Icon ausblenden
    @State private var kreuzUeberButton: Bool = false
    /// true wenn das X auf dem Button "gestempelt" wurde → X auf Button zeigen, unten X weg
    @State private var kreuzAufButton: Bool = false

    private var executionsToday: Int {
        guard let executions = gardenStore.badHabitExecutions[deko.id] else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return executions.filter { Calendar.current.startOfDay(for: $0.date) == startOfDay }.count
    }

    var body: some View {
        ZStack {
            // MARK: - Layer 0: Visual Card Background
            Button {
                guard !kreuzAufButton else { return }
                isVisualPressed = true
                FeedbackManager.shared.playTap()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    isVisualPressed = false
                    onTap()
                }
            } label: {
                Rectangle().fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 320)
            }
            .buttonStyle(PflanzenCardButtonStyle(isVisualPressed: isVisualPressed, isDead: false))

            // MARK: - Layer 1: Interactive Card Content
            VStack(spacing: 16) {
                Color.clear.frame(height: 14)

                // Habit Name
                VStack(spacing: 4) {
                    let titleKey = settings.showHabitInsteadOfName ? deko.habitNameKey : deko.objectNameKey
                    Text(NSLocalizedString(titleKey, comment: ""))
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 4)

                    Text(String(localized: "bad_habit.label", defaultValue: "Schlechte Gewohnheit"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orangePrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orangePrimary.opacity(0.12)))
                        
                    let streakDays = calculateBadHabitStreak()
                    HStack(spacing: 4) {
                        Image("streak")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                        
                        Text("\(String(localized: "streak.label", defaultValue: "Streak")): \(streakDays)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(Color(hex: "#D95F00"))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                // MARK: - Icon Area
                GeometryReader { geo in
                    let scale = min(geo.size.width / 160, 1.2)

                    ZStack {
                        // 3D-Button-Rahmen bleibt immer sichtbar
                        // Nur das Icon drin verschwindet wenn X drüber ist
                        Item3DButton(
                            farbe: .red,
                            sekundaerFarbe: .red.darker(by: 0.2),
                            groesse: 110 * scale,
                            aktion: onTap
                        ) {
                            Group {
                                if UIImage(named: deko.sfSymbol) != nil {
                                    Image(deko.sfSymbol)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(2.2)
                                } else {
                                    Image(systemName: deko.sfSymbol)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(2.2)
                                        .foregroundStyle(.white)
                                }
                            }
                            .opacity((kreuzUeberButton || kreuzAufButton) ? 0 : 1)
                            .animation(.easeInOut(duration: 0.18), value: kreuzUeberButton)
                            .animation(.easeInOut(duration: 0.18), value: kreuzAufButton)
                        }

                        // X auf dem Button — sichtbar wenn gestempelt wurde
                        if kreuzAufButton {
                            Image("SchlechteGewohnheitKreuz")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90 * scale, height: 90 * scale)
                                .transition(.scale(scale: 0.6).combined(with: .opacity))
                        }

                        // Badge Zähler
                        if executionsToday > 0 {
                            Text("\(executionsToday)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.red)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: (110 * scale) / 2.5, y: -(110 * scale) / 2.5)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color.clear
                            .allowsHitTesting(false)
                            .onAppear {
                                let frame = geo.frame(in: .named("BadHabitCardSpace"))
                                position = CGPoint(x: frame.midX, y: frame.midY)
                            }
                    )
                }
                .frame(height: 150)
                .padding(.vertical, 8)
                .scaleEffect(wobble)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: wobble)

                // Drag to Weed Cross
                DragToWeedCross(
                    onCrossApplied: {
                        handleCrossApplied()
                    },
                    pflanzenPosition: position,
                    istErledigt: false,
                    coordinateSpace: .named("BadHabitCardSpace"),
                    istUeberZiel: $kreuzUeberButton,
                    kreuzAufButton: $kreuzAufButton
                )
                .allowsHitTesting(true)
                .frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(true)
        }
        .coordinateSpace(name: "BadHabitCardSpace")
    }

    private func handleCrossApplied() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            wobble = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                wobble = 1.0
            }
        }
        FeedbackManager.shared.playWatering()
        onCrossApplied()

        // Nach dem Sheet schließen: alles zurücksetzen
        // Das passiert via onCrossApplied() → GartenView öffnet Sheet
        // Wir resetten nach einer kurzen Pause (Sheet wird geöffnet)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                kreuzAufButton = false
                kreuzUeberButton = false
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
        onCrossApplied: {},
        onTap: {}
    )
    .background(Color.appHintergrund)
    .environmentObject(GardenStore(isMock: true))
    .environmentObject(SettingsStore())
}
