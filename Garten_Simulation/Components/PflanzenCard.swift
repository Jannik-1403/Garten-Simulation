import SwiftUI

/// Höhe der sichtbaren Kartenfläche (weißer Bereich), damit der 3D-Sockel nicht die volle Zeilenhöhe der LazyVGrid einnimmt.
private struct PflanzenKartenFaceHoeheKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

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
    @State private var cardPressed = false
    @State private var cardHapticTrigger = false
    @State private var threatPulse = false
    @State private var stopwatchExpanded = false
    @State private var kartenSockelHoehe: CGFloat = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let now = timeline.date
            let phase = PflanzenModel.berechnePhase(letzteGiessung: letzteGiessung, jetzt: now)
            let thirstState = thirstSystem.state(at: now)
            let vz = PflanzenModel.verbleibendeZeit(letzteGiessung: letzteGiessung, jetzt: now)
            let countdownKurz = Self.kurzerCountdownText(verbleibend: vz)
            let anzeigeBild = phase == .tot ? "bonsai_stufe5" : bildName

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.78, green: 0.78, blue: 0.82))
                    .frame(maxWidth: .infinity)
                    .frame(height: kartenSockelHoehe)
                    .opacity(kartenSockelHoehe > 0 ? 1 : 0)

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
                        .onTapGesture {
                            cardHapticTrigger.toggle()
                            stopwatchExpanded = true
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
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    seltenheit.ringFarbe.opacity(gewaessert ? 0.55 : 0.35),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay {
                            if phase == .kampf {
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                            }
                        }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: PflanzenKartenFaceHoeheKey.self,
                            value: geo.size.height
                        )
                    }
                )
                .shadow(
                    color: Color.black.opacity(0.14),
                    radius: 6,
                    y: 5
                )
                .offset(y: cardPressed ? 0 : -8)
                .animation(.spring(.snappy(duration: 0.02)), value: cardPressed)
            }
            .fixedSize(horizontal: false, vertical: true)
            .onPreferenceChange(PflanzenKartenFaceHoeheKey.self) { h in
                kartenSockelHoehe = h
            }
            .saturation(phase == .tot ? 0.2 : 1.0)
            .id(pflanzenPhase)
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $stopwatchExpanded) {
            ThirstTimerSheetView(
                letzteGiessung: letzteGiessung,
                onDismiss: { stopwatchExpanded = false }
            )
            .presentationDetents([PresentationDetent.medium])
            .presentationCornerRadius(32)
            .presentationBackground(.regularMaterial)
        }
        .contentShape(RoundedRectangle(cornerRadius: 24))
        .sensoryFeedback(.selection, trigger: cardHapticTrigger)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    cardPressed = true
                    cardHapticTrigger.toggle()
                }
                .onEnded { _ in
                    cardPressed = false
                }
        )
        .onDisappear {
            cardPressed = false
        }
        .onAppear {
            threatPulse = true
        }
        .onChange(of: gewaessert) { _, neu in
            if neu {
                stopwatchExpanded = false
            }
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

                DuolingoButton(title: "OK", color: .gruenPrimary) {
                    onDismiss()
                }
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

