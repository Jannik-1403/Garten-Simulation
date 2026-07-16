import Foundation

struct AssessmentActionStep {
    let phaseTitleKey: String
    let descriptionKey: String
    let recommendedPlantIDs: [String]
}

protocol DetailedAssessmentResult {
    var worstParameterTextKey: String { get }
    var actionSteps: [AssessmentActionStep] { get }
}

extension AssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("kontrolle", rawKontrolle),
            ("entscheidung", rawEntscheidung),
            ("risiko", rawRisiko)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.finance.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.aloe_vera"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.sonnenblume"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.mandelbaum"])
        ]
    }
}

extension HealthAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("regeneration", rawRegeneration),
            ("kraftstoff", rawKraftstoff),
            ("praevention", rawPraevention)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.health.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.zitronenbaum"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.erdbeerpflanze"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.apfelbaum"])
        ]
    }
}

extension MentalAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("resilienz", rawResilienz),
            ("fokus", rawFokus),
            ("ego", rawEgo)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.mental.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.lotus"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.kirschbaum"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.aloe_vera"])
        ]
    }
}

extension GrowthAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("disziplin", rawDisziplin),
            ("effizienz", rawEffizienz),
            ("umsetzung", rawUmsetzung)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.growth.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.bambus"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.efeu"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.sonnenblume"])
        ]
    }
}

extension FitnessAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("konsistenz", rawKonsistenz),
            ("intensitaet", rawIntensitaet),
            ("verantwortung", rawVerantwortung)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.fitness.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.efeu"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.wildgras"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.bambus"])
        ]
    }
}

extension LifestyleAssessmentResult: DetailedAssessmentResult {
    var worstParameterTextKey: String {
        let scores = [
            ("umfeld", rawUmfeld),
            ("standards", rawStandards),
            ("einfluss", rawEinfluss)
        ]
        let worst = scores.min { $0.1 < $1.1 }!
        return "assessment.lifestyle.worst.\(worst.0)"
    }
    
    var actionSteps: [AssessmentActionStep] {
        return [
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase1.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.minzpflanze"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase2.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.lavendel"]),
            AssessmentActionStep(phaseTitleKey: "assessment.roadmap.phase3.title", descriptionKey: "assessment.roadmap.phase.desc", recommendedPlantIDs: ["plant.sonnenblume"])
        ]
    }
}
