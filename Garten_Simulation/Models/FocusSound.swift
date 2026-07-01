import Foundation

/// Definiert die auswählbaren Fokus-Sounds
enum FocusSound: String, CaseIterable, Identifiable {
    case none = "focus.sound.none"
    case whiteNoise = "focus.sound.white_noise"
    case brownNoise = "focus.sound.brown_noise"
    case rain = "focus.sound.rain"
    case cafe = "focus.sound.cafe"
    case zenFlute = "focus.sound.zen_flute"
    
    var id: String { rawValue }
    
    /// Gibt an, ob dieser Sound nur in der Pro-Version verfügbar ist
    var isPremium: Bool {
        switch self {
        case .none, .whiteNoise:
            return false
        default:
            return true
        }
    }
    
    /// Der lokalisierte Anzeigename des Sounds
    var displayName: String {
        switch self {
        case .none:
            return String(localized: "focus.sound.none", defaultValue: "Kein Sound")
        case .whiteNoise:
            return String(localized: "focus.sound.white_noise", defaultValue: "Weißes Rauschen")
        case .brownNoise:
            return String(localized: "focus.sound.brown_noise", defaultValue: "Braunes Rauschen")
        case .rain:
            return String(localized: "focus.sound.rain", defaultValue: "Waldregen")
        case .cafe:
            return String(localized: "focus.sound.cafe", defaultValue: "Kaffeehaus")
        case .zenFlute:
            return String(localized: "focus.sound.zen_flute", defaultValue: "Zen-Flöte")
        }
    }
    
    /// SF-Symbol Name für das Icon des Sounds
    var iconName: String {
        switch self {
        case .none:
            return "speaker.slash.fill"
        case .whiteNoise:
            return "waveform"
        case .brownNoise:
            return "waveform.path"
        case .rain:
            return "cloud.rain.fill"
        case .cafe:
            return "cup.and.saucer.fill"
        case .zenFlute:
            return "music.note"
        }
    }
    
    /// Dateiname der MP3-Ressource im App-Bundle (falls zutreffend)
    var fileName: String {
        switch self {
        case .rain:
            return "forest_rain"
        case .cafe:
            return "coffeehouse"
        case .zenFlute:
            return "zen_flute"
        default:
            return ""
        }
    }
}
