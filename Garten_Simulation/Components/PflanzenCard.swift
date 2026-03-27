import SwiftUI

struct PflanzenCard: View {
    let name: String
    let bildName: String
    let fortschritt: Double
    let gewaessert: Bool
    let giessZaehler: Int
    let seltenheit: Seltenheit
    let letzteGiessung: Date?
    let pflanzenPhase: PflanzenPhase
    let thirstSystem: ThirstSystem
    let wetterEvent: WetterEvent
    let onGiessen: () -> Void
    let onTap: () -> Void

    @State private var pflanzenPosition: CGPoint = .zero
    @State private var giessAnimation = false
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0
    @State private var wasserPressAktiv = false
    @State private var threatPulse = false
    @State private var stopwatchExpanded = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date
            let phase = PflanzenModel.berechnePhase(letzteGiessung: letzteGiessung, jetzt: now)
            let vz = PflanzenModel.verbleibendeZeit(letzteGiessung: letzteGiessung, jetzt: now)
            let countdownKurz = Self.kurzerCountdownText(verbleibend: vz)
            let anzeigeBild = phase == .tot ? "bonsai_stufe5" : bildName

            Button(action: {
                // Delay to allow the 3D "pop-back" animation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    onTap()
                }
            }) {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text(name)
                            .font(.appSubheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)

                        Text(seltenheit.bezeichnung)
                            .font(.appBadge)
                            .foregroundStyle(seltenheit.ringFarbe)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(seltenheit.ringFarbe.opacity(0.15))
                            )

                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(countdownKurz)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    ZStack {
                        SeltenheitProgressRing(
                            progress: CGFloat(fortschritt),
                            color: seltenheit.ringFarbe,
                            lineWidth: 7,
                            size: 100,
                            celebrateTrigger: gewaessert
                        )
                        .allowsHitTesting(false)

                        Circle()
                            .stroke(
                                Color.gruenPrimary.opacity(0.55 * greenGlowOpacity),
                                lineWidth: 6
                            )
                            .frame(width: 126, height: 126)
                            .blur(radius: 1.2)
                            .opacity(greenGlowOpacity)
                            .allowsHitTesting(false)

                        PflanzenButton(
                            bildName: anzeigeBild,
                            farbe: .gruenPrimary,
                            sekundaerFarbe: .gruenSecondary,
                            groesse: 88,
                            externerPress: wasserPressAktiv
                        ) {
                            onTap()
                        }
                        .saturation(phase == .tot ? 0.2 : (phase == .kampf ? 0.75 : 1.0))
                        .opacity(phase == .tot ? 0.65 : 1.0)
                        .offset(x: phase == .kampf ? (threatPulse ? -1 : 1) : 0)

                        Circle()
                            .fill(Color.cyan.opacity(0.35))
                            .frame(width: 118, height: 118)
                            .scaleEffect(giessAnimation ? 1.45 : 1.0)
                            .opacity(giessAnimation ? 0.65 : 0)
                            .animation(.easeOut(duration: 0.6), value: giessAnimation)
                            .allowsHitTesting(false)
                    }
                    .scaleEffect(plantWobble)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.4),
                        value: plantWobble
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .allowsHitTesting(false)
                                .onAppear {
                                    updatePflanzenPosition(from: geo)
                                }
                                .onGeometryChange(for: CGRect.self) { proxy in
                                    proxy.frame(in: .global)
                                } action: { _, newFrame in
                                    pflanzenPosition = CGPoint(
                                        x: newFrame.midX,
                                        y: newFrame.midY
                                    )
                                }
                        }
                    )

                    if !gewaessert {
                        VStack(spacing: 4) {
                            DragToWater(
                                onGiessen: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                        plantWobble = 1.15
                                        greenGlowOpacity = 1.0
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                            plantWobble = 1.0
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
                                        withAnimation(.easeOut(duration: 0.35)) {
                                            greenGlowOpacity = 0
                                        }
                                    }
                                    withAnimation {
                                        giessAnimation = true
                                        wasserPressAktiv = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                        withAnimation(.spring(.snappy(duration: 0.02))) {
                                            wasserPressAktiv = false
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(
                                        deadline: .now() + 0.6
                                    ) {
                                        giessAnimation = false
                                        onGiessen()
                                    }
                                },
                                pflanzenPosition: pflanzenPosition,
                                istErledigt: gewaessert
                            )
                            .id("tropfen-\(giessZaehler)-\(gewaessert)")

                            if wetterEvent == .duerre, giessZaehler == 1 {
                                Text("Noch 1x gießen!")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.gruenPrimary)
                            Text("ERLEDIGT")
                                .font(.appButtonKlein)
                                .foregroundStyle(Color.gruenPrimary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(PflanzenCardButtonStyle(
                seltenheitFarbe: seltenheit.ringFarbe,
                isPhase2: phase == .kampf
            ))
            .saturation(phase == .tot ? 0.2 : 1.0)
            .id(pflanzenPhase)
        }
        .onAppear {
            threatPulse = true
        }
        .onChange(of: gewaessert) { _, neu in
            if neu {
                stopwatchExpanded = false
            }
        }
        .sheet(isPresented: $stopwatchExpanded) {
            ThirstTimerSheetView(
                letzteGiessung: letzteGiessung,
                onDismiss: { stopwatchExpanded = false }
            )
            .presentationDetents([PresentationDetent.medium])
            .presentationCornerRadius(32)
            .presentationBackground(.regularMaterial)
        }
    }

    private func updatePflanzenPosition(from geo: GeometryProxy) {
        let frame = geo.frame(in: .global)
        pflanzenPosition = CGPoint(x: frame.midX, y: frame.midY)
    }

    private static func kurzerCountdownText(verbleibend: TimeInterval) -> String {
        let s = max(0, Int(verbleibend))
        let h = s / 3600
        let m = (s % 3600) / 60
        return "\(h)h \(m)m"
    }

}

struct PflanzenCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let seltenheitFarbe: Color
    let isPhase2: Bool
    private let depth: CGFloat = 8
    private let cornerRadius: CGFloat = 24

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let baseColor = isPhase2 ? Color.orange : seltenheitFarbe
        
        ZStack(alignment: .top) {
            // Unterer Layer (Sockel) - Nutzt hidden Label zur Größenfindung
            configuration.label
                .hidden()
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(baseColor)
                )
                .offset(y: depth)

            // Oberer Layer (Weiße Face)
            configuration.label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                )
                .offset(y: isPressed ? depth : 0)
        }
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.75) : nil
        }
    }
}

// MARK: - Timer-Sheet (Gieß-Countdown)

private struct ThirstTimerSheetView: View {
    let letzteGiessung: Date?
    let onDismiss: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let vz = PflanzenModel.verbleibendeZeit(letzteGiessung: letzteGiessung, jetzt: now)
            let verbleibInt = max(0, Int(vz))
            let stunden = verbleibInt / 3600
            let minuten = (verbleibInt % 3600) / 60
            let sekunden = verbleibInt % 60
            let phase = PflanzenModel.berechnePhase(letzteGiessung: letzteGiessung, jetzt: now)
            let fortschrittInPhase: CGFloat = {
                switch phase {
                case .wachstum, .kampf:
                    return CGFloat(max(0, min(1, 1.0 - (vz / (24 * 3600)))))
                case .tot:
                    return 1.0
                }
            }()
            let phaseFarbe: Color = {
                switch phase {
                case .wachstum: return Color.gruenPrimary
                case .kampf: return Color.orange
                case .tot: return Color.red
                }
            }()
            let (badgeText, badgeColor, beschreibung): (String, Color, String) = {
                switch phase {
                case .wachstum:
                    return (
                        "Phase 1 · Wachstum 🌱",
                        Color.gruenPrimary,
                        "Volle Belohnung wenn du jetzt gießt!"
                    )
                case .kampf:
                    return (
                        "Phase 2 · Überlebenskampf ⚠️",
                        Color.orange,
                        "Nur 50% Belohnung — beeil dich!"
                    )
                case .tot:
                    return (
                        "Pflanze tot 💀",
                        Color.red,
                        "Pflanze ist eingegangen!"
                    )
                }
            }()

            VStack(spacing: 20) {
                Text("Nächstes Gießen in")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 32)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: fortschrittInPhase)
                        .stroke(
                            phaseFarbe,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            ZeitEinheit(wert: stunden, label: "Std")
                            Text(":")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            ZeitEinheit(wert: minuten, label: "Min")
                            Text(":")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            ZeitEinheit(wert: sekunden, label: "Sek")
                        }
                    }
                }
                .padding(.top, 40)

                VStack(spacing: 8) {
                    Text(badgeText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(badgeColor.opacity(0.15)))
                        .foregroundStyle(badgeColor)

                    Text(beschreibung)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button("OK") {
                    onDismiss()
                }
                .buttonStyle(DuolingoButtonStyle())
                .padding(.horizontal, 40)
            }
            .padding(28)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ZeitEinheit: View {
    let wert: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", wert))
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundStyle(.primary)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(width: 75)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack(spacing: 16) {
        PflanzenCard(
            name: "Gym",
            bildName: Seltenheit.silber.iconName,
            fortschritt: 0.6,
            gewaessert: false,
            giessZaehler: 0,
            seltenheit: .silber,
            letzteGiessung: nil,
            pflanzenPhase: .wachstum,
            thirstSystem: ThirstSystem(),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            name: "Lesen",
            bildName: Seltenheit.diamant.iconName,
            fortschritt: 0.9,
            gewaessert: true,
            giessZaehler: 0,
            seltenheit: .diamant,
            letzteGiessung: nil,
            pflanzenPhase: .wachstum,
            thirstSystem: ThirstSystem(),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
}

