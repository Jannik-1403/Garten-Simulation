import SwiftUI

struct PflanzenCard: View {
    let name: String
    let bildName: String
    let fortschritt: Double
    let gewaessert: Bool
    let giessZaehler: Int
    let seltenheit: Seltenheit
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

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { timeline in
            let now = timeline.date
            let thirstState = thirstSystem.state(at: now)
            let ringColor = thirstState == .dead ? Color.gray : thirstSystem.interpolatedColor(at: now)
            let ringTrim = thirstSystem.remainingFraction48h(at: now)
            let countdownKurz = thirstSystem.remainingTextHoursMinutes(at: now)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.86, green: 0.86, blue: 0.88))

                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    // Removed any overlay that draws a pulsating rarity ring here, leaving only the static stroke
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                seltenheit.ringFarbe.opacity(gewaessert ? 0.55 : 0.35),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: Color.black.opacity(0.10),
                        radius: 8,
                        y: 4
                    )
                    .offset(y: cardPressed ? 0 : -8)
                    .animation(.spring(.snappy(duration: 0.02)), value: cardPressed)

                GoldSanduhrCountdownBadge(countdownText: countdownKurz, style: .compact)
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    .offset(x: 0, y: 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .zIndex(4)
                    .onTapGesture {
                        cardHapticTrigger.toggle()
                        stopwatchExpanded = true
                    }

                if thirstState == .thirsty {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.red.opacity(threatPulse ? 0.55 : 0.2), lineWidth: threatPulse ? 3 : 1)
                        .blur(radius: threatPulse ? 8 : 3)
                        .animation(
                            .easeInOut(duration: thirstSystem.thirstyPulseDuration(at: now)).repeatForever(autoreverses: true),
                            value: threatPulse
                        )
                        .allowsHitTesting(false)
                }

                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(name)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(seltenheit.bezeichnung)
                            .font(.appBadge)
                            .foregroundStyle(seltenheit.ringFarbe)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(seltenheit.ringFarbe.opacity(0.15))
                            )
                    }

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                            .frame(width: 90, height: 90)
                            .allowsHitTesting(false)

                        Circle()
                            .trim(from: 0, to: ringTrim)
                            .stroke(
                                ringColor,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.8), value: ringTrim)
                            .allowsHitTesting(false)

                        Circle()
                            .stroke(
                                Color.gruenPrimary.opacity(0.55 * greenGlowOpacity),
                                lineWidth: 4
                            )
                            .frame(width: 96, height: 96)
                            .blur(radius: 1.2)
                            .opacity(greenGlowOpacity)
                            .allowsHitTesting(false)

                        PflanzenButton(
                            bildName: bildName,
                            farbe: .gruenPrimary,
                            sekundaerFarbe: .gruenSecondary,
                            groesse: 72,
                            externerPress: wasserPressAktiv
                        ) {
                            onTap()
                        }
                        .saturation(thirstState == .dead ? 0.0 : (thirstState == .thirsty ? 0.7 : 1.0))
                        .opacity(thirstState == .dead ? 0.55 : 1.0)
                        .offset(x: thirstState == .thirsty ? (threatPulse ? -1 : 1) : 0)

                        Circle()
                            .fill(Color.cyan.opacity(0.35))
                            .frame(width: 90, height: 90)
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
                    .padding(.vertical, 8)
                }
            }
            .padding(20)
            }
        }
        .fullScreenCover(isPresented: $stopwatchExpanded) {
            ThirstStopwatchFullScreenView(
                habitName: name,
                thirstSystem: thirstSystem,
                onDismiss: { stopwatchExpanded = false }
            )
            .presentationBackground(.clear)
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

}

// MARK: - Vollbild-Stoppuhr (Durst-Infos)

private struct ThirstStopwatchFullScreenView: View {
    let habitName: String
    let thirstSystem: ThirstSystem
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                let now = timeline.date
                let sekunden = thirstSystem.remainingSeconds(at: now)
                let countdownAnzeige = thirstSystem.remainingTextHoursMinutes(at: now)
                let phase = thirstSystem.state(at: now)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(habitName)
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("48-Stunden-Fenster")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                            Spacer()
                            Button {
                                onDismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 32))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.white.opacity(0.95))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 4)

                        GoldSanduhrCountdownBadge(countdownText: countdownAnzeige, style: .magnified)
                            .padding(.vertical, 8)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Verbleibende Zeit (exakt)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.8))
                            Text(sekundenFormat(sekunden))
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .fontDesign(.monospaced)
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.12))
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aktuelle Phase")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(phaseTitel(phase))
                                .font(.system(size: 17, weight: .heavy, design: .rounded))
                                .foregroundStyle(phaseAkzent(phase))
                            Text(phaseDetails(phase))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.12))
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Alle Phasen im Überblick")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            phaseInfoKarte(
                                titel: "Phase 1 · 0–24 Std. · Wachstum",
                                zeilen: [
                                    "Farbe der Anzeige: Grün bis Gelb.",
                                    "Belohnung: 100 % Münzen, voller Fortschritt beim Gießen.",
                                    "Die Pflanze wirkt zufrieden, der Ring kann leicht pulsieren.",
                                ]
                            )
                            phaseInfoKarte(
                                titel: "Phase 2 · 24–48 Std. · Überlebenskampf",
                                zeilen: [
                                    "Farbe: Gelb bis kräftiges Rot.",
                                    "Belohnung: reduziert (bis ca. 50 %), kein zusätzliches „Wachstum“ mehr – nur noch Erhalt.",
                                    "Stärkere Stress-Signale (z. B. Zittern/Blässe), Countdown wird im UI betont.",
                                ]
                            )
                            phaseInfoKarte(
                                titel: "Nach 48 Std. · Exitus",
                                zeilen: [
                                    "Die Pflanze wird grau entsättigt, der Glas-Look bricht visuell.",
                                    "Der Streak dieser Gewohnheit geht verloren, wenn du erst dann wieder gießt.",
                                ]
                            )
                        }

                        Button {
                            onDismiss()
                        } label: {
                            Text("Schließen")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.22))
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)

                        Text("Oder tippe oben auf ✕ · Sekunden aktualisieren jede Sekunde.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .padding(.bottom, 36)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sekundenFormat(_ s: Int) -> String {
        "\(s.formatted(.number.grouping(.automatic))) Sekunden"
    }

    private func phaseTitel(_ s: ThirstState) -> String {
        switch s {
        case .healthy: return "Wachstum (0–24 h)"
        case .thirsty: return "Überlebenskampf (24–48 h)"
        case .dead: return "Exitus (über 48 h)"
        }
    }

    private func phaseAkzent(_ s: ThirstState) -> Color {
        switch s {
        case .healthy: return Color(red: 0.45, green: 0.92, blue: 0.55)
        case .thirsty: return Color(red: 1.0, green: 0.45, blue: 0.42)
        case .dead: return Color(white: 0.75)
        }
    }

    private func phaseDetails(_ s: ThirstState) -> String {
        switch s {
        case .healthy:
            return "Du bist in der ersten Hälfte des Fensters. Volle Belohnungen und normales Gieß-Verhalten – so bleibt der Rhythmus gesund."
        case .thirsty:
            return "Die zweite Hälfte des Fensters: Belohnungen sinken stündlich Richtung 50 %, der Fokus liegt auf Überleben. Gießen wirkt nur noch als Erhalt."
        case .dead:
            return "Das 48-Stunden-Limit ist erreicht. Wenn du jetzt gießt, setzt sich diese Uhr zwar zurück, aber der Streak wurde bereits verworfen (laut Spielregel)."
        }
    }

    private func phaseInfoKarte(titel: String, zeilen: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titel)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
            ForEach(Array(zeilen.enumerated()), id: \.offset) { _, z in
                Text("• \(z)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        PflanzenCard(
            name: "Gym",
            bildName: Seltenheit.selten.iconName,
            fortschritt: 0.6,
            gewaessert: false,
            giessZaehler: 0,
            seltenheit: .selten,
            thirstSystem: ThirstSystem(),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            name: "Lesen",
            bildName: Seltenheit.legendaer.iconName,
            fortschritt: 0.9,
            gewaessert: true,
            giessZaehler: 0,
            seltenheit: .legendaer,
            thirstSystem: ThirstSystem(),
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
}

private struct SanduhrSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let my = h * 0.5
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: my * 0.88))
        path.addLine(to: CGPoint(x: w * 0.5, y: my))
        path.addLine(to: CGPoint(x: w, y: h - my * 0.88))
        path.addLine(to: CGPoint(x: w * 0.5, y: h))
        path.addLine(to: CGPoint(x: 0, y: h - my * 0.88))
        path.addLine(to: CGPoint(x: w * 0.5, y: my))
        path.addLine(to: CGPoint(x: 0, y: my * 0.88))
        path.closeSubpath()
        return path
    }
}

/// Goldene, isometrische Sanduhr + Stoppuhr-Hybrid (Belohnungs-Gold, digitaler Countdown).
private struct GoldSanduhrCountdownBadge: View {
    enum Style {
        case compact
        case magnified
    }

    let countdownText: String
    let style: Style

    private var chassisW: CGFloat { style == .compact ? 40 : 82 }
    private var chassisH: CGFloat { style == .compact ? 46 : 92 }
    private var kronenH: CGFloat { style == .compact ? 7 : 12 }
    private var schrift: CGFloat { style == .compact ? 7.2 : 14 }
    private var aussenW: CGFloat { style == .compact ? 52 : 104 }
    private var aussenH: CGFloat { style == .compact ? 62 : 124 }

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: chassisW * 0.88, height: chassisH * 0.14)
                .offset(y: chassisH * 0.52)
                .blur(radius: 3)

            ZStack {
                RoundedRectangle(cornerRadius: style == .compact ? 11 : 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.belohnungGoldHighlight,
                                Color.belohnungGoldMid,
                                Color.belohnungGoldSchatten,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: style == .compact ? 11 : 16)
                            .stroke(Color.white.opacity(0.42), lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: style == .compact ? 11 : 16)
                            .stroke(Color.belohnungGoldSchatten.opacity(0.55), lineWidth: 0.7)
                            .padding(1)
                    )
                    .frame(width: chassisW, height: chassisH)

                SanduhrSilhouette()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.seltenSecondary.opacity(0.08),
                                Color.orangePrimary.opacity(0.35),
                                Color.belohnungGoldSchatten.opacity(0.45),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: chassisW * 0.42, height: chassisH * 0.48)
                    .offset(y: -chassisH * 0.04)

                SanduhrSilhouette()
                    .stroke(Color.belohnungGoldSchatten.opacity(0.88), lineWidth: style == .compact ? 1.1 : 1.8)
                    .frame(width: chassisW * 0.42, height: chassisH * 0.48)
                    .offset(y: -chassisH * 0.04)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.belohnungGoldHighlight, Color.belohnungGoldSchatten],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: chassisW * 0.38, height: kronenH)
                    .offset(y: -chassisH * 0.54)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                    )

                HStack(spacing: chassisW * 0.2) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.belohnungGoldHighlight, Color.belohnungGoldSchatten],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: style == .compact ? 5 : 8, height: style == .compact ? 5 : 8)
                        .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 0.35))
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.belohnungGoldHighlight, Color.belohnungGoldSchatten],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: style == .compact ? 5 : 8, height: style == .compact ? 5 : 8)
                        .overlay(Circle().stroke(Color.white.opacity(0.28), lineWidth: 0.35))
                }
                .offset(y: -chassisH * 0.44)

                Text(countdownText)
                    .font(.system(size: schrift, weight: .heavy, design: .monospaced))
                    .fontDesign(.monospaced)
                    .foregroundStyle(Color(red: 0.12, green: 0.1, blue: 0.06))
                    .minimumScaleFactor(0.45)
                    .lineLimit(1)
                    .tracking(0.15)
                    .padding(.horizontal, style == .compact ? 5 : 10)
                    .padding(.vertical, style == .compact ? 3 : 5)
                    .background(
                        RoundedRectangle(cornerRadius: style == .compact ? 5 : 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.94),
                                        Color(red: 0.98, green: 0.95, blue: 0.88),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: style == .compact ? 5 : 8)
                            .stroke(Color.belohnungGoldSchatten.opacity(0.35), lineWidth: 0.6)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 1, y: 0.5)
                    .offset(y: chassisH * 0.28)
            }
            .rotation3DEffect(.degrees(11), axis: (x: 1, y: -0.72, z: 0))
            .rotationEffect(.degrees(-2.5))
            .shadow(color: Color.belohnungGoldSchatten.opacity(0.35), radius: 0.5, y: 1)
        }
        .frame(width: aussenW, height: aussenH)
        .accessibilityLabel("Countdown \(countdownText)")
    }
}

