import SwiftUI

struct BadHabitCard: View {
    let deko: DecorationItem
    let onCrossApplied: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    @State private var isVisualPressed = false
    @State private var wobble: CGFloat = 1.0

    private var cleanDays: Int {
        let executions = gardenStore.badHabitExecutions[deko.id] ?? []
        guard let lastExecution = executions.max(by: { $0.date < $1.date })?.date else {
            return 0
        }
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfLast = Calendar.current.startOfDay(for: lastExecution)
        let diff = Calendar.current.dateComponents([.day], from: startOfLast, to: startOfToday).day ?? 0
        return max(0, diff)
    }

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
                    .frame(minHeight: 300)
            }
            .buttonStyle(PflanzenCardButtonStyle(isVisualPressed: isVisualPressed, isDead: false))

            // MARK: - Layer 1: Card Content
            VStack(spacing: 14) {
                Color.clear.frame(height: 10)

                // MARK: Habit Name & Badge
                VStack(spacing: 6) {
                    let titleKey = settings.showHabitInsteadOfName ? deko.habitNameKey : deko.objectNameKey
                    Text(NSLocalizedString(titleKey, comment: ""))
                        .font(.system(size: 17, weight: .black, design: .rounded))
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

                    if cleanDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.green)
                            Text(String(format: String(localized: "bad_habit.clean_streak", defaultValue: "%d Tage sauber"), cleanDays))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                // MARK: Icon Area
                ZStack {
                    Item3DButton(
                        farbe: .red,
                        sekundaerFarbe: .red.darker(by: 0.2),
                        groesse: 100,
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
                    }

                    // Tages-Zähler Badge
                    if executionsToday > 0 {
                        Text("\(executionsToday)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.red)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .offset(x: 44, y: -44)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .scaleEffect(wobble)
                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: wobble)

                // MARK: Press-&-Hold Button „Heute ausgerutscht"
                HoldToConfirmButton(
                    label: String(localized: "bad_habit.log_action", defaultValue: "Heute ausgerutscht"),
                    icon: "SchlechteGewohnheitKreuz",
                    holdDuration: 0.7
                ) {
                    handleCrossApplied()
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .center)
            .allowsHitTesting(true)
        }
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
    }
}

// MARK: - Press & Hold Confirm Button
/// Hält der User den Button für `holdDuration` Sekunden gedrückt,
/// feuert `onConfirm()`. Lässt er früher los, bricht es ab.
struct HoldToConfirmButton: View {
    let label: String
    var icon: String? = nil
    var holdDuration: Double = 0.8
    let onConfirm: () -> Void

    @State private var progress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var timer: Timer? = nil
    @State private var didFire: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Hintergrund
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1.2)
                )

            // Füll-Balken
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.6), Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.linear(duration: 0.05), value: progress)
            }

            // Label
            HStack(spacing: 8) {
                if let iconName = icon, UIImage(named: iconName) != nil {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isHolding ? .white : .red)
                }

                Text(isHolding
                     ? String(localized: "bad_habit.holding", defaultValue: "Halten…")
                     : label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isHolding ? .white : .red)
                    .lineLimit(1)
                    .animation(.easeInOut(duration: 0.15), value: isHolding)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .scaleEffect(isHolding ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHolding)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !didFire else { return }
                    if !isHolding {
                        startHolding()
                    }
                }
                .onEnded { _ in
                    cancelHolding()
                }
        )
        .onChange(of: didFire) { _, fired in
            if fired {
                // kurz warten, dann zurücksetzen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        progress = 0
                        isHolding = false
                        didFire = false
                    }
                }
            }
        }
    }

    private func startHolding() {
        isHolding = true
        progress = 0
        let step = 0.05 / holdDuration
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            progress = min(progress + step, 1.0)
            if progress >= 1.0 {
                t.invalidate()
                timer = nil
                didFire = true
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                onConfirm()
            }
        }
    }

    private func cancelHolding() {
        timer?.invalidate()
        timer = nil
        guard !didFire else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            progress = 0
            isHolding = false
        }
    }
}

#Preview {
    VStack(spacing: 16) {
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
}
