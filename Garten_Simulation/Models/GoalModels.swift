import Foundation

// MARK: - Goal Types & Weights

enum GoalType: String, Codable, CaseIterable {
    case year = "year"
    case week = "week"
    
    var localizationKey: String {
        switch self {
        case .year: return "goal.type.year"
        case .week: return "goal.type.week"
        }
    }
}

enum GoalWeight: Int, Codable, CaseIterable {
    case massive = 20
    case bit = 5
    case none = 0
    
    var localizationKey: String {
        switch self {
        case .massive: return "goal.weight.massive"
        case .bit: return "goal.weight.bit"
        case .none: return "goal.link.none"
        }
    }
}

// MARK: - Core Goal Models

struct GoalModel: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String // Bei eigenen Zielen vom Nutzer eingegeben, bei Templates der lokalisierte Name
    var type: GoalType
    var createdAt: Date = Date()
    
    // Opt-in: Wenn der Nutzer das Ziel visuell im Hintergrund repräsentieren will,
    // könnte man hier später eine `backgroundThemeId` oder ähnliches speichern.
}

struct GoalHabitLink: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var goalId: UUID
    var habitId: String // Referenziert HabitModel.id
    var weight: GoalWeight
    var frequencyPerWeek: Int? // Optional für Abwärtskompatibilität, Standard ist 7
    var createdAt: Date = Date()
}

struct GoalLog: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var goalId: UUID
    var habitId: String
    var pointsEarned: Int
}

// MARK: - Templates for Onboarding

struct GoalTemplate {
    var id: String
    var titleKey: String
    var type: GoalType
    var suggestedHabitIds: [String: GoalWeight] // Habit Template ID : Gewichtung
}

extension GoalTemplate {
    static let fiveYearTemplates: [GoalTemplate] = [
        GoalTemplate(
            id: "career_fulfillment",
            titleKey: "goal.template.career",
            type: .year,
            suggestedHabitIds: [:]
        ),
        GoalTemplate(
            id: "financial_freedom",
            titleKey: "goal.template.finance",
            type: .year,
            suggestedHabitIds: [:]
        ),
        GoalTemplate(
            id: "health_fitness",
            titleKey: "goal.template.health",
            type: .year,
            suggestedHabitIds: [:]
        )
    ]
    
    static let weekTemplates: [GoalTemplate] = [
        GoalTemplate(
            id: "workout_3x",
            titleKey: "goal.template.week.workout",
            type: .week,
            suggestedHabitIds: [:]
        ),
        GoalTemplate(
            id: "read_daily",
            titleKey: "goal.template.week.reading",
            type: .week,
            suggestedHabitIds: [:]
        ),
        GoalTemplate(
            id: "reduce_screentime",
            titleKey: "goal.template.week.screentime",
            type: .week,
            suggestedHabitIds: [:]
        )
    ]
}
