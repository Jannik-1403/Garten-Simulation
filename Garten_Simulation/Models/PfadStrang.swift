import Foundation
import SwiftData

@Model
class PfadStrang {
    @Attribute(.unique) var id: UUID
    var pflanzenID: String          // Welche Pflanze gehört zu diesem Strang
    var pflanzenName: String        // Anzeigename
    var pflanzenSymbol: String      // SF Symbol aus HabitModel
    var farbe: String               // Hex-Farbe des Strangs
    var istAktiv: Bool              // false = gesperrt (Pflanze noch nicht gekauft)
    var startTag: Int               // Ab welchem Tag dieser Strang beginnt
    var verschmelzungTag: Int?      // Bei welchem Tag verschmilzt er mit dem Hauptstrang
    var reihenfolgeIndex: Int       // 0 = links, 1 = rechts, 2 = mitte, etc.
    
    @Relationship(deleteRule: .cascade, inverse: \PfadStrangTag.strang)
    var tags: [PfadStrangTag]       // Die einzelnen Tages-Nodes dieses Strangs
    
    init(id: UUID = UUID(), 
         pflanzenID: String = "", 
         pflanzenName: String = "", 
         pflanzenSymbol: String = "leaf.fill", 
         farbe: String = "#58CC02", 
         istAktiv: Bool = false, 
         startTag: Int = 1, 
         verschmelzungTag: Int? = nil, 
         reihenfolgeIndex: Int = 0) {
        self.id = id
        self.pflanzenID = pflanzenID
        self.pflanzenName = pflanzenName
        self.pflanzenSymbol = pflanzenSymbol
        self.farbe = farbe
        self.istAktiv = istAktiv
        self.startTag = startTag
        self.verschmelzungTag = verschmelzungTag
        self.reihenfolgeIndex = reihenfolgeIndex
        self.tags = []
    }
}
