import Foundation
import FamilyControls

struct MyLimit: Codable {
    var token: ApplicationToken
    var time: Int
}
let selection = FamilyActivitySelection()
// We can't initialize an ApplicationToken easily to test.
