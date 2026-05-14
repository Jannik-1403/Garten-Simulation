import SwiftUI

struct PathTileView: View {
    let dayNumber: Int
    let status: TileStatus
    let action: () -> Void

    enum TileStatus {
        case erledigt
        case freigeschalten
        case nichtFreigeschalten
    }

    // Größe = tileWidth aus IsometricMath
    private let size: CGFloat = IsometricMath.tileWidth // = 130, quadratisch

    var body: some View {
        Button(action: action) {
            ZStack {
                // Bild exakt in Kachel-Proportionen rendern
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)



                // 2. DIE ZAHL (Nur anzeigen, wenn NICHT freigeschaltet)
                if status == .nichtFreigeschalten {
                    Text("\(dayNumber)")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundColor(textColor)
                        .shadow(color: shadowColor, radius: 0, x: 0, y: 2)
                        .offset(y: -8)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: size, height: size)
    }


    private var imageName: String {
        switch status {
        case .erledigt:
            return "Baumstamm_Erledigt"
        case .freigeschalten:
            return "Baumstamm_Freigeschalten"
        case .nichtFreigeschalten:
            return "Baumstamm_nicht_Freigeschalten"
        }
    }

    private var textColor: Color {
        switch status {
        case .erledigt:
            return .white
        case .freigeschalten:
            return Color(hex: "#4E342E") // Dunkles Braun für den aktiven
        case .nichtFreigeschalten:
            return Color.white.opacity(0.6)
        }
    }

    private var shadowColor: Color {
        switch status {
        case .erledigt:
            return Color.black.opacity(0.3)
        default:
            return Color.clear
        }
    }
}
