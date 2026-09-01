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
        biologicalSex: Int?,
        activityMultiplier: Double = 1.3, // Standardwert für leichte Aktivität (Bürojob + 1-3x Sport)
        weightGoalType: Int = 0, // 0 = maintain, 1 = lose, 2 = gain
        weightGoalTargetKg: Double = 0.0,
        weightGoalDateInterval: Double = 0.0,
        bodyFatPercentage: Double? = nil
    ) -> MacroRecommendation? {
        
        guard let weight = weightKg, let height = heightCm, let age = ageYears, let sex = biologicalSex, sex > 0 else {
            return nil
        }
        
        var bmr: Double = 0
        if let bodyFat = bodyFatPercentage, bodyFat > 0 {
            // Katch-McArdle Formel (genauer bei bekanntem Körperfettanteil)
            let leanBodyMass = weight * (100.0 - bodyFat) / 100.0
            bmr = 370.0 + (21.6 * leanBodyMass)
        } else {
            // Mifflin-St Jeor Formel
            bmr = (10 * weight) + (6.25 * height) - (5.0 * Double(age))
            
            if sex == 1 { // 1 = female in HKBiologicalSex
                bmr -= 161
            } else { // 2 = male
                bmr += 5 
            }
        }
        
        let tdee = bmr * activityMultiplier
        
        // Weight Goal Adjustment
        var energyOffset = 0.0
        
        if weightGoalType != 0 && weightGoalTargetKg > 0 && weightGoalDateInterval > 0 {
            let targetDate = Date(timeIntervalSince1970: weightGoalDateInterval)
            let daysUntilTarget = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
            
            if daysUntilTarget > 0 {
                let weightDifference = abs(weight - weightGoalTargetKg)
                let totalCaloriesDifference = weightDifference * 7700.0 // 1kg body fat = ~7700 kcal
                let dailyOffset = totalCaloriesDifference / Double(daysUntilTarget)
                
                if weightGoalType == 1 && weight > weightGoalTargetKg {
                    // Lose weight
                    energyOffset = -dailyOffset
                } else if weightGoalType == 2 && weight < weightGoalTargetKg {
                    // Gain weight
                    energyOffset = dailyOffset
                }
            }
        }
        
        var energy = tdee + energyOffset
        
        // Safety Limits
        if sex == 1 { // Female
            energy = max(energy, 1200)
        } else { // Male
            energy = max(energy, 1500)
        }
        
        // Makroverteilung (Moderat: 50% Kohlenhydrate, 30% Protein, 20% Fett)
        let protein = (energy * 0.30) / 4.0
        let carbs = (energy * 0.50) / 4.0
        let fat = (energy * 0.20) / 9.0
        
        return MacroRecommendation(energy: energy, protein: protein, carbs: carbs, fat: fat)
    }
}
