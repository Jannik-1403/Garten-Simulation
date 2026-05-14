import Foundation
import SwiftData

@Model
class PfadVerschmelzung {
    @Attribute(.unique) var id: UUID
    var tagNummer: Int              // Bei welchem Tag die Verschmelzung stattfindet
    var strangIDs: [String]         // Welche Stränge verschmelzen (UUIDs als String)
    var istErreicht: Bool           // Hat der Nutzer diesen Punkt erreicht?
    var neuerStrangFarbe: String    // Farbe des neuen kombinierten Strangs
    
    init(id: UUID = UUID(), 
         tagNummer: Int, 
         strangIDs: [String], 
         istErreicht: Bool = false, 
         neuerStrangFarbe: String = "#FFD700") {
        self.id = id
        self.tagNummer = tagNummer
        self.strangIDs = strangIDs
        self.istErreicht = istErreicht
        self.neuerStrangFarbe = neuerStrangFarbe
    }
}
