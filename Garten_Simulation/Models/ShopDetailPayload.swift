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
    let minGartenLevel: Int
    
    let itemType: ShopItemType
    let habitCategory: HabitCategory?
    let symbolism: String?
    let howToUse: String?
    let habitName: String?
    
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
        minGartenLevel: Int = 1,
        itemType: ShopItemType,
        habitCategory: HabitCategory? = nil,
        symbolism: String? = nil,
        howToUse: String? = nil,
        habitName: String? = nil
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
        self.minGartenLevel = minGartenLevel
        self.itemType = itemType
        self.habitCategory = habitCategory
        self.symbolism = symbolism
        self.howToUse = howToUse
        self.habitName = habitName
    }
}

extension ShopDetailPayload {
    static func from(plant: Plant) -> ShopDetailPayload {
        ShopDetailPayload(
            id: plant.id,
            title: plant.name,
            subtitle: "Exklusive Pflanze",
            description: plant.symbolism,
            price: plant.basePrice,
            icon: plant.symbolName,
            colorHex: "#27AE60", // Default green
            symbolColor: plant.symbolColor,
            shadowColorHex: "#1E8449",
            minGartenLevel: plant.minGartenLevel,
            itemType: .plant,
            habitCategory: plant.habitCategory,
            symbolism: plant.symbolism,
            habitName: plant.habitName
        )
    }
    
    static func from(powerUp: PowerUpItem) -> ShopDetailPayload {
        ShopDetailPayload(
            id: powerUp.id,
            title: powerUp.name,
            subtitle: "Power-Up",
            description: powerUp.description,
            price: powerUp.basePrice,
            icon: powerUp.symbolName,
            colorHex: "#3498DB", // Default blue
            symbolColor: powerUp.symbolColor,
            shadowColorHex: "#2980B9",
            minGartenLevel: powerUp.minGartenLevel,
            itemType: .powerUp,
            howToUse: powerUp.howToUse
        )
    }

    static func from(decoration: DecorationItem) -> ShopDetailPayload {
        ShopDetailPayload(
            id: decoration.id,
            title: decoration.nameKey,
            subtitle: "Dekoration",
            description: decoration.descriptionKey,
            price: decoration.price,
            icon: decoration.sfSymbol,
            colorHex: "#9B59B6", // Default purple
            symbolColor: "purple",
            shadowColorHex: "#8E44AD",
            minGartenLevel: decoration.minGartenLevel,
            itemType: .decoration
        )
    }
}
