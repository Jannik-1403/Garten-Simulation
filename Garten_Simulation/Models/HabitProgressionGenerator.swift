import Foundation

enum ProgressionType {
    case linear(baseAnfaenger: Double, incAnfaenger: Double, 
                baseFortgeschritten: Double, incFortgeschritten: Double, 
                baseExperte: Double, incExperte: Double, 
                unitKey: String, templateKey: String)
    case phase(einstiegKey: String, aufbauKey: String, vertiefungKey: String, meisterschaftKey: String)
}

struct HabitProgression {
    let plantID: String
    let type: ProgressionType
}

class HabitProgressionGenerator {
    static let progressions: [String: HabitProgression] = [
        // Fitness
        "plant.wildgras": HabitProgression(plantID: "plant.wildgras", type: .linear(
            baseAnfaenger: 2.0, incAnfaenger: 0.1, 
            baseFortgeschritten: 5.0, incFortgeschritten: 0.15, 
            baseExperte: 10.0, incExperte: 0.25, 
            unitKey: "progression_unit_km", templateKey: "progression_template_run"
        )),
        "plant.bambus": HabitProgression(plantID: "plant.bambus", type: .linear(
            baseAnfaenger: 10, incAnfaenger: 0.5, 
            baseFortgeschritten: 20, incFortgeschritten: 1.0, 
            baseExperte: 40, incExperte: 2.0, 
            unitKey: "progression_unit_reps", templateKey: "progression_template_strength"
        )),
        "plant.efeu": HabitProgression(plantID: "plant.efeu", type: .linear(
            baseAnfaenger: 5, incAnfaenger: 0.2, 
            baseFortgeschritten: 10, incFortgeschritten: 0.3, 
            baseExperte: 20, incExperte: 0.5, 
            unitKey: "progression_unit_min", templateKey: "progression_template_stretch"
        )),
        
        // Mental
        "plant.lotus": HabitProgression(plantID: "plant.lotus", type: .linear(
            baseAnfaenger: 5, incAnfaenger: 0.2, 
            baseFortgeschritten: 15, incFortgeschritten: 0.4, 
            baseExperte: 30, incExperte: 0.6, 
            unitKey: "progression_unit_min", templateKey: "progression_template_meditate"
        )),
        "plant.kirschbaum": HabitProgression(plantID: "plant.kirschbaum", type: .phase(
            einstiegKey: "progression_selfcare_einstieg",
            aufbauKey: "progression_selfcare_aufbau",
            vertiefungKey: "progression_selfcare_vertiefung",
            meisterschaftKey: "progression_selfcare_meisterschaft"
        )),
        "plant.aloe_vera": HabitProgression(plantID: "plant.aloe_vera", type: .phase(
            einstiegKey: "progression_screentime_einstieg",
            aufbauKey: "progression_screentime_aufbau",
            vertiefungKey: "progression_screentime_vertiefung",
            meisterschaftKey: "progression_screentime_meisterschaft"
        )),
        "plant.klee": HabitProgression(plantID: "plant.klee", type: .linear(
            baseAnfaenger: 1, incAnfaenger: 0.05, 
            baseFortgeschritten: 3, incFortgeschritten: 0.05, 
            baseExperte: 5, incExperte: 0.1, 
            unitKey: "progression_unit_things", templateKey: "progression_template_gratitude"
        )),
        
        // Health
        "plant.minzpflanze": HabitProgression(plantID: "plant.minzpflanze", type: .phase(
            einstiegKey: "progression_teeth_einstieg",
            aufbauKey: "progression_teeth_aufbau",
            vertiefungKey: "progression_teeth_vertiefung",
            meisterschaftKey: "progression_teeth_meisterschaft"
        )),
        "plant.zitronenbaum": HabitProgression(plantID: "plant.zitronenbaum", type: .linear(
            baseAnfaenger: 1.5, incAnfaenger: 0.01, 
            baseFortgeschritten: 2.0, incFortgeschritten: 0.02, 
            baseExperte: 3.0, incExperte: 0.01, 
            unitKey: "progression_unit_liter", templateKey: "progression_template_water"
        )),
        "plant.erdbeerpflanze": HabitProgression(plantID: "plant.erdbeerpflanze", type: .linear(
            baseAnfaenger: 1, incAnfaenger: 0.02, 
            baseFortgeschritten: 3, incFortgeschritten: 0.03, 
            baseExperte: 5, incExperte: 0.05, 
            unitKey: "progression_unit_portions", templateKey: "progression_template_fruits"
        )),
        "plant.kaktus": HabitProgression(plantID: "plant.kaktus", type: .linear(
            baseAnfaenger: 10, incAnfaenger: 1.0, 
            baseFortgeschritten: 30, incFortgeschritten: 2.0, 
            baseExperte: 60, incExperte: 3.0, 
            unitKey: "progression_unit_sec", templateKey: "progression_template_coldshower"
        )),
        "plant.weinrebe": HabitProgression(plantID: "plant.weinrebe", type: .phase(
            einstiegKey: "progression_noalcohol_einstieg",
            aufbauKey: "progression_noalcohol_aufbau",
            vertiefungKey: "progression_noalcohol_vertiefung",
            meisterschaftKey: "progression_noalcohol_meisterschaft"
        )),
        "plant.apfelbaum": HabitProgression(plantID: "plant.apfelbaum", type: .phase(
            einstiegKey: "progression_cooking_einstieg",
            aufbauKey: "progression_cooking_aufbau",
            vertiefungKey: "progression_cooking_vertiefung",
            meisterschaftKey: "progression_cooking_meisterschaft"
        )),
        "plant.lavendel": HabitProgression(plantID: "plant.lavendel", type: .phase(
            einstiegKey: "progression_sleep_einstieg",
            aufbauKey: "progression_sleep_aufbau",
            vertiefungKey: "progression_sleep_vertiefung",
            meisterschaftKey: "progression_sleep_meisterschaft"
        )),
        
        // Growth & Lifestyle & Finance
        "plant.sonnenblume": HabitProgression(plantID: "plant.sonnenblume", type: .phase(
            einstiegKey: "progression_wakeup_einstieg",
            aufbauKey: "progression_wakeup_aufbau",
            vertiefungKey: "progression_wakeup_vertiefung",
            meisterschaftKey: "progression_wakeup_meisterschaft"
        )),
        "plant.weizenfeld": HabitProgression(plantID: "plant.weizenfeld", type: .linear(
            baseAnfaenger: 30, incAnfaenger: 1.0, 
            baseFortgeschritten: 60, incFortgeschritten: 2.0, 
            baseExperte: 120, incExperte: 3.0, 
            unitKey: "progression_unit_min", templateKey: "progression_template_deepwork"
        )),
        "plant.chrysantheme": HabitProgression(plantID: "plant.chrysantheme", type: .linear(
            baseAnfaenger: 5, incAnfaenger: 0.2, 
            baseFortgeschritten: 15, incFortgeschritten: 0.5, 
            baseExperte: 30, incExperte: 0.5, 
            unitKey: "progression_unit_min", templateKey: "progression_template_cleaning"
        )),
        "plant.mandelbaum": HabitProgression(plantID: "plant.mandelbaum", type: .linear(
            baseAnfaenger: 1, incAnfaenger: 0.05, 
            baseFortgeschritten: 5, incFortgeschritten: 0.1, 
            baseExperte: 10, incExperte: 0.2, 
            unitKey: "progression_unit_currency", templateKey: "progression_template_saving"
        )),
        "plant.mystic_seed": HabitProgression(plantID: "plant.mystic_seed", type: .linear(
            baseAnfaenger: 3, incAnfaenger: 0.1, 
            baseFortgeschritten: 10, incFortgeschritten: 0.2, 
            baseExperte: 20, incExperte: 0.3, 
            unitKey: "progression_unit_min", templateKey: "progression_template_breathwork"
        ))
    ]
    
    static func generateDescription(for plantID: String, dayNum: Int, difficulty: String, language: String) -> String? {
        guard let prog = progressions[plantID.lowercased()] else { return nil }
        
        switch prog.type {
        case .linear(let baseAnf, let incAnf, let baseFort, let incFort, let baseExp, let incExp, let unitKey, let templateKey):
            let baseValue: Double
            let dailyIncrease: Double
            
            switch difficulty.lowercased() {
            case "experte":
                baseValue = baseExp
                dailyIncrease = incExp
            case "fortgeschritten":
                baseValue = baseFort
                dailyIncrease = incFort
            default:
                baseValue = baseAnf
                dailyIncrease = incAnf
            }
            
            let targetValue = baseValue + (Double(dayNum - 1) * dailyIncrease)
            
            let isIntegerUnit = ["progression_unit_reps", "progression_unit_min", "progression_unit_sec", "progression_unit_things", "progression_unit_portions"].contains(unitKey)
            
            let formattedValue = isIntegerUnit ? String(format: "%.0f", targetValue) : String(format: "%.1f", targetValue)
            let formattedValueStr = formattedValue.replacingOccurrences(of: ".", with: ",") // For German locale compatibility if needed, but AppStrings format uses %@
            
            let template = NSLocalizedString(templateKey, comment: "")
            let unitText = NSLocalizedString(unitKey, comment: "")
            
            let motIndex = (dayNum % 5) + 1
            let motivation = NSLocalizedString("progression_mot_\(motIndex)", comment: "")
            
            // Replaces %@ with value and unit
            // Note: Make sure the template in AppStrings uses `%1$@` and `%2$@` or `%@` sequentially
            let baseText = String(format: template, formattedValueStr, unitText)
            
            return "\(baseText) \(motivation)"
            
        case .phase(let einstiegKey, let aufbauKey, let vertiefungKey, let meisterschaftKey):
            let phaseKey: String
            if dayNum <= 14 { phaseKey = einstiegKey }
            else if dayNum <= 45 { phaseKey = aufbauKey }
            else if dayNum <= 75 { phaseKey = vertiefungKey }
            else { phaseKey = meisterschaftKey }
            
            let text = NSLocalizedString(phaseKey, comment: "")
            
            var diffText = ""
            if difficulty.lowercased() == "experte" {
                diffText = NSLocalizedString("progression_diff_experte_prefix", comment: "") + " "
            } else if difficulty.lowercased() == "fortgeschritten" {
                diffText = NSLocalizedString("progression_diff_fortgeschritten_prefix", comment: "") + " "
            }
            
            return "\(diffText)\(text)"
        }
    }
}
