import Foundation

protocol DetailedAssessmentResult {
    var worstParameterTextKey: String { get }
}

extension AssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("control", rawKontrolle),
            ("budget", rawEntscheidung),
            ("reserves", rawRisiko)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.worst.\(worst)"
    }
}

extension HealthAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("sleep", rawRegeneration),
            ("nutrition", rawKraftstoff),
            ("regeneration", rawPraevention)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.worst.\(worst)"
    }
}

extension MentalAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("stress", rawResilienz),
            ("focus", rawFokus),
            ("mindfulness", rawEgo)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.worst.\(worst)"
    }
}

extension GrowthAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("discipline", rawDisziplin),
            ("efficiency", rawEffizienz),
            ("execution", rawUmsetzung)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.worst.\(worst)"
    }
}

extension FitnessAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("strength", rawKonsistenz),
            ("endurance", rawIntensitaet),
            ("mobility", rawVerantwortung)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.worst.\(worst)"
    }
}

extension LifestyleAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("routine", rawUmfeld),
            ("environment", rawStandards),
            ("balance", rawEinfluss)
        ]
        let worst = scores.min(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.worst.\(worst)"
    }
}
