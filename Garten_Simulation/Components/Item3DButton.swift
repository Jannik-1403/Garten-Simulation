import SwiftUI

struct Item3DButton: View {
    let icon: String
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var iconSkalierung: CGFloat = 0.7
    var isRectangular: Bool = false
    var isPermanentlyPressed: Bool = false
    var shadowDepthFactor: CGFloat = 0.08
    var isDisabled: Bool = false // NEU: Deaktivierter Zustand in Graustufen
    var aktion: (() -> Void)? = nil
    
    @State private var manualPress = false
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    
    // New: Support for custom views
    private var customLabel: AnyView? = nil

    init(icon: String, farbe: Color, sekundaerFarbe: Color, groesse: CGFloat, iconSkalierung: CGFloat = 0.7, isRectangular: Bool = false, isPermanentlyPressed: Bool = false, isDisabled: Bool = false, aktion: (() -> Void)? = nil) {
        self.icon = icon
        self.farbe = farbe
        self.sekundaerFarbe = sekundaerFarbe
        self.groesse = groesse
        self.iconSkalierung = iconSkalierung
        self.isRectangular = isRectangular
        self.isPermanentlyPressed = isPermanentlyPressed
        self.isDisabled = isDisabled
        self.aktion = aktion
    }

    init<V: View>(farbe: Color, sekundaerFarbe: Color, groesse: CGFloat, iconSkalierung: CGFloat = 0.7, shadowDepthFactor: CGFloat = 0.08, isRectangular: Bool = false, isPermanentlyPressed: Bool = false, isDisabled: Bool = false, aktion: (() -> Void)? = nil, @ViewBuilder label: () -> V) {
        self.icon = "" // Not used
        self.farbe = farbe
        self.sekundaerFarbe = sekundaerFarbe
        self.groesse = groesse
        self.iconSkalierung = iconSkalierung
        self.shadowDepthFactor = shadowDepthFactor
        self.isRectangular = isRectangular
        self.isPermanentlyPressed = isPermanentlyPressed
        self.isDisabled = isDisabled
        self.aktion = aktion
        self.customLabel = AnyView(label())
    }
    
    var body: some View {
        Button {
            if isHapticEnabled {
                let impactLight = UIImpactFeedbackGenerator(style: .soft)
                impactLight.impactOccurred(intensity: 0.8)
            }
            
            // Garantierte Animation bei schnellem Tippen
            manualPress = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                manualPress = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    aktion?()
                }
            }
        } label: {
            if let customLabel = customLabel {
                customLabel
            } else {
                defaultLabel
            }
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: isDisabled ? Color(UIColor.systemGray3) : farbe,
            sekundaerFarbe: isDisabled ? Color(UIColor.systemGray) : sekundaerFarbe,
            groesse: groesse,
            iconSkalierung: iconSkalierung,
            shadowDepthFactor: shadowDepthFactor,
            isRectangular: isRectangular,
            isPermanentlyPressed: isPermanentlyPressed,
            isDisabled: isDisabled,
            forcePressed: manualPress
        ))
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var defaultLabel: some View {
        Group {
            if UIImage(named: icon) != nil {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .grayscale(isDisabled ? 1.0 : 0.0)
            } else if let _ = UIImage(systemName: icon) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isDisabled ? Color.white : .white)
            } else {
                Text(icon)
                    .font(.system(size: groesse * 0.45))
                    .foregroundStyle(isDisabled ? Color.white : .white)
            }
        }
    }
}

struct Item3DButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var iconSkalierung: CGFloat = 0.7
    var shadowDepthFactor: CGFloat = 0.08
    var isRectangular: Bool = false
    var isPermanentlyPressed: Bool = false
    var isDisabled: Bool = false
    var forcePressed: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        let shadowDepth: CGFloat = groesse * shadowDepthFactor
        let isPressed = configuration.isPressed || isPermanentlyPressed || forcePressed
        
        ZStack {
            // Shadow / Base
            if isRectangular {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(sekundaerFarbe)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.1), lineWidth: 1))
            } else {
                Circle()
                    .fill(sekundaerFarbe)
                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
            }
            
            // Top Layer
            if isRectangular {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(farbe)
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.black.opacity(0.15), lineWidth: 1))
                    .overlay {
                        configuration.label
                            .padding(.horizontal, 10)
                    }
                    .offset(y: isPressed ? 0 : -shadowDepth)
            } else {
                Circle()
                    .fill(farbe)
                    .overlay(Circle().stroke(Color.black.opacity(0.15), lineWidth: 1))
                    .overlay {
                        configuration.label
                            .frame(width: groesse * iconSkalierung, height: groesse * iconSkalierung)
                    }
                    .offset(y: isPressed ? 0 : -shadowDepth)
            }
        }
        .frame(width: isRectangular ? nil : groesse, height: groesse)
        .animation(.spring(response: 0.22, dampingFraction: 0.5, blendDuration: 0), value: isPressed)
        .sensoryFeedback(trigger: configuration.isPressed) { _, newValue in
            (isHapticEnabled && newValue && !forcePressed) ? .impact(flexibility: .soft, intensity: 0.8) : nil
        }
    }
}
