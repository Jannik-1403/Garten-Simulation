import SwiftUI

struct PflanzenButton: View {
    let bildName: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var externerPress: Bool = false
    var aktion: (() -> Void)? = nil
    
    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                aktion?()
            }
        } label: {
            Image(bildName)
                .resizable()
                .scaledToFit()
        }
        .buttonStyle(PflanzenButtonStyle(
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: groesse,
            externerPress: externerPress
        ))
    }
}

struct PflanzenButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var externerPress: Bool

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed || externerPress
        
        ZStack {
            Ellipse()
                .fill(sekundaerFarbe)
            Ellipse()
                .fill(farbe)
                .overlay {
                    configuration.label
                        .frame(width: groesse * 0.55, height: groesse * 0.55)
                }
                .offset(y: isPressed ? 0 : -6)
        }
        .frame(width: groesse, height: groesse)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: configuration.isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .selection : nil
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        PflanzenButton(
            bildName: "bonsai_stufe1",
            farbe: .gruenPrimary,
            sekundaerFarbe: .gruenSecondary,
            groesse: 100
        )
        
        PflanzenButton(
            bildName: "bonsai_stufe4",
            farbe: .gruenPrimary,
            sekundaerFarbe: .gruenSecondary,
            groesse: 80
        )
    }
    .padding()
}
