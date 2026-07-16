import Foundation
import SwiftUI

// MARK: - Protocol

protocol DetailedAssessmentResult {
    // Existing
    var topStrengthKey: String { get }
    var biggestWeaknessKey: String { get }
    var pitfallKey: String { get }
    var benchmarkKey: String { get }
    var benchmarkPercentile: Double { get }  // 0.0 = weakest, 1.0 = strongest
    // New
    var strengthIcon: String { get }
    var weaknessIcon: String { get }
    var benchmarkLabel: String { get }
    var strengthDataSources: [AssessmentDataSource] { get }
    var weaknessDataSources: [AssessmentDataSource] { get }
    var pitfallDataSources: [AssessmentDataSource] { get }
    var benchmarkDataSources: [AssessmentDataSource] { get }
}

// MARK: - AssessmentResult (Finance)

extension AssessmentResult: DetailedAssessmentResult {

    private var financeParams: [(String, Int)] {
        [("control", rawKontrolle), ("budget", rawEntscheidung), ("reserves", rawRisiko)]
    }

    var topStrengthKey: String {
        let best = financeParams.max(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = financeParams.min(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = financeParams.min(by: { $0.1 < $1.1 })?.0 ?? "control"
        return "assessment.finance.pitfall.\(worst)"
    }

    var benchmarkKey: String {
        let t = Double(rawKontrolle + rawEntscheidung + rawRisiko)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawKontrolle + rawEntscheidung + rawRisiko)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawKontrolle + rawEntscheidung + rawRisiko)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }

    var strengthIcon: String { "checkmark.circle.fill" }
    var weaknessIcon: String { "exclamationmark.circle.fill" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fin.q3", defaultValue: "Frage 3: Kontostand ohne Nachschauen (Finanzkontrolle)"),
                String(localized: "assessment.source.fin.q4", defaultValue: "Frage 4: Reaktion auf unnötige Abos (Budgetentscheidung)"),
                String(localized: "assessment.source.fin.q6", defaultValue: "Frage 6: Verhalten bei Lifestyle-Creep (Risikoabsicherung)"),
                String(localized: "assessment.source.fin.q14", defaultValue: "Frage 14: Umgang mit kleinen Ausgaben (Mikrolecks)")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.fin.control", defaultValue: "Finanzkontrolle:")) \(rawKontrolle > 0 ? "+" : "")\(rawKontrolle) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.fin.decision", defaultValue: "Entscheidung:")) \(rawEntscheidung > 0 ? "+" : "")\(rawEntscheidung) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.fin.risk", defaultValue: "Risikoabsicherung:")) \(rawRisiko > 0 ? "+" : "")\(rawRisiko) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                String(localized: "assessment.source.strongest_param", defaultValue: "Dein stärkster Parameter = deine Stärke")
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fin.q1", defaultValue: "Frage 1: Reaktion auf unerwartete Rückzahlung"),
                String(localized: "assessment.source.fin.q2", defaultValue: "Frage 2: Investment-App-Verhalten"),
                String(localized: "assessment.source.fin.q7", defaultValue: "Frage 7: Status vs. vernünftige Ausgaben"),
                String(localized: "assessment.source.fin.q12", defaultValue: "Frage 12: Die Gier-Falle (riskante Investments)")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.weakest_area", defaultValue: "Dein schwächster Bereich"), items: [
                String(localized: "assessment.source.weakest_1", defaultValue: "Dein schwächster Rohscore bestimmt die Schwäche."),
                String(localized: "assessment.source.weakest_2", defaultValue: "Alle drei Parameter werden miteinander verglichen."),
                String(localized: "assessment.source.weakest_3", defaultValue: "Der niedrigste Wert = größtes Verbesserungspotenzial.")
            ])
        ]
    }
    var pitfallDataSources: [AssessmentDataSource] {
        weaknessDataSources
    }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawKontrolle + rawEntscheidung + rawRisiko) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −41 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +41 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                String(localized: "assessment.source.fin.percentile", defaultValue: "Dein Percentil = (Score + 41) / 82")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}

// MARK: - HealthAssessmentResult

extension HealthAssessmentResult: DetailedAssessmentResult {

    private var healthParams: [(String, Int)] {
        [("sleep", rawRegeneration), ("nutrition", rawKraftstoff), ("regeneration", rawPraevention)]
    }

    var topStrengthKey: String {
        let best = healthParams.max(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = healthParams.min(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = healthParams.min(by: { $0.1 < $1.1 })?.0 ?? "sleep"
        return "assessment.health.pitfall.\(worst)"
    }
    var benchmarkKey: String {
        let t = Double(rawRegeneration + rawKraftstoff + rawPraevention)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawRegeneration + rawKraftstoff + rawPraevention)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawRegeneration + rawKraftstoff + rawPraevention)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }
    var strengthIcon: String { "heart.fill" }
    var weaknessIcon: String { "heart.slash.fill" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.hea.q_sleep", defaultValue: "Schlaf-Fragen: Schlafdauer und Schlafqualität"),
                String(localized: "assessment.source.hea.q_nutri", defaultValue: "Ernährungs-Fragen: Mahlzeitenplanung & Zucker"),
                String(localized: "assessment.source.hea.q_regen", defaultValue: "Regenerations-Fragen: Pausen, Dehnen, Prävention")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.hea.sleep", defaultValue: "Regeneration (Schlaf):")) \(rawRegeneration > 0 ? "+" : "")\(rawRegeneration) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.hea.nutri", defaultValue: "Kraftstoff (Ernährung):")) \(rawKraftstoff > 0 ? "+" : "")\(rawKraftstoff) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.hea.prev", defaultValue: "Prävention:")) \(rawPraevention > 0 ? "+" : "")\(rawPraevention) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawRegeneration + rawKraftstoff + rawPraevention) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}

// MARK: - MentalAssessmentResult

extension MentalAssessmentResult: DetailedAssessmentResult {

    private var mentalParams: [(String, Int)] {
        [("stress", rawResilienz), ("focus", rawFokus), ("mindfulness", rawEgo)]
    }

    var topStrengthKey: String {
        let best = mentalParams.max(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = mentalParams.min(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = mentalParams.min(by: { $0.1 < $1.1 })?.0 ?? "stress"
        return "assessment.mental.pitfall.\(worst)"
    }
    var benchmarkKey: String {
        let t = Double(rawResilienz + rawFokus + rawEgo)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawResilienz + rawFokus + rawEgo)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawResilienz + rawFokus + rawEgo)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }
    var strengthIcon: String { "brain.head.profile" }
    var weaknessIcon: String { "bolt.trianglebadge.exclamationmark.fill" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.men.q_resil", defaultValue: "Resilienz-Fragen: Reaktion auf Rückschläge & Stress"),
                String(localized: "assessment.source.men.q_focus", defaultValue: "Fokus-Fragen: Ablenkbarkeit und Tiefarbeit"),
                String(localized: "assessment.source.men.q_ego", defaultValue: "Ego-Fragen: Selbstreflexion und Mindset")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.men.resil", defaultValue: "Resilienz:")) \(rawResilienz > 0 ? "+" : "")\(rawResilienz) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.men.focus", defaultValue: "Fokus:")) \(rawFokus > 0 ? "+" : "")\(rawFokus) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.men.ego", defaultValue: "Ego/Mindset:")) \(rawEgo > 0 ? "+" : "")\(rawEgo) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawResilienz + rawFokus + rawEgo) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}

// MARK: - GrowthAssessmentResult

extension GrowthAssessmentResult: DetailedAssessmentResult {

    private var growthParams: [(String, Int)] {
        [("discipline", rawDisziplin), ("efficiency", rawEffizienz), ("execution", rawUmsetzung)]
    }

    var topStrengthKey: String {
        let best = growthParams.max(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = growthParams.min(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = growthParams.min(by: { $0.1 < $1.1 })?.0 ?? "discipline"
        return "assessment.growth.pitfall.\(worst)"
    }
    var benchmarkKey: String {
        let t = Double(rawDisziplin + rawEffizienz + rawUmsetzung)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawDisziplin + rawEffizienz + rawUmsetzung)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawDisziplin + rawEffizienz + rawUmsetzung)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }
    var strengthIcon: String { "arrow.up.circle.fill" }
    var weaknessIcon: String { "arrow.down.circle.fill" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.gro.q_disc", defaultValue: "Disziplin-Fragen: Konsistenz, auch ohne Motivation"),
                String(localized: "assessment.source.gro.q_eff", defaultValue: "Effizienz-Fragen: Zeitnutzung und Priorisierung"),
                String(localized: "assessment.source.gro.q_exec", defaultValue: "Umsetzungs-Fragen: Planung vs. tatsächliches Handeln")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.gro.disc", defaultValue: "Disziplin:")) \(rawDisziplin > 0 ? "+" : "")\(rawDisziplin) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.gro.eff", defaultValue: "Effizienz:")) \(rawEffizienz > 0 ? "+" : "")\(rawEffizienz) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.gro.exec", defaultValue: "Umsetzung:")) \(rawUmsetzung > 0 ? "+" : "")\(rawUmsetzung) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawDisziplin + rawEffizienz + rawUmsetzung) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}

// MARK: - FitnessAssessmentResult

extension FitnessAssessmentResult: DetailedAssessmentResult {

    private var fitnessParams: [(String, Int)] {
        [("strength", rawKonsistenz), ("endurance", rawIntensitaet), ("mobility", rawVerantwortung)]
    }

    var topStrengthKey: String {
        let best = fitnessParams.max(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = fitnessParams.min(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = fitnessParams.min(by: { $0.1 < $1.1 })?.0 ?? "strength"
        return "assessment.fitness.pitfall.\(worst)"
    }
    var benchmarkKey: String {
        let t = Double(rawKonsistenz + rawIntensitaet + rawVerantwortung)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawKonsistenz + rawIntensitaet + rawVerantwortung)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawKonsistenz + rawIntensitaet + rawVerantwortung)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }
    var strengthIcon: String { "figure.strengthtraining.traditional" }
    var weaknessIcon: String { "figure.stand" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fit.q_cons", defaultValue: "Konsistenz-Fragen: Trainings-Häufigkeit und Regelmäßigkeit"),
                String(localized: "assessment.source.fit.q_int", defaultValue: "Intensitäts-Fragen: Anstrengungsgrad deiner Workouts"),
                String(localized: "assessment.source.fit.q_resp", defaultValue: "Verantwortungs-Fragen: Eigenverantwortung für Fitness")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.fit.cons", defaultValue: "Konsistenz:")) \(rawKonsistenz > 0 ? "+" : "")\(rawKonsistenz) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.fit.int", defaultValue: "Intensität:")) \(rawIntensitaet > 0 ? "+" : "")\(rawIntensitaet) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.fit.resp", defaultValue: "Eigenverantwortung:")) \(rawVerantwortung > 0 ? "+" : "")\(rawVerantwortung) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawKonsistenz + rawIntensitaet + rawVerantwortung) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}

// MARK: - LifestyleAssessmentResult

extension LifestyleAssessmentResult: DetailedAssessmentResult {

    private var lifestyleParams: [(String, Int)] {
        [("routine", rawUmfeld), ("environment", rawStandards), ("balance", rawEinfluss)]
    }

    var topStrengthKey: String {
        let best = lifestyleParams.max(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.strength.\(best)"
    }
    var biggestWeaknessKey: String {
        let worst = lifestyleParams.min(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.weakness.\(worst)"
    }
    var pitfallKey: String {
        let worst = lifestyleParams.min(by: { $0.1 < $1.1 })?.0 ?? "routine"
        return "assessment.lifestyle.pitfall.\(worst)"
    }
    var benchmarkKey: String {
        let t = Double(rawUmfeld + rawStandards + rawEinfluss)
        if t > 15 { return "assessment.benchmark.top10" }
        if t > 0  { return "assessment.benchmark.top30" }
        if t > -10 { return "assessment.benchmark.average" }
        return "assessment.benchmark.bottom30"
    }
    var benchmarkPercentile: Double {
        let t = Double(rawUmfeld + rawStandards + rawEinfluss)
        return max(0.05, min(0.95, (t + 40) / 80.0))
    }
    var benchmarkLabel: String {
        let t = Double(rawUmfeld + rawStandards + rawEinfluss)
        if t > 15 { return "Top 10%" }
        if t > 0  { return "Top 30%" }
        if t > -10 { return "Ø Durchschnitt" }
        return "Unterdurchschnitt"
    }
    var strengthIcon: String { "house.fill" }
    var weaknessIcon: String { "xmark.circle.fill" }

    var strengthDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.lif.q_env", defaultValue: "Umfeld-Fragen: Wer umgibt dich, welchen Einfluss haben sie?"),
                String(localized: "assessment.source.lif.q_std", defaultValue: "Standards-Fragen: Wie hoch setzt du die Messlatte?"),
                String(localized: "assessment.source.lif.q_inf", defaultValue: "Einfluss-Fragen: Übernimmst du Kontrolle oder lässt du Dinge passieren?")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\(String(localized: "assessment.source.lif.env", defaultValue: "Umfeld:")) \(rawUmfeld > 0 ? "+" : "")\(rawUmfeld) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.lif.std", defaultValue: "Standards:")) \(rawStandards > 0 ? "+" : "")\(rawStandards) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.lif.inf", defaultValue: "Einflussbereich:")) \(rawEinfluss > 0 ? "+" : "")\(rawEinfluss) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \(rawUmfeld + rawStandards + rawEinfluss) \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])
        ]
    }
}
