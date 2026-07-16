import Foundation

protocol DetailedAssessmentResult {
    var topStrengthKey: String { get }
    var biggestWeaknessKey: String { get }
    var pitfallKey: String { get }
    var benchmarkKey: String { get }
    var benchmarkPercentile: Double { get } // 0.0 to 1.0
}

extension AssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("control", rawKontrolle), ("budget", rawEntscheidung), ("reserves", rawRisiko)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("control", rawKontrolle), ("budget", rawEntscheidung), ("reserves", rawRisiko)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("control", rawKontrolle), ("budget", rawEntscheidung), ("reserves", rawRisiko)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawKontrolle + rawEntscheidung + rawRisiko)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawKontrolle + rawEntscheidung + rawRisiko)
        // Max is ~40, Min is ~ -40. Map to 0...1
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}

extension HealthAssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("sleep", rawRegeneration), ("nutrition", rawKraftstoff), ("regeneration", rawPraevention)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("sleep", rawRegeneration), ("nutrition", rawKraftstoff), ("regeneration", rawPraevention)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("sleep", rawRegeneration), ("nutrition", rawKraftstoff), ("regeneration", rawPraevention)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawRegeneration + rawKraftstoff + rawPraevention)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawRegeneration + rawKraftstoff + rawPraevention)
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}

extension MentalAssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("stress", rawResilienz), ("focus", rawFokus), ("mindfulness", rawEgo)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("stress", rawResilienz), ("focus", rawFokus), ("mindfulness", rawEgo)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("stress", rawResilienz), ("focus", rawFokus), ("mindfulness", rawEgo)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawResilienz + rawFokus + rawEgo)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawResilienz + rawFokus + rawEgo)
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}

extension GrowthAssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("discipline", rawDisziplin), ("efficiency", rawEffizienz), ("execution", rawUmsetzung)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("discipline", rawDisziplin), ("efficiency", rawEffizienz), ("execution", rawUmsetzung)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("discipline", rawDisziplin), ("efficiency", rawEffizienz), ("execution", rawUmsetzung)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawDisziplin + rawEffizienz + rawUmsetzung)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawDisziplin + rawEffizienz + rawUmsetzung)
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}

extension FitnessAssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("strength", rawKonsistenz), ("endurance", rawIntensitaet), ("mobility", rawVerantwortung)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("strength", rawKonsistenz), ("endurance", rawIntensitaet), ("mobility", rawVerantwortung)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("strength", rawKonsistenz), ("endurance", rawIntensitaet), ("mobility", rawVerantwortung)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawKonsistenz + rawIntensitaet + rawVerantwortung)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawKonsistenz + rawIntensitaet + rawVerantwortung)
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}

extension LifestyleAssessmentResult: DetailedAssessmentResult {
    var topStrengthKey: String {
        let scores = [("routine", rawUmfeld), ("environment", rawStandards), ("balance", rawEinfluss)]
        let best = scores.max(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.strength.\(best)"
    }
    
    var biggestWeaknessKey: String {
        let scores = [("routine", rawUmfeld), ("environment", rawStandards), ("balance", rawEinfluss)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.weakness.\(worst)"
    }
    
    var pitfallKey: String {
        let scores = [("routine", rawUmfeld), ("environment", rawStandards), ("balance", rawEinfluss)]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.pitfall.\(worst)"
    }
    
    var benchmarkKey: String {
        let total = Double(rawUmfeld + rawStandards + rawEinfluss)
        if total > 15 { return "assessment.benchmark.top10" }
        if total > 5 { return "assessment.benchmark.top30" }
        if total > -5 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    
    var benchmarkPercentile: Double {
        let total = Double(rawUmfeld + rawStandards + rawEinfluss)
        let mapped = (total + 40) / 80.0
        return max(0.1, min(0.95, mapped))
    }
}
