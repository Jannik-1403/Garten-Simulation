import SwiftUI

struct PflanzenButton: View {
    let plant: Plant
    let seltenheit: PflanzenSeltenheit
    let farbe: Color
    let sekundaerFarbe: Color
    let groesse: CGFloat
    var alwaysShowFullGrown: Bool = false
    var externerPress: Bool = false
    var aktion: (() -> Void)? = nil
    
    var body: some View {
        Button {
            aktion?()
        } label: {
            PlantIconView(plant: plant, seltenheit: seltenheit, size: groesse * 0.55, alwaysShowFullGrown: alwaysShowFullGrown)
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
        if let plant1 = GameDatabase.allPlants.first {
            PflanzenButton(
                plant: plant1,
                seltenheit: .bronze,
                farbe: .gruenPrimary,
                sekundaerFarbe: .gruenSecondary,
                groesse: 100
            )
        }
        
        if GameDatabase.allPlants.count > 3 {
            PflanzenButton(
                plant: GameDatabase.allPlants[3],
                seltenheit: .gold,
                farbe: .gruenPrimary,
                sekundaerFarbe: .gruenSecondary,
                groesse: 80
            )
        }
    }
    .padding()
}
