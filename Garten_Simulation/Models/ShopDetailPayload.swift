import SwiftUI

enum ShopItemType: String, Codable {
    case plant, powerUp, trash
}

struct ShopDetailPayload: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let price: Int
    let icon: String        // SF Symbol Name
    let color: Color
    let symbolColor: String // String Name für HabitModel
    let shadowColor: Color
    let tag: String?
    
    let itemType: ShopItemType
    let habitCategory: HabitCategory?
    let symbolism: String?
    let howToUse: String?
}
