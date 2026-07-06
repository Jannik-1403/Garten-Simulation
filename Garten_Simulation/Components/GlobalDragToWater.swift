import SwiftUI

struct GlobalDragToWater: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    let cardPositions: [CardPositionData]

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    @State private var hoveredCardID: String? = nil
    @State private var hoveredWateredCardID: String? = nil
    
    // Feedback and Animation state
    @State private var hapticTrigger = false
    @State private var errorTrigger = false
    @State private var tropfenSkalierung: CGFloat = 1.0

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
                    var hitWateredID: String? = nil
                    for card in cardPositions {
                        if card.frame.contains(globalLocation) {
                            // Hit
                            if let pflanze = gardenStore.pflanzen.first(where: { $0.id == card.id }), !pflanze.isDead {
                                if !pflanze.istBewässert {
                                    hitID = card.id
                                } else {
                                    hitWateredID = card.id
                                }
                                break
                            }
                        }
                    }
                    
                    hoveredWateredCardID = hitWateredID
                    
                    if hitID != hoveredCardID {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            hoveredCardID = hitID
                            tropfenSkalierung = hitID != nil ? 1.6 : 1.3
                        }
                        if hitID != nil {
                            hapticTrigger.toggle()
                        }
                    } else if isFirstTick {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            tropfenSkalierung = 1.3
                        }
                    }
                }
                .onEnded { value in
                    if let hitID = hoveredCardID,
                       let pflanze = gardenStore.pflanzen.first(where: { $0.id == hitID }) {
                        
                        // Watering action
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                            tropfenSkalierung = 1.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            FeedbackManager.shared.playWatering()
                            // Simulate setting GiessTriggerID so PflanzenCard can animate
                            gardenStore.letzteGiessPflanzeID = hitID
                            gardenStore.giessTriggerID = UUID()
                            
                            gardenStore.giessen(pflanze: pflanze, powerUpStore: powerUpStore)
                            
                            // Reset
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                dragOffset = .zero
                                isDragging = false
                                hoveredCardID = nil
                                hoveredWateredCardID = nil
                                tropfenSkalierung = 1.0
                            }
                        }
                    } else if hoveredWateredCardID != nil {
                        // Error feedback for dropping on already watered plant
                        errorTrigger.toggle()
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            dragOffset = .zero
                            isDragging = false
                            hoveredCardID = nil
                            hoveredWateredCardID = nil
                            tropfenSkalierung = 1.0
                        }
                    } else {
                        // Reset back to original position
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            dragOffset = .zero
                            isDragging = false
                            hoveredCardID = nil
                            hoveredWateredCardID = nil
                            tropfenSkalierung = 1.0
                        }
                    }
                }
            
            // The Button View
            ZStack {
                // Stationary Button Background
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: .blauPrimary.darker(),
                    groesse: 65,
                    isRectangular: true,
                    aktion: {}
                ) {
                    Color.clear
                }
                .frame(width: 65)
                .allowsHitTesting(false)
                
                // Draggable Icon
                ZStack {
                    Image("Drop water")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35) // Kleiner passend zum Button
                        .brightness(hoveredCardID != nil ? 0.2 : 0)
                        .offset(y: -4) // Icon etwas weiter nach oben im Button
                }
                .frame(width: 65, height: 65)
                .contentShape(RoundedRectangle(cornerRadius: 15))
                .scaleEffect(tropfenSkalierung)
                .offset(dragOffset)
                .gesture(dragGesture)
            }
            // Position at bottom right, moved back down
            .position(x: geo.size.width - 50, y: geo.size.height - 70)
            .sensoryFeedback(.impact, trigger: hoveredCardID != nil)
            .sensoryFeedback(.success, trigger: hapticTrigger)
            .sensoryFeedback(.error, trigger: errorTrigger)
        }
        .ignoresSafeArea(.keyboard)
    }
}
