import SwiftUI

// MARK: - Globaler Wasser-Tropfen für den Garten
/// Der User zieht diesen Tropfen vom linken Rand auf eine Pflanzenkarte.
/// Karten leuchten grün auf sobald der Tropfen über ihnen schwebt.
struct GlobalWaterDropView: View {
    let cardPositions: [CardPositionData]
    let pflanzen: [HabitModel]
    @Binding var highlightedPlantId: String?
    let onGiessen: (HabitModel) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var pulseScale: CGFloat = 1.0

    private let trefferRadius: CGFloat = 95

    private var unwateredCount: Int {
        pflanzen.filter { !$0.istBewässert && !$0.isDead }.count
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Wasser-Tropfen Icon
            ZStack(alignment: .topTrailing) {
                // Tropfen Bild
                Image("Drop water")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: isDragging ? 68 : 52,
                        height: isDragging ? 80 : 62
                    )
                    .shadow(
                        color: isDragging ? Color.blue.opacity(0.7) : Color.blue.opacity(0.3),
                        radius: isDragging ? 18 : 8,
                        y: isDragging ? 4 : 2
                    )
                    .scaleEffect(isDragging ? 1.0 : pulseScale)

                // Badge: Anzahl un-gegossener Pflanzen
                if unwateredCount > 0 && !isDragging {
                    Text("\(unwateredCount)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .offset(x: 4, y: -4)
                }
            }
            .offset(dragOffset)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { value in
                        // Drag-Offset aktualisieren (ohne Animation für smoothes Folgen)
                        var t = Transaction()
                        t.animation = nil
                        withTransaction(t) {
                            dragOffset = value.translation
                        }
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            isDragging = true
                        }

                        // Nächste un-gegossene Karte finden
                        let loc = value.location
                        let nearest = cardPositions
                            .filter { pos in
                                pflanzen.first(where: { $0.id == pos.id })
                                    .map { !$0.istBewässert && !$0.isDead } ?? false
                            }
                            .min(by: { dist($0.center, loc) < dist($1.center, loc) })

                        if let n = nearest, dist(n.center, loc) < trefferRadius {
                            if highlightedPlantId != n.id {
                                withAnimation(.spring(response: 0.2)) {
                                    highlightedPlantId = n.id
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        } else {
                            if highlightedPlantId != nil {
                                withAnimation(.spring(response: 0.2)) {
                                    highlightedPlantId = nil
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let loc = value.location

                        // Pflanze gießen wenn im Trefferradius
                        if let id = highlightedPlantId,
                           let pflanze = pflanzen.first(where: { $0.id == id }),
                           !pflanze.istBewässert && !pflanze.isDead {
                            // Splash-Effekt Verzögerung für haptisches Feedback
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            onGiessen(pflanze)
                        } else {
                            // Kein Treffer → Tropfen zurückschnappen lassen
                            _ = loc // suppress warning
                        }

                        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                            dragOffset = .zero
                            isDragging = false
                            highlightedPlantId = nil
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
        }
        .onAppear {
            startPulseAnimation()
        }
    }

    // MARK: - Pulsierender Idle-Zustand (Hinweis für User)
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.4)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.08
        }
    }

    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}

#Preview {
    ZStack(alignment: .bottomLeading) {
        Color.appHintergrund.ignoresSafeArea()
        GlobalWaterDropView(
            cardPositions: [],
            pflanzen: [HabitModel(id: "1", name: "Test", symbolName: "leaf", symbolColor: "green", habitCategory: .fitness)],
            highlightedPlantId: .constant(nil),
            onGiessen: { _ in }
        )
        .padding(.leading, 16)
        .padding(.bottom, 100)
    }
}
