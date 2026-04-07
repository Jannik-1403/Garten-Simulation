import SwiftUI

struct EffektIkonButton: View {
    let effekt: PflanzenEffekt
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Group {
                switch effekt.ikonQuelle {
                case .system(let name):
                    Image(systemName: name)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white)
                case .asset(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .padding(2)
                }
            }
            .frame(width: 20, height: 20)
        }
        .buttonStyle(Item3DButtonStyle(
            farbe: effekt.typ.ikonFarbe,
            sekundaerFarbe: effekt.typ.ikonFarbe.darker(),
            groesse: 20
        ))
    }
}
