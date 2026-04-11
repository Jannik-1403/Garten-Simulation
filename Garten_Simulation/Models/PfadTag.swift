import Foundation
import SwiftUI
import SwiftData

@Model
class PfadTag {
    var tagNummer: Int           // 1–90
    var titel: String            // z.B. "Erster Schritt"
    var beschreibung: String     // Was heute zu tun ist
    var pflanzenIDs: [String]    // Welche Pflanzen heute aktiv sind
    var istErledigt: Bool
    var istMeilenstein: Bool     // true bei Tag 7, 14, 30, 60, 90
    var neuerPflanzenHinweis: String?  // nil oder PlantID die empfohlen wird
    var phase: PfadPhase
    var datum: Date?             // Wird gesetzt wenn Pfad startet
    
    init(tagNummer: Int, titel: String, beschreibung: String, pflanzenIDs: [String], istErledigt: Bool = false, istMeilenstein: Bool = false, neuerPflanzenHinweis: String? = nil, phase: PfadPhase, datum: Date? = nil) {
        self.tagNummer = tagNummer
        self.titel = titel
        self.beschreibung = beschreibung
        self.pflanzenIDs = pflanzenIDs
        self.istErledigt = istErledigt
        self.istMeilenstein = istMeilenstein
        self.neuerPflanzenHinweis = neuerPflanzenHinweis
        self.phase = phase
        self.datum = datum
    }
}

enum PfadPhase: String, Codable {
    case einstieg    // Tag 1–14
    case aufbau      // Tag 15–30
    case vertiefung  // Tag 31–60
    case meisterschaft // Tag 61–90
    
    var titel: String {
        switch self {
        case .einstieg: return NSLocalizedString("pfad_phase_einstieg", comment: "")
        case .aufbau: return NSLocalizedString("pfad_phase_aufbau", comment: "")
        case .vertiefung: return NSLocalizedString("pfad_phase_vertiefung", comment: "")
        case .meisterschaft: return NSLocalizedString("pfad_phase_meisterschaft", comment: "")
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
