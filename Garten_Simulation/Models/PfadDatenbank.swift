import Foundation

struct PfadTagVorlage {
    let tagNummer: Int
    let titelKey: String
    let beschreibungKey: String
    let phase: PfadPhase
    let istMeilenstein: Bool
    let neuerPflanzenHinweis: String?
}

class PfadDatenbank {
    static func pfadGenerieren(ziel: String, pflanzeEins: String, pflanzeZwei: String) -> [PfadTagVorlage] {
        var pfad: [PfadTagVorlage] = []
        
        let zielSchluessel: String
        switch ziel {
        case "gesund":    zielSchluessel = "gesund"
        case "produktiv": zielSchluessel = "produktiv"
        case "mental":    zielSchluessel = "mental"
        case "fit":       zielSchluessel = "fit"
        case "lernen":    zielSchluessel = "lernen"
        default:          zielSchluessel = "fehlt"
        }
        
        for i in 1...90 {
            let phase: PfadPhase
            var istMeilenstein = false
            var neuerPflanzenHinweis: String? = nil
            
            if i <= 14 {
                phase = .einstieg
                if i == 7 || i == 14 { istMeilenstein = true }
            } else if i <= 30 {
                phase = .aufbau
                if i == 21 || i == 30 { istMeilenstein = true }
                if i == 30 {
                    neuerPflanzenHinweis = empfohleneDrittePflanze(fuer: zielSchluessel)
                }
            } else if i <= 60 {
                phase = .vertiefung
                if i == 45 || i == 60 { istMeilenstein = true }
            } else {
                phase = .meisterschaft
                if i == 90 { istMeilenstein = true }
            }
            
            // Hierarchische Key-Logik (Schritt 1)
            let titelKey: String
            let beschreibungKey: String
            
            let bekannteTage = [1, 2, 7, 14, 21, 30, 45, 60, 90]
            
            if bekannteTage.contains(i) {
                titelKey = "pfad_\(zielSchluessel)_day_\(i)_title"
                beschreibungKey = "pfad_\(zielSchluessel)_day_\(i)_desc"
            } else {
                // Fallback für alle anderen Tage
                titelKey = "pfad_phase_tag_titel_\(phase.rawValue)"
                beschreibungKey = "pfad_\(zielSchluessel)_phase_\(phase.rawValue)_desc"
            }
            
            pfad.append(PfadTagVorlage(
                tagNummer: i,
                titelKey: titelKey,
                beschreibungKey: beschreibungKey,
                phase: phase,
                istMeilenstein: istMeilenstein,
                neuerPflanzenHinweis: neuerPflanzenHinweis
            ))
        }
        
        return pfad
    }
    
    private static func empfohleneDrittePflanze(fuer ziel: String) -> String? {
        switch ziel {
        case "gesund":    return "plant.erdbeerpflanze"
        case "produktiv": return "plant.kirschbaum"
        case "mental":    return "plant.lavendel"
        case "fit":       return "plant.efeu"
        case "lernen":    return "plant.minzpflanze"
        default:          return nil
        }
    }
}
