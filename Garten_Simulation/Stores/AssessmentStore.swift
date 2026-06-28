import SwiftUI
import Combine

class AssessmentStore: ObservableObject {

    // MARK: - Published State
    @Published var financeResult: AssessmentResult? {
        didSet { persist() }
    }

    @Published var mentalResult: MentalAssessmentResult? {
        didSet { persistMental() }
    }

    @Published var growthResult: GrowthAssessmentResult? {
        didSet { persistGrowth() }
    }

    @Published var healthResult: HealthAssessmentResult? {
        didSet { persistHealth() }
    }

    @Published var fitnessResult: FitnessAssessmentResult? {
        didSet { persistFitness() }
    }

    @Published var lifestyleResult: LifestyleAssessmentResult? {
        didSet { persistLifestyle() }
    }

    // MARK: - Init
    init() {
        load()
    }

    // MARK: - Public API

    /// Wertet die gegebenen Antworten aus und speichert das Ergebnis.
    func submitFinanceQuiz(answers: [Int: AssessmentAnswer]) {
        var score = AssessmentRawScore()

        for (_, answer) in answers {
            score.kontrolle    += answer.delta.kontrolle
            score.entscheidung += answer.delta.entscheidung
            score.risiko       += answer.delta.risiko
        }

        let profile = AssessmentScoringEngine.computeProfile(from: score)

        financeResult = AssessmentResult(
            profile: profile,
            rawKontrolle: score.kontrolle,
            rawEntscheidung: score.entscheidung,
            rawRisiko: score.risiko,
            date: Date()
        )
    }

    /// Setzt das Finance-Ergebnis zurück (Quiz erneut starten).
    func resetFinanceResult() {
        financeResult = nil
    }
    
    /// Setzt alle Quiz-Ergebnisse (Assessments) zurück.
    func resetAll() {
        resetFinanceResult()
        resetMentalResult()
        resetGrowthResult()
        resetHealthResult()
        resetFitnessResult()
        resetLifestyleResult()
    }

    // MARK: - Persistence (UserDefaults)

    private let financeResultKey = "assessmentStore.financeResult"

    private func persist() {
        if let result = financeResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: financeResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: financeResultKey)
        }
        persistMental()
        persistGrowth()
        persistHealth()
        persistFitness()
        persistLifestyle()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: financeResultKey),
           let decoded = try? JSONDecoder().decode(AssessmentResult.self, from: data) {
            self.financeResult = decoded
        }
        loadMental()
        loadGrowth()
        loadHealth()
        loadFitness()
        loadLifestyle()
    }
}

// MARK: - Mental Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Mental

    /// Berechnet das mentale Profil aus den gegebenen Antworten und speichert es.
    func submitMentalQuiz(answers: [Int: MentalAnswer]) {
        var score = MentalRawScore()

        for (_, answer) in answers {
            score.resilienz += answer.delta.resilienz
            score.fokus     += answer.delta.fokus
            score.ego       += answer.delta.ego
        }

        let profile = MentalScoringEngine.computeProfile(from: score)

        mentalResult = MentalAssessmentResult(
            profile: profile,
            rawResilienz: score.resilienz,
            rawFokus:     score.fokus,
            rawEgo:       score.ego,
            date: Date()
        )
    }

    /// Setzt das Mental-Ergebnis zurück.
    func resetMentalResult() {
        mentalResult = nil
    }

    // MARK: Persistence — Mental

    private var mentalResultKey: String { "assessmentStore.mentalResult" }

    func persistMental() {
        if let result = mentalResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: mentalResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: mentalResultKey)
        }
    }

    func loadMental() {
        if let data = UserDefaults.standard.data(forKey: mentalResultKey),
           let decoded = try? JSONDecoder().decode(MentalAssessmentResult.self, from: data) {
            self.mentalResult = decoded
        }
    }
}

// MARK: - Growth Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Growth

    func submitGrowthQuiz(answers: [Int: GrowthAnswer]) {
        var score = GrowthRawScore()

        for (_, answer) in answers {
            score.disziplin += answer.delta.disziplin
            score.effizienz += answer.delta.effizienz
            score.umsetzung += answer.delta.umsetzung
        }

        let profile = GrowthScoringEngine.computeProfile(from: score)

        growthResult = GrowthAssessmentResult(
            profile: profile,
            rawDisziplin: score.disziplin,
            rawEffizienz: score.effizienz,
            rawUmsetzung: score.umsetzung,
            date: Date()
        )
    }

    func resetGrowthResult() {
        growthResult = nil
    }

    // MARK: Persistence — Growth

    private var growthResultKey: String { "assessmentStore.growthResult" }

    func persistGrowth() {
        if let result = growthResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: growthResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: growthResultKey)
        }
    }

    func loadGrowth() {
        if let data = UserDefaults.standard.data(forKey: growthResultKey),
           let decoded = try? JSONDecoder().decode(GrowthAssessmentResult.self, from: data) {
            self.growthResult = decoded
        }
    }
}

// MARK: - Health Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Health

    func submitHealthQuiz(answers: [Int: HealthAnswer]) {
        var score = HealthRawScore()

        for (_, answer) in answers {
            score.regeneration += answer.delta.regeneration
            score.kraftstoff   += answer.delta.kraftstoff
            score.praevention  += answer.delta.praevention
        }

        let profile = HealthScoringEngine.computeProfile(from: score)

        healthResult = HealthAssessmentResult(
            profile: profile,
            rawRegeneration: score.regeneration,
            rawKraftstoff:   score.kraftstoff,
            rawPraevention:  score.praevention,
            date: Date()
        )
    }

    func resetHealthResult() {
        healthResult = nil
    }

    // MARK: Persistence — Health

    private var healthResultKey: String { "assessmentStore.healthResult" }

    func persistHealth() {
        if let result = healthResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: healthResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: healthResultKey)
        }
    }

    func loadHealth() {
        if let data = UserDefaults.standard.data(forKey: healthResultKey),
           let decoded = try? JSONDecoder().decode(HealthAssessmentResult.self, from: data) {
            self.healthResult = decoded
        }
    }
}


// MARK: - Fitness Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Fitness

    func submitFitnessQuiz(answers: [Int: FitnessAnswer]) {
        var score = FitnessRawScore()

        for (_, answer) in answers {
            score.konsistenz += answer.delta.konsistenz
            score.intensitaet += answer.delta.intensitaet
            score.verantwortung += answer.delta.verantwortung
        }

        let profile = FitnessScoringEngine.computeProfile(from: score)

        fitnessResult = FitnessAssessmentResult(
            profile: profile,
            rawKonsistenz: score.konsistenz,
            rawIntensitaet: score.intensitaet,
            rawVerantwortung: score.verantwortung,
            date: Date()
        )
    }

    func resetFitnessResult() {
        fitnessResult = nil
    }

    // MARK: Persistence — Fitness

    private var fitnessResultKey: String { "assessmentStore.fitnessResult" }

    func persistFitness() {
        if let result = fitnessResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: fitnessResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: fitnessResultKey)
        }
    }

    func loadFitness() {
        if let data = UserDefaults.standard.data(forKey: fitnessResultKey),
           let decoded = try? JSONDecoder().decode(FitnessAssessmentResult.self, from: data) {
            self.fitnessResult = decoded
        }
    }
}

// MARK: - Lifestyle Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Lifestyle

    func submitLifestyleQuiz(answers: [Int: LifestyleAnswer]) {
        var score = LifestyleRawScore()

        for (_, answer) in answers {
            score.umfeld += answer.delta.umfeld
            score.standards += answer.delta.standards
            score.einfluss += answer.delta.einfluss
        }

        let profile = LifestyleScoringEngine.computeProfile(from: score)

        lifestyleResult = LifestyleAssessmentResult(
            profile: profile,
            rawUmfeld: score.umfeld,
            rawStandards: score.standards,
            rawEinfluss: score.einfluss,
            date: Date()
        )
    }

    func resetLifestyleResult() {
        lifestyleResult = nil
    }

    // MARK: Persistence — Lifestyle

    private var lifestyleResultKey: String { "assessmentStore.lifestyleResult" }

    func persistLifestyle() {
        if let result = lifestyleResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: lifestyleResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: lifestyleResultKey)
        }
    }

    func loadLifestyle() {
        if let data = UserDefaults.standard.data(forKey: lifestyleResultKey),
           let decoded = try? JSONDecoder().decode(LifestyleAssessmentResult.self, from: data) {
            self.lifestyleResult = decoded
        }
    }
}
