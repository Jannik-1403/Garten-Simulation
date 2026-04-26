import Foundation
import SwiftData
import SwiftUI

@Model
class PfadStrangTag: Identifiable {
    var id: UUID = UUID()
    var tagNummer: Int
    var titelKey: String
    var beschreibungKey: String
    var istErledigt: Bool
    var istMeilenstein: Bool
    var istVerschmelzungsPunkt: Bool  // true = dieser Node ist der Merge-Punkt
    var datum: Date?
    var igelAsset: String
    var strang: PfadStrang?
    
    var phase: PfadPhase {
        if tagNummer <= 14 { return .einstieg }
        if tagNummer <= 30 { return .aufbau }
        if tagNummer <= 60 { return .vertiefung }
        return .meisterschaft
    }
    
    init(tagNummer: Int, 
         titelKey: String, 
         beschreibungKey: String, 
         istErledigt: Bool = false, 
         istMeilenstein: Bool = false, 
         istVerschmelzungsPunkt: Bool = false, 
         datum: Date? = nil, 
         igelAsset: String = "Igel-wandern") {
        self.tagNummer = tagNummer
        self.titelKey = titelKey
        self.beschreibungKey = beschreibungKey
        self.istErledigt = istErledigt
        self.istMeilenstein = istMeilenstein
        self.istVerschmelzungsPunkt = istVerschmelzungsPunkt
        self.datum = datum
        self.igelAsset = igelAsset
    }
}

enum PfadPhase: String, Codable, CaseIterable {
    case einstieg    // Tag 1–14
    case aufbau      // Tag 15–30
    case vertiefung  // Tag 31–60
    case meisterschaft // Tag 61–90
    
    var farbe: Color {
        switch self {
        case .einstieg: return Color.green
        case .aufbau: return Color.blue
        case .vertiefung: return Color.orange
        case .meisterschaft: return Color.goldPrimary
        }
    }
}
