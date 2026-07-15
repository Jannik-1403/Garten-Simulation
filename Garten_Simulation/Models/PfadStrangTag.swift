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
    
    @Attribute(.externalStorage) var userPhotoData: Data?
    var userNote: String?
    
    var phase: PfadPhase {
        if tagNummer <= 14 { return .einstieg }
        if tagNummer <= 30 { return .aufbau }
        if tagNummer <= 60 { return .vertiefung }
        return .meisterschaft
    }
    
    var belohnung: PfadBelohnung? {
        switch tagNummer {
        case 7: return .coins(100)
        case 14: return .powerup("powerup.gartenschutz")
        case 21: return .coins(250)
        case 30: return .powerup("powerup.zeitkapsel")
        case 45: return .coins(500)
        case 60: return .powerup("powerup.gluecks_segen")
        case 90: return .powerup("powerup.diamant_erde")
        default: return nil
        }
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
    

    var localizedTitle: String {
        switch self {
        case .einstieg: return String(localized: "pfad_phase_tag_titel_einstieg", defaultValue: "Einstieg")
        case .aufbau: return String(localized: "pfad_phase_tag_titel_aufbau", defaultValue: "Aufbau")
        case .vertiefung: return String(localized: "pfad_phase_tag_titel_vertiefung", defaultValue: "Vertiefung")
        case .meisterschaft: return String(localized: "pfad_phase_tag_titel_meisterschaft", defaultValue: "Meisterschaft")
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .einstieg: return String(localized: "pfad_phase_beschreibung_einstieg", defaultValue: "Tag 1–14")
        case .aufbau: return String(localized: "pfad_phase_beschreibung_aufbau", defaultValue: "Tag 15–30")
        case .vertiefung: return String(localized: "pfad_phase_beschreibung_vertiefung", defaultValue: "Tag 31–60")
        case .meisterschaft: return String(localized: "pfad_phase_beschreibung_meisterschaft", defaultValue: "Tag 61–90")
        }
    }

    var farbe: Color {
        switch self {
        case .einstieg: return Color.green
        case .aufbau: return Color.blue
        case .vertiefung: return Color.orange
        case .meisterschaft: return Color.goldPrimary
        }
    }
}
