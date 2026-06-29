import SwiftUI

// MARK: - Weed Partikel

struct WeedPartikel: Identifiable {
    let id = UUID()
    let winkel: Double
    var distanz: CGFloat
    let groesse: CGFloat
    var opazitaet: Double = 1.0
}

// MARK: - Drag to Weed Cross

struct DragToWeedCross: View {
    let onCrossApplied: () -> Void
    let pflanzenPosition: CGPoint
    let istErledigt: Bool
    var coordinateSpace: CoordinateSpace = .global

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var treffer = false
    @State private var letzterTreffer = false
    @State private var hapticTrigger = false
    @State private var crossKippWinkel: Double = 0
    @State private var crossSkalierung: CGFloat = 1.0
    @State private var crossOpazitaet: Double = 1.0
    @State private var istVerschwunden = false
    @State private var partikel: [WeedPartikel] = []

    private let crossBreite: CGFloat = 64
    private let crossHoehe: CGFloat = 64
    private let trefferRadius: CGFloat = 75

    var body: some View {
        GeometryReader { geo in
            let stripGlobal = geo.frame(in: coordinateSpace)
            let plantLocal = CGPoint(
                x: pflanzenPosition.x - stripGlobal.minX,
                y: pflanzenPosition.y - stripGlobal.minY
            )

            let dragGesture = DragGesture(coordinateSpace: coordinateSpace)
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
                    crossKippWinkel = min(max(rotation, -15), 15)

                    let distanz = distance(
                        from: value.location,
                        to: pflanzenPosition
                    )

                    let neuerTreffer = distanz < trefferRadius
                    let trefferGeaendert = neuerTreffer != letzterTreffer

                    if ersterDragTick || trefferGeaendert {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            treffer = neuerTreffer
                            crossSkalierung = neuerTreffer ? 1.4 : 1.2
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
                        crossKippWinkel = 0
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            crossSkalierung = 1.6
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            spawnPartikelTropfen()
                            withAnimation(.easeIn(duration: 0.2)) {
                                crossSkalierung = 0.0
                                crossOpazitaet = 0.0
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            onCrossApplied()
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
                            crossKippWinkel = 0
                            crossSkalierung = 1.0
                            crossOpazitaet = 1.0
                        }
                    }
                }

            ZStack {
                ForEach(partikel) { p in
                    let rad = p.winkel * .pi / 180
                    let dx = cos(rad) * p.distanz
                    let dy = sin(rad) * p.distanz
                    let h = p.groesse
                    let w = h

                    Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.red)
                        .frame(width: w, height: h)
                        .position(x: plantLocal.x + dx, y: plantLocal.y + dy)
                        .opacity(p.opazitaet)
                }

                if !istVerschwunden {
                    Image("SchlechteGewohnheitKreuz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: crossBreite * 1.2, height: crossHoehe * 1.2)
                        .padding(20) // Generous touch area
                        .contentShape(Rectangle())
                        .simultaneousGesture(dragGesture)
                        .brightness(treffer ? 0.12 : 0)
                        .scaleEffect(crossSkalierung)
                        .opacity(crossOpazitaet)
                        .rotationEffect(.degrees(isDragging ? crossKippWinkel : 0))
                        .offset(dragOffset)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.5),
                            value: treffer
                        )
                        .animation(
                            .spring(response: 0.15, dampingFraction: 0.6),
                            value: crossSkalierung
                        )
                        .animation(
                            .easeIn(duration: 0.2),
                            value: crossOpazitaet
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .allowsHitTesting(!istVerschwunden)
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

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }

    private func spawnPartikelTropfen() {
        partikel = (0..<12).map { _ in
            WeedPartikel(
                winkel: Double.random(in: 0...360),
                distanz: CGFloat.random(in: 20...60),
                groesse: CGFloat.random(in: 8...14)
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
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        DragToWeedCross(
            onCrossApplied: { print("Angewendet!") },
            pflanzenPosition: CGPoint(x: 200, y: 300),
            istErledigt: false
        )
    }
}
