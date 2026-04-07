import SwiftUI

struct PflanzenEffekt: Identifiable {
    let id: UUID
    let typ: EffektTyp
    let ikonQuelle: IkonQuelle
    let titel: String
    let beschreibung: String
    let expiresAt: Date?
    
    enum IkonQuelle {
        case system(String)      // SF Symbol — für Wetter-Effekte
        case asset(String)       // Image Asset Name — für Power-Ups
    }
    
    enum EffektTyp {
        case wetter, powerUp, status
        
        var hintergrundFarbe: Color {
            switch self {
            case .wetter:  return Color(.systemBlue).opacity(0.12)
            case .powerUp: return Color(.systemGreen).opacity(0.12)
            case .status:  return Color(.systemOrange).opacity(0.12)
            }
        }
        var ikonFarbe: Color {
            switch self {
            case .wetter:  return Color(.systemBlue)
            case .powerUp: return Color(.systemGreen)
            case .status:  return Color(.systemOrange)
            }
        }
        var rahmenFarbe: Color {
            switch self {
            case .wetter:  return Color(.systemBlue).opacity(0.25)
            case .powerUp: return Color(.systemGreen).opacity(0.25)
            case .status:  return Color(.systemOrange).opacity(0.25)
            }
        }
    }
}
