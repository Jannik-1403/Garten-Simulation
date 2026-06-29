import SwiftUI

// MARK: - Drag to Weed Cross

struct DragToWeedCross: View {
    let onCrossApplied: () -> Void
    let pflanzenPosition: CGPoint
    let istErledigt: Bool
    var coordinateSpace: CoordinateSpace = .global

    /// Extern beobachtbar: X schwebt gerade über dem Button (Button-Icon soll verschwinden)
    @Binding var istUeberZiel: Bool
    /// Extern beobachtbar: X wurde auf Button gelassen → Button zeigt das X, das untere X weg
    @Binding var kreuzAufButton: Bool

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var treffer = false
    @State private var letzterTreffer = false
    @State private var hapticTrigger = false
    @State private var crossKippWinkel: Double = 0
    @State private var crossSkalierung: CGFloat = 1.0

    private let crossBreite: CGFloat = 64
    private let crossHoehe: CGFloat = 64
    private let trefferRadius: CGFloat = 75

    var body: some View {
        GeometryReader { geo in
            let dragGesture = DragGesture(coordinateSpace: coordinateSpace)
                .onChanged { value in
                    guard !istErledigt, !kreuzAufButton else { return }

                    let ersterDragTick = !isDragging
                    var t = Transaction()
                    t.animation = nil
                    withTransaction(t) {
                        dragOffset = value.translation
                    }
                    isDragging = true

                    let rotation = Double(value.translation.width) / 20
                    crossKippWinkel = min(max(rotation, -15), 15)

                    let distanz = distance(from: value.location, to: pflanzenPosition)
                    let neuerTreffer = distanz < trefferRadius
                    let trefferGeaendert = neuerTreffer != letzterTreffer

                    if ersterDragTick || trefferGeaendert {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                            treffer = neuerTreffer
                            crossSkalierung = neuerTreffer ? 1.3 : 1.0
                            istUeberZiel = neuerTreffer
                        }
                        letzterTreffer = neuerTreffer
                        if trefferGeaendert {
                            hapticTrigger.toggle()
                        }
                    }
                }
                .onEnded { _ in
                    guard !istErledigt, !kreuzAufButton else { return }

                    if treffer {
                        // X landet auf dem Button: unten ausblenden, oben anzeigen
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                            dragOffset = .zero
                            crossKippWinkel = 0
                            crossSkalierung = 1.0
                            isDragging = false
                            treffer = false
                            letzterTreffer = false
                            kreuzAufButton = true   // X ist jetzt oben auf dem Button
                            // istUeberZiel bleibt true → Button-Icon bleibt unsichtbar
                        }
                        // Rückfall melden
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            onCrossApplied()
                        }
                    } else {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                            dragOffset = .zero
                            isDragging = false
                            treffer = false
                            letzterTreffer = false
                            crossKippWinkel = 0
                            crossSkalierung = 1.0
                            istUeberZiel = false
                        }
                    }
                }

            // Das X unten: verschwindet sobald es auf dem Button gelandet ist
            if !kreuzAufButton {
                ZStack {
                    Image("SchlechteGewohnheitKreuz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: crossBreite * 1.2, height: crossHoehe * 1.2)
                        .padding(20)
                        .contentShape(Rectangle())
                        .simultaneousGesture(dragGesture)
                        .brightness(treffer ? 0.12 : 0)
                        .scaleEffect(crossSkalierung)
                        .rotationEffect(.degrees(isDragging ? crossKippWinkel : 0))
                        .offset(dragOffset)
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: treffer)
                        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: crossSkalierung)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .allowsHitTesting(!kreuzAufButton)
        .sensoryFeedback(.impact, trigger: treffer)
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .onChange(of: istErledigt) { _, erledigt in
            if !erledigt {
                letzterTreffer = false
            }
        }
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        DragToWeedCross(
            onCrossApplied: { print("Angewendet!") },
            pflanzenPosition: CGPoint(x: 200, y: 300),
            istErledigt: false,
            istUeberZiel: .constant(false),
            kreuzAufButton: .constant(false)
        )
    }
}
