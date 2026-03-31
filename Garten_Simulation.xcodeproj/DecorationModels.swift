import Foundation

// Central model for garden decorations used across the app.
// Conforms to Codable so we can persist to UserDefaults.
enum DecorationCategory: String, CaseIterable, Codable {
    case moebel
    case wasser
    case tiere
    case pfade
    case beleuchtung

    var localizationKey: String { "decoration.category.\(rawValue)" }
}

struct DecorationItem: Identifiable, Codable {
    let id: String
    let nameKey: String
    let descriptionKey: String
    let sfSymbol: String
    let price: Int
    let category: DecorationCategory
    let coinBonus: Int
}
