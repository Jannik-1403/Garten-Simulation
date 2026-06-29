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
    /// Wird von DragToWeedCross gesetzt, wenn das X über dem Button schwebt
    @State private var kreuzUeberButton: Bool = false

    private var executionsToday: Int {
        guard let executions = gardenStore.badHabitExecutions[deko.id] else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return executions.filter { Calendar.current.startOfDay(for: $0.date) == startOfDay }.count
    }

    var body: some View {
        ZStack {
            // MARK: - Layer 0: Visual Card Background
            Button {
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
                // Spacer for the top
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
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                // MARK: - Icon Area (Button + Kreuz overlay)
                GeometryReader { geo in
                    let scale = min(geo.size.width / 160, 1.2)

                    ZStack {
                        // Normaler roter Button — verschwindet wenn X drüber schwebt
                        Item3DButton(
                            icon: deko.sfSymbol,
                            farbe: .red,
                            sekundaerFarbe: .red.darker(by: 0.2),
                            groesse: 110 * scale,
                            aktion: onTap
                        )
                        .opacity(kreuzUeberButton ? 0 : 1)
                        .animation(.easeInOut(duration: 0.15), value: kreuzUeberButton)

                        // Kreuz-Overlay auf dem Button — nur sichtbar wenn X drüber ist
                        if kreuzUeberButton {
                            Image("SchlechteGewohnheitKreuz")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80 * scale, height: 80 * scale)
                                .scaleEffect(kreuzUeberButton ? 1.1 : 0.6)
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: kreuzUeberButton)
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
                    istUeberZiel: $kreuzUeberButton
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            FeedbackManager.shared.playWatering()
            onCrossApplied()
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
