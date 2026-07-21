import Foundation

let filePath = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/HabitProgressionStrategy.swift"
guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("Could not read file")
    exit(1)
}

var modifiedContent = content

// Replace Phase Info
modifiedContent = modifiedContent.replacingOccurrences(
    of: "return \"Fundament & Basisaufbau\"",
    with: "return String(localized: \"prog_strength_phase1_desc\", defaultValue: \"Fundament & Basisaufbau\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "return \"Intensivierung & Hypertrophie\"",
    with: "return String(localized: \"prog_strength_phase2_desc\", defaultValue: \"Intensivierung & Hypertrophie\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "return \"Crucible & Maximale Kraft\"",
    with: "return String(localized: \"prog_strength_phase3_desc\", defaultValue: \"Crucible & Maximale Kraft\")"
)

// D1
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Montag: Push-Fokus\"",
    with: "title: String(localized: \"prog_strength_d1_title\", defaultValue: \"Push-Fokus\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Absolviere ein EMOM (Every Minute on the Minute) - \\(rounds * 4) Minuten.\\nMinute 1: Übung 1\\nMinute 2: Übung 2\\nMinute 3: Übung 3\\nMinute 4: Pause\"",
    with: "description: String(localized: \"prog_strength_d1_desc\", defaultValue: \"Absolviere ein EMOM (Every Minute on the Minute) - \\(rounds * 4) Minuten.\\nMinute 1: Übung 1\\nMinute 2: Übung 2\\nMinute 3: Übung 3\\nMinute 4: Pause\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"\\(rounds) Runden absolviert\"",
    with: "String(localized: \"prog_strength_rounds\", defaultValue: \"\\(rounds) Runden absolviert\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 1: \\(pushups) \\(pushupType)\"",
    with: "String(localized: \"prog_strength_d1_t1\", defaultValue: \"Minute 1: \\(pushups) \\(pushupType)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 2: \\(dipType)\"",
    with: "String(localized: \"prog_strength_d1_t2\", defaultValue: \"Minute 2: \\(dipType)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 3: 30s Pike Hold / Handstand\"",
    with: "String(localized: \"prog_strength_d1_t3\", defaultValue: \"Minute 3: 30s Pike Hold / Handstand\")"
)

// D2
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Dienstag: Pull & Core\"",
    with: "title: String(localized: \"prog_strength_d2_title\", defaultValue: \"Pull & Core\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Absolviere ein EMOM - \\(rounds * 4) Minuten.\\nZiele auf saubere Wiederholungen ohne Schwung.\"",
    with: "description: String(localized: \"prog_strength_d2_desc\", defaultValue: \"Absolviere ein EMOM - \\(rounds * 4) Minuten.\\nZiele auf saubere Wiederholungen ohne Schwung.\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 1: \\(pullText)\"",
    with: "String(localized: \"prog_strength_d2_t1\", defaultValue: \"Minute 1: \\(pullText)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 2: \\(rows) Bodyweight Rows\"",
    with: "String(localized: \"prog_strength_d2_t2\", defaultValue: \"Minute 2: \\(rows) Bodyweight Rows\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 3: 15-20 Leg Raises\"",
    with: "String(localized: \"prog_strength_d2_t3\", defaultValue: \"Minute 3: 15-20 Leg Raises\")"
)

// D3
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Mittwoch: Explosive Kraft\"",
    with: "title: String(localized: \"prog_strength_d3_title\", defaultValue: \"Explosive Kraft\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Fokus auf 100% Effort pro Sprint. Langsame Erholung beim Zurückgehen.\"",
    with: "description: String(localized: \"prog_strength_d3_desc\", defaultValue: \"Fokus auf 100% Effort pro Sprint. Langsame Erholung beim Zurückgehen.\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"10 Min dynamisches Dehnen\"",
    with: "String(localized: \"prog_strength_d3_t1\", defaultValue: \"10 Min dynamisches Dehnen\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"\\(sprints) x \\(distance) Sprints (Maximale Intensität)\"",
    with: "String(localized: \"prog_strength_d3_t2\", defaultValue: \"\\(sprints) x \\(distance) Sprints (Maximale Intensität)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"3x 15 Jump Squats Finisher\"",
    with: "String(localized: \"prog_strength_d3_t3\", defaultValue: \"3x 15 Jump Squats Finisher\")"
)

// D4
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Donnerstag: Kapazität (AMRAP)\"",
    with: "title: String(localized: \"prog_strength_d4_title\", defaultValue: \"Kapazität (AMRAP)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Stelle einen Timer auf \\(amrapTime) Minuten. Absolviere so viele saubere Runden wie möglich. Bei unsauberer Technik abbrechen!\"",
    with: "description: String(localized: \"prog_strength_d4_desc\", defaultValue: \"Stelle einen Timer auf \\(amrapTime) Minuten. Absolviere so viele saubere Runden wie möglich. Bei unsauberer Technik abbrechen!\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"\\(amrapTime) Minuten Timer absolviert\"",
    with: "String(localized: \"prog_strength_d4_t1\", defaultValue: \"\\(amrapTime) Minuten Timer absolviert\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Runde: \\(pullVol) Pull-ups\"",
    with: "String(localized: \"prog_strength_d4_t2\", defaultValue: \"Runde: \\(pullVol) Pull-ups\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Runde: \\(pushVol) Push-ups\"",
    with: "String(localized: \"prog_strength_d4_t3\", defaultValue: \"Runde: \\(pushVol) Push-ups\")"
)

// D5
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Freitag: Beine & Core\"",
    with: "title: String(localized: \"prog_strength_d5_title\", defaultValue: \"Beine & Core\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Absolviere ein EMOM - \\(rounds * 4) Minuten. Squats müssen tief sein (Hüfte unter Kniehöhe).\"",
    with: "description: String(localized: \"prog_strength_d5_desc\", defaultValue: \"Absolviere ein EMOM - \\(rounds * 4) Minuten. Squats müssen tief sein (Hüfte unter Kniehöhe).\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 1: \\(lunges) \\(lungeType)\"",
    with: "String(localized: \"prog_strength_d5_t1\", defaultValue: \"Minute 1: \\(lunges) \\(lungeType)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 2: \\(squats) Squats\"",
    with: "String(localized: \"prog_strength_d5_t2\", defaultValue: \"Minute 2: \\(squats) Squats\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Minute 3: 40s Plank / L-Sit\"",
    with: "String(localized: \"prog_strength_d5_t3\", defaultValue: \"Minute 3: 40s Plank / L-Sit\")"
)

// D6
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Samstag: MetCon\"",
    with: "title: String(localized: \"prog_strength_d6_title\", defaultValue: \"MetCon\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"Auf Zeit! Absolviere \\(rds) Runden so schnell wie möglich mit sauberer Form. Ziel: Bei hohem Puls Technik beibehalten.\"",
    with: "description: String(localized: \"prog_strength_d6_desc\", defaultValue: \"Auf Zeit! Absolviere \\(rds) Runden so schnell wie möglich mit sauberer Form. Ziel: Bei hohem Puls Technik beibehalten.\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Übung: \\(burpees) Burpees\"",
    with: "String(localized: \"prog_strength_d6_t1\", defaultValue: \"Übung: \\(burpees) Burpees\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Übung: \\(run) Lauf\"",
    with: "String(localized: \"prog_strength_d6_t2\", defaultValue: \"Übung: \\(run) Lauf\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Übung: \\(pullPart)\"",
    with: "String(localized: \"prog_strength_d6_t3\", defaultValue: \"Übung: \\(pullPart)\")"
)

// D7
modifiedContent = modifiedContent.replacingOccurrences(
    of: "title: \"Sonntag: Aktive Erholung\"",
    with: "title: String(localized: \"prog_strength_d7_title\", defaultValue: \"Aktive Erholung\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "description: \"KEIN Sofa-Tag. Aktive Regeneration für Muskeln und Nervensystem.\"",
    with: "description: String(localized: \"prog_strength_d7_desc\", defaultValue: \"KEIN Sofa-Tag. Aktive Regeneration für Muskeln und Nervensystem.\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"30 Min Mobilitätsarbeit / Dehnen\"",
    with: "String(localized: \"prog_strength_d7_t1\", defaultValue: \"30 Min Mobilitätsarbeit / Dehnen\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Leichter Spaziergang (30+ Min)\"",
    with: "String(localized: \"prog_strength_d7_t2\", defaultValue: \"Leichter Spaziergang (30+ Min)\")"
)
modifiedContent = modifiedContent.replacingOccurrences(
    of: "\"Mentale Vorbereitung auf nächste Woche\"",
    with: "String(localized: \"prog_strength_d7_t3\", defaultValue: \"Mentale Vorbereitung auf nächste Woche\")"
)


try! modifiedContent.write(toFile: filePath, atomically: true, encoding: .utf8)
print("Updated HabitProgressionStrategy.swift")
