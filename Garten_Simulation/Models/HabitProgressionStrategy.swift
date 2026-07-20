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
            phaseTitle: String(localized: "prog_strength_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
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
            title = String(localized: "prog_running_d1_title", defaultValue: "Recovery Run")
            desc = String(localized: "prog_running_d1_desc", defaultValue: "Ein sehr lockerer Lauf, um die Beine nach dem Wochenende durchzubewegen. Du solltest dabei entspannt durch die Nase atmen können.")
            let dist = max(1.0, currentDist * 0.5)
            todos = [String(localized: "prog_running_d1_t1", defaultValue: "\(String(format: ")%.1fString(localized: "prog_running_d1_t2", defaultValue: ", dist)) km locker laufen"), String(localized: "prog_running_d1_t3", defaultValue: "Bewusst durch die Nase atmen")]
        case 2:
            title = String(localized: "prog_running_d2_title", defaultValue: "Intervall-Training")
            desc = String(localized: "prog_running_d2_desc", defaultValue: "Fokus auf Geschwindigkeit und Herz-Kreislauf-Belastung. Kurze, harte Intervalle gefolgt von Geh-Pausen.")
            let intervals = isBeginner ? 4 : (isIntermediate ? 6 : 8)
            let sprintTime = isBeginner ? "30s" : "60s"
            todos = [String(localized: "prog_running_d2_t1", defaultValue: "10 Min Aufwärmen"), String(localized: "prog_running_d2_t2", defaultValue: "\(intervals)x \(sprintTime) Sprint / 1 Min Gehen"), String(localized: "prog_running_d2_t3", defaultValue: "10 Min Cool-down")]
        case 3:
            title = String(localized: "prog_running_d3_title", defaultValue: "Lauf-ABC & Core")
            desc = String(localized: "prog_running_d3_desc", defaultValue: "Heute arbeiten wir an der Lauftechnik und Rumpfstabilität, um Verletzungen vorzubeugen.")
            todos = [String(localized: "prog_running_d3_t1", defaultValue: "15 Min Lauf-ABC (Kniehebelauf, Anfersen)"), String(localized: "prog_running_d3_t2", defaultValue: "3x 45s Plank"), String(localized: "prog_running_d3_t3", defaultValue: "3x 15 Glute Bridges")]
        case 4:
            title = String(localized: "prog_running_d4_title", defaultValue: "Tempodauerlauf")
            desc = String(localized: "prog_running_d4_desc", defaultValue: "Ein Lauf in ambitioniertem, aber haltbarem Tempo (Zone 3). Es sollte anstrengend, aber kontrolliert sein.")
            let dist = currentDist * 0.75
            todos = [String(localized: "prog_running_d4_t1", defaultValue: "\(String(format: ")%.1fString(localized: "prog_running_d4_t2", defaultValue: ", dist)) km im zügigen Tempo")]
        case 5:
            title = String(localized: "prog_running_d5_title", defaultValue: "Aktive Erholung")
            desc = String(localized: "prog_running_d5_desc", defaultValue: "Die Muskeln brauchen Pause. Ein zügiger Spaziergang oder eine Dehn-Session reichen heute aus.")
            todos = [String(localized: "prog_running_d5_t1", defaultValue: "30 Min zügiges Spazieren"), String(localized: "prog_running_d5_t2", defaultValue: "Ausgiebiges Dehnen (Waden, Oberschenkel)")]
        case 6:
            title = String(localized: "prog_running_d6_title", defaultValue: "Long Run")
            desc = String(localized: "prog_running_d6_desc", defaultValue: "Der wichtigste Lauf der Woche für die Grundlagenausdauer. Das Tempo ist absolut zweitrangig.")
            let dist = currentDist * 1.5
            todos = [String(localized: "prog_running_d6_t1", defaultValue: "\(String(format: ")%.1fString(localized: "prog_running_d6_t2", defaultValue: ", dist)) km absolviert"), String(localized: "prog_running_d6_t3", defaultValue: "Tempo bewusst niedrig gehalten")]
        case 7:
            title = String(localized: "prog_running_d7_title", defaultValue: "Complete Rest")
            desc = String(localized: "prog_running_d7_desc", defaultValue: "Komplette Pause. Der Körper repariert das Gewebe und baut Muskeln auf.")
            todos = [String(localized: "prog_running_d7_t1", defaultValue: "Beine hochgelegt"), String(localized: "prog_running_d7_t2", defaultValue: "Ausreichend Protein konsumiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_running_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_running_phase_desc_ausdauer___kondition", defaultValue: "Ausdauer & Kondition"),
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
            title = String(localized: "prog_stretching_d1_title", defaultValue: "Hüftöffner")
            desc = String(localized: "prog_stretching_d1_desc", defaultValue: "Ein Fokus auf den Psoas und die Hüftbeuger, perfekt um das viele Sitzen auszugleichen.")
            todos = [String(localized: "prog_stretching_d1_t1", defaultValue: "\(currentMin) Min Fokus auf Hüfte"), String(localized: "prog_stretching_d1_t2", defaultValue: "Pigeon Pose 1 Min pro Seite"), String(localized: "prog_stretching_d1_t3", defaultValue: "Deep Squat Hold")]
        case 2:
            title = String(localized: "prog_stretching_d2_title", defaultValue: "Schulter & Nacken")
            desc = String(localized: "prog_stretching_d2_desc", defaultValue: "Verspannungen im oberen Rücken lösen.")
            todos = [String(localized: "prog_stretching_d2_t1", defaultValue: "\(currentMin) Min Fokus auf Schultern"), String(localized: "prog_stretching_d2_t2", defaultValue: "Chest Opener an der Wand"), String(localized: "prog_stretching_d2_t3", defaultValue: "Nacken sanft mobilisiert")]
        case 3:
            title = String(localized: "prog_stretching_d3_title", defaultValue: "Beinrückseite (Hamstrings)")
            desc = String(localized: "prog_stretching_d3_desc", defaultValue: "Ziel ist die Verlängerung der hinteren Kette. Wichtig: Nicht über den Schmerzpunkt hinausgehen!")
            todos = [String(localized: "prog_stretching_d3_t1", defaultValue: "\(currentMin) Min Fokus auf Beine"), String(localized: "prog_stretching_d3_t2", defaultValue: "Forward Fold (Vorbeuge)"), String(localized: "prog_stretching_d3_t3", defaultValue: "Downward Dog")]
        case 4:
            title = String(localized: "prog_stretching_d4_title", defaultValue: "Spinal Twists")
            desc = String(localized: "prog_stretching_d4_desc", defaultValue: "Rotationen für die Wirbelsäule, um Bandscheiben zu nähren und die Mobilität des Rumpfes zu verbessern.")
            todos = [String(localized: "prog_stretching_d4_t1", defaultValue: "\(currentMin) Min Fokus auf Wirbelsäule"), String(localized: "prog_stretching_d4_t2", defaultValue: "Liegende Rotation (Krokodil)"), String(localized: "prog_stretching_d4_t3", defaultValue: "Cat-Cow Mobilisation")]
        case 5:
            title = String(localized: "prog_stretching_d5_title", defaultValue: "Full Body Flow")
            desc = String(localized: "prog_stretching_d5_desc", defaultValue: "Eine Kombination aus allen Elementen dieser Woche in einem fließenden Ablauf.")
            todos = [String(localized: "prog_stretching_d5_t1", defaultValue: "\(currentMin) Min Full Body Flow"), String(localized: "prog_stretching_d5_t2", defaultValue: "Fließende Übergänge geübt")]
        case 6:
            title = String(localized: "prog_stretching_d6_title", defaultValue: "Animal Flow / Dynamisch")
            desc = String(localized: "prog_stretching_d6_desc", defaultValue: "Bringe Bewegung in deine Mobility-Routine. Keine statischen Holds, sondern dynamische Wechsel.")
            todos = [String(localized: "prog_stretching_d6_t1", defaultValue: "\(currentMin) Min dynamisches Dehnen"), String(localized: "prog_stretching_d6_t2", defaultValue: "Neue Mobilitäts-Position ausprobiert")]
        case 7:
            title = String(localized: "prog_stretching_d7_title", defaultValue: "Yin Yoga / Tiefe Entspannung")
            desc = String(localized: "prog_stretching_d7_desc", defaultValue: "Sehr langes Halten von wenigen Posen. Nutze Schwerkraft und Atmung, statt Muskelkraft.")
            todos = [String(localized: "prog_stretching_d7_t1", defaultValue: "\(currentMin) Min Yin-Stil (Pose 2+ Min halten)"), String(localized: "prog_stretching_d7_t2", defaultValue: "Tief in den Bauch geatmet")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_stretching_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_stretching_phase_desc_flexibilität___mobil", defaultValue: "Flexibilität & Mobility"),
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
            title = String(localized: "prog_meditation_d1_title", defaultValue: "Atem-Fokus")
            desc = String(localized: "prog_meditation_d1_desc", defaultValue: "Der absolute Basic-Anker. Beobachte deinen Atem an der Nasenspitze oder im Bauchraum. Wenn du abschweifst, kehre sanft zurück.")
            todos = [String(localized: "prog_meditation_d1_t1", defaultValue: "\(currentMin) Min Atem-Fokus"), String(localized: "prog_meditation_d1_t2", defaultValue: "Jedes Mal sanft zurückgekehrt")]
        case 2:
            title = String(localized: "prog_meditation_d2_title", defaultValue: "Body Scan")
            desc = String(localized: "prog_meditation_d2_desc", defaultValue: "Gehe gedanklich von den Zehen bis zum Scheitel durch deinen Körper. Fühle Spannungen und lasse sie los.")
            todos = [String(localized: "prog_meditation_d2_t1", defaultValue: "\(currentMin) Min Body Scan"), String(localized: "prog_meditation_d2_t2", defaultValue: "Eine Spannung im Körper gelöst")]
        case 3:
            title = String(localized: "prog_meditation_d3_title", defaultValue: "Gefühle benennen (Labeling)")
            desc = String(localized: "prog_meditation_d3_desc", defaultValue: "Sobald ein Gedanke oder Gefühl auftaucht, gib ihm ein stilles Etikett (z.B. 'Planen', 'Sorgen', 'Freude') und lass es ziehen.")
            todos = [String(localized: "prog_meditation_d3_t1", defaultValue: "\(currentMin) Min Labeling"), String(localized: "prog_meditation_d3_t2", defaultValue: "3 verschiedene Emotionen/Gedanken benannt")]
        case 4:
            title = String(localized: "prog_meditation_d4_title", defaultValue: "Loving-Kindness (Metta)")
            desc = String(localized: "prog_meditation_d4_desc", defaultValue: "Wünsche dir selbst, einem geliebten Menschen und jemandem, den du schwer erträgst, still 'Mögest du glücklich sein'.")
            todos = [String(localized: "prog_meditation_d4_t1", defaultValue: "\(currentMin) Min Loving-Kindness"), String(localized: "prog_meditation_d4_t2", defaultValue: "Echtes Mitgefühl für 3 Personen empfunden")]
        case 5:
            title = String(localized: "prog_meditation_d5_title", defaultValue: "Geräusche & Offenheit")
            desc = String(localized: "prog_meditation_d5_desc", defaultValue: "Öffne deine Wahrnehmung. Fixiere dich nicht auf den Atem, sondern lausche den Geräuschen im Raum, ohne sie zu bewerten.")
            todos = [String(localized: "prog_meditation_d5_t1", defaultValue: "\(currentMin) Min Open Awareness"), String(localized: "prog_meditation_d5_t2", defaultValue: "Geräusche als reine Schwingung wahrgenommen")]
        case 6:
            title = String(localized: "prog_meditation_d6_title", defaultValue: "Visualisierung")
            desc = String(localized: "prog_meditation_d6_desc", defaultValue: "Stelle dir vor, wie mit jedem Einatmen helles Licht in dich strömt und mit dem Ausatmen dunkler Rauch (Stress) entweicht.")
            todos = [String(localized: "prog_meditation_d6_t1", defaultValue: "\(currentMin) Min Visualisierung"), String(localized: "prog_meditation_d6_t2", defaultValue: "Den Körper als Lichtkugel visualisiert")]
        case 7:
            title = String(localized: "prog_meditation_d7_title", defaultValue: "Stille (Ungeführt)")
            desc = String(localized: "prog_meditation_d7_desc", defaultValue: "Heute gibt es keine Technik. Sitze einfach. Sei präsent mit dem, was ist. Absolute Stille.")
            todos = [String(localized: "prog_meditation_d7_t1", defaultValue: "\(currentMin) Min reine Stille"), String(localized: "prog_meditation_d7_t2", defaultValue: "Die Langeweile/Unruhe akzeptiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_meditation_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_meditation_phase_desc_geistige_klarheit___", defaultValue: "Geistige Klarheit & Fokus"),
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
            title = String(localized: "prog_gratitude_d1_title", defaultValue: "Die kleinen Dinge")
            desc = String(localized: "prog_gratitude_d1_desc", defaultValue: "Notiere heute Dinge, die absolut alltäglich sind, die du aber oft für selbstverständlich hältst (z.B. fließend warmes Wasser).")
            todos = [String(localized: "prog_gratitude_d1_t1", defaultValue: "\(targetCount) kleine Alltagsdinge notiert"), String(localized: "prog_gratitude_d1_t2", defaultValue: "Bewusst beim Schreiben gefühlt")]
        case 2:
            title = String(localized: "prog_gratitude_d2_title", defaultValue: "Menschen in deinem Leben")
            desc = String(localized: "prog_gratitude_d2_desc", defaultValue: "Für wen bist du heute dankbar? Ein Freund, Kollege oder die Kassiererin, die gelächelt hat?")
            todos = [String(localized: "prog_gratitude_d2_t1", defaultValue: "\(targetCount) Personen oder Interaktionen aufgeschrieben"), String(localized: "prog_gratitude_d2_t2", defaultValue: "Einer Person eventuell sogar 'Danke' gesagt")]
        case 3:
            title = String(localized: "prog_gratitude_d3_title", defaultValue: "Persönliche Stärken")
            desc = String(localized: "prog_gratitude_d3_desc", defaultValue: "Sei dankbar für dich selbst. Welche Fähigkeit oder Eigenschaft hat dir heute oder in der Vergangenheit geholfen?")
            todos = [String(localized: "prog_gratitude_d3_t1", defaultValue: "\(targetCount) eigene Stärken notiert"), String(localized: "prog_gratitude_d3_t2", defaultValue: "Stolz empfunden")]
        case 4:
            title = String(localized: "prog_gratitude_d4_title", defaultValue: "Negative Visualisierung")
            desc = String(localized: "prog_gratitude_d4_desc", defaultValue: "Stell dir vor, etwas Wertvolles in deinem Leben wäre nicht da. Wie wäre das? Sei dankbar, dass es da ist.")
            todos = [String(localized: "prog_gratitude_d4_t1", defaultValue: "\(targetCount) Dinge notiert, ohne die dein Leben viel schwerer wäre")]
        case 5:
            title = String(localized: "prog_gratitude_d5_title", defaultValue: "Vergangene Herausforderungen")
            desc = String(localized: "prog_gratitude_d5_desc", defaultValue: "Welcher Rückschlag aus der Vergangenheit hat dich am Ende stärker gemacht? Finde den Silberstreifen.")
            todos = [String(localized: "prog_gratitude_d5_t1", defaultValue: "\(targetCount) gelernte Lektionen aus Fehlern notiert")]
        case 6:
            title = String(localized: "prog_gratitude_d6_title", defaultValue: "Der eigene Körper")
            desc = String(localized: "prog_gratitude_d6_desc", defaultValue: "Egal ob er wehtut oder perfekt funktioniert: Dein Körper hält dich am Leben. Wofür dankst du ihm heute?")
            todos = [String(localized: "prog_gratitude_d6_t1", defaultValue: "\(targetCount) physische Fähigkeiten notiert (Sehen, Gehen, Atmen)")]
        case 7:
            title = String(localized: "prog_gratitude_d7_title", defaultValue: "Die Natur & Umgebung")
            desc = String(localized: "prog_gratitude_d7_desc", defaultValue: "Gibt es einen Baum, das Wetter oder einen schönen Raum, der dir heute Ruhe geschenkt hat?")
            todos = [String(localized: "prog_gratitude_d7_t1", defaultValue: "\(targetCount) Elemente deiner Umgebung notiert"), String(localized: "prog_gratitude_d7_t2", defaultValue: "Tief durchgeatmet und gelächelt")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_gratitude_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_gratitude_phase_desc_positiver_fokus", defaultValue: "Positiver Fokus"),
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
            title = String(localized: "prog_breathwork_d1_title", defaultValue: "Box Breathing")
            desc = String(localized: "prog_breathwork_d1_desc", defaultValue: "4 Sekunden ein, 4 Sekunden halten, 4 Sekunden aus, 4 Sekunden halten. Ideal für Fokus und Stressabbau.")
            todos = [String(localized: "prog_breathwork_d1_t1", defaultValue: "\(currentMin) Min Box Breathing"), String(localized: "prog_breathwork_d1_t2", defaultValue: "Puls bewusst gesenkt")]
        case 2:
            title = String(localized: "prog_breathwork_d2_title", defaultValue: "4-7-8 Atmung")
            desc = String(localized: "prog_breathwork_d2_desc", defaultValue: "4s ein, 7s halten, 8s ausatmen. Stark parasympathisch, ideal zum Herunterfahren.")
            todos = [String(localized: "prog_breathwork_d2_t1", defaultValue: "\(currentMin) Min 4-7-8 Atmung"), String(localized: "prog_breathwork_d2_t2", defaultValue: "Volle Ausatmung erzwungen")]
        case 3:
            title = String(localized: "prog_breathwork_d3_title", defaultValue: "Physiological Sigh")
            desc = String(localized: "prog_breathwork_d3_desc", defaultValue: "Zwei kurze Einatmungen durch die Nase, ein langer Seufzer durch den Mund. Der schnellste Weg, um Cortisol zu senken.")
            todos = [String(localized: "prog_breathwork_d3_t1", defaultValue: "10x Physiological Sigh (Doppel-Einatmen)"), String(localized: "prog_breathwork_d3_t2", defaultValue: "Danach \(currentMin) Min ruhige Nasenatmung")]
        case 4:
            title = String(localized: "prog_breathwork_d4_title", defaultValue: "Wim Hof (Light)")
            desc = String(localized: "prog_breathwork_d4_desc", defaultValue: "30 tiefe, schnelle Atemzüge, gefolgt von Luft anhalten. Danach tief einatmen und halten. (Sicher sitzen/liegen!)")
            let rounds = isBeginner ? 2 : 3
            todos = [String(localized: "prog_breathwork_d4_t1", defaultValue: "\(rounds) Runden Power-Breathing"), String(localized: "prog_breathwork_d4_t2", defaultValue: "Luft in der Leere gehalten"), String(localized: "prog_breathwork_d4_t3", defaultValue: "Energieschub gespürt")]
        case 5:
            title = String(localized: "prog_breathwork_d5_title", defaultValue: "Alternate Nostril Breathing")
            desc = String(localized: "prog_breathwork_d5_desc", defaultValue: "Nadi Shodhana. Abwechselnd durch das linke und rechte Nasenloch atmen. Balanciert die Gehirnhälften.")
            todos = [String(localized: "prog_breathwork_d5_t1", defaultValue: "\(currentMin) Min Wechselatmung"), String(localized: "prog_breathwork_d5_t2", defaultValue: "Auf absolute Stille beim Atmen geachtet")]
        case 6:
            title = String(localized: "prog_breathwork_d6_title", defaultValue: "Diaphragmatische Atmung")
            desc = String(localized: "prog_breathwork_d6_desc", defaultValue: "Lege ein Buch auf den Bauch. Beim Einatmen muss es sich heben. Die Brust bewegt sich fast gar nicht.")
            todos = [String(localized: "prog_breathwork_d6_t1", defaultValue: "\(currentMin) Min strikte Bauchatmung")]
        case 7:
            title = String(localized: "prog_breathwork_d7_title", defaultValue: "CO2-Toleranz")
            desc = String(localized: "prog_breathwork_d7_desc", defaultValue: "Atme normal ein, und atme dann so langsam wie nur irgendwie möglich aus (Pursed Lips). Zögere den nächsten Atemzug hinaus.")
            todos = [String(localized: "prog_breathwork_d7_t1", defaultValue: "\(currentMin) Min extrem verlängerte Ausatmung"), String(localized: "prog_breathwork_d7_t2", defaultValue: "Gegen den Lufthunger entspannt")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_breathwork_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_breathwork_phase_desc_kontrolle_des_nerven", defaultValue: "Kontrolle des Nervensystems"),
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
            title = String(localized: "prog_water_d1_title", defaultValue: "Morning Flush")
            desc = String(localized: "prog_water_d1_desc", defaultValue: "Direkt nach dem Aufstehen hat dein Körper über Nacht dehydriert. Trinke ein großes Glas (ca. 400-500ml) Wasser direkt nach dem Wachwerden.")
            todos = [String(localized: "prog_water_d1_t1", defaultValue: "500ml direkt nach dem Aufstehen getrunken"), String(localized: "prog_water_d1_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 2:
            title = String(localized: "prog_water_d2_title", defaultValue: "Fokus auf die erste Tageshälfte")
            desc = String(localized: "prog_water_d2_desc", defaultValue: "Versuche, mindestens 60% deines Wasserbedarfs vor 14 Uhr zu decken. Das verhindert abendliches Trinken und nächtliche Klobesuche.")
            todos = [String(localized: "prog_water_d2_t1", defaultValue: "60% vor 14:00 Uhr getrunken"), String(localized: "prog_water_d2_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 3:
            title = String(localized: "prog_water_d3_title", defaultValue: "Elektrolyte")
            desc = String(localized: "prog_water_d3_desc", defaultValue: "Reines Wasser spült oft Mineralien aus. Gib heute eine Prise gutes Salz (Meer- oder Ursalz) in eine deiner Flaschen.")
            todos = [String(localized: "prog_water_d3_t1", defaultValue: "Prise Salz ins Wasser gegeben"), String(localized: "prog_water_d3_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 4:
            title = String(localized: "prog_water_d4_title", defaultValue: "Vor den Mahlzeiten")
            desc = String(localized: "prog_water_d4_desc", defaultValue: "Trinke 30 Minuten vor jedem großen Essen ein Glas Wasser. Das hilft der Verdauung und dem Sättigungsgefühl.")
            todos = [String(localized: "prog_water_d4_t1", defaultValue: "Glas Wasser vor jeder Mahlzeit"), String(localized: "prog_water_d4_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 5:
            title = String(localized: "prog_water_d5_title", defaultValue: "Visualisierung")
            desc = String(localized: "prog_water_d5_desc", defaultValue: "Stelle dir deine gesamte Tagesration morgens sichtbar an den Arbeitsplatz oder in die Küche.")
            todos = [String(localized: "prog_water_d5_t1", defaultValue: "Tagesration morgens sichtbar platziert"), String(localized: "prog_water_d5_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 6:
            title = String(localized: "prog_water_d6_title", defaultValue: "Tee-Integration")
            desc = String(localized: "prog_water_d6_desc", defaultValue: "Ungesüßter Kräutertee zählt als Wasser. Baue heute eine Kanne Tee in deine Hydration ein.")
            todos = [String(localized: "prog_water_d6_t1", defaultValue: "Kräutertee als Teil der Ration genutzt"), String(localized: "prog_water_d6_t2", defaultValue: "Tagesziel: \(formattedValue) L erreicht")]
        case 7:
            title = String(localized: "prog_water_d7_title", defaultValue: "Tracking-Check")
            desc = String(localized: "prog_water_d7_desc", defaultValue: "Lief die Woche gut? Achte heute besonders darauf, dass du trotz Wochenende und fehlendem Büro-Alltag auf deine Menge kommst.")
            todos = [String(localized: "prog_water_d7_t1", defaultValue: "Tagesziel: \(formattedValue) L erreicht"), String(localized: "prog_water_d7_t2", defaultValue: "Trinkverhalten der Woche reflektiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_water_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_water_phase_desc_zelluläre_hydration", defaultValue: "Zelluläre Hydration"),
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
            title = String(localized: "prog_nutrition_d1_title", defaultValue: "Grüner Start")
            desc = String(localized: "prog_nutrition_d1_desc", defaultValue: "Integriere heute zwingend etwas Grünes (Spinat, Brokkoli, Gurke, Salat) in eine deiner Mahlzeiten.")
            todos = [String(localized: "prog_nutrition_d1_t1", defaultValue: "\(targetCount) Portionen Gemüse/Obst gegessen"), String(localized: "prog_nutrition_d1_t2", defaultValue: "Eine grüne Portion eingebaut")]
        case 2:
            title = String(localized: "prog_nutrition_d2_title", defaultValue: "Snack-Tausch")
            desc = String(localized: "prog_nutrition_d2_desc", defaultValue: "Ersetze einen üblichen ungesunden Snack durch einen Apfel, Beeren oder Gemüsesticks.")
            todos = [String(localized: "prog_nutrition_d2_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d2_t2", defaultValue: "Snack durch Obst/Gemüse ersetzt")]
        case 3:
            title = String(localized: "prog_nutrition_d3_title", defaultValue: "Eat the Rainbow")
            desc = String(localized: "prog_nutrition_d3_desc", defaultValue: "Versuche heute drei verschiedene Farben auf deinem Teller oder über den Tag verteilt zu essen (z.B. rot, grün, orange).")
            todos = [String(localized: "prog_nutrition_d3_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d3_t2", defaultValue: "Mindestens 3 verschiedene Farben gegessen")]
        case 4:
            title = String(localized: "prog_nutrition_d4_title", defaultValue: "Rohkost")
            desc = String(localized: "prog_nutrition_d4_desc", defaultValue: "Verzehre mindestens eine Portion komplett roh, um alle hitzeempfindlichen Vitamine zu bewahren.")
            todos = [String(localized: "prog_nutrition_d4_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d4_t2", defaultValue: "Eine Portion zu 100% roh gegessen")]
        case 5:
            title = String(localized: "prog_nutrition_d5_title", defaultValue: "Neues entdecken")
            desc = String(localized: "prog_nutrition_d5_desc", defaultValue: "Iss heute ein Gemüse oder Obst, das du schon sehr lange nicht mehr oder noch nie gegessen hast.")
            todos = [String(localized: "prog_nutrition_d5_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d5_t2", defaultValue: "Neues/seltenes Obst/Gemüse probiert")]
        case 6:
            title = String(localized: "prog_nutrition_d6_title", defaultValue: "Smoothie oder Suppe")
            desc = String(localized: "prog_nutrition_d6_desc", defaultValue: "Püriere deine Nährstoffe heute. Mach dir einen großen Smoothie oder eine Gemüsesuppe.")
            todos = [String(localized: "prog_nutrition_d6_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d6_t2", defaultValue: "Eine flüssige/pürierte Mahlzeit eingebaut")]
        case 7:
            title = String(localized: "prog_nutrition_d7_title", defaultValue: "Meal-Prep Vorbereitung")
            desc = String(localized: "prog_nutrition_d7_desc", defaultValue: "Wasche und schneide schon heute Gemüse für die kommenden Tage vor (z.B. Paprika in Dosen in den Kühlschrank).")
            todos = [String(localized: "prog_nutrition_d7_t1", defaultValue: "\(targetCount) Portionen erreicht"), String(localized: "prog_nutrition_d7_t2", defaultValue: "Gemüse für Montag vorbereitet")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_nutrition_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_nutrition_phase_desc_mikronährstoffe___vi", defaultValue: "Mikronährstoffe & Vitalität"),
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
            title = String(localized: "prog_coldshower_d1_title", defaultValue: "Atem-Fokus")
            desc = String(localized: "prog_coldshower_d1_desc", defaultValue: "Der Moment, in dem das Wasser dich trifft, löst einen Schnapp-Reflex aus. Kontrolliere sofort die Ausatmung.")
            todos = [String(localized: "prog_coldshower_d1_t1", defaultValue: "\(currentSec) Sekunden kalt geduscht"), String(localized: "prog_coldshower_d1_t2", defaultValue: "Ausatmung bewusst verlangsamt")]
        case 2:
            title = String(localized: "prog_coldshower_d2_title", defaultValue: "Nacken & Rücken")
            desc = String(localized: "prog_coldshower_d2_desc", defaultValue: "Lass das kalte Wasser heute bewusst über den Nacken und zwischen die Schulterblätter laufen (aktiviert braunes Fettgewebe).")
            todos = [String(localized: "prog_coldshower_d2_t1", defaultValue: "\(currentSec) Sekunden kalt geduscht"), String(localized: "prog_coldshower_d2_t2", defaultValue: "Kaltes Wasser auf den Nacken fokussiert")]
        case 3:
            title = String(localized: "prog_coldshower_d3_title", defaultValue: "Gesicht & Kopf")
            desc = String(localized: "prog_coldshower_d3_desc", defaultValue: "Wasche dir das Gesicht zuerst mit kaltem Wasser und lass es dann über den ganzen Kopf laufen (stimuliert den Vagusnerv stark).")
            todos = [String(localized: "prog_coldshower_d3_t1", defaultValue: "\(currentSec) Sekunden kalt geduscht"), String(localized: "prog_coldshower_d3_t2", defaultValue: "Kopf komplett unter Wasser gehabt")]
        case 4:
            title = String(localized: "prog_coldshower_d4_title", defaultValue: "Extremitäten zuerst")
            desc = String(localized: "prog_coldshower_d4_desc", defaultValue: "Beginne an den Füßen und Händen und wandere langsam Richtung Herzmuskel.")
            todos = [String(localized: "prog_coldshower_d4_t1", defaultValue: "\(currentSec) Sekunden kalt geduscht"), String(localized: "prog_coldshower_d4_t2", defaultValue: "An Beinen/Armen gestartet")]
        case 5:
            title = String(localized: "prog_coldshower_d5_title", defaultValue: "Der Mindset-Shift")
            desc = String(localized: "prog_coldshower_d5_desc", defaultValue: "Versuche heute nicht die Sekunden zu zählen, sondern entspanne deine Muskeln aktiv, während du frierst. Kein Zittern, kein Anspannen.")
            todos = [String(localized: "prog_coldshower_d5_t1", defaultValue: "\(currentSec) Sekunden kalt geduscht"), String(localized: "prog_coldshower_d5_t2", defaultValue: "Muskeln während der Kälte komplett entspannt")]
        case 6:
            title = String(localized: "prog_coldshower_d6_title", defaultValue: "Kontrast-Dusche")
            desc = String(localized: "prog_coldshower_d6_desc", defaultValue: "Dusche heiß, dann wechsle abrupt auf eiskalt. Spüre, wie das Blut in den Kern schießt.")
            todos = [String(localized: "prog_coldshower_d6_t1", defaultValue: "Kontrastdusche (heiß zu kalt) durchgeführt"), String(localized: "prog_coldshower_d6_t2", defaultValue: "Zuletzt \(currentSec) Sekunden eiskalt geblieben")]
        case 7:
            title = String(localized: "prog_coldshower_d7_title", defaultValue: "Pure Kälte")
            desc = String(localized: "prog_coldshower_d7_desc", defaultValue: "Drehe nicht erst warm auf. Gehe direkt ins eiskalte Wasser. Die ultimative mentale Hürde.")
            todos = [String(localized: "prog_coldshower_d7_t1", defaultValue: "Ohne vorher heiß zu duschen ins Kalte gegangen"), String(localized: "prog_coldshower_d7_t2", defaultValue: "\(currentSec) Sekunden durchgehalten")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_coldshower_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_coldshower_phase_desc_resilienz___dopamin", defaultValue: "Resilienz & Dopamin"),
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
            title = String(localized: "prog_teeth_d1_title", defaultValue: "Fokus Zahnseide")
            desc = String(localized: "prog_teeth_d1_desc", defaultValue: "Zahnseide ist wichtiger als das Putzen der Kauflächen. Reinige heute jeden einzelnen Zahnzwischenraum penibel.")
            todos = [String(localized: "prog_teeth_d1_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d1_t2", defaultValue: "Jeden Zwischenraum mit Zahnseide gereinigt")]
        case 2:
            title = String(localized: "prog_teeth_d2_title", defaultValue: "Zungenreinigung")
            desc = String(localized: "prog_teeth_d2_desc", defaultValue: "Nutze einen Zungenkratzer (oder zur Not den Löffel), um Bakterienbelag am Morgen vor dem ersten Glas Wasser zu entfernen.")
            todos = [String(localized: "prog_teeth_d2_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d2_t2", defaultValue: "Zunge am Morgen abgezogen")]
        case 3:
            title = String(localized: "prog_teeth_d3_title", defaultValue: "Sanfter Druck")
            desc = String(localized: "prog_teeth_d3_desc", defaultValue: "Wir putzen oft zu hart. Achte heute darauf, die Zahnbürste nur sehr leicht aufzudrücken, um den Schmelz und das Zahnfleisch zu schonen.")
            todos = [String(localized: "prog_teeth_d3_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d3_t2", defaultValue: "Bewusst auf leichten Druck geachtet")]
        case 4:
            title = String(localized: "prog_teeth_d4_title", defaultValue: "Die Innenseiten")
            desc = String(localized: "prog_teeth_d4_desc", defaultValue: "Die Innenseiten der Unterkiefer-Schneidezähne verkalken am schnellsten. Fokussiere dich heute besonders auf diese Stellen.")
            todos = [String(localized: "prog_teeth_d4_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d4_t2", defaultValue: "Fokus auf die Zahn-Innenseiten")]
        case 5:
            title = String(localized: "prog_teeth_d5_title", defaultValue: "Mundspülung vermeiden")
            desc = String(localized: "prog_teeth_d5_desc", defaultValue: "Spüle Zahnpasta am Ende NICHT mit Wasser aus. Spucke nur aus. Das Fluorid muss einwirken!")
            todos = [String(localized: "prog_teeth_d5_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d5_t2", defaultValue: "Nach dem Putzen nicht ausgespült")]
        case 6:
            title = String(localized: "prog_teeth_d6_title", defaultValue: "Interdental-Bürsten")
            desc = String(localized: "prog_teeth_d6_desc", defaultValue: "Falls vorhanden, nutze Interdentalbürstchen für die größeren Lücken hinten. Dort kommt Zahnseide oft nicht richtig hin.")
            todos = [String(localized: "prog_teeth_d6_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d6_t2", defaultValue: "Interdentalbürsten oder Zahnseide genutzt")]
        case 7:
            title = String(localized: "prog_teeth_d7_title", defaultValue: "Check-up Routine")
            desc = String(localized: "prog_teeth_d7_desc", defaultValue: "Inspiziere dein Zahnfleisch im Spiegel. Sieht es rosa und gesund aus oder gibt es rötliche, blutende Stellen?")
            todos = [String(localized: "prog_teeth_d7_t1", defaultValue: "2 Min morgens & abends geputzt"), String(localized: "prog_teeth_d7_t2", defaultValue: "Zahnfleisch-Check durchgeführt")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_teeth_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_teeth_phase_desc_dentale_langlebigkei", defaultValue: "Dentale Langlebigkeit"),
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
            title = String(localized: "prog_noalcohol_d1_title", defaultValue: "Trigger identifizieren")
            desc = String(localized: "prog_noalcohol_d1_desc", defaultValue: "Achte heute darauf, in welchen Momenten du normalerweise ans Trinken denkst (Stress, Feierabend, Belohnung).")
            todos = [String(localized: "prog_noalcohol_d1_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d1_t2", defaultValue: "Einen potenziellen Trigger erkannt")]
        case 2:
            title = String(localized: "prog_noalcohol_d2_title", defaultValue: "Das Ersatzgetränk")
            desc = String(localized: "prog_noalcohol_d2_desc", defaultValue: "Finde ein Premium-Ersatzgetränk. Kombucha, alkoholfreies IPA oder ein Mocktail. Es muss sich nach 'Feierabend' anfühlen.")
            todos = [String(localized: "prog_noalcohol_d2_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d2_t2", defaultValue: "Hochwertiges Ersatzgetränk genossen")]
        case 3:
            title = String(localized: "prog_noalcohol_d3_title", defaultValue: "Craving Surfing")
            desc = String(localized: "prog_noalcohol_d3_desc", defaultValue: "Sollte Verlangen aufkommen: Kämpfe nicht dagegen an. Beobachte das Gefühl wie eine Welle, die ansteigt und wieder bricht.")
            todos = [String(localized: "prog_noalcohol_d3_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d3_t2", defaultValue: "Einen Impuls vorbeiziehen lassen")]
        case 4:
            title = String(localized: "prog_noalcohol_d4_title", defaultValue: "Schlaf-Fokus")
            desc = String(localized: "prog_noalcohol_d4_desc", defaultValue: "Alkohol zerstört den REM-Schlaf. Achte heute Nacht bewusst auf deine Traumphasen und wie erholt du aufwachst.")
            todos = [String(localized: "prog_noalcohol_d4_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d4_t2", defaultValue: "Dankbarkeit für klaren Schlaf empfunden")]
        case 5:
            title = String(localized: "prog_noalcohol_d5_title", defaultValue: "Socializing Challenge")
            desc = String(localized: "prog_noalcohol_d5_desc", defaultValue: "Das Wochenende beginnt. Wenn du unter Leute gehst, sei die Person, die sich als Erstes selbstbewusst ein Wasser oder AF-Bier bestellt.")
            todos = [String(localized: "prog_noalcohol_d5_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d5_t2", defaultValue: "Souverän 'Nein' gesagt")]
        case 6:
            title = String(localized: "prog_noalcohol_d6_title", defaultValue: "Der Kater-freie Morgen")
            desc = String(localized: "prog_noalcohol_d6_desc", defaultValue: "Nutze die Energie. Anstatt den halben Samstag im Bett zu liegen, mach etwas Produktives oder Sport.")
            todos = [String(localized: "prog_noalcohol_d6_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d6_t2", defaultValue: "Die extra Energie am Morgen genutzt")]
        case 7:
            title = String(localized: "prog_noalcohol_d7_title", defaultValue: "Stolz & Reflektion")
            desc = String(localized: "prog_noalcohol_d7_desc", defaultValue: "Du hast eine ganze Woche geschafft. Wie fühlst du dich physisch und mental im Vergleich zu vor der Challenge?")
            todos = [String(localized: "prog_noalcohol_d7_t1", defaultValue: "Keinen Alkohol getrunken"), String(localized: "prog_noalcohol_d7_t2", defaultValue: "Woche stolz reflektiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_noalcohol_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_noalcohol_phase_desc_physische___mentale_", defaultValue: "Physische & Mentale Klarheit"),
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
            title = String(localized: "prog_cooking_d1_title", defaultValue: "Protein-Fokus")
            desc = String(localized: "prog_cooking_d1_desc", defaultValue: "Achte heute bei deiner Hauptmahlzeit darauf, dass sie eine adäquate Menge an Protein (20-40g) enthält.")
            todos = [String(localized: "prog_cooking_d1_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d1_t2", defaultValue: "Fokus auf hohen Proteingehalt")]
        case 2:
            title = String(localized: "prog_cooking_d2_title", defaultValue: "Kein versteckter Zucker")
            desc = String(localized: "prog_cooking_d2_desc", defaultValue: "Lass alle fertigen Saucen (Ketchup, BBQ, Fertigdressing) weg. Mach dein Dressing selbst aus Olivenöl und Essig/Zitrone.")
            todos = [String(localized: "prog_cooking_d2_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d2_t2", defaultValue: "Komplett auf Zuckerzusätze verzichtet")]
        case 3:
            title = String(localized: "prog_cooking_d3_title", defaultValue: "Ballaststoff-Bombe")
            desc = String(localized: "prog_cooking_d3_desc", defaultValue: "Integriere heute Hülsenfrüchte (Bohnen, Linsen) oder Haferflocken, um deine Darmbakterien zu füttern.")
            todos = [String(localized: "prog_cooking_d3_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d3_t2", defaultValue: "Extra Ballaststoffe eingebaut")]
        case 4:
            title = String(localized: "prog_cooking_d4_title", defaultValue: "Healthy Fats")
            desc = String(localized: "prog_cooking_d4_desc", defaultValue: "Vermeide Rapsöl oder Sonnenblumenöl zum Braten. Nutze Olivenöl, Butter, Ghee oder Kokosöl. Füge Nüsse/Avocado hinzu.")
            todos = [String(localized: "prog_cooking_d4_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d4_t2", defaultValue: "Nur hochwertige Fette genutzt")]
        case 5:
            title = String(localized: "prog_cooking_d5_title", defaultValue: "Neues Rezept")
            desc = String(localized: "prog_cooking_d5_desc", defaultValue: "Koche etwas, das du noch nie zubereitet hast. Such dir ein gesundes Rezept im Internet und folge ihm.")
            todos = [String(localized: "prog_cooking_d5_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d5_t2", defaultValue: "Ein neues Rezept ausprobiert")]
        case 6:
            title = String(localized: "prog_cooking_d6_title", defaultValue: "Zero Processed Foods")
            desc = String(localized: "prog_cooking_d6_desc", defaultValue: "Nutze heute absolut keine Lebensmittel, die mehr als 3 Zutaten auf der Verpackung stehen haben.")
            todos = [String(localized: "prog_cooking_d6_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d6_t2", defaultValue: "Nur Whole-Foods (unverarbeitet) verwendet")]
        case 7:
            title = String(localized: "prog_cooking_d7_title", defaultValue: "Meal Prep")
            desc = String(localized: "prog_cooking_d7_desc", defaultValue: "Koche heute die doppelte oder dreifache Menge, damit du Montag und Dienstag direkt Tupperdosen für die Arbeit/Uni hast.")
            todos = [String(localized: "prog_cooking_d7_t1", defaultValue: "Mahlzeit selbst zubereitet"), String(localized: "prog_cooking_d7_t2", defaultValue: "Mehrere Portionen für die Woche vorgekocht")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_cooking_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_cooking_phase_desc_ernährung___zell_tre", defaultValue: "Ernährung & Zell-Treibstoff"),
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
            title = String(localized: "prog_deepwork_d1_title", defaultValue: "Eat the Frog")
            desc = String(localized: "prog_deepwork_d1_desc", defaultValue: "Erledige die absolut wichtigste und schwerste Aufgabe des Tages direkt in deiner ersten Deep Work Session. Schiebe nichts auf.")
            todos = [String(localized: "prog_deepwork_d1_t1", defaultValue: "\(currentMin) Min Deep Work absolviert"), String(localized: "prog_deepwork_d1_t2", defaultValue: "Schwerste Aufgabe zuerst erledigt")]
        case 2:
            title = String(localized: "prog_deepwork_d2_title", defaultValue: "Zero Notifications")
            desc = String(localized: "prog_deepwork_d2_desc", defaultValue: "Schalte dein Handy in den Flugmodus und schließe alle Mail/Chat-Programme auf dem Desktop. Volle Isolation.")
            todos = [String(localized: "prog_deepwork_d2_t1", defaultValue: "\(currentMin) Min Deep Work absolviert"), String(localized: "prog_deepwork_d2_t2", defaultValue: "Alle Notifications strikt deaktiviert")]
        case 3:
            title = String(localized: "prog_deepwork_d3_title", defaultValue: "Pomodoro-Taktung")
            desc = String(localized: "prog_deepwork_d3_desc", defaultValue: "Unterteile deine Session in 25-Minuten-Blöcke (Fokus) und 5-Minuten-Pausen (Aufstehen, Augen vom Bildschirm weg).")
            todos = [String(localized: "prog_deepwork_d3_t1", defaultValue: "\(currentMin) Min Deep Work absolviert"), String(localized: "prog_deepwork_d3_t2", defaultValue: "Pomodoro-Technik sauber angewandt")]
        case 4:
            title = String(localized: "prog_deepwork_d4_title", defaultValue: "Klare Zielsetzung")
            desc = String(localized: "prog_deepwork_d4_desc", defaultValue: "Schreibe VOR dem Starten des Timers exakt auf, welches Outcome du in dieser Session erreichen willst. Keine ungerichtete Arbeit.")
            todos = [String(localized: "prog_deepwork_d4_t1", defaultValue: "\(currentMin) Min Deep Work absolviert"), String(localized: "prog_deepwork_d4_t2", defaultValue: "Spezifisches Ziel vorher definiert und erreicht")]
        case 5:
            title = String(localized: "prog_deepwork_d5_title", defaultValue: "Der aufgeräumte Schreibtisch")
            desc = String(localized: "prog_deepwork_d5_desc", defaultValue: "Räume vor dem Arbeiten physisch deinen Tisch auf. Visuelle Unordnung frisst unbewusst kognitive Kapazität.")
            todos = [String(localized: "prog_deepwork_d5_t1", defaultValue: "\(currentMin) Min Deep Work absolviert"), String(localized: "prog_deepwork_d5_t2", defaultValue: "Schreibtisch vor Beginn komplett gecleant")]
        case 6:
            title = String(localized: "prog_deepwork_d6_title", defaultValue: "Deep Learning")
            desc = String(localized: "prog_deepwork_d6_desc", defaultValue: "Nutze den Deep Work Slot am Wochenende nicht für Arbeit, sondern um dir ungestört eine neue, komplexe Fähigkeit anzueignen (Buch, Kurs).")
            todos = [String(localized: "prog_deepwork_d6_t1", defaultValue: "\(currentMin) Min Deep Learning"), String(localized: "prog_deepwork_d6_t2", defaultValue: "Neues Wissen erarbeitet statt Abarbeiten")]
        case 7:
            title = String(localized: "prog_deepwork_d7_title", defaultValue: "Planung & Erholung")
            desc = String(localized: "prog_deepwork_d7_desc", defaultValue: "Keine harte kognitive Arbeit heute. Setze dich 15 Minuten hin und plane die Deep Work Slots für die kommende Woche in deinen Kalender ein.")
            todos = [String(localized: "prog_deepwork_d7_t1", defaultValue: "Deep Work Kalender für nächste Woche geblockt")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_deepwork_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_deepwork_phase_desc_laserfokus___produkt", defaultValue: "Laserfokus & Produktivität"),
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
            title = String(localized: "prog_cleaning_d1_title", defaultValue: "Küche & Spüle")
            desc = String(localized: "prog_cleaning_d1_desc", defaultValue: "Eine saubere Küche ist das Herzstück. Gehe niemals mit dreckigem Geschirr in der Spüle ins Bett.")
            todos = [String(localized: "prog_cleaning_d1_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d1_t2", defaultValue: "Spüle komplett leer und sauber")]
        case 2:
            title = String(localized: "prog_cleaning_d2_title", defaultValue: "Bodenfreiheit")
            desc = String(localized: "prog_cleaning_d2_desc", defaultValue: "Räume alles vom Boden auf, was dort nicht hingehört (Kleidung, Schuhe, Taschen). Der Raum wirkt sofort größer.")
            todos = [String(localized: "prog_cleaning_d2_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d2_t2", defaultValue: "Alle Böden komplett freigeräumt")]
        case 3:
            title = String(localized: "prog_cleaning_d3_title", defaultValue: "Hotspot-Tackling")
            desc = String(localized: "prog_cleaning_d3_desc", defaultValue: "Jeder hat diesen einen Stuhl oder Tisch, auf dem sich alles sammelt. Nimm dir heute diesen Hotspot vor.")
            todos = [String(localized: "prog_cleaning_d3_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d3_t2", defaultValue: "Deinen größten Chaos-Hotspot bereinigt")]
        case 4:
            title = String(localized: "prog_cleaning_d4_title", defaultValue: "Trash & Recycle")
            desc = String(localized: "prog_cleaning_d4_desc", defaultValue: "Geh durch alle Räume: Mülleimer leeren, Pfandflaschen zusammenstellen, Papiermüll entsorgen.")
            todos = [String(localized: "prog_cleaning_d4_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d4_t2", defaultValue: "Allen Müll aus der Wohnung entfernt")]
        case 5:
            title = String(localized: "prog_cleaning_d5_title", defaultValue: "Declutter (Entmisten)")
            desc = String(localized: "prog_cleaning_d5_desc", defaultValue: "Finde heute 3 Dinge in deiner Wohnung, die du nicht mehr brauchst. Wegwerfen, spenden oder verkaufen.")
            todos = [String(localized: "prog_cleaning_d5_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d5_t2", defaultValue: "Mindestens 3 Gegenstände aussortiert")]
        case 6:
            title = String(localized: "prog_cleaning_d6_title", defaultValue: "Das Bett & Schlafzimmer")
            desc = String(localized: "prog_cleaning_d6_desc", defaultValue: "Wasche deine Bettwäsche oder beziehe das Bett neu. Ein frisches Bett verbessert die Schlafqualität enorm.")
            todos = [String(localized: "prog_cleaning_d6_t1", defaultValue: "\(currentMin) Min aufgeräumt"), String(localized: "prog_cleaning_d6_t2", defaultValue: "Schlafzimmer in eine Oase verwandelt")]
        case 7:
            title = String(localized: "prog_cleaning_d7_title", defaultValue: "Sunday Reset")
            desc = String(localized: "prog_cleaning_d7_desc", defaultValue: "Die 10-Minuten-Runde durch die ganze Wohnung. Bring alles dorthin zurück, wo es eigentlich wohnt. Bereite den Raum für die neue Woche vor.")
            todos = [String(localized: "prog_cleaning_d7_t1", defaultValue: "\(currentMin) Min Sunday Reset"), String(localized: "prog_cleaning_d7_t2", defaultValue: "Mit einem guten Gefühl in die Woche starten")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_cleaning_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_cleaning_phase_desc_ordnung_im_außen___r", defaultValue: "Ordnung im Außen = Ruhe im Innen"),
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
            title = String(localized: "prog_saving_d1_title", defaultValue: "Pay Yourself First")
            desc = String(localized: "prog_saving_d1_desc", defaultValue: "Lege den heutigen Betrag physisch oder per Dauerauftrag beiseite. Behandle diese Einzahlung wie eine feste Rechnung.")
            todos = [String(localized: "prog_saving_d1_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d1_t2", defaultValue: "Geld mental als 'ausgegeben' verbucht")]
        case 2:
            title = String(localized: "prog_saving_d2_title", defaultValue: "Ausgaben tracken")
            desc = String(localized: "prog_saving_d2_desc", defaultValue: "Schreibe heute (und generell) absolut jeden Cent auf, den du ausgibst. Bewusstsein ist der erste Schritt zur Kontrolle.")
            todos = [String(localized: "prog_saving_d2_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d2_t2", defaultValue: "Alle heutigen Ausgaben notiert")]
        case 3:
            title = String(localized: "prog_saving_d3_title", defaultValue: "No-Spend-Day")
            desc = String(localized: "prog_saving_d3_desc", defaultValue: "Gib heute keinen einzigen Cent aus (Fixkosten ausgenommen). Kein Coffee-to-go, kein Bäcker, kein Online-Shopping.")
            todos = [String(localized: "prog_saving_d3_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d3_t2", defaultValue: "Erfolgreicher No-Spend-Day")]
        case 4:
            title = String(localized: "prog_saving_d4_title", defaultValue: "Die 72-Stunden-Regel")
            desc = String(localized: "prog_saving_d4_desc", defaultValue: "Wenn du online etwas siehst, das du kaufen willst: Pack es in den Warenkorb, aber warte 72 Stunden. Meistens verfliegt der Drang.")
            todos = [String(localized: "prog_saving_d4_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d4_t2", defaultValue: "Impulskäufen widerstanden")]
        case 5:
            title = String(localized: "prog_saving_d5_title", defaultValue: "Abo-Check")
            desc = String(localized: "prog_saving_d5_desc", defaultValue: "Schau dir deine Kontoauszüge an. Gibt es ein Abo (Netflix, Gym, App), das du nicht nutzt? Kündige es HEUTE.")
            todos = [String(localized: "prog_saving_d5_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d5_t2", defaultValue: "Abos auf Sinnhaftigkeit geprüft")]
        case 6:
            title = String(localized: "prog_saving_d6_title", defaultValue: "Essen von Zuhause")
            desc = String(localized: "prog_saving_d6_desc", defaultValue: "Am Wochenende gibt man am meisten für Essen aus. Koche heute selbst oder lade Freunde zu dir ein, statt teuer auszugehen.")
            todos = [String(localized: "prog_saving_d6_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d6_t2", defaultValue: "Gastro-Kosten gespart")]
        case 7:
            title = String(localized: "prog_saving_d7_title", defaultValue: "Finanz-Review")
            desc = String(localized: "prog_saving_d7_desc", defaultValue: "Blicke auf die Woche zurück. Wo hast du sinnlos Geld verbrannt? Wo warst du diszipliniert?")
            todos = [String(localized: "prog_saving_d7_t1", defaultValue: "\(formattedValue) € beiseite gelegt"), String(localized: "prog_saving_d7_t2", defaultValue: "Ausgaben der Woche ehrlich reflektiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_saving_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_saving_phase_desc_finanzielle_freiheit", defaultValue: "Finanzielle Freiheit"),
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
            title = String(localized: "prog_selfcare_d1_title", defaultValue: "Physische Pflege")
            desc = String(localized: "prog_selfcare_d1_desc", defaultValue: "Nimm dir heute extra Zeit für deinen Körper. Eine Gesichtsmaske, ein Peeling oder Eincremen mit bewusster Aufmerksamkeit.")
            todos = [String(localized: "prog_selfcare_d1_t1", defaultValue: "Physische Selfcare betrieben"), String(localized: "prog_selfcare_d1_t2", defaultValue: "Dich in deiner Haut wohlgefühlt")]
        case 2:
            title = String(localized: "prog_selfcare_d2_title", defaultValue: "Das Wort 'Nein'")
            desc = String(localized: "prog_selfcare_d2_desc", defaultValue: "Selfcare bedeutet Grenzen zu setzen. Sage heute bewusst 'Nein' zu einer Anfrage, einem Gefallen oder einer Aufgabe, die dich auslaugt.")
            todos = [String(localized: "prog_selfcare_d2_t1", defaultValue: "Erfolgreich 'Nein' gesagt"), String(localized: "prog_selfcare_d2_t2", defaultValue: "Eigene Ressourcen geschützt")]
        case 3:
            title = String(localized: "prog_selfcare_d3_title", defaultValue: "Digitaler Detox")
            desc = String(localized: "prog_selfcare_d3_desc", defaultValue: "Gehe eine Stunde vor dem Schlafengehen offline. Kein Social Media, keine Nachrichten. Nur ein Buch oder Stille.")
            todos = [String(localized: "prog_selfcare_d3_t1", defaultValue: "Abendlichen Digital Detox durchgeführt")]
        case 4:
            title = String(localized: "prog_selfcare_d4_title", defaultValue: "Solitary Walk")
            desc = String(localized: "prog_selfcare_d4_desc", defaultValue: "Geh 20 Minuten spazieren. Ohne Musik, ohne Podcast, ohne Begleitung. Nur du und deine Gedanken.")
            todos = [String(localized: "prog_selfcare_d4_t1", defaultValue: "20 Min Walk ohne Input"), String(localized: "prog_selfcare_d4_t2", defaultValue: "Gedanken fließen gelassen")]
        case 5:
            title = String(localized: "prog_selfcare_d5_title", defaultValue: "Das innere Kind")
            desc = String(localized: "prog_selfcare_d5_desc", defaultValue: "Mach heute etwas, das absolut keinen produktiven Zweck hat, dir aber als Kind Freude bereitet hat (Malen, Gaming, Legos, in die Badewanne gehen).")
            todos = [String(localized: "prog_selfcare_d5_t1", defaultValue: "Etwas rein für die Freude getan"), String(localized: "prog_selfcare_d5_t2", defaultValue: "Leistungsdruck losgelassen")]
        case 6:
            title = String(localized: "prog_selfcare_d6_title", defaultValue: "Social Batterie laden")
            desc = String(localized: "prog_selfcare_d6_desc", defaultValue: "Triff dich mit einer Person, die dir Energie gibt (Energiespender) und halte Abstand von Menschen, die nur meckern (Energiesauger).")
            todos = [String(localized: "prog_selfcare_d6_t1", defaultValue: "Mit positiven Menschen umgeben")]
        case 7:
            title = String(localized: "prog_selfcare_d7_title", defaultValue: "Weekly Review")
            desc = String(localized: "prog_selfcare_d7_desc", defaultValue: "Schreib drei Dinge auf, die du diese Woche an dir selbst gut fandest. Kein Eigenlob ist heute übertrieben.")
            todos = [String(localized: "prog_selfcare_d7_t1", defaultValue: "3 Dinge notiert, auf die du stolz bist"), String(localized: "prog_selfcare_d7_t2", defaultValue: "Woche positiv abgeschlossen")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_selfcare_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_selfcare_phase_desc_mentaler_schutzschil", defaultValue: "Mentaler Schutzschild"),
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
            title = String(localized: "prog_screentime_d1_title", defaultValue: "App-Limits Respektieren")
            desc = String(localized: "prog_screentime_d1_desc", defaultValue: "Wenn der Timer im Handy heute abläuft, klicke NICHT auf '15 Minuten ignorieren'. Die App bleibt zu.")
            todos = [String(localized: "prog_screentime_d1_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d1_t2", defaultValue: "Kein Limit ignoriert")]
        case 2:
            title = String(localized: "prog_screentime_d2_title", defaultValue: "Graustufen-Modus")
            desc = String(localized: "prog_screentime_d2_desc", defaultValue: "Stelle dein Handy-Display heute in den Einstellungen komplett auf Schwarz-Weiß. Beobachte, wie der Dopamin-Drang sinkst.")
            todos = [String(localized: "prog_screentime_d2_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d2_t2", defaultValue: "Graustufen-Modus aktiviert")]
        case 3:
            title = String(localized: "prog_screentime_d3_title", defaultValue: "Kein Screen beim Essen")
            desc = String(localized: "prog_screentime_d3_desc", defaultValue: "Kein YouTube, kein TikTok, kein TV während deiner Mahlzeiten. Kau und schmecke dein Essen.")
            todos = [String(localized: "prog_screentime_d3_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d3_t2", defaultValue: "Alle Mahlzeiten offline eingenommen")]
        case 4:
            title = String(localized: "prog_screentime_d4_title", defaultValue: "Das blinde Badezimmer")
            desc = String(localized: "prog_screentime_d4_desc", defaultValue: "Das Handy bleibt draußen, wenn du aufs Klo gehst oder duschst. Das Badezimmer ist eine No-Phone-Zone.")
            todos = [String(localized: "prog_screentime_d4_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d4_t2", defaultValue: "Handy nicht mit ins Bad genommen")]
        case 5:
            title = String(localized: "prog_screentime_d5_title", defaultValue: "Notification-Purge")
            desc = String(localized: "prog_screentime_d5_desc", defaultValue: "Schalte heute die Benachrichtigungen für alle Social-Media- und Shopping-Apps dauerhaft aus. Nur echte Menschen dürfen piepen.")
            todos = [String(localized: "prog_screentime_d5_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d5_t2", defaultValue: "Sinnlose Notifications deaktiviert")]
        case 6:
            title = String(localized: "prog_screentime_d6_title", defaultValue: "Der Wecker-Trick")
            desc = String(localized: "prog_screentime_d6_desc", defaultValue: "Lade dein Handy heute Nacht nicht neben dem Bett, sondern in einem anderen Raum oder auf der anderen Seite des Zimmers.")
            todos = [String(localized: "prog_screentime_d6_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d6_t2", defaultValue: "Handy weit weg vom Bett platziert")]
        case 7:
            title = String(localized: "prog_screentime_d7_title", defaultValue: "Screentime Report")
            desc = String(localized: "prog_screentime_d7_desc", defaultValue: "Schau dir deine Wochenstatistik an. Wo hast du die meiste Zeit verbrannt? Wo lief es besser?")
            todos = [String(localized: "prog_screentime_d7_t1", defaultValue: "Bildschirmzeit-Limit eingehalten"), String(localized: "prog_screentime_d7_t2", defaultValue: "Statistik ehrlich analysiert")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_screentime_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_screentime_phase_desc_dopamin_kontrolle", defaultValue: "Dopamin-Kontrolle"),
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
            title = String(localized: "prog_sleep_d1_title", defaultValue: "Fixe Zielzeit")
            desc = String(localized: "prog_sleep_d1_desc", defaultValue: "Gehe heute auf die Minute genau zu deiner vorgenommenen Zeit ins Bett. Konsistenz richtet den circadianen Rhythmus aus.")
            todos = [String(localized: "prog_sleep_d1_t1", defaultValue: "Exakt zur Zielzeit im Bett gewesen")]
        case 2:
            title = String(localized: "prog_sleep_d2_title", defaultValue: "Temperatur-Drop")
            desc = String(localized: "prog_sleep_d2_desc", defaultValue: "Lüfte das Schlafzimmer durch. Der Körper muss zum Einschlafen an Kerntemperatur verlieren. Es sollte kühl sein (16-18°C).")
            todos = [String(localized: "prog_sleep_d2_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d2_t2", defaultValue: "Kühle Raumtemperatur sichergestellt")]
        case 3:
            title = String(localized: "prog_sleep_d3_title", defaultValue: "Koffein-Cutoff")
            desc = String(localized: "prog_sleep_d3_desc", defaultValue: "Trinke heute keinen Kaffee oder Energy-Drinks mehr nach 14:00 Uhr. Koffein hat eine Halbwertszeit von ca. 5 Stunden!")
            todos = [String(localized: "prog_sleep_d3_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d3_t2", defaultValue: "Koffein-Cutoff respektiert")]
        case 4:
            title = String(localized: "prog_sleep_d4_title", defaultValue: "Blaulicht-Blocker")
            desc = String(localized: "prog_sleep_d4_desc", defaultValue: "Schalte 60 Minuten vor dem Schlafen alle Deckenlichter aus (nutze warme Tischlampen) und aktiviere Night-Shift an Geräten.")
            todos = [String(localized: "prog_sleep_d4_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d4_t2", defaultValue: "Lichtumgebung abends abgedunkelt")]
        case 5:
            title = String(localized: "prog_sleep_d5_title", defaultValue: "Der Brain-Dump")
            desc = String(localized: "prog_sleep_d5_desc", defaultValue: "Wenn der Kopf rattert: Lege dir Zettel und Stift ans Bett. Schreibe alle Gedanken und To-Dos für morgen auf, damit der Kopf leer ist.")
            todos = [String(localized: "prog_sleep_d5_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d5_t2", defaultValue: "Gedanken vor dem Schlafen auf Papier entleert")]
        case 6:
            title = String(localized: "prog_sleep_d6_title", defaultValue: "Kein schweres Essen")
            desc = String(localized: "prog_sleep_d6_desc", defaultValue: "Iss deine letzte große Mahlzeit mindestens 3 Stunden vor dem Schlafengehen. Die Verdauung hindert dich am Tiefschlaf.")
            todos = [String(localized: "prog_sleep_d6_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d6_t2", defaultValue: "Mit leichtem Magen schlafen gegangen")]
        case 7:
            title = String(localized: "prog_sleep_d7_title", defaultValue: "Die Entspannungs-Stunde")
            desc = String(localized: "prog_sleep_d7_desc", defaultValue: "Lies ein Buch (Fiction, kein Business-Buch) oder höre ruhige Musik in der letzten Stunde vor dem Bett. Kein Screen.")
            todos = [String(localized: "prog_sleep_d7_t1", defaultValue: "Zur Zielzeit im Bett"), String(localized: "prog_sleep_d7_t2", defaultValue: "Offline-Entspannung vor dem Schlaf")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_sleep_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_sleep_phase_desc_regeneration___tiefs", defaultValue: "Regeneration & Tiefschlaf"),
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
            title = String(localized: "prog_wakeup_d1_title", defaultValue: "Der Snooze-Bann")
            desc = String(localized: "prog_wakeup_d1_desc", defaultValue: "Snoozen fragmentiert den Schlaf und macht dich müder. Wenn der Wecker klingelt, stehen die Füße in 5 Sekunden auf dem Boden.")
            todos = [String(localized: "prog_wakeup_d1_t1", defaultValue: "Beim 1. Weckerklingeln aufgestanden"), String(localized: "prog_wakeup_d1_t2", defaultValue: "Snooze-Taste NICHT berührt")]
        case 2:
            title = String(localized: "prog_wakeup_d2_title", defaultValue: "Wecker weit weg")
            desc = String(localized: "prog_wakeup_d2_desc", defaultValue: "Platziere das Handy/den Wecker so weit weg vom Bett, dass du physisch aufstehen MUSST, um ihn auszumachen.")
            todos = [String(localized: "prog_wakeup_d2_t1", defaultValue: "Beim 1. Weckerklingeln aufgestanden"), String(localized: "prog_wakeup_d2_t2", defaultValue: "Physisch aus dem Bett gezwungen")]
        case 3:
            title = String(localized: "prog_wakeup_d3_title", defaultValue: "Licht-Injektion")
            desc = String(localized: "prog_wakeup_d3_desc", defaultValue: "Mache sofort nach dem Aufstehen das Licht an oder öffne die Vorhänge. Helles Licht stoppt die Melatonin-Produktion schlagartig.")
            todos = [String(localized: "prog_wakeup_d3_t1", defaultValue: "Beim 1. Weckerklingeln aufgestanden"), String(localized: "prog_wakeup_d3_t2", defaultValue: "Sofort Licht ausgesetzt")]
        case 4:
            title = String(localized: "prog_wakeup_d4_title", defaultValue: "Wasser & Bewegung")
            desc = String(localized: "prog_wakeup_d4_desc", defaultValue: "Trinke sofort ein Glas Wasser und strecke dich für 2 Minuten. Aktiviere den Kreislauf, bevor das Gehirn Ausreden findet.")
            todos = [String(localized: "prog_wakeup_d4_t1", defaultValue: "Beim 1. Weckerklingeln aufgestanden"), String(localized: "prog_wakeup_d4_t2", defaultValue: "Kreislauf direkt hochgefahren")]
        case 5:
            title = String(localized: "prog_wakeup_d5_title", defaultValue: "Das Morgen-Warum")
            desc = String(localized: "prog_wakeup_d5_desc", defaultValue: "Warum stehst du so früh auf? Rufe dir dein wichtigstes Ziel des Tages in Erinnerung, noch während du die Decke zurückschlägst.")
            todos = [String(localized: "prog_wakeup_d5_t1", defaultValue: "Beim 1. Weckerklingeln aufgestanden"), String(localized: "prog_wakeup_d5_t2", defaultValue: "Tagesziel visualisiert")]
        case 6:
            title = String(localized: "prog_wakeup_d6_title", defaultValue: "Rhythmus halten")
            desc = String(localized: "prog_wakeup_d6_desc", defaultValue: "Versuche, auch am Wochenende maximal 30-60 Minuten von deiner unter der Woche gewohnten Aufstehzeit abzuweichen.")
            todos = [String(localized: "prog_wakeup_d6_t1", defaultValue: "Zur Zielzeit (bzw. +30 Min) aufgestanden"), String(localized: "prog_wakeup_d6_t2", defaultValue: "Wochenend-Jetlag vermieden")]
        case 7:
            title = String(localized: "prog_wakeup_d7_title", defaultValue: "Die Belohnung")
            desc = String(localized: "prog_wakeup_d7_desc", defaultValue: "Genieße die Stille des frühen Sonntagmorgens. Mach dir einen guten Kaffee oder Tee, während der Rest der Welt noch schläft.")
            todos = [String(localized: "prog_wakeup_d7_t1", defaultValue: "Zur Zielzeit aufgestanden"), String(localized: "prog_wakeup_d7_t2", defaultValue: "Die morgendliche Stille genossen")]
        default:
            break
        }
        
        return ProgressionData(
            phaseNumber: phaseNumber,
            phaseTitle: String(localized: "prog_wakeup_phase_title_woche___phasenumber_", defaultValue: "Woche \(phaseNumber)"),
            phaseDescription: String(localized: "prog_wakeup_phase_desc_der_perfekte_start", defaultValue: "Der perfekte Start"),
            dailyTitle: title,
            dailyDescription: desc,
            dailyTodos: todos
        )
    }
}

