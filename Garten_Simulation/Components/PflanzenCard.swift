import SwiftUI

struct PflanzenCard: View {
    let name: String
    let bildName: String
    let fortschritt: Double
    let gewaessert: Bool
    let seltenheit: Seltenheit
    let wetterEvent: WetterEvent
    let onGiessen: () -> Void
    let onTap: () -> Void

    @State private var pflanzenPosition: CGPoint = .zero
    @State private var giessAnimation = false
    @State private var plantWobble: CGFloat = 1.0
    @State private var greenGlowOpacity: Double = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            gewaessert
                                ? seltenheit.ringFarbe.opacity(0.4)
                                : wetterEvent.kartenBorder,
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: seltenheit.ringFarbe.opacity(0.15),
                    radius: 8,
                    y: 4
                )

            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text(name)
                        .font(.appSubheadline)
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
                        .trim(from: 0, to: fortschritt)
                        .stroke(
                            gewaessert
                                ? seltenheit.ringFarbe
                                : wetterEvent.bannerFarbe,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: fortschritt)
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
                        groesse: 72
                    ) {
                        onTap()
                    }

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
            .padding(16)
        }
    }

    private func updatePflanzenPosition(from geo: GeometryProxy) {
        let frame = geo.frame(in: .global)
        pflanzenPosition = CGPoint(x: frame.midX, y: frame.midY)
    }
}

#Preview {
    HStack(spacing: 16) {
        PflanzenCard(
            name: "Gym",
            bildName: "icon-bonsaipng",
            fortschritt: 0.6,
            gewaessert: false,
            seltenheit: .selten,
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
        PflanzenCard(
            name: "Lesen",
            bildName: "icon-bonsaipng",
            fortschritt: 0.9,
            gewaessert: true,
            seltenheit: .legendaer,
            wetterEvent: .normal,
            onGiessen: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color.appHintergrund)
}
