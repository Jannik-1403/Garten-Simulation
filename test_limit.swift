import Foundation
import FamilyControls

struct LimitEntry: Codable {
    var limit: Int
    var selection: FamilyActivitySelection
}

var selection = FamilyActivitySelection()
let entry = LimitEntry(limit: 5, selection: selection)
let data = try! JSONEncoder().encode([entry])
let decoded = try! JSONDecoder().decode([LimitEntry].self, from: data)
print(decoded.first!.limit)
