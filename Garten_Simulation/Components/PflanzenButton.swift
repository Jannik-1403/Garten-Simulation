import SwiftUI

struct PflanzenButton: View {
    let bildName: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var externerPress: Bool = false
    var aktion: (() -> Void)? = nil
    
    @State private var isPressed = false
    @State private var hapticTrigger = false
    @State private var hatAusgeloest = false
    
    var body: some View {
        ZStack {
            Ellipse()
                .fill(sekundaerFarbe)
            Ellipse()
                .fill(farbe)
                .overlay {
                    Image(bildName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: groesse * 0.55, height: groesse * 0.55)
                }
                .offset(y: (isPressed || externerPress) ? 0 : -6)
        }
        .frame(width: groesse, height: groesse)
        .animation(
            .spring(response: 0.22, dampingFraction: 0.86),
            value: isPressed || externerPress
        )
        .sensoryFeedback(.selection, trigger: hapticTrigger)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                    if !hatAusgeloest {
                        hatAusgeloest = true
                        hapticTrigger.toggle()
                        // Keep the down state briefly, then reset even if a sheet opens immediately.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            aktion?()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            isPressed = false
                            hatAusgeloest = false
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    hatAusgeloest = false
                }
        )
        .onDisappear {
            isPressed = false
            hatAusgeloest = false
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        PflanzenButton(
            bildName: Seltenheit.gewoehnlich.iconName,
            farbe: .gruenPrimary,
            sekundaerFarbe: .gruenSecondary,
            groesse: 100
        )
        
        PflanzenButton(
            bildName: Seltenheit.legendaer.iconName,
            farbe: .gruenPrimary,
            sekundaerFarbe: .gruenSecondary,
            groesse: 80
        )
    }
    .padding()
}
