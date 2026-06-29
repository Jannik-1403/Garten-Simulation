import SwiftUI

struct BadHabitCard: View {
    let deko: DecorationItem
    let onCrossApplied: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var position: CGPoint = .zero
    @State private var wobble: CGFloat = 1.0

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
                // Spacer for the top where timer would be
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

                GeometryReader { geo in
                    let scale = min(geo.size.width / 160, 1.2)
                    let baseDim: CGFloat = 135 * scale

                    ZStack {
                        Item3DButton(
                            icon: deko.sfSymbol,
                            farbe: .orangePrimary,
                            sekundaerFarbe: .orangeSecondary,
                            groesse: 110 * scale,
                            aktion: onTap
                        )
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
                    coordinateSpace: .named("BadHabitCardSpace")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            FeedbackManager.shared.playWatering() // Or a specific sound for bad habit
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
}
