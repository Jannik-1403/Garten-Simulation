import SwiftUI

struct ShopDetailPayload: Identifiable {
    let id: String          // z.B. "wunder-box", "starter-bundle", item.name
    let title: String
    let subtitle: String
    let description: String
    let price: Int
    let icon: String
    let color: Color
    let shadowColor: Color
    let tag: String?
}
