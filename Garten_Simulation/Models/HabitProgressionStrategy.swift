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
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
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


// MARK: - Running (Laufen) Strategy
class RunningProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        // Base distance calculation (phase multiplier)
        let phaseMult = 1.0 + (Double(phaseNumber - 1) * 0.15)
        let baseDist = isBeginner ? 2.0 : (isIntermediate ? 4.0 : 6.0)
        let currentDist = baseDist * phaseMult
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Recovery Run"
            desc = "Ein sehr lockerer Lauf, um die Beine nach dem Wochenende durchzubewegen. Du solltest dabei entspannt durch die Nase atmen können."
            let dist = max(1.0, currentDist * 0.5)
            todos = ["\(String(format: "%.1f", dist)) km locker laufen", "Bewusst durch die Nase atmen"]
        case 2:
            title = "Dienstag: Intervall-Training"
            desc = "Fokus auf Geschwindigkeit und Herz-Kreislauf-Belastung. Kurze, harte Intervalle gefolgt von Geh-Pausen."
            let intervals = isBeginner ? 4 : (isIntermediate ? 6 : 8)
            let sprintTime = isBeginner ? "30s" : "60s"
            todos = ["10 Min Aufwärmen", "\(intervals)x \(sprintTime) Sprint / 1 Min Gehen", "10 Min Cool-down"]
        case 3:
            title = "Mittwoch: Lauf-ABC & Core"
            desc = "Heute arbeiten wir an der Lauftechnik und Rumpfstabilität, um Verletzungen vorzubeugen."
            todos = ["15 Min Lauf-ABC (Kniehebelauf, Anfersen)", "3x 45s Plank", "3x 15 Glute Bridges"]
        case 4:
            title = "Donnerstag: Tempodauerlauf"
            desc = "Ein Lauf in ambitioniertem, aber haltbarem Tempo (Zone 3). Es sollte anstrengend, aber kontrolliert sein."
            let dist = currentDist * 0.75
            todos = ["\(String(format: "%.1f", dist)) km im zügigen Tempo"]
        case 5:
            title = "Freitag: Aktive Erholung"
            desc = "Die Muskeln brauchen Pause. Ein zügiger Spaziergang oder eine Dehn-Session reichen heute aus."
            todos = ["30 Min zügiges Spazieren", "Ausgiebiges Dehnen (Waden, Oberschenkel)"]
        case 6:
            title = "Samstag: Long Run"
            desc = "Der wichtigste Lauf der Woche für die Grundlagenausdauer. Das Tempo ist absolut zweitrangig."
            let dist = currentDist * 1.5
            todos = ["\(String(format: "%.1f", dist)) km absolviert", "Tempo bewusst niedrig gehalten"]
        case 7:
            title = "Sonntag: Complete Rest"
            desc = "Komplette Pause. Der Körper repariert das Gewebe und baut Muskeln auf."
            todos = ["Beine hochgelegt", "Ausreichend Protein konsumiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Ausdauer & Kondition",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Stretching (Dehnen) Strategy
class StretchingProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseMin = isBeginner ? 5 : (isIntermediate ? 10 : 15)
        let currentMin = baseMin + (phaseNumber - 1)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Hüftöffner"
            desc = "Ein Fokus auf den Psoas und die Hüftbeuger, perfekt um das viele Sitzen auszugleichen."
            todos = ["\(currentMin) Min Fokus auf Hüfte", "Pigeon Pose 1 Min pro Seite", "Deep Squat Hold"]
        case 2:
            title = "Dienstag: Schulter & Nacken"
            desc = "Verspannungen im oberen Rücken lösen."
            todos = ["\(currentMin) Min Fokus auf Schultern", "Chest Opener an der Wand", "Nacken sanft mobilisiert"]
        case 3:
            title = "Mittwoch: Beinrückseite (Hamstrings)"
            desc = "Ziel ist die Verlängerung der hinteren Kette. Wichtig: Nicht über den Schmerzpunkt hinausgehen!"
            todos = ["\(currentMin) Min Fokus auf Beine", "Forward Fold (Vorbeuge)", "Downward Dog"]
        case 4:
            title = "Donnerstag: Spinal Twists"
            desc = "Rotationen für die Wirbelsäule, um Bandscheiben zu nähren und die Mobilität des Rumpfes zu verbessern."
            todos = ["\(currentMin) Min Fokus auf Wirbelsäule", "Liegende Rotation (Krokodil)", "Cat-Cow Mobilisation"]
        case 5:
            title = "Freitag: Full Body Flow"
            desc = "Eine Kombination aus allen Elementen dieser Woche in einem fließenden Ablauf."
            todos = ["\(currentMin) Min Full Body Flow", "Fließende Übergänge geübt"]
        case 6:
            title = "Samstag: Animal Flow / Dynamisch"
            desc = "Bringe Bewegung in deine Mobility-Routine. Keine statischen Holds, sondern dynamische Wechsel."
            todos = ["\(currentMin) Min dynamisches Dehnen", "Neue Mobilitäts-Position ausprobiert"]
        case 7:
            title = "Sonntag: Yin Yoga / Tiefe Entspannung"
            desc = "Sehr langes Halten von wenigen Posen. Nutze Schwerkraft und Atmung, statt Muskelkraft."
            todos = ["\(currentMin) Min Yin-Stil (Pose 2+ Min halten)", "Tief in den Bauch geatmet"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Flexibilität & Mobility",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Meditation (Lotus) Strategy
class MeditationProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseMin = isBeginner ? 5 : (isIntermediate ? 10 : 20)
        let currentMin = baseMin + (phaseNumber - 1)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Atem-Fokus"
            desc = "Der absolute Basic-Anker. Beobachte deinen Atem an der Nasenspitze oder im Bauchraum. Wenn du abschweifst, kehre sanft zurück."
            todos = ["\(currentMin) Min Atem-Fokus", "Jedes Mal sanft zurückgekehrt"]
        case 2:
            title = "Dienstag: Body Scan"
            desc = "Gehe gedanklich von den Zehen bis zum Scheitel durch deinen Körper. Fühle Spannungen und lasse sie los."
            todos = ["\(currentMin) Min Body Scan", "Eine Spannung im Körper gelöst"]
        case 3:
            title = "Mittwoch: Gefühle benennen (Labeling)"
            desc = "Sobald ein Gedanke oder Gefühl auftaucht, gib ihm ein stilles Etikett (z.B. 'Planen', 'Sorgen', 'Freude') und lass es ziehen."
            todos = ["\(currentMin) Min Labeling", "3 verschiedene Emotionen/Gedanken benannt"]
        case 4:
            title = "Donnerstag: Loving-Kindness (Metta)"
            desc = "Wünsche dir selbst, einem geliebten Menschen und jemandem, den du schwer erträgst, still 'Mögest du glücklich sein'."
            todos = ["\(currentMin) Min Loving-Kindness", "Echtes Mitgefühl für 3 Personen empfunden"]
        case 5:
            title = "Freitag: Geräusche & Offenheit"
            desc = "Öffne deine Wahrnehmung. Fixiere dich nicht auf den Atem, sondern lausche den Geräuschen im Raum, ohne sie zu bewerten."
            todos = ["\(currentMin) Min Open Awareness", "Geräusche als reine Schwingung wahrgenommen"]
        case 6:
            title = "Samstag: Visualisierung"
            desc = "Stelle dir vor, wie mit jedem Einatmen helles Licht in dich strömt und mit dem Ausatmen dunkler Rauch (Stress) entweicht."
            todos = ["\(currentMin) Min Visualisierung", "Den Körper als Lichtkugel visualisiert"]
        case 7:
            title = "Sonntag: Stille (Ungeführt)"
            desc = "Heute gibt es keine Technik. Sitze einfach. Sei präsent mit dem, was ist. Absolute Stille."
            todos = ["\(currentMin) Min reine Stille", "Die Langeweile/Unruhe akzeptiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Geistige Klarheit & Fokus",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Dankbarkeit (Klee) Strategy
class GratitudeProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let targetCount = isBeginner ? 3 : (isIntermediate ? 5 : 7)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Die kleinen Dinge"
            desc = "Notiere heute Dinge, die absolut alltäglich sind, die du aber oft für selbstverständlich hältst (z.B. fließend warmes Wasser)."
            todos = ["\(targetCount) kleine Alltagsdinge notiert", "Bewusst beim Schreiben gefühlt"]
        case 2:
            title = "Dienstag: Menschen in deinem Leben"
            desc = "Für wen bist du heute dankbar? Ein Freund, Kollege oder die Kassiererin, die gelächelt hat?"
            todos = ["\(targetCount) Personen oder Interaktionen aufgeschrieben", "Einer Person eventuell sogar 'Danke' gesagt"]
        case 3:
            title = "Mittwoch: Persönliche Stärken"
            desc = "Sei dankbar für dich selbst. Welche Fähigkeit oder Eigenschaft hat dir heute oder in der Vergangenheit geholfen?"
            todos = ["\(targetCount) eigene Stärken notiert", "Stolz empfunden"]
        case 4:
            title = "Donnerstag: Negative Visualisierung"
            desc = "Stell dir vor, etwas Wertvolles in deinem Leben wäre nicht da. Wie wäre das? Sei dankbar, dass es da ist."
            todos = ["\(targetCount) Dinge notiert, ohne die dein Leben viel schwerer wäre"]
        case 5:
            title = "Freitag: Vergangene Herausforderungen"
            desc = "Welcher Rückschlag aus der Vergangenheit hat dich am Ende stärker gemacht? Finde den Silberstreifen."
            todos = ["\(targetCount) gelernte Lektionen aus Fehlern notiert"]
        case 6:
            title = "Samstag: Der eigene Körper"
            desc = "Egal ob er wehtut oder perfekt funktioniert: Dein Körper hält dich am Leben. Wofür dankst du ihm heute?"
            todos = ["\(targetCount) physische Fähigkeiten notiert (Sehen, Gehen, Atmen)"]
        case 7:
            title = "Sonntag: Die Natur & Umgebung"
            desc = "Gibt es einen Baum, das Wetter oder einen schönen Raum, der dir heute Ruhe geschenkt hat?"
            todos = ["\(targetCount) Elemente deiner Umgebung notiert", "Tief durchgeatmet und gelächelt"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Positiver Fokus",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Breathwork (Mystic Seed) Strategy
class BreathworkProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseMin = isBeginner ? 3 : (isIntermediate ? 6 : 10)
        let currentMin = baseMin + (phaseNumber / 2)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Box Breathing"
            desc = "4 Sekunden ein, 4 Sekunden halten, 4 Sekunden aus, 4 Sekunden halten. Ideal für Fokus und Stressabbau."
            todos = ["\(currentMin) Min Box Breathing", "Puls bewusst gesenkt"]
        case 2:
            title = "Dienstag: 4-7-8 Atmung"
            desc = "4s ein, 7s halten, 8s ausatmen. Stark parasympathisch, ideal zum Herunterfahren."
            todos = ["\(currentMin) Min 4-7-8 Atmung", "Volle Ausatmung erzwungen"]
        case 3:
            title = "Mittwoch: Physiological Sigh"
            desc = "Zwei kurze Einatmungen durch die Nase, ein langer Seufzer durch den Mund. Der schnellste Weg, um Cortisol zu senken."
            todos = ["10x Physiological Sigh (Doppel-Einatmen)", "Danach \(currentMin) Min ruhige Nasenatmung"]
        case 4:
            title = "Donnerstag: Wim Hof (Light)"
            desc = "30 tiefe, schnelle Atemzüge, gefolgt von Luft anhalten. Danach tief einatmen und halten. (Sicher sitzen/liegen!)"
            let rounds = isBeginner ? 2 : 3
            todos = ["\(rounds) Runden Power-Breathing", "Luft in der Leere gehalten", "Energieschub gespürt"]
        case 5:
            title = "Freitag: Alternate Nostril Breathing"
            desc = "Nadi Shodhana. Abwechselnd durch das linke und rechte Nasenloch atmen. Balanciert die Gehirnhälften."
            todos = ["\(currentMin) Min Wechselatmung", "Auf absolute Stille beim Atmen geachtet"]
        case 6:
            title = "Samstag: Diaphragmatische Atmung"
            desc = "Lege ein Buch auf den Bauch. Beim Einatmen muss es sich heben. Die Brust bewegt sich fast gar nicht."
            todos = ["\(currentMin) Min strikte Bauchatmung"]
        case 7:
            title = "Sonntag: CO2-Toleranz"
            desc = "Atme normal ein, und atme dann so langsam wie nur irgendwie möglich aus (Pursed Lips). Zögere den nächsten Atemzug hinaus."
            todos = ["\(currentMin) Min extrem verlängerte Ausatmung", "Gegen den Lufthunger entspannt"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Kontrolle des Nervensystems",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Water (Zitronenbaum) Strategy
class WaterProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseValue = isBeginner ? 1.5 : (isIntermediate ? 2.0 : 3.0)
        let targetValue = baseValue + (Double(phaseNumber - 1) * 0.1)
        let formattedValue = String(format: "%.1f", targetValue).replacingOccurrences(of: ".", with: ",")
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Morning Flush"
            desc = "Direkt nach dem Aufstehen hat dein Körper über Nacht dehydriert. Trinke ein großes Glas (ca. 400-500ml) Wasser direkt nach dem Wachwerden."
            todos = ["500ml direkt nach dem Aufstehen getrunken", "Tagesziel: \(formattedValue) L erreicht"]
        case 2:
            title = "Dienstag: Fokus auf die erste Tageshälfte"
            desc = "Versuche, mindestens 60% deines Wasserbedarfs vor 14 Uhr zu decken. Das verhindert abendliches Trinken und nächtliche Klobesuche."
            todos = ["60% vor 14:00 Uhr getrunken", "Tagesziel: \(formattedValue) L erreicht"]
        case 3:
            title = "Mittwoch: Elektrolyte"
            desc = "Reines Wasser spült oft Mineralien aus. Gib heute eine Prise gutes Salz (Meer- oder Ursalz) in eine deiner Flaschen."
            todos = ["Prise Salz ins Wasser gegeben", "Tagesziel: \(formattedValue) L erreicht"]
        case 4:
            title = "Donnerstag: Vor den Mahlzeiten"
            desc = "Trinke 30 Minuten vor jedem großen Essen ein Glas Wasser. Das hilft der Verdauung und dem Sättigungsgefühl."
            todos = ["Glas Wasser vor jeder Mahlzeit", "Tagesziel: \(formattedValue) L erreicht"]
        case 5:
            title = "Freitag: Visualisierung"
            desc = "Stelle dir deine gesamte Tagesration morgens sichtbar an den Arbeitsplatz oder in die Küche."
            todos = ["Tagesration morgens sichtbar platziert", "Tagesziel: \(formattedValue) L erreicht"]
        case 6:
            title = "Samstag: Tee-Integration"
            desc = "Ungesüßter Kräutertee zählt als Wasser. Baue heute eine Kanne Tee in deine Hydration ein."
            todos = ["Kräutertee als Teil der Ration genutzt", "Tagesziel: \(formattedValue) L erreicht"]
        case 7:
            title = "Sonntag: Tracking-Check"
            desc = "Lief die Woche gut? Achte heute besonders darauf, dass du trotz Wochenende und fehlendem Büro-Alltag auf deine Menge kommst."
            todos = ["Tagesziel: \(formattedValue) L erreicht", "Trinkverhalten der Woche reflektiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Zelluläre Hydration",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Fruits/Veggies (Erdbeerpflanze) Strategy
class NutritionProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let targetCount = isBeginner ? 1 : (isIntermediate ? 3 : 5)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Grüner Start"
            desc = "Integriere heute zwingend etwas Grünes (Spinat, Brokkoli, Gurke, Salat) in eine deiner Mahlzeiten."
            todos = ["\(targetCount) Portionen Gemüse/Obst gegessen", "Eine grüne Portion eingebaut"]
        case 2:
            title = "Dienstag: Snack-Tausch"
            desc = "Ersetze einen üblichen ungesunden Snack durch einen Apfel, Beeren oder Gemüsesticks."
            todos = ["\(targetCount) Portionen erreicht", "Snack durch Obst/Gemüse ersetzt"]
        case 3:
            title = "Mittwoch: Eat the Rainbow"
            desc = "Versuche heute drei verschiedene Farben auf deinem Teller oder über den Tag verteilt zu essen (z.B. rot, grün, orange)."
            todos = ["\(targetCount) Portionen erreicht", "Mindestens 3 verschiedene Farben gegessen"]
        case 4:
            title = "Donnerstag: Rohkost"
            desc = "Verzehre mindestens eine Portion komplett roh, um alle hitzeempfindlichen Vitamine zu bewahren."
            todos = ["\(targetCount) Portionen erreicht", "Eine Portion zu 100% roh gegessen"]
        case 5:
            title = "Freitag: Neues entdecken"
            desc = "Iss heute ein Gemüse oder Obst, das du schon sehr lange nicht mehr oder noch nie gegessen hast."
            todos = ["\(targetCount) Portionen erreicht", "Neues/seltenes Obst/Gemüse probiert"]
        case 6:
            title = "Samstag: Smoothie oder Suppe"
            desc = "Püriere deine Nährstoffe heute. Mach dir einen großen Smoothie oder eine Gemüsesuppe."
            todos = ["\(targetCount) Portionen erreicht", "Eine flüssige/pürierte Mahlzeit eingebaut"]
        case 7:
            title = "Sonntag: Meal-Prep Vorbereitung"
            desc = "Wasche und schneide schon heute Gemüse für die kommenden Tage vor (z.B. Paprika in Dosen in den Kühlschrank)."
            todos = ["\(targetCount) Portionen erreicht", "Gemüse für Montag vorbereitet"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Mikronährstoffe & Vitalität",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Cold Shower (Kaktus) Strategy
class ColdShowerProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseSec = isBeginner ? 10 : (isIntermediate ? 30 : 60)
        let currentSec = baseSec + (phaseNumber * 5)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Atem-Fokus"
            desc = "Der Moment, in dem das Wasser dich trifft, löst einen Schnapp-Reflex aus. Kontrolliere sofort die Ausatmung."
            todos = ["\(currentSec) Sekunden kalt geduscht", "Ausatmung bewusst verlangsamt"]
        case 2:
            title = "Dienstag: Nacken & Rücken"
            desc = "Lass das kalte Wasser heute bewusst über den Nacken und zwischen die Schulterblätter laufen (aktiviert braunes Fettgewebe)."
            todos = ["\(currentSec) Sekunden kalt geduscht", "Kaltes Wasser auf den Nacken fokussiert"]
        case 3:
            title = "Mittwoch: Gesicht & Kopf"
            desc = "Wasche dir das Gesicht zuerst mit kaltem Wasser und lass es dann über den ganzen Kopf laufen (stimuliert den Vagusnerv stark)."
            todos = ["\(currentSec) Sekunden kalt geduscht", "Kopf komplett unter Wasser gehabt"]
        case 4:
            title = "Donnerstag: Extremitäten zuerst"
            desc = "Beginne an den Füßen und Händen und wandere langsam Richtung Herzmuskel."
            todos = ["\(currentSec) Sekunden kalt geduscht", "An Beinen/Armen gestartet"]
        case 5:
            title = "Freitag: Der Mindset-Shift"
            desc = "Versuche heute nicht die Sekunden zu zählen, sondern entspanne deine Muskeln aktiv, während du frierst. Kein Zittern, kein Anspannen."
            todos = ["\(currentSec) Sekunden kalt geduscht", "Muskeln während der Kälte komplett entspannt"]
        case 6:
            title = "Samstag: Kontrast-Dusche"
            desc = "Dusche heiß, dann wechsle abrupt auf eiskalt. Spüre, wie das Blut in den Kern schießt."
            todos = ["Kontrastdusche (heiß zu kalt) durchgeführt", "Zuletzt \(currentSec) Sekunden eiskalt geblieben"]
        case 7:
            title = "Sonntag: Pure Kälte"
            desc = "Drehe nicht erst warm auf. Gehe direkt ins eiskalte Wasser. Die ultimative mentale Hürde."
            todos = ["Ohne vorher heiß zu duschen ins Kalte gegangen", "\(currentSec) Sekunden durchgehalten"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Resilienz & Dopamin",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Teeth (Minzpflanze) Strategy
class TeethProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Fokus Zahnseide"
            desc = "Zahnseide ist wichtiger als das Putzen der Kauflächen. Reinige heute jeden einzelnen Zahnzwischenraum penibel."
            todos = ["2 Min morgens & abends geputzt", "Jeden Zwischenraum mit Zahnseide gereinigt"]
        case 2:
            title = "Dienstag: Zungenreinigung"
            desc = "Nutze einen Zungenkratzer (oder zur Not den Löffel), um Bakterienbelag am Morgen vor dem ersten Glas Wasser zu entfernen."
            todos = ["2 Min morgens & abends geputzt", "Zunge am Morgen abgezogen"]
        case 3:
            title = "Mittwoch: Sanfter Druck"
            desc = "Wir putzen oft zu hart. Achte heute darauf, die Zahnbürste nur sehr leicht aufzudrücken, um den Schmelz und das Zahnfleisch zu schonen."
            todos = ["2 Min morgens & abends geputzt", "Bewusst auf leichten Druck geachtet"]
        case 4:
            title = "Donnerstag: Die Innenseiten"
            desc = "Die Innenseiten der Unterkiefer-Schneidezähne verkalken am schnellsten. Fokussiere dich heute besonders auf diese Stellen."
            todos = ["2 Min morgens & abends geputzt", "Fokus auf die Zahn-Innenseiten"]
        case 5:
            title = "Freitag: Mundspülung vermeiden"
            desc = "Spüle Zahnpasta am Ende NICHT mit Wasser aus. Spucke nur aus. Das Fluorid muss einwirken!"
            todos = ["2 Min morgens & abends geputzt", "Nach dem Putzen nicht ausgespült"]
        case 6:
            title = "Samstag: Interdental-Bürsten"
            desc = "Falls vorhanden, nutze Interdentalbürstchen für die größeren Lücken hinten. Dort kommt Zahnseide oft nicht richtig hin."
            todos = ["2 Min morgens & abends geputzt", "Interdentalbürsten oder Zahnseide genutzt"]
        case 7:
            title = "Sonntag: Check-up Routine"
            desc = "Inspiziere dein Zahnfleisch im Spiegel. Sieht es rosa und gesund aus oder gibt es rötliche, blutende Stellen?"
            todos = ["2 Min morgens & abends geputzt", "Zahnfleisch-Check durchgeführt"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Dentale Langlebigkeit",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - No Alcohol (Weinrebe) Strategy
class NoAlcoholProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Trigger identifizieren"
            desc = "Achte heute darauf, in welchen Momenten du normalerweise ans Trinken denkst (Stress, Feierabend, Belohnung)."
            todos = ["Keinen Alkohol getrunken", "Einen potenziellen Trigger erkannt"]
        case 2:
            title = "Dienstag: Das Ersatzgetränk"
            desc = "Finde ein Premium-Ersatzgetränk. Kombucha, alkoholfreies IPA oder ein Mocktail. Es muss sich nach 'Feierabend' anfühlen."
            todos = ["Keinen Alkohol getrunken", "Hochwertiges Ersatzgetränk genossen"]
        case 3:
            title = "Mittwoch: Craving Surfing"
            desc = "Sollte Verlangen aufkommen: Kämpfe nicht dagegen an. Beobachte das Gefühl wie eine Welle, die ansteigt und wieder bricht."
            todos = ["Keinen Alkohol getrunken", "Einen Impuls vorbeiziehen lassen"]
        case 4:
            title = "Donnerstag: Schlaf-Fokus"
            desc = "Alkohol zerstört den REM-Schlaf. Achte heute Nacht bewusst auf deine Traumphasen und wie erholt du aufwachst."
            todos = ["Keinen Alkohol getrunken", "Dankbarkeit für klaren Schlaf empfunden"]
        case 5:
            title = "Freitag: Socializing Challenge"
            desc = "Das Wochenende beginnt. Wenn du unter Leute gehst, sei die Person, die sich als Erstes selbstbewusst ein Wasser oder AF-Bier bestellt."
            todos = ["Keinen Alkohol getrunken", "Souverän 'Nein' gesagt"]
        case 6:
            title = "Samstag: Der Kater-freie Morgen"
            desc = "Nutze die Energie. Anstatt den halben Samstag im Bett zu liegen, mach etwas Produktives oder Sport."
            todos = ["Keinen Alkohol getrunken", "Die extra Energie am Morgen genutzt"]
        case 7:
            title = "Sonntag: Stolz & Reflektion"
            desc = "Du hast eine ganze Woche geschafft. Wie fühlst du dich physisch und mental im Vergleich zu vor der Challenge?"
            todos = ["Keinen Alkohol getrunken", "Woche stolz reflektiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Physische & Mentale Klarheit",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Healthy Cooking (Apfelbaum) Strategy
class CookingProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Protein-Fokus"
            desc = "Achte heute bei deiner Hauptmahlzeit darauf, dass sie eine adäquate Menge an Protein (20-40g) enthält."
            todos = ["Mahlzeit selbst zubereitet", "Fokus auf hohen Proteingehalt"]
        case 2:
            title = "Dienstag: Kein versteckter Zucker"
            desc = "Lass alle fertigen Saucen (Ketchup, BBQ, Fertigdressing) weg. Mach dein Dressing selbst aus Olivenöl und Essig/Zitrone."
            todos = ["Mahlzeit selbst zubereitet", "Komplett auf Zuckerzusätze verzichtet"]
        case 3:
            title = "Mittwoch: Ballaststoff-Bombe"
            desc = "Integriere heute Hülsenfrüchte (Bohnen, Linsen) oder Haferflocken, um deine Darmbakterien zu füttern."
            todos = ["Mahlzeit selbst zubereitet", "Extra Ballaststoffe eingebaut"]
        case 4:
            title = "Donnerstag: Healthy Fats"
            desc = "Vermeide Rapsöl oder Sonnenblumenöl zum Braten. Nutze Olivenöl, Butter, Ghee oder Kokosöl. Füge Nüsse/Avocado hinzu."
            todos = ["Mahlzeit selbst zubereitet", "Nur hochwertige Fette genutzt"]
        case 5:
            title = "Freitag: Neues Rezept"
            desc = "Koche etwas, das du noch nie zubereitet hast. Such dir ein gesundes Rezept im Internet und folge ihm."
            todos = ["Mahlzeit selbst zubereitet", "Ein neues Rezept ausprobiert"]
        case 6:
            title = "Samstag: Zero Processed Foods"
            desc = "Nutze heute absolut keine Lebensmittel, die mehr als 3 Zutaten auf der Verpackung stehen haben."
            todos = ["Mahlzeit selbst zubereitet", "Nur Whole-Foods (unverarbeitet) verwendet"]
        case 7:
            title = "Sonntag: Meal Prep"
            desc = "Koche heute die doppelte oder dreifache Menge, damit du Montag und Dienstag direkt Tupperdosen für die Arbeit/Uni hast."
            todos = ["Mahlzeit selbst zubereitet", "Mehrere Portionen für die Woche vorgekocht"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Ernährung & Zell-Treibstoff",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Deep Work (Weizenfeld) Strategy
class DeepWorkProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseMin = isBeginner ? 30 : (isIntermediate ? 60 : 90)
        let currentMin = baseMin + (phaseNumber * 5)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Eat the Frog"
            desc = "Erledige die absolut wichtigste und schwerste Aufgabe des Tages direkt in deiner ersten Deep Work Session. Schiebe nichts auf."
            todos = ["\(currentMin) Min Deep Work absolviert", "Schwerste Aufgabe zuerst erledigt"]
        case 2:
            title = "Dienstag: Zero Notifications"
            desc = "Schalte dein Handy in den Flugmodus und schließe alle Mail/Chat-Programme auf dem Desktop. Volle Isolation."
            todos = ["\(currentMin) Min Deep Work absolviert", "Alle Notifications strikt deaktiviert"]
        case 3:
            title = "Mittwoch: Pomodoro-Taktung"
            desc = "Unterteile deine Session in 25-Minuten-Blöcke (Fokus) und 5-Minuten-Pausen (Aufstehen, Augen vom Bildschirm weg)."
            todos = ["\(currentMin) Min Deep Work absolviert", "Pomodoro-Technik sauber angewandt"]
        case 4:
            title = "Donnerstag: Klare Zielsetzung"
            desc = "Schreibe VOR dem Starten des Timers exakt auf, welches Outcome du in dieser Session erreichen willst. Keine ungerichtete Arbeit."
            todos = ["\(currentMin) Min Deep Work absolviert", "Spezifisches Ziel vorher definiert und erreicht"]
        case 5:
            title = "Freitag: Der aufgeräumte Schreibtisch"
            desc = "Räume vor dem Arbeiten physisch deinen Tisch auf. Visuelle Unordnung frisst unbewusst kognitive Kapazität."
            todos = ["\(currentMin) Min Deep Work absolviert", "Schreibtisch vor Beginn komplett gecleant"]
        case 6:
            title = "Samstag: Deep Learning"
            desc = "Nutze den Deep Work Slot am Wochenende nicht für Arbeit, sondern um dir ungestört eine neue, komplexe Fähigkeit anzueignen (Buch, Kurs)."
            todos = ["\(currentMin) Min Deep Learning", "Neues Wissen erarbeitet statt Abarbeiten"]
        case 7:
            title = "Sonntag: Planung & Erholung"
            desc = "Keine harte kognitive Arbeit heute. Setze dich 15 Minuten hin und plane die Deep Work Slots für die kommende Woche in deinen Kalender ein."
            todos = ["Deep Work Kalender für nächste Woche geblockt"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Laserfokus & Produktivität",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Cleaning/Tidying (Chrysantheme) Strategy
class CleaningProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseMin = isBeginner ? 5 : (isIntermediate ? 15 : 30)
        let currentMin = baseMin + (phaseNumber - 1)
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Küche & Spüle"
            desc = "Eine saubere Küche ist das Herzstück. Gehe niemals mit dreckigem Geschirr in der Spüle ins Bett."
            todos = ["\(currentMin) Min aufgeräumt", "Spüle komplett leer und sauber"]
        case 2:
            title = "Dienstag: Bodenfreiheit"
            desc = "Räume alles vom Boden auf, was dort nicht hingehört (Kleidung, Schuhe, Taschen). Der Raum wirkt sofort größer."
            todos = ["\(currentMin) Min aufgeräumt", "Alle Böden komplett freigeräumt"]
        case 3:
            title = "Mittwoch: Hotspot-Tackling"
            desc = "Jeder hat diesen einen Stuhl oder Tisch, auf dem sich alles sammelt. Nimm dir heute diesen Hotspot vor."
            todos = ["\(currentMin) Min aufgeräumt", "Deinen größten Chaos-Hotspot bereinigt"]
        case 4:
            title = "Donnerstag: Trash & Recycle"
            desc = "Geh durch alle Räume: Mülleimer leeren, Pfandflaschen zusammenstellen, Papiermüll entsorgen."
            todos = ["\(currentMin) Min aufgeräumt", "Allen Müll aus der Wohnung entfernt"]
        case 5:
            title = "Freitag: Declutter (Entmisten)"
            desc = "Finde heute 3 Dinge in deiner Wohnung, die du nicht mehr brauchst. Wegwerfen, spenden oder verkaufen."
            todos = ["\(currentMin) Min aufgeräumt", "Mindestens 3 Gegenstände aussortiert"]
        case 6:
            title = "Samstag: Das Bett & Schlafzimmer"
            desc = "Wasche deine Bettwäsche oder beziehe das Bett neu. Ein frisches Bett verbessert die Schlafqualität enorm."
            todos = ["\(currentMin) Min aufgeräumt", "Schlafzimmer in eine Oase verwandelt"]
        case 7:
            title = "Sonntag: Sunday Reset"
            desc = "Die 10-Minuten-Runde durch die ganze Wohnung. Bring alles dorthin zurück, wo es eigentlich wohnt. Bereite den Raum für die neue Woche vor."
            todos = ["\(currentMin) Min Sunday Reset", "Mit einem guten Gefühl in die Woche starten"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Ordnung im Außen = Ruhe im Innen",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Saving Money (Mandelbaum) Strategy
class SavingProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        let isBeginner = difficulty.lowercased() == "anfaenger"
        let isIntermediate = difficulty.lowercased() == "fortgeschritten"
        
        let baseEur = isBeginner ? 1.0 : (isIntermediate ? 5.0 : 10.0)
        let currentEur = baseEur + (Double(phaseNumber - 1) * 0.5)
        let formattedValue = String(format: "%.2f", currentEur).replacingOccurrences(of: ".", with: ",")
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Pay Yourself First"
            desc = "Lege den heutigen Betrag physisch oder per Dauerauftrag beiseite. Behandle diese Einzahlung wie eine feste Rechnung."
            todos = ["\(formattedValue) € beiseite gelegt", "Geld mental als 'ausgegeben' verbucht"]
        case 2:
            title = "Dienstag: Ausgaben tracken"
            desc = "Schreibe heute (und generell) absolut jeden Cent auf, den du ausgibst. Bewusstsein ist der erste Schritt zur Kontrolle."
            todos = ["\(formattedValue) € beiseite gelegt", "Alle heutigen Ausgaben notiert"]
        case 3:
            title = "Mittwoch: No-Spend-Day"
            desc = "Gib heute keinen einzigen Cent aus (Fixkosten ausgenommen). Kein Coffee-to-go, kein Bäcker, kein Online-Shopping."
            todos = ["\(formattedValue) € beiseite gelegt", "Erfolgreicher No-Spend-Day"]
        case 4:
            title = "Donnerstag: Die 72-Stunden-Regel"
            desc = "Wenn du online etwas siehst, das du kaufen willst: Pack es in den Warenkorb, aber warte 72 Stunden. Meistens verfliegt der Drang."
            todos = ["\(formattedValue) € beiseite gelegt", "Impulskäufen widerstanden"]
        case 5:
            title = "Freitag: Abo-Check"
            desc = "Schau dir deine Kontoauszüge an. Gibt es ein Abo (Netflix, Gym, App), das du nicht nutzt? Kündige es HEUTE."
            todos = ["\(formattedValue) € beiseite gelegt", "Abos auf Sinnhaftigkeit geprüft"]
        case 6:
            title = "Samstag: Essen von Zuhause"
            desc = "Am Wochenende gibt man am meisten für Essen aus. Koche heute selbst oder lade Freunde zu dir ein, statt teuer auszugehen."
            todos = ["\(formattedValue) € beiseite gelegt", "Gastro-Kosten gespart"]
        case 7:
            title = "Sonntag: Finanz-Review"
            desc = "Blicke auf die Woche zurück. Wo hast du sinnlos Geld verbrannt? Wo warst du diszipliniert?"
            todos = ["\(formattedValue) € beiseite gelegt", "Ausgaben der Woche ehrlich reflektiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Finanzielle Freiheit",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Selfcare (Kirschbaum) Strategy
class SelfcareProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Physische Pflege"
            desc = "Nimm dir heute extra Zeit für deinen Körper. Eine Gesichtsmaske, ein Peeling oder Eincremen mit bewusster Aufmerksamkeit."
            todos = ["Physische Selfcare betrieben", "Dich in deiner Haut wohlgefühlt"]
        case 2:
            title = "Dienstag: Das Wort 'Nein'"
            desc = "Selfcare bedeutet Grenzen zu setzen. Sage heute bewusst 'Nein' zu einer Anfrage, einem Gefallen oder einer Aufgabe, die dich auslaugt."
            todos = ["Erfolgreich 'Nein' gesagt", "Eigene Ressourcen geschützt"]
        case 3:
            title = "Mittwoch: Digitaler Detox"
            desc = "Gehe eine Stunde vor dem Schlafengehen offline. Kein Social Media, keine Nachrichten. Nur ein Buch oder Stille."
            todos = ["Abendlichen Digital Detox durchgeführt"]
        case 4:
            title = "Donnerstag: Solitary Walk"
            desc = "Geh 20 Minuten spazieren. Ohne Musik, ohne Podcast, ohne Begleitung. Nur du und deine Gedanken."
            todos = ["20 Min Walk ohne Input", "Gedanken fließen gelassen"]
        case 5:
            title = "Freitag: Das innere Kind"
            desc = "Mach heute etwas, das absolut keinen produktiven Zweck hat, dir aber als Kind Freude bereitet hat (Malen, Gaming, Legos, in die Badewanne gehen)."
            todos = ["Etwas rein für die Freude getan", "Leistungsdruck losgelassen"]
        case 6:
            title = "Samstag: Social Batterie laden"
            desc = "Triff dich mit einer Person, die dir Energie gibt (Energiespender) und halte Abstand von Menschen, die nur meckern (Energiesauger)."
            todos = ["Mit positiven Menschen umgeben"]
        case 7:
            title = "Sonntag: Weekly Review"
            desc = "Schreib drei Dinge auf, die du diese Woche an dir selbst gut fandest. Kein Eigenlob ist heute übertrieben."
            todos = ["3 Dinge notiert, auf die du stolz bist", "Woche positiv abgeschlossen"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Mentaler Schutzschild",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Screen Time (Aloe Vera) Strategy
class ScreentimeProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: App-Limits Respektieren"
            desc = "Wenn der Timer im Handy heute abläuft, klicke NICHT auf '15 Minuten ignorieren'. Die App bleibt zu."
            todos = ["Bildschirmzeit-Limit eingehalten", "Kein Limit ignoriert"]
        case 2:
            title = "Dienstag: Graustufen-Modus"
            desc = "Stelle dein Handy-Display heute in den Einstellungen komplett auf Schwarz-Weiß. Beobachte, wie der Dopamin-Drang sinkst."
            todos = ["Bildschirmzeit-Limit eingehalten", "Graustufen-Modus aktiviert"]
        case 3:
            title = "Mittwoch: Kein Screen beim Essen"
            desc = "Kein YouTube, kein TikTok, kein TV während deiner Mahlzeiten. Kau und schmecke dein Essen."
            todos = ["Bildschirmzeit-Limit eingehalten", "Alle Mahlzeiten offline eingenommen"]
        case 4:
            title = "Donnerstag: Das blinde Badezimmer"
            desc = "Das Handy bleibt draußen, wenn du aufs Klo gehst oder duschst. Das Badezimmer ist eine No-Phone-Zone."
            todos = ["Bildschirmzeit-Limit eingehalten", "Handy nicht mit ins Bad genommen"]
        case 5:
            title = "Freitag: Notification-Purge"
            desc = "Schalte heute die Benachrichtigungen für alle Social-Media- und Shopping-Apps dauerhaft aus. Nur echte Menschen dürfen piepen."
            todos = ["Bildschirmzeit-Limit eingehalten", "Sinnlose Notifications deaktiviert"]
        case 6:
            title = "Samstag: Der Wecker-Trick"
            desc = "Lade dein Handy heute Nacht nicht neben dem Bett, sondern in einem anderen Raum oder auf der anderen Seite des Zimmers."
            todos = ["Bildschirmzeit-Limit eingehalten", "Handy weit weg vom Bett platziert"]
        case 7:
            title = "Sonntag: Screentime Report"
            desc = "Schau dir deine Wochenstatistik an. Wo hast du die meiste Zeit verbrannt? Wo lief es besser?"
            todos = ["Bildschirmzeit-Limit eingehalten", "Statistik ehrlich analysiert"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Dopamin-Kontrolle",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Sleep Routine (Lavendel) Strategy
class SleepProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Fixe Zielzeit"
            desc = "Gehe heute auf die Minute genau zu deiner vorgenommenen Zeit ins Bett. Konsistenz richtet den circadianen Rhythmus aus."
            todos = ["Exakt zur Zielzeit im Bett gewesen"]
        case 2:
            title = "Dienstag: Temperatur-Drop"
            desc = "Lüfte das Schlafzimmer durch. Der Körper muss zum Einschlafen an Kerntemperatur verlieren. Es sollte kühl sein (16-18°C)."
            todos = ["Zur Zielzeit im Bett", "Kühle Raumtemperatur sichergestellt"]
        case 3:
            title = "Mittwoch: Koffein-Cutoff"
            desc = "Trinke heute keinen Kaffee oder Energy-Drinks mehr nach 14:00 Uhr. Koffein hat eine Halbwertszeit von ca. 5 Stunden!"
            todos = ["Zur Zielzeit im Bett", "Koffein-Cutoff respektiert"]
        case 4:
            title = "Donnerstag: Blaulicht-Blocker"
            desc = "Schalte 60 Minuten vor dem Schlafen alle Deckenlichter aus (nutze warme Tischlampen) und aktiviere Night-Shift an Geräten."
            todos = ["Zur Zielzeit im Bett", "Lichtumgebung abends abgedunkelt"]
        case 5:
            title = "Freitag: Der Brain-Dump"
            desc = "Wenn der Kopf rattert: Lege dir Zettel und Stift ans Bett. Schreibe alle Gedanken und To-Dos für morgen auf, damit der Kopf leer ist."
            todos = ["Zur Zielzeit im Bett", "Gedanken vor dem Schlafen auf Papier entleert"]
        case 6:
            title = "Samstag: Kein schweres Essen"
            desc = "Iss deine letzte große Mahlzeit mindestens 3 Stunden vor dem Schlafengehen. Die Verdauung hindert dich am Tiefschlaf."
            todos = ["Zur Zielzeit im Bett", "Mit leichtem Magen schlafen gegangen"]
        case 7:
            title = "Sonntag: Die Entspannungs-Stunde"
            desc = "Lies ein Buch (Fiction, kein Business-Buch) oder höre ruhige Musik in der letzten Stunde vor dem Bett. Kein Screen."
            todos = ["Zur Zielzeit im Bett", "Offline-Entspannung vor dem Schlaf"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Regeneration & Tiefschlaf",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

// MARK: - Wake Up (Sonnenblume) Strategy
class WakeUpProgressionStrategy: HabitProgressionStrategy {
    func generateProgression(dayNum: Int, difficulty: String) -> ProgressionData {
        let phaseNumber = min(13, max(1, ((dayNum - 1) / 7) + 1))
        let cycleDay = ((dayNum - 1) % 7) + 1
        
        var title = ""
        var desc = ""
        var todos: [String] = []
        
        switch cycleDay {
        case 1:
            title = "Montag: Der Snooze-Bann"
            desc = "Snoozen fragmentiert den Schlaf und macht dich müder. Wenn der Wecker klingelt, stehen die Füße in 5 Sekunden auf dem Boden."
            todos = ["Beim 1. Weckerklingeln aufgestanden", "Snooze-Taste NICHT berührt"]
        case 2:
            title = "Dienstag: Wecker weit weg"
            desc = "Platziere das Handy/den Wecker so weit weg vom Bett, dass du physisch aufstehen MUSST, um ihn auszumachen."
            todos = ["Beim 1. Weckerklingeln aufgestanden", "Physisch aus dem Bett gezwungen"]
        case 3:
            title = "Mittwoch: Licht-Injektion"
            desc = "Mache sofort nach dem Aufstehen das Licht an oder öffne die Vorhänge. Helles Licht stoppt die Melatonin-Produktion schlagartig."
            todos = ["Beim 1. Weckerklingeln aufgestanden", "Sofort Licht ausgesetzt"]
        case 4:
            title = "Donnerstag: Wasser & Bewegung"
            desc = "Trinke sofort ein Glas Wasser und strecke dich für 2 Minuten. Aktiviere den Kreislauf, bevor das Gehirn Ausreden findet."
            todos = ["Beim 1. Weckerklingeln aufgestanden", "Kreislauf direkt hochgefahren"]
        case 5:
            title = "Freitag: Das Morgen-Warum"
            desc = "Warum stehst du so früh auf? Rufe dir dein wichtigstes Ziel des Tages in Erinnerung, noch während du die Decke zurückschlägst."
            todos = ["Beim 1. Weckerklingeln aufgestanden", "Tagesziel visualisiert"]
        case 6:
            title = "Samstag: Rhythmus halten"
            desc = "Versuche, auch am Wochenende maximal 30-60 Minuten von deiner unter der Woche gewohnten Aufstehzeit abzuweichen."
            todos = ["Zur Zielzeit (bzw. +30 Min) aufgestanden", "Wochenend-Jetlag vermieden"]
        case 7:
            title = "Sonntag: Die Belohnung"
            desc = "Genieße die Stille des frühen Sonntagmorgens. Mach dir einen guten Kaffee oder Tee, während der Rest der Welt noch schläft."
            todos = ["Zur Zielzeit aufgestanden", "Die morgendliche Stille genossen"]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: "Woche \(phaseNumber)",
            phaseDescription: "Der perfekte Start",
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

