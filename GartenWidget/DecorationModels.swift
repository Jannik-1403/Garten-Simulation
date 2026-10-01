import Foundation

struct DecorationItem: Identifiable, Codable {
    let id: String
    let objectNameKey: String
    let objectDescriptionKey: String
    let habitNameKey: String
    let habitDescriptionKey: String
    let sfSymbol: String
    let price: Int
    let category: DecorationCategory

    init(
        id: String,
        objectNameKey: String,
        objectDescriptionKey: String,
        habitNameKey: String,
        habitDescriptionKey: String,
        sfSymbol: String,
        price: Int,
        category: DecorationCategory
    ) {
        self.id = id
        self.objectNameKey = objectNameKey
        self.objectDescriptionKey = objectDescriptionKey
        self.habitNameKey = habitNameKey
        self.habitDescriptionKey = habitDescriptionKey
        self.sfSymbol = sfSymbol
        self.price = price
        self.category = category
    }
}

enum DecorationCategory: String, CaseIterable, Codable {
    case moebel
    case wasser
    case tiere
    case pfade
    case beleuchtung
    case deko
    case pflanzen

    var localizationKey: String {
        "decoration.category.\(self.rawValue)"
    }

    var icon: String {
        switch self {
        case .moebel: return "chair.lounge.fill"
        case .wasser: return "drop.fill"
        case .tiere: return "bird.fill"
        case .pfade: return "point.topleft.down.curvedto.point.bottomright.up"
        case .beleuchtung: return "lightbulb.fill"
        case .deko: return "sparkles"
        case .pflanzen: return "leaf.fill"
        }
    }
}
