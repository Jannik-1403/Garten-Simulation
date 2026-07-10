import Foundation

protocol HabitProgressionStrategy {
    func generateDescription(dayNum: Int, difficulty: String) -> String
}

class StrengthProgressionStrategy: HabitProgressionStrategy {
    
    func generateDescription(dayNum: Int, difficulty: String) -> String {
        let phase = getPhase(dayNum: dayNum)
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        // Base modifiers depending on difficulty
        let isBeginner = difficulty.lowercased() == "anfänger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        let isExpert = difficulty.lowercased() == "experte" || (!isBeginner && !isIntermediate)
        
        // Progression multipliers based on phase
        let phaseMultiplier: Double
        if phase == 1 { phaseMultiplier = 1.0 }
        else if phase == 2 { phaseMultiplier = 1.2 }
        else { phaseMultiplier = 1.5 }
        
        let introText = getIntro(phase: phase, difficulty: difficulty)
        let workoutText = getWorkout(cycleDay: cycleDay, isBeginner: isBeginner, isIntermediate: isIntermediate, isExpert: isExpert, phase: phase, phaseMultiplier: phaseMultiplier)
        
        return "\(introText)\n\n\(workoutText)"
    }
    
    private func getPhase(dayNum: Int) -> Int {
        if dayNum <= 30 { return 1 }
        else if dayNum <= 60 { return 2 }
        else { return 3 }
    }
    
    private func getIntro(phase: Int, difficulty: String) -> String {
        switch phase {
        case 1:
            return "**Phase 1: Fundament (Tag 1–30)**\nFokus: Sauberkeit der Form. Der Körper adaptiert sich."
        case 2:
            return "**Phase 2: Intensivierung (Tag 31–60)**\nFokus: Das Volumen steigt, die Pausen werden kürzer."
        case 3:
            return "**Phase 3: Crucible (Tag 61–90)**\nFokus: Maximale Progression. Einführung von einarmigen/einbeinigen Varianten und Zusatzwiderständen."
        default:
            return ""
        }
    }
    
    private func getWorkout(cycleDay: Int, isBeginner: Bool, isIntermediate: Bool, isExpert: Bool, phase: Int, phaseMultiplier: Double) -> String {
        let rounds = isBeginner ? 3 : (isIntermediate ? 4 : 5)
        
        switch cycleDay {
        case 1:
            // Push-Fokus
            let pushups = Int(Double(isBeginner ? 5 : (isIntermediate ? 10 : 15)) * phaseMultiplier)
            let dips = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let pushupType = isBeginner ? "Knie-Liegestütze" : (isExpert && phase == 3 ? "Archer Push-ups" : "Strict Push-ups")
            let dipText = dips > 0 ? "• Minute 2: \(dips) Dips (Stuhl/Ringe)" : "• Minute 2: \(pushups) Negative Liegestütze"
            
            return """
            **Montag: Push-Fokus**
            Absolviere ein EMOM (Every Minute on the Minute) - \(rounds * 4) Minuten:
            • Minute 1: \(pushups) \(pushupType)
            \(dipText)
            • Minute 3: 30 Sekunden Pike Hold oder Handstand an der Wand
            • Minute 4: Pause
            Wiederhole das für \(rounds) Runden.
            """
            
        case 2:
            // Pull & Core
            let pullups = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let rows = Int(Double(isBeginner ? 10 : (isIntermediate ? 12 : 15)) * phaseMultiplier)
            let pullText = pullups > 0 ? "Strict Pull-ups (Kein Schwung!)" : "Negative Klimmzüge oder Band-Assisted"
            
            return """
            **Dienstag: Pull & Core**
            Absolviere ein EMOM - \(rounds * 4) Minuten:
            • Minute 1: \(pullups > 0 ? "\(pullups)" : "5") \(pullText)
            • Minute 2: \(rows) Bodyweight Rows (Tischkante/Ringe)
            • Minute 3: 15-20 Leg Raises (Hängend oder liegend)
            • Minute 4: Pause
            Wiederhole das für \(rounds) Runden.
            """
            
        case 3:
            // Explosive Kraft & Sprints
            let sprints = Int(Double(isBeginner ? 5 : (isIntermediate ? 8 : 10)) * phaseMultiplier)
            let distance = phase >= 2 && isExpert ? "75-Meter" : "50-Meter"
            let hill = phase == 3 && isExpert ? " an einer Steigung (Hillsprints)" : ""
            
            return """
            **Mittwoch: Explosive Kraft & Sprints**
            • Aufwärmen: 10 Min dynamisches Dehnen
            • Sprint-Protokoll: \(sprints) x \(distance) Sprints\(hill) mit maximaler Intensität (100% Effort).
            • Pause: Langsames Zurückgehen zum Start (ca. 60-90 Sek).
            • Finisher: 3 Sätze à 15 Jump Squats.
            """
            
        case 4:
            // Dichte-Training (AMRAP)
            let amrapTime = isBeginner ? 10 : (isIntermediate ? 12 : 15)
            let pullVol = isBeginner ? 3 : 5
            let pushVol = isBeginner ? 5 : 10
            
            return """
            **Donnerstag: Push & Pull Kapazität**
            Stelle einen Timer auf \(amrapTime) Minuten.
            Absolviere so viele saubere Runden wie möglich (AMRAP) von:
            • \(pullVol) Pull-ups (oder Alternativen)
            • \(pushVol) Push-ups
            Sobald die Technik unsauber wird: Satz abbrechen. Keine halben Wiederholungen!
            """
            
        case 5:
            // Beine & Core
            let lunges = Int(Double(isBeginner ? 10 : (isIntermediate ? 16 : 20)) * phaseMultiplier)
            let squats = Int(Double(isBeginner ? 15 : (isIntermediate ? 20 : 25)) * phaseMultiplier)
            let lungeType = (isExpert && phase == 3) ? "Pistol Squats (falls möglich) oder schwere Lunges" : "Lunges (abwechselnd)"
            
            return """
            **Freitag: Beine & Core**
            Absolviere ein EMOM - \(rounds * 4) Minuten:
            • Minute 1: \(lunges) \(lungeType)
            • Minute 2: \(squats) Squats (Tief, Hüfte unter Kniehöhe)
            • Minute 3: 40 Sekunden Plank oder L-Sit Hold
            • Minute 4: Pause
            Wiederhole das für \(rounds) Runden.
            """
            
        case 6:
            // MetCon
            let burpees = Int(Double(isBeginner ? 10 : (isIntermediate ? 15 : 20)) * phaseMultiplier)
            let run = isBeginner ? "200" : (isIntermediate ? "300" : "400")
            let pullups = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let rds = isBeginner ? 3 : (isIntermediate ? 4 : 5)
            let pullPart = pullups > 0 ? "• \(pullups) Pull-ups" : "• 10 Bodyweight Rows"
            
            return """
            **Samstag: MetCon (Metabolic Conditioning)**
            Auf Zeit! Absolviere \(rds) Runden so schnell wie möglich mit sauberer Form:
            • \(burpees) Burpees
            • \(run) Meter Lauf (hohe Pace)
            \(pullPart)
            Ziel: Bei hohem Puls die Technik beibehalten.
            """
            
        case 7:
            // Aktive Erholung
            return """
            **Sonntag: Aktive Erholung**
            • KEIN Sofa-Tag.
            • 30 bis 45 Minuten Mobilitätsarbeit, statisches Dehnen.
            • Ein leichter Spaziergang.
            Bereite dich mental auf die nächste Woche vor.
            """
            
        default:
            return ""
        }
    }
}
