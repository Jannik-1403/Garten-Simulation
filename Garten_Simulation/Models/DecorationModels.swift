import Foundation

struct DecorationItem: Identifiable, Codable {
    let id: String
    let nameKey: String
    let descriptionKey: String
    let sfSymbol: String
    let price: Int
    let category: DecorationCategory
    let minGartenLevel: Int

    init(
        id: String,
        nameKey: String,
        descriptionKey: String,
        sfSymbol: String,
        price: Int,
        category: DecorationCategory,
        minGartenLevel: Int = 1
    ) {
        self.id = id
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.sfSymbol = sfSymbol
        self.price = price
        self.category = category
        self.minGartenLevel = minGartenLevel
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
