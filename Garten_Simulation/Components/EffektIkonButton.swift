import SwiftUI

struct EffektIkonButton: View {
    let effekt: PflanzenEffekt
    var size: CGFloat = 20
    var iconSkalierung: CGFloat = 0.7
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                switch effekt.ikonQuelle {
                case .system(let name):
                    Image(systemName: name)
                        .font(.system(size: size * iconSkalierung, weight: .medium))
                        .foregroundStyle(.white)
                case .asset(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        // No padding if iconSkalierung is large, otherwise a tiny bit
                        .padding(iconSkalierung > 1.0 ? 0 : size * 0.1)
                }
            }
            .frame(width: size * iconSkalierung, height: size * iconSkalierung)
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: effekt.typ.ikonFarbe,
            sekundaerFarbe: effekt.typ.ikonFarbe.darker(),
            groesse: size,
            iconSkalierung: iconSkalierung
        ))
    }
}
