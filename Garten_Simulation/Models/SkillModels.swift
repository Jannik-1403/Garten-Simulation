import SwiftUI

enum SkillType: String, CaseIterable, Codable {
    case fitness, productivity, knowledge, discipline, tech, writing, focus, creativity, rhetoric, soccer, programming, badminton
    
    var icon: String {
        switch self {
        case .fitness:      return "figure.run"
        case .productivity: return "rocket.fill"
        case .knowledge:    return "book.fill"
        case .discipline:   return "arrow.clockwise"
        case .tech:         return "cpu"
        case .writing:      return "pencil"
        case .focus:        return "target"
        case .creativity:   return "lightbulb.fill"
        case .rhetoric:     return "mouth.fill"
        case .soccer:       return "soccerball"
        case .programming:  return "chevron.left.forwardslash.chevron.right"
        case .badminton:    return "shuttlecock"
        }
    }
    
    var localizationKey: String {
        "skill.\(self.rawValue)"
    }
}

struct SkillInfo: Identifiable {
    let id: SkillType
    let level: Int
    let currentXP: Int
    let requiredXP: Int
    let totalXP: Int
    
    var progress: Double {
        Double(currentXP) / Double(requiredXP)
    }
}

class SkillHelper {
    static func getSkill(for plant: HabitModel) -> SkillType? {
        let name = plant.name.lowercased()
        let habitName = plant.habitName.lowercased()
        
        // Match by specific names first
        if name.contains("programm") || habitName.contains("programm") || name.contains("code") { return .programming }
        if name.contains("fußball") || habitName.contains("fußball") || name.contains("soccer") { return .soccer }
        if name.contains("badminton") || habitName.contains("badminton") { return .badminton }
        if name.contains("schreiben") || habitName.contains("writing") || name.contains("texte") { return .writing }
        if name.contains("rhetorik") || habitName.contains("rhetoric") || name.contains("reden") { return .rhetoric }
        if name.contains("kreativ") || habitName.contains("creative") || habitName.contains("malen") { return .creativity }
        if name.contains("fokus") || name.contains("konzentration") || habitName.contains("deep_work") { return .focus }
        if name.contains("technik") || name.contains("hardware") || name.contains("chip") { return .tech }
        
        // Match by categories
        if plant.habitCategory == .fitness { return .fitness }
        if plant.habitCategory == .growth {
            if habitName.contains("work") || habitName.contains("produktiv") { return .productivity }
            return .knowledge
        }
        if plant.habitCategory == .lifestyle || plant.habitCategory == .health {
            if habitName.contains("aufraeumen") || habitName.contains("routine") || habitName.contains("duschen") { return .discipline }
        }
        
        return .discipline // Default to discipline if nothing else matches well
    }
    
    static func getLevelInfo(totalXP: Int) -> (level: Int, current: Int, required: Int) {
        let thresholds = [0, 250, 500, 1500, 3000, 5000, 7500, 10000, 15000, 25000]
        
        var level = 1
        var remainingXP = totalXP
        
        for i in 0..<thresholds.count - 1 {
            let step = thresholds[i+1] - thresholds[i]
            if remainingXP >= step {
                remainingXP -= step
                level += 1
            } else {
                return (level, remainingXP, step)
            }
        }
        
        // Max level reached or beyond thresholds
        return (level, remainingXP, 10000)
    }
}
