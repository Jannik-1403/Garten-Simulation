import Foundation

struct TrashItem: Identifiable, Codable, Equatable {
    let id: String
    let nameKey: String
    let descriptionKey: String
    let sfSymbol: String
    let price: Int
    let category: TrashCategory
    let coinBonus: Int
    
    init(
        id: String,
        nameKey: String,
        descriptionKey: String,
        sfSymbol: String,
        price: Int,
        category: TrashCategory,
        coinBonus: Int = 0
    ) {
        self.id = id
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.sfSymbol = sfSymbol
        self.price = price
        self.category = category
        self.coinBonus = coinBonus
    }
}
