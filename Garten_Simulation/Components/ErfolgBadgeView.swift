import SwiftUI

struct ErfolgBadgeView: View {
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    
    var body: some View {
        ZStack {
            // Äußerer Ring
            Circle()
                .strokeBorder(
                    istFreigeschaltet ? erfolg.farbe : Color.gray.opacity(0.3),
                    lineWidth: 5
                )
                .frame(width: 80, height: 80)
                .shadow(
                    color: istFreigeschaltet ? erfolg.farbe.opacity(0.4) : .clear,
                    radius: 8, y: 3
                )
            
            // Innerer Kreis mit Gradient
            Circle()
                .fill(
                    istFreigeschaltet
                    ? RadialGradient(
                        colors: [erfolg.farbe.opacity(0.9), erfolg.farbe],
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: 40
                      )
                    : RadialGradient(
                        colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                      )
                )
                .frame(width: 68, height: 68)
            
            // Icon
            Image(systemName: istFreigeschaltet ? erfolg.sfSymbol : "lock.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                .offset(y: -4)  // leicht nach oben für Platz der Zahl
            
            // Fortschritts-Zahl unten im Badge
            if istFreigeschaltet || true { // We want the pill regardless of unlock state, or do we? Task says "bei gesperrten 'X/Ziel'". 
                VStack {
                    Spacer()
                    Text(erfolg.fortschrittLabel)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.black.opacity(0.35), in: Capsule())
                        .padding(.bottom, 8)
                }
                .frame(width: 68, height: 68)
            }
        }
        .frame(width: 80, height: 80)
        // Gesperrte Badges: leicht ausgegraut
        .grayscale(istFreigeschaltet ? 0 : 1)
        .opacity(istFreigeschaltet ? 1 : 0.45)
    }
}
