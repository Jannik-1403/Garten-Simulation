import SwiftUI

struct Item3DButton: View {
    let icon: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var aktion: (() -> Void)? = nil
    
    var body: some View {
        Button {
            // Delay to allow the 3D "pop-back" animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                aktion?()
            }
        } label: {
            Group {
                if UIImage(named: icon) != nil {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: groesse
        ))
    }
}

struct Item3DButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let shadowDepth: CGFloat = 6
        
        ZStack {
            // Shadow / Base
            Circle()
                .fill(sekundaerFarbe)
            
            // Top Layer
            Circle()
                .fill(farbe)
                .overlay {
                    configuration.label
                        .frame(width: groesse * 0.5, height: groesse * 0.5)
                }
                .offset(y: isPressed ? 0 : -shadowDepth)
        }
        .frame(width: groesse, height: groesse)
        .animation(isPressed ? nil : .spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
        .sensoryFeedback(trigger: configuration.isPressed) { _, newValue in
            (isHapticEnabled && newValue) ? .impact(flexibility: .soft, intensity: 0.7) : nil
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        Item3DButton(
            icon: "wunder-box", // Use actual asset if available
            farbe: .white,
            sekundaerFarbe: .gray.opacity(0.2),
            groesse: 80
        )
        
        Item3DButton(
            icon: "epische-samen", 
            farbe: .lilaPrimary.opacity(0.1),
            sekundaerFarbe: .lilaPrimary.opacity(0.3),
            groesse: 80
        )
    }
    .padding()
    .background(Color.blue.opacity(0.05))
}
