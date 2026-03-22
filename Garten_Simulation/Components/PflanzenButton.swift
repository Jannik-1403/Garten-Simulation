import SwiftUI

struct PflanzenButton: View {
    let bildName: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var aktion: (() -> Void)? = nil
    
    @State private var hapticTrigger = false
    
    var body: some View {
        Button {
            hapticTrigger.toggle()
            aktion?()
        } label: {
            Image(bildName)
                .resizable()
                .scaledToFit()
                .frame(width: groesse * 0.55, height: groesse * 0.55)
        }
        .frame(width: groesse, height: groesse)
        .buttonStyle(DepthButtonStyle(
            foregroundColor: farbe,
            backgroundColor: sekundaerFarbe
        ))
        .sensoryFeedback(.selection, trigger: hapticTrigger)
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
