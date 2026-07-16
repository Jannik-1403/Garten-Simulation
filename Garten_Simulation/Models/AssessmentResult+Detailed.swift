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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Frage 3: Kontostand ohne Nachschauen (Finanzkontrolle)",
                "Frage 4: Reaktion auf unnötige Abos (Budgetentscheidung)",
                "Frage 6: Verhalten bei Lifestyle-Creep (Risikoabsicherung)",
                "Frage 14: Umgang mit kleinen Ausgaben (Mikrolecks)"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Finanzkontrolle: \(rawKontrolle > 0 ? "+" : "")\(rawKontrolle) Punkte",
                "Entscheidung: \(rawEntscheidung > 0 ? "+" : "")\(rawEntscheidung) Punkte",
                "Risikoabsicherung: \(rawRisiko > 0 ? "+" : "")\(rawRisiko) Punkte",
                "Dein stärkster Parameter = deine Stärke"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Frage 1: Reaktion auf unerwartete Rückzahlung",
                "Frage 2: Investment-App-Verhalten",
                "Frage 7: Status vs. vernünftige Ausgaben",
                "Frage 12: Die Gier-Falle (riskante Investments)"
            ]),
            AssessmentDataSource(sectionTitle: "Dein schwächster Bereich", items: [
                "Dein schwächster Rohscore bestimmt die Schwäche.",
                "Alle drei Parameter werden miteinander verglichen.",
                "Der niedrigste Wert = größtes Verbesserungspotenzial."
            ])
        ]
    }
    var pitfallDataSources: [AssessmentDataSource] {
        weaknessDataSources
    }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawKontrolle + rawEntscheidung + rawRisiko) Punkte",
                "Minimum möglich: −41 Punkte",
                "Maximum möglich: +41 Punkte",
                "Dein Percentil = (Score + 41) / 82"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Schlaf-Fragen: Schlafdauer und Schlafqualität",
                "Ernährungs-Fragen: Mahlzeitenplanung & Zucker",
                "Regenerations-Fragen: Pausen, Dehnen, Prävention"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Regeneration (Schlaf): \(rawRegeneration > 0 ? "+" : "")\(rawRegeneration) Punkte",
                "Kraftstoff (Ernährung): \(rawKraftstoff > 0 ? "+" : "")\(rawKraftstoff) Punkte",
                "Prävention: \(rawPraevention > 0 ? "+" : "")\(rawPraevention) Punkte"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawRegeneration + rawKraftstoff + rawPraevention) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Resilienz-Fragen: Reaktion auf Rückschläge & Stress",
                "Fokus-Fragen: Ablenkbarkeit und Tiefarbeit",
                "Ego-Fragen: Selbstreflexion und Mindset"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Resilienz: \(rawResilienz > 0 ? "+" : "")\(rawResilienz) Punkte",
                "Fokus: \(rawFokus > 0 ? "+" : "")\(rawFokus) Punkte",
                "Ego/Mindset: \(rawEgo > 0 ? "+" : "")\(rawEgo) Punkte"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawResilienz + rawFokus + rawEgo) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Disziplin-Fragen: Konsistenz, auch ohne Motivation",
                "Effizienz-Fragen: Zeitnutzung und Priorisierung",
                "Umsetzungs-Fragen: Planung vs. tatsächliches Handeln"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Disziplin: \(rawDisziplin > 0 ? "+" : "")\(rawDisziplin) Punkte",
                "Effizienz: \(rawEffizienz > 0 ? "+" : "")\(rawEffizienz) Punkte",
                "Umsetzung: \(rawUmsetzung > 0 ? "+" : "")\(rawUmsetzung) Punkte"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawDisziplin + rawEffizienz + rawUmsetzung) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Konsistenz-Fragen: Trainings-Häufigkeit und Regelmäßigkeit",
                "Intensitäts-Fragen: Anstrengungsgrad deiner Workouts",
                "Verantwortungs-Fragen: Eigenverantwortung für Fitness"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Konsistenz: \(rawKonsistenz > 0 ? "+" : "")\(rawKonsistenz) Punkte",
                "Intensität: \(rawIntensitaet > 0 ? "+" : "")\(rawIntensitaet) Punkte",
                "Eigenverantwortung: \(rawVerantwortung > 0 ? "+" : "")\(rawVerantwortung) Punkte"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawKonsistenz + rawIntensitaet + rawVerantwortung) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
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
            AssessmentDataSource(sectionTitle: "Fragen im Assessment", items: [
                "Umfeld-Fragen: Wer umgibt dich, welchen Einfluss haben sie?",
                "Standards-Fragen: Wie hoch setzt du die Messlatte?",
                "Einfluss-Fragen: Übernimmst du Kontrolle oder lässt du Dinge passieren?"
            ]),
            AssessmentDataSource(sectionTitle: "Deine Rohscores", items: [
                "Umfeld: \(rawUmfeld > 0 ? "+" : "")\(rawUmfeld) Punkte",
                "Standards: \(rawStandards > 0 ? "+" : "")\(rawStandards) Punkte",
                "Einflussbereich: \(rawEinfluss > 0 ? "+" : "")\(rawEinfluss) Punkte"
            ])
        ]
    }
    var weaknessDataSources: [AssessmentDataSource] { strengthDataSources }
    var pitfallDataSources: [AssessmentDataSource] { strengthDataSources }
    var benchmarkDataSources: [AssessmentDataSource] {
        [
            AssessmentDataSource(sectionTitle: "Berechnung", items: [
                "Summe aller 3 Rohscores: \(rawUmfeld + rawStandards + rawEinfluss) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: "Kategorien", items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])
        ]
    }
}
