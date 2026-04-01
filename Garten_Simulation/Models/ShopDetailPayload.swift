import SwiftUI

enum ShopItemType: String, Codable {
    case plant, powerUp, decoration
}

struct ShopDetailPayload: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let price: Int
    let icon: String        // SF Symbol Name
    let colorHex: String    // Persistent hex string
    let symbolColor: String // String Name für HabitModel
    let shadowColorHex: String // Persistent hex string
    let tag: String?
    
    let itemType: ShopItemType
    let habitCategory: HabitCategory?
    let symbolism: String?
    let howToUse: String?
    
    var color: Color { Color(hex: colorHex) }
    var shadowColor: Color { Color(hex: shadowColorHex) }

    init(
        id: String,
        title: String,
        subtitle: String,
        description: String,
        price: Int,
        icon: String,
        colorHex: String,
        symbolColor: String,
        shadowColorHex: String,
        tag: String? = nil,
        itemType: ShopItemType,
        habitCategory: HabitCategory? = nil,
        symbolism: String? = nil,
        howToUse: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.price = price
        self.icon = icon
        self.colorHex = colorHex
        self.symbolColor = symbolColor
        self.shadowColorHex = shadowColorHex
        self.tag = tag
        self.itemType = itemType
        self.habitCategory = habitCategory
        self.symbolism = symbolism
        self.howToUse = howToUse
    }
}
