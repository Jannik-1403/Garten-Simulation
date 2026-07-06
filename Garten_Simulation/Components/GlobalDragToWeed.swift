import SwiftUI

struct GlobalDragToWeed: View {
    let cardPositions: [CardPositionData]
    let onCrossApplied: (String) -> Void

    @EnvironmentObject var gardenStore: GardenStore

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var hoveredCardID: String? = nil
    
    // Feedback and Animation state
    @State private var hapticTrigger = false
    @State private var crossSkalierung: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            let dragGesture = DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    let isFirstTick = !isDragging
                    isDragging = true
                    dragOffset = value.translation
                    
                    let globalLocation = value.location
                    
                    // Check intersection with cardPositions (using frame)
                    var hitID: String? = nil
                    for card in cardPositions {
                        if card.frame.contains(globalLocation) {
                            hitID = card.id
                            break
                        }
                    }
                    
                    if hitID != hoveredCardID {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            hoveredCardID = hitID
                            crossSkalierung = hitID != nil ? 1.6 : 1.3
                        }
                        if hitID != nil {
                            hapticTrigger.toggle()
                        }
                    } else if isFirstTick {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            crossSkalierung = 1.3
                        }
                    }
                }
                .onEnded { value in
                    if let hitID = hoveredCardID {
                        // Weed action
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            crossSkalierung = 1.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            FeedbackManager.shared.playWatering() // Same sound as water for now, or just haptics
                            onCrossApplied(hitID)
                            
                            // Reset
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                dragOffset = .zero
                                isDragging = false
                                hoveredCardID = nil
                                crossSkalierung = 1.0
                            }
                        }
                    } else {
                        // Reset back to original position
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            dragOffset = .zero
                            isDragging = false
                            hoveredCardID = nil
                            crossSkalierung = 1.0
                        }
                    }
                }
            
            // The Button View
            ZStack {
                // Stationary Button Background
                Item3DButton(
                    farbe: .red,
                    sekundaerFarbe: Color.red.opacity(0.8), // Assuming darker isn't available or just use opacity
                    groesse: 65,
                    isRectangular: true,
                    aktion: {}
                ) {
                    Color.clear
                }
                .allowsHitTesting(false)
                
                // Draggable Icon
                ZStack {
                    Image("SchlechteGewohnheitKreuz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                        .brightness(hoveredCardID != nil ? 0.2 : 0)
                        .offset(y: -4) // Icon etwas weiter nach oben im Button
                }
                .frame(width: 65, height: 65)
                .contentShape(RoundedRectangle(cornerRadius: 15))
                .scaleEffect(crossSkalierung)
                .offset(dragOffset)
                .gesture(dragGesture)
            }
            // Position at bottom right, above the water drop
            .position(x: geo.size.width - 50, y: geo.size.height - 145)
            .sensoryFeedback(.impact, trigger: hoveredCardID != nil)
            .sensoryFeedback(.success, trigger: hapticTrigger)
            
        }
        .ignoresSafeArea(.keyboard)
    }
}
