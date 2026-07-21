import re

with open("Garten_Simulation/Models/AssessmentResult+Detailed.swift", "r") as f:
    content = f.read()

# Define the precise blocks to replace
replacements = [
    # FINANCE
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Frage 3: Kontostand ohne Nachschauen (Finanzkontrolle)",
                "Frage 4: Reaktion auf unnötige Abos (Budgetentscheidung)",
                "Frage 6: Verhalten bei Lifestyle-Creep (Risikoabsicherung)",
                "Frage 14: Umgang mit kleinen Ausgaben (Mikrolecks)"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Finanzkontrolle: \\(rawKontrolle > 0 ? "+" : "")\\(rawKontrolle) Punkte",
                "Entscheidung: \\(rawEntscheidung > 0 ? "+" : "")\\(rawEntscheidung) Punkte",
                "Risikoabsicherung: \\(rawRisiko > 0 ? "+" : "")\\(rawRisiko) Punkte",
                "Dein stärkster Parameter = deine Stärke"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fin.q3", defaultValue: "Frage 3: Kontostand ohne Nachschauen (Finanzkontrolle)"),
                String(localized: "assessment.source.fin.q4", defaultValue: "Frage 4: Reaktion auf unnötige Abos (Budgetentscheidung)"),
                String(localized: "assessment.source.fin.q6", defaultValue: "Frage 6: Verhalten bei Lifestyle-Creep (Risikoabsicherung)"),
                String(localized: "assessment.source.fin.q14", defaultValue: "Frage 14: Umgang mit kleinen Ausgaben (Mikrolecks)")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.fin.control", defaultValue: "Finanzkontrolle:")) \\(rawKontrolle > 0 ? "+" : "")\\(rawKontrolle) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.fin.decision", defaultValue: "Entscheidung:")) \\(rawEntscheidung > 0 ? "+" : "")\\(rawEntscheidung) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.fin.risk", defaultValue: "Risikoabsicherung:")) \\(rawRisiko > 0 ? "+" : "")\\(rawRisiko) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                String(localized: "assessment.source.strongest_param", defaultValue: "Dein stärkster Parameter = deine Stärke")
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Frage 1: Reaktion auf unerwartete Rückzahlung",
                "Frage 2: Investment-App-Verhalten",
                "Frage 7: Status vs. vernünftige Ausgaben",
                "Frage 12: Die Gier-Falle (riskante Investments)"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.weakest_area", defaultValue: "Dein schwächster Bereich"), items: [
                "Dein schwächster Rohscore bestimmt die Schwäche.",
                "Alle drei Parameter werden miteinander verglichen.",
                "Der niedrigste Wert = größtes Verbesserungspotenzial."
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fin.q1", defaultValue: "Frage 1: Reaktion auf unerwartete Rückzahlung"),
                String(localized: "assessment.source.fin.q2", defaultValue: "Frage 2: Investment-App-Verhalten"),
                String(localized: "assessment.source.fin.q7", defaultValue: "Frage 7: Status vs. vernünftige Ausgaben"),
                String(localized: "assessment.source.fin.q12", defaultValue: "Frage 12: Die Gier-Falle (riskante Investments)")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.weakest_area", defaultValue: "Dein schwächster Bereich"), items: [
                String(localized: "assessment.source.weakest_1", defaultValue: "Dein schwächster Rohscore bestimmt die Schwäche."),
                String(localized: "assessment.source.weakest_2", defaultValue: "Alle drei Parameter werden miteinander verglichen."),
                String(localized: "assessment.source.weakest_3", defaultValue: "Der niedrigste Wert = größtes Verbesserungspotenzial.")
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawKontrolle + rawEntscheidung + rawRisiko) Punkte",
                "Minimum möglich: −41 Punkte",
                "Maximum möglich: +41 Punkte",
                "Dein Percentil = (Score + 41) / 82"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawKontrolle + rawEntscheidung + rawRisiko) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −41 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +41 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                String(localized: "assessment.source.fin.percentile", defaultValue: "Dein Percentil = (Score + 41) / 82")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    ),
    
    # HEALTH
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Schlaf-Fragen: Schlafdauer und Schlafqualität",
                "Ernährungs-Fragen: Mahlzeitenplanung & Zucker",
                "Regenerations-Fragen: Pausen, Dehnen, Prävention"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Regeneration (Schlaf): \\(rawRegeneration > 0 ? "+" : "")\\(rawRegeneration) Punkte",
                "Kraftstoff (Ernährung): \\(rawKraftstoff > 0 ? "+" : "")\\(rawKraftstoff) Punkte",
                "Prävention: \\(rawPraevention > 0 ? "+" : "")\\(rawPraevention) Punkte"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.hea.q_sleep", defaultValue: "Schlaf-Fragen: Schlafdauer und Schlafqualität"),
                String(localized: "assessment.source.hea.q_nutri", defaultValue: "Ernährungs-Fragen: Mahlzeitenplanung & Zucker"),
                String(localized: "assessment.source.hea.q_regen", defaultValue: "Regenerations-Fragen: Pausen, Dehnen, Prävention")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.hea.sleep", defaultValue: "Regeneration (Schlaf):")) \\(rawRegeneration > 0 ? "+" : "")\\(rawRegeneration) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.hea.nutri", defaultValue: "Kraftstoff (Ernährung):")) \\(rawKraftstoff > 0 ? "+" : "")\\(rawKraftstoff) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.hea.prev", defaultValue: "Prävention:")) \\(rawPraevention > 0 ? "+" : "")\\(rawPraevention) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawRegeneration + rawKraftstoff + rawPraevention) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawRegeneration + rawKraftstoff + rawPraevention) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    ),
    
    # MENTAL
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Resilienz-Fragen: Reaktion auf Rückschläge & Stress",
                "Fokus-Fragen: Ablenkbarkeit und Tiefarbeit",
                "Ego-Fragen: Selbstreflexion und Mindset"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Resilienz: \\(rawResilienz > 0 ? "+" : "")\\(rawResilienz) Punkte",
                "Fokus: \\(rawFokus > 0 ? "+" : "")\\(rawFokus) Punkte",
                "Ego/Mindset: \\(rawEgo > 0 ? "+" : "")\\(rawEgo) Punkte"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.men.q_resil", defaultValue: "Resilienz-Fragen: Reaktion auf Rückschläge & Stress"),
                String(localized: "assessment.source.men.q_focus", defaultValue: "Fokus-Fragen: Ablenkbarkeit und Tiefarbeit"),
                String(localized: "assessment.source.men.q_ego", defaultValue: "Ego-Fragen: Selbstreflexion und Mindset")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.men.resil", defaultValue: "Resilienz:")) \\(rawResilienz > 0 ? "+" : "")\\(rawResilienz) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.men.focus", defaultValue: "Fokus:")) \\(rawFokus > 0 ? "+" : "")\\(rawFokus) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.men.ego", defaultValue: "Ego/Mindset:")) \\(rawEgo > 0 ? "+" : "")\\(rawEgo) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawResilienz + rawFokus + rawEgo) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawResilienz + rawFokus + rawEgo) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    ),
    
    # GROWTH
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Disziplin-Fragen: Konsistenz, auch ohne Motivation",
                "Effizienz-Fragen: Zeitnutzung und Priorisierung",
                "Umsetzungs-Fragen: Planung vs. tatsächliches Handeln"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Disziplin: \\(rawDisziplin > 0 ? "+" : "")\\(rawDisziplin) Punkte",
                "Effizienz: \\(rawEffizienz > 0 ? "+" : "")\\(rawEffizienz) Punkte",
                "Umsetzung: \\(rawUmsetzung > 0 ? "+" : "")\\(rawUmsetzung) Punkte"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.gro.q_disc", defaultValue: "Disziplin-Fragen: Konsistenz, auch ohne Motivation"),
                String(localized: "assessment.source.gro.q_eff", defaultValue: "Effizienz-Fragen: Zeitnutzung und Priorisierung"),
                String(localized: "assessment.source.gro.q_exec", defaultValue: "Umsetzungs-Fragen: Planung vs. tatsächliches Handeln")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.gro.disc", defaultValue: "Disziplin:")) \\(rawDisziplin > 0 ? "+" : "")\\(rawDisziplin) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.gro.eff", defaultValue: "Effizienz:")) \\(rawEffizienz > 0 ? "+" : "")\\(rawEffizienz) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.gro.exec", defaultValue: "Umsetzung:")) \\(rawUmsetzung > 0 ? "+" : "")\\(rawUmsetzung) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawDisziplin + rawEffizienz + rawUmsetzung) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawDisziplin + rawEffizienz + rawUmsetzung) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    ),
    
    # FITNESS
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Konsistenz-Fragen: Trainings-Häufigkeit und Regelmäßigkeit",
                "Intensitäts-Fragen: Anstrengungsgrad deiner Workouts",
                "Verantwortungs-Fragen: Eigenverantwortung für Fitness"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Konsistenz: \\(rawKonsistenz > 0 ? "+" : "")\\(rawKonsistenz) Punkte",
                "Intensität: \\(rawIntensitaet > 0 ? "+" : "")\\(rawIntensitaet) Punkte",
                "Eigenverantwortung: \\(rawVerantwortung > 0 ? "+" : "")\\(rawVerantwortung) Punkte"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.fit.q_cons", defaultValue: "Konsistenz-Fragen: Trainings-Häufigkeit und Regelmäßigkeit"),
                String(localized: "assessment.source.fit.q_int", defaultValue: "Intensitäts-Fragen: Anstrengungsgrad deiner Workouts"),
                String(localized: "assessment.source.fit.q_resp", defaultValue: "Verantwortungs-Fragen: Eigenverantwortung für Fitness")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.fit.cons", defaultValue: "Konsistenz:")) \\(rawKonsistenz > 0 ? "+" : "")\\(rawKonsistenz) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.fit.int", defaultValue: "Intensität:")) \\(rawIntensitaet > 0 ? "+" : "")\\(rawIntensitaet) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.fit.resp", defaultValue: "Eigenverantwortung:")) \\(rawVerantwortung > 0 ? "+" : "")\\(rawVerantwortung) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawKonsistenz + rawIntensitaet + rawVerantwortung) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawKonsistenz + rawIntensitaet + rawVerantwortung) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    ),
    
    # LIFESTYLE
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                "Umfeld-Fragen: Wer umgibt dich, welchen Einfluss haben sie?",
                "Standards-Fragen: Wie hoch setzt du die Messlatte?",
                "Einfluss-Fragen: Übernimmst du Kontrolle oder lässt du Dinge passieren?"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "Umfeld: \\(rawUmfeld > 0 ? "+" : "")\\(rawUmfeld) Punkte",
                "Standards: \\(rawStandards > 0 ? "+" : "")\\(rawStandards) Punkte",
                "Einflussbereich: \\(rawEinfluss > 0 ? "+" : "")\\(rawEinfluss) Punkte"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.questions", defaultValue: "Fragen im Assessment"), items: [
                String(localized: "assessment.source.lif.q_env", defaultValue: "Umfeld-Fragen: Wer umgibt dich, welchen Einfluss haben sie?"),
                String(localized: "assessment.source.lif.q_std", defaultValue: "Standards-Fragen: Wie hoch setzt du die Messlatte?"),
                String(localized: "assessment.source.lif.q_inf", defaultValue: "Einfluss-Fragen: Übernimmst du Kontrolle oder lässt du Dinge passieren?")
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.raw_scores", defaultValue: "Deine Rohscores"), items: [
                "\\(String(localized: "assessment.source.lif.env", defaultValue: "Umfeld:")) \\(rawUmfeld > 0 ? "+" : "")\\(rawUmfeld) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.lif.std", defaultValue: "Standards:")) \\(rawStandards > 0 ? "+" : "")\\(rawStandards) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.lif.inf", defaultValue: "Einflussbereich:")) \\(rawEinfluss > 0 ? "+" : "")\\(rawEinfluss) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ])'''
    ),
    (
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "Summe aller 3 Rohscores: \\(rawUmfeld + rawStandards + rawEinfluss) Punkte",
                "Minimum möglich: −40 Punkte",
                "Maximum möglich: +40 Punkte"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                "Top 10%: Score über +15",
                "Top 30%: Score über 0",
                "Durchschnitt: Score zwischen 0 und −10",
                "Unterdurchschnitt: Score unter −10"
            ])''',
        '''            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.calculation", defaultValue: "Berechnung"), items: [
                "\\(String(localized: "assessment.source.sum_3_scores", defaultValue: "Summe aller 3 Rohscores:")) \\(rawUmfeld + rawStandards + rawEinfluss) \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.min_possible", defaultValue: "Minimum möglich:")) −40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))",
                "\\(String(localized: "assessment.source.max_possible", defaultValue: "Maximum möglich:")) +40 \\(String(localized: "assessment.source.points", defaultValue: "Punkte"))"
            ]),
            AssessmentDataSource(sectionTitle: String(localized: "assessment.source.categories", defaultValue: "Kategorien"), items: [
                String(localized: "assessment.source.cat.top10", defaultValue: "Top 10%: Score über +15"),
                String(localized: "assessment.source.cat.top30", defaultValue: "Top 30%: Score über 0"),
                String(localized: "assessment.source.cat.avg", defaultValue: "Durchschnitt: Score zwischen 0 und −10"),
                String(localized: "assessment.source.cat.below_avg", defaultValue: "Unterdurchschnitt: Score unter −10")
            ])'''
    )
]

for orig, new_text in replacements:
    if orig not in content:
        print("COULD NOT FIND BLOCK:")
        print(orig[:50] + "...")
    content = content.replace(orig, new_text)

with open("Garten_Simulation/Models/AssessmentResult+Detailed.swift", "w") as f:
    f.write(content)

print("SUCCESS")
