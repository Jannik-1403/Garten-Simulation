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
    let minGartenLevel: Int

    init(
        id: String,
        objectNameKey: String,
        objectDescriptionKey: String,
        habitNameKey: String,
        habitDescriptionKey: String,
        sfSymbol: String,
        price: Int,
        category: DecorationCategory,
        minGartenLevel: Int = 1
    ) {
        self.id = id
        self.objectNameKey = objectNameKey
        self.objectDescriptionKey = objectDescriptionKey
        self.habitNameKey = habitNameKey
        self.habitDescriptionKey = habitDescriptionKey
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

    var localizedName: String {
        switch self {
        case .moebel: return String(localized: "badhabit.category.sucht", defaultValue: "Sucht & Laster")
        case .wasser: return String(localized: "badhabit.category.ernaehrung", defaultValue: "Ernährung")
        case .tiere: return String(localized: "badhabit.category.digital", defaultValue: "Digitales")
        case .pfade: return String(localized: "badhabit.category.finanzen", defaultValue: "Konsum")
        case .beleuchtung: return String(localized: "badhabit.category.freizeit", defaultValue: "Freizeit")
        case .deko: return String(localized: "badhabit.category.faulheit", defaultValue: "Faulheit")
        case .pflanzen: return String(localized: "badhabit.category.sonstiges", defaultValue: "Sonstiges")
        }
    }

    var icon: String {
        switch self {
        case .moebel: return "pills.fill"
        case .wasser: return "fork.knife"
        case .tiere: return "iphone"
        case .pfade: return "dollarsign.circle"
        case .beleuchtung: return "gamecontroller.fill"
        case .deko: return "bed.double.fill"
        case .pflanzen: return "ellipsis.circle"
        }
    }
}
