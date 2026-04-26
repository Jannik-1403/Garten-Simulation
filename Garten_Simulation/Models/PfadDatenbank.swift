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
    static func pfadGenerieren(
        ziel: String,
        pflanzeEins: String,
        pflanzeZwei: String,
        schwierigkeit: PfadSchwierigkeit
    ) -> [PfadTagVorlage] {
        var pfad: [PfadTagVorlage] = []
        
        let zielSchluessel = zielZuSchluessel(ziel)
        
        for i in 1...90 {
            let phase = phaseForTag(i)
            var istMeilenstein = false
            var neuerPflanzenHinweis: String? = nil
            
            if i <= 14 {
                if i == 7 || i == 14 { istMeilenstein = true }
            } else if i <= 30 {
                if i == 21 || i == 30 { istMeilenstein = true }
                if i == 30 {
                    neuerPflanzenHinweis = empfohleneDrittePflanze(fuer: zielSchluessel)
                }
            } else if i <= 60 {
                if i == 45 || i == 60 { istMeilenstein = true }
            } else {
                if i == 90 { istMeilenstein = true }
            }
            
            // Hierarchische Key-Logik (Schritt 1)
            let titelKey: String
            let beschreibungKey: String
            
            let bekannteTage = [1, 2, 7, 14, 21, 30, 45, 60, 90]
            
            if bekannteTage.contains(i) {
                titelKey = "pfad_\(zielSchluessel)_day_\(i)_title"
                // Suffix direkt einbauen:
                beschreibungKey = "pfad_\(zielSchluessel)_day_\(i)_desc_\(schwierigkeit.rawValue)"
            } else {
                titelKey = "pfad_phase_tag_titel_\(phase.rawValue)"
                // Phasen-Fallback auch mit Suffix:
                beschreibungKey = "pfad_\(zielSchluessel)_phase_\(phase.rawValue)_desc_\(schwierigkeit.rawValue)"
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

    // MARK: - Multi-Strand Helpers

    static func zielZuSchluessel(_ ziel: String) -> String {
        switch ziel {
        case "gesund":    return "gesund"
        case "produktiv": return "produktiv"
        case "mental":    return "mental"
        case "fit":       return "fit"
        case "lernen":    return "lernen"
        default:          return "fehlt"
        }
    }

    static func phaseForTag(_ i: Int) -> PfadPhase {
        if i <= 14 { return .einstieg }
        if i <= 30 { return .aufbau }
        if i <= 60 { return .vertiefung }
        return .meisterschaft
    }
    
    static func strangTagsGenerieren(
        ziel: String,
        pflanzenID: String,
        strangIndex: Int,
        schwierigkeit: PfadSchwierigkeit,
        verschmelzungTag: Int?
    ) -> [PfadTagVorlage] {
        var tags: [PfadTagVorlage] = []
        let zielSchluessel = zielZuSchluessel(ziel)

        for i in 1...90 {
            let phase = phaseForTag(i)
            let istMeilenstein = [7, 14, 21, 30, 45, 60, 90].contains(i)
            let bekannteTage = [1, 2, 7, 14, 21, 30, 45, 60, 90]

            // Prüfen ob Tag verschmolzen ist
            let istVerschmolzen = (verschmelzungTag != nil && i >= (verschmelzungTag ?? 999))
            
            let titelKey: String
            let beschreibungKey: String

            let plantIDClean = pflanzenID.replacingOccurrences(of: "plant.", with: "")
            let plantTitelKey = "pfad_\(plantIDClean)_day_\(i)_title"
            let genericTitelKey = bekannteTage.contains(i) ? "pfad_generic_day_\(i)_title" : "pfad_phase_tag_titel_\(phase.rawValue)"
            let goalTitelKey = bekannteTage.contains(i) ? "pfad_\(zielSchluessel)_day_\(i)_title" : "pfad_phase_tag_titel_\(phase.rawValue)"
            
            // Check plant -> then generic -> then goal
            if NSLocalizedString(plantTitelKey, comment: "") != plantTitelKey {
                titelKey = plantTitelKey
            } else if NSLocalizedString(genericTitelKey, comment: "") != genericTitelKey {
                titelKey = genericTitelKey
            } else {
                titelKey = goalTitelKey
            }

            if bekannteTage.contains(i) {
                let plantDescKey = "pfad_\(plantIDClean)_day_\(i)_desc_\(schwierigkeit.rawValue)"
                let genericDescKey = "pfad_generic_day_\(i)_desc_\(schwierigkeit.rawValue)"
                let goalDescKey = "pfad_\(zielSchluessel)_day_\(i)_desc_\(schwierigkeit.rawValue)"
                
                if NSLocalizedString(plantDescKey, comment: "") != plantDescKey {
                    beschreibungKey = plantDescKey
                } else if NSLocalizedString(genericDescKey, comment: "") != genericDescKey {
                    beschreibungKey = genericDescKey
                } else {
                    beschreibungKey = goalDescKey
                }
            } else {
                let plantPhaseKey = "pfad_\(plantIDClean)_phase_\(phase.rawValue)_desc_\(schwierigkeit.rawValue)"
                let genericPhaseKey = "pfad_generic_phase_\(phase.rawValue)_desc_\(schwierigkeit.rawValue)"
                let goalPhaseKey = "pfad_\(zielSchluessel)_phase_\(phase.rawValue)_desc_\(schwierigkeit.rawValue)"
                
                if NSLocalizedString(plantPhaseKey, comment: "") != plantPhaseKey {
                    beschreibungKey = plantPhaseKey
                } else if NSLocalizedString(genericPhaseKey, comment: "") != genericPhaseKey {
                    beschreibungKey = genericPhaseKey
                } else {
                    beschreibungKey = goalPhaseKey
                }
            }

            tags.append(PfadTagVorlage(
                tagNummer: i,
                titelKey: titelKey,
                beschreibungKey: beschreibungKey,
                phase: phase,
                istMeilenstein: istMeilenstein,
                neuerPflanzenHinweis: i == 30 ? empfohleneDrittePflanze(fuer: zielSchluessel) : nil
            ))
        }
        return tags
    }
    
    static func empfohleneDrittePflanze(fuer ziel: String) -> String? {
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
