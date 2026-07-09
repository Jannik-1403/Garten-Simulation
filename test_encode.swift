import Foundation
import FamilyControls

struct AppLimit: Codable {
    let token: ApplicationToken
    var minutes: Int
}
let sel = FamilyActivitySelection()
let limit = AppLimit(token: ApplicationToken(), minutes: 15) // cannot instantiate ApplicationToken() directly
