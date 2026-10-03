import Foundation

/// Wie der Tagesfortschritt einer Gewohnheit manuell erfasst wird.
enum HabitTrackingMode: String, Codable, CaseIterable, Identifiable {
    /// Prozent-Slider (0–100 %)
    case slider
    /// Zähler mit Zielwert (z. B. 50 Liegestütze = 100 %)
    case counter

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .slider: return String(localized: "tracking.mode.slider", defaultValue: "Prozent")
        case .counter: return String(localized: "tracking.mode.counter", defaultValue: "Zähler")
        }
    }
}
