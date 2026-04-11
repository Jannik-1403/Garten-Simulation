import SwiftUI

struct Item3DButton: View {
    let icon: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var iconSkalierung: CGFloat = 0.7
    var aktion: (() -> Void)? = nil
    
    var body: some View {
        Button {
            // Delay to allow the 3D "pop-back" animation to complete
            // Increased to 0.22s for better visibility of the "up" motion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                aktion?()
            }
        } label: {
            Group {
                if UIImage(named: icon) != nil {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                } else if let _ = UIImage(systemName: icon) {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                } else {
                    // Falls weder Asset noch SF Symbol, zeige es als Text (Emoji Support)
                    Text(icon)
                        .font(.system(size: groesse * 0.45))
                }
            }
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: groesse,
            iconSkalierung: iconSkalierung
        ))
    }
}

struct Item3DButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var iconSkalierung: CGFloat = 0.7

    func makeBody(configuration: Configuration) -> some View {
        Item3DButtonVisualView(
            configuration: configuration,
            farbe: farbe,
            sekundaerFarbe: sekundaerFarbe,
            groesse: groesse,
            iconSkalierung: iconSkalierung,
            isHapticEnabled: isHapticEnabled
        )
    }
}

/// A helper view to manage the visual "pressed" state, ensuring it lasts long enough to be seen.
private struct Item3DButtonVisualView: View {
    let configuration: ButtonStyle.Configuration
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var iconSkalierung: CGFloat = 0.7
    let isHapticEnabled: Bool
    
    @State private var isVisualPressed = false
    
    var body: some View {
        let shadowDepth: CGFloat = groesse * 0.08
        
        ZStack {
            // Shadow / Base
            Circle()
                .fill(sekundaerFarbe)
            
            // Top Layer
            Circle()
                .fill(farbe)
                .overlay {
                    configuration.label
                        .frame(width: groesse * iconSkalierung, height: groesse * iconSkalierung)
                }
                .offset(y: isVisualPressed ? 0 : -shadowDepth)
        }
        .frame(width: groesse, height: groesse)
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: isVisualPressed)
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if newValue {
                // Instantly show pressed state
                isVisualPressed = true
            } else {
                // On release, ensure the "down" state was held for a minimum duration
                // so the animation is visible even for ultra-fast taps.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isVisualPressed = false
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: configuration.isPressed)
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
