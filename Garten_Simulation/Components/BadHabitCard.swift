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
                    .frame(minHeight: 110)
            }
            .buttonStyle(PflanzenCardButtonStyle(isVisualPressed: isVisualPressed, isDead: false))

            // MARK: - Layer 1: Interactive Card Content
            HStack(spacing: 12) {
                // --- Left: Icon ---
                ZStack {
                    if UIImage(named: deko.sfSymbol) != nil {
                        Image(deko.sfSymbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    } else {
                        Image(systemName: deko.sfSymbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundStyle(Color.primary)
                    }

                    // Badge Zähler
                    if executionsToday > 0 {
                        Text("\(executionsToday)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.red)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .offset(x: 20, y: -20)
                    }
                }
                .frame(width: 56, height: 56)

                // --- Middle: Text ---
                VStack(alignment: .leading, spacing: 4) {
                    let titleKey = settings.showHabitInsteadOfName ? deko.habitNameKey : deko.objectNameKey
                    Text(NSLocalizedString(titleKey, comment: ""))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(String(localized: "bad_habit.label", defaultValue: "Schlechte Gewohnheit"))
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.orangePrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.orangePrimary.opacity(0.12)))
                }

                Spacer(minLength: 4)

                // --- Right: Drag Cross & Target Box ---
                HStack(spacing: 16) {
                    // Draggable Cross
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
                    .frame(width: 64, height: 64)

                    // Target Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(hex: "#F2F2F7"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(kreuzUeberButton ? Color.orangePrimary : Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                            )
                            .animation(.easeInOut(duration: 0.2), value: kreuzUeberButton)

                        if kreuzAufButton {
                            Image("SchlechteGewohnheitKreuz")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .transition(.scale(scale: 0.6).combined(with: .opacity))
                        }
                    }
                    .frame(width: 64, height: 64)
                    .background(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                let frame = geo.frame(in: .named("BadHabitCardSpace"))
                                position = CGPoint(x: frame.midX, y: frame.midY)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(true)
        }
        .scaleEffect(wobble)
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: wobble)
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
