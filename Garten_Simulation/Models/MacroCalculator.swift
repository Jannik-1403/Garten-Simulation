import Foundation
import HealthKit

struct MacroRecommendation {
    let energy: Double
    let protein: Double
    let carbs: Double
    let fat: Double
}

class MacroCalculator {
    
    /// Berechnet die empfohlene Makroverteilung basierend auf Körperdaten
    /// - Returns: Eine MacroRecommendation oder nil, falls Daten fehlen.
    static func calculateRecommendation(
        weightKg: Double?,
        heightCm: Double?,
        ageYears: Int?,
        biologicalSex: HKBiologicalSexObject?,
        activityMultiplier: Double = 1.3 // Standardwert für leichte Aktivität (Bürojob + 1-3x Sport)
    ) -> MacroRecommendation? {
        
        guard let weight = weightKg, let height = heightCm, let age = ageYears, let sexObject = biologicalSex else {
            return nil
        }
        
        let sex = sexObject.biologicalSex
        
        // Mifflin-St Jeor Formel
        var bmr: Double = (10 * weight) + (6.25 * height) - (5.0 * Double(age))
        
        if sex == .female {
            bmr -= 161
        } else {
            bmr += 5 
        }
        
        let tdee = bmr * activityMultiplier
        
        // Makroverteilung (Moderat: 50% Kohlenhydrate, 30% Protein, 20% Fett)
        let energy = tdee
        let protein = (tdee * 0.30) / 4.0
        let carbs = (tdee * 0.50) / 4.0
        let fat = (tdee * 0.20) / 9.0
        
        return MacroRecommendation(energy: energy, protein: protein, carbs: carbs, fat: fat)
    }
}
