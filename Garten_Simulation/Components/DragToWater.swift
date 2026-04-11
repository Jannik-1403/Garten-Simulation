import SwiftUI

// MARK: - Wasser-Partikel

struct WasserPartikel: Identifiable {
    let id = UUID()
    let winkel: Double
    var distanz: CGFloat
    let groesse: CGFloat
    var opazitaet: Double = 1.0
}

// MARK: - Drag to Water

struct DragToWater: View {
    let onGiessen: () -> Void
    let pflanzenPosition: CGPoint
    let istErledigt: Bool

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var treffer = false
    @State private var letzterTreffer = false
    @State private var hapticTrigger = false
    @State private var tropfenKippWinkel: Double = 0
    @State private var tropfenSkalierung: CGFloat = 1.0
    @State private var tropfenOpazitaet: Double = 1.0
    @State private var istVerschwunden = false
    @State private var partikel: [WasserPartikel] = []

    private let tropfenBreite: CGFloat = 64
    private let tropfenHoehe: CGFloat = 84
    private let trefferRadius: CGFloat = 75

    private var partikelCyan: Color {
        Color(red: 0.2, green: 0.9, blue: 1.0)
    }

    private var partikelBlau: Color {
        Color(red: 0.0, green: 0.45, blue: 0.95)
    }

    var body: some View {
        GeometryReader { geo in
            let stripGlobal = geo.frame(in: .global)
            let plantLocal = CGPoint(
                x: pflanzenPosition.x - stripGlobal.minX,
                y: pflanzenPosition.y - stripGlobal.minY
            )

            ZStack {
                ForEach(partikel) { p in
                    let rad = p.winkel * .pi / 180
                    let dx = cos(rad) * p.distanz
                    let dy = sin(rad) * p.distanz
                    let h = p.groesse
                    let w = h * (tropfenBreite / tropfenHoehe)

                    Image("Drop water")
                        .resizable()
                        .scaledToFit()
                        .frame(width: w, height: h)
                        .rotationEffect(.degrees(winkelZuRotation(p.winkel)))
                        .position(x: plantLocal.x + dx, y: plantLocal.y + dy)
                        .opacity(p.opazitaet)
                }

                if !istVerschwunden {
                    Image("Drop water")
                        .resizable()
                        .scaledToFit()
                        .frame(width: tropfenBreite * 1.2, height: tropfenHoehe * 1.2) // Scaling slightly for asset
                        .brightness(treffer ? 0.12 : 0)
                        .scaleEffect(tropfenSkalierung)
                        .opacity(tropfenOpazitaet)
                        .rotationEffect(.degrees(isDragging ? tropfenKippWinkel : 0))
                        .offset(dragOffset)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.5),
                            value: treffer
                        )
                        .animation(
                            .spring(response: 0.15, dampingFraction: 0.6),
                            value: tropfenSkalierung
                        )
                        .animation(
                            .easeIn(duration: 0.2),
                            value: tropfenOpazitaet
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .contentShape(Rectangle())
        .allowsHitTesting(!istVerschwunden)
        .simultaneousGesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    guard !istErledigt, !istVerschwunden else { return }

                    let ersterDragTick = !isDragging
                    var t = Transaction()
                    t.animation = nil
                    withTransaction(t) {
                        dragOffset = value.translation
                    }
                    isDragging = true

                    let rotation = Double(value.translation.width) / 20
                    tropfenKippWinkel = min(max(rotation, -15), 15)

                    let distanz = distance(
                        from: value.location,
                        to: pflanzenPosition
                    )

                    let neuerTreffer = distanz < trefferRadius
                    let trefferGeaendert = neuerTreffer != letzterTreffer

                    if ersterDragTick || trefferGeaendert {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            treffer = neuerTreffer
                            tropfenSkalierung = neuerTreffer ? 1.4 : 1.2
                        }
                        letzterTreffer = neuerTreffer
                        if trefferGeaendert {
                            hapticTrigger.toggle()
                        }
                    }
                }
                .onEnded { _ in
                    guard !istErledigt, !istVerschwunden else { return }

                    if treffer {
                        isDragging = false
                        tropfenKippWinkel = 0
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            tropfenSkalierung = 1.6
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            spawnPartikelTropfen()
                            withAnimation(.easeIn(duration: 0.2)) {
                                tropfenSkalierung = 0.0
                                tropfenOpazitaet = 0.0
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            onGiessen()
                            istVerschwunden = true
                            dragOffset = .zero
                            isDragging = false
                            treffer = false
                            letzterTreffer = false
                        }
                    } else {
                        withAnimation(
                            .spring(
                                response: 0.5,
                                dampingFraction: 0.6
                            )
                        ) {
                            dragOffset = .zero
                            isDragging = false
                            treffer = false
                            letzterTreffer = false
                            tropfenKippWinkel = 0
                            tropfenSkalierung = 1.0
                            tropfenOpazitaet = 1.0
                        }
                    }
                }
        )
        .sensoryFeedback(.impact, trigger: treffer)
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .onChange(of: istErledigt) { _, erledigt in
            if erledigt {
                partikel = []
            } else {
                istVerschwunden = false
                letzterTreffer = false
            }
        }
    }


    private func winkelZuRotation(_ winkel: Double) -> Double {
        winkel - 90
    }

    private func spawnPartikelTropfen() {
        partikel = (0..<10).map { _ in
            WasserPartikel(
                winkel: Double.random(in: 0...360),
                distanz: CGFloat.random(in: 20...60),
                groesse: CGFloat.random(in: 10...18)
            )
        }

        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.6)) {
                partikel = partikel.map { p in
                    var q = p
                    q.distanz *= 2.5
                    q.opazitaet = 0
                    return q
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            partikel = []
        }
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        DragToWater(
            onGiessen: { /* print("Gegossen!") */ },
            pflanzenPosition: CGPoint(x: 200, y: 300),
            istErledigt: false
        )
    }
}
