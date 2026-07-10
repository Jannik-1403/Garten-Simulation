import Foundation

struct ProgressionData {
    var phaseNumber: Int
    var phaseTitle: String
    var phaseDescription: String
    var dailyTitle: String
    var dailyDescription: String
    var dailyTodos: [String]
}

protocol HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData
}

class StrengthProgressionStrategy: HabitProgressionStrategy {
    
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        // Phase is determined by 7-day weeks. Day 1-7 = Phase 1, Day 8-14 = Phase 2...
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfänger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        let isExpert = difficulty.lowercased() == "experte" || (!isBeginner && !isIntermediate)
        
        // Progression multiplier based on phase 1 to 13 (approx 1.0 to 2.5)
        let phaseMultiplier = 1.0 + (Double(phaseNumber - 1) * 0.12)
        
        let phaseInfo = getPhaseInfo(phase: phaseNumber)
        let workoutInfo = getWorkoutInfo(cycleDay: cycleDay, isBeginner: isBeginner, isIntermediate: isIntermediate, isExpert: isExpert, phaseNumber: phaseNumber, phaseMultiplier: phaseMultiplier)
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: phaseInfo,
            dailyTitle: workoutInfo.title,
            dailyDescription: workoutInfo.description,
            dailyTodos: workoutInfo.todos
        )
    }
    
    private func getPhaseInfo(phase: Int) -> String {
        if phase <= 4 {
            return "Fundament & Basisaufbau"
        } else if phase <= 9 {
            return "Intensivierung & Hypertrophie"
        } else {
            return "Crucible & Maximale Kraft"
        }
    }
    
    private func getWorkoutInfo(cycleDay: Int, isBeginner: Bool, isIntermediate: Bool, isExpert: Bool, phaseNumber: Int, phaseMultiplier: Double) -> (title: String, description: String, todos: [String]) {
        let rounds = isBeginner ? 3 : (isIntermediate ? 4 : (phaseNumber > 6 ? 5 : 4))
        
        switch cycleDay {
        case 1:
            // Push-Fokus
            let pushups = Int(Double(isBeginner ? 5 : (isIntermediate ? 10 : 15)) * phaseMultiplier)
            let dips = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let pushupType = isBeginner ? "Knie-Liegestütze" : (isExpert && phaseNumber > 9 ? "Archer Push-ups" : "Strict Push-ups")
            let dipType = dips > 0 ? "\(dips) Dips" : "\(pushups) Negative Liegestütze"
            
            return (
                title: "Montag: Push-Fokus",
                description: "Absolviere ein EMOM (Every Minute on the Minute) - \(rounds * 4) Minuten.\nMinute 1: Übung 1\nMinute 2: Übung 2\nMinute 3: Übung 3\nMinute 4: Pause",
                todos: [
                    "\(rounds) Runden absolviert",
                    "Minute 1: \(pushups) \(pushupType)",
                    "Minute 2: \(dipType)",
                    "Minute 3: 30s Pike Hold / Handstand"
                ]
            )
            
        case 2:
            // Pull & Core
            let pullups = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let rows = Int(Double(isBeginner ? 10 : (isIntermediate ? 12 : 15)) * phaseMultiplier)
            let pullText = pullups > 0 ? "\(pullups) Strict Pull-ups" : "5 Negative Klimmzüge"
            
            return (
                title: "Dienstag: Pull & Core",
                description: "Absolviere ein EMOM - \(rounds * 4) Minuten.\nZiele auf saubere Wiederholungen ohne Schwung.",
                todos: [
                    "\(rounds) Runden absolviert",
                    "Minute 1: \(pullText)",
                    "Minute 2: \(rows) Bodyweight Rows",
                    "Minute 3: 15-20 Leg Raises"
                ]
            )
            
        case 3:
            // Sprints
            let sprints = Int(Double(isBeginner ? 5 : (isIntermediate ? 8 : 10)) * phaseMultiplier)
            let distance = phaseNumber >= 5 && isExpert ? "75-Meter" : "50-Meter"
            
            return (
                title: "Mittwoch: Explosive Kraft",
                description: "Fokus auf 100% Effort pro Sprint. Langsame Erholung beim Zurückgehen.",
                todos: [
                    "10 Min dynamisches Dehnen",
                    "\(sprints) x \(distance) Sprints (Maximale Intensität)",
                    "3x 15 Jump Squats Finisher"
                ]
            )
            
        case 4:
            // AMRAP
            let amrapTime = isBeginner ? 10 : (isIntermediate ? 12 : 15)
            let pullVol = isBeginner ? 3 : 5
            let pushVol = isBeginner ? 5 : 10
            
            return (
                title: "Donnerstag: Kapazität (AMRAP)",
                description: "Stelle einen Timer auf \(amrapTime) Minuten. Absolviere so viele saubere Runden wie möglich. Bei unsauberer Technik abbrechen!",
                todos: [
                    "\(amrapTime) Minuten Timer absolviert",
                    "Runde: \(pullVol) Pull-ups",
                    "Runde: \(pushVol) Push-ups"
                ]
            )
            
        case 5:
            // Beine
            let lunges = Int(Double(isBeginner ? 10 : (isIntermediate ? 16 : 20)) * phaseMultiplier)
            let squats = Int(Double(isBeginner ? 15 : (isIntermediate ? 20 : 25)) * phaseMultiplier)
            let lungeType = (isExpert && phaseNumber > 8) ? "Pistol Squats / schwere Lunges" : "Lunges"
            
            return (
                title: "Freitag: Beine & Core",
                description: "Absolviere ein EMOM - \(rounds * 4) Minuten. Squats müssen tief sein (Hüfte unter Kniehöhe).",
                todos: [
                    "\(rounds) Runden absolviert",
                    "Minute 1: \(lunges) \(lungeType)",
                    "Minute 2: \(squats) Squats",
                    "Minute 3: 40s Plank / L-Sit"
                ]
            )
            
        case 6:
            // MetCon
            let burpees = Int(Double(isBeginner ? 10 : (isIntermediate ? 15 : 20)) * phaseMultiplier)
            let run = isBeginner ? "200m" : (isIntermediate ? "300m" : "400m")
            let pullups = Int(Double(isBeginner ? 0 : (isIntermediate ? 5 : 10)) * phaseMultiplier)
            let rds = isBeginner ? 3 : (isIntermediate ? 4 : 5)
            let pullPart = pullups > 0 ? "\(pullups) Pull-ups" : "10 Bodyweight Rows"
            
            return (
                title: "Samstag: MetCon",
                description: "Auf Zeit! Absolviere \(rds) Runden so schnell wie möglich mit sauberer Form. Ziel: Bei hohem Puls Technik beibehalten.",
                todos: [
                    "\(rds) Runden absolviert",
                    "Übung: \(burpees) Burpees",
                    "Übung: \(run) Lauf",
                    "Übung: \(pullPart)"
                ]
            )
            
        case 7:
            // Erholung
            return (
                title: "Sonntag: Aktive Erholung",
                description: "KEIN Sofa-Tag. Aktive Regeneration für Muskeln und Nervensystem.",
                todos: [
                    "30 Min Mobilitätsarbeit / Dehnen",
                    "Leichter Spaziergang (30+ Min)",
                    "Mentale Vorbereitung auf nächste Woche"
                ]
            )
            
        default:
            return (title: "", description: "", todos: [])
        }
    }
}
