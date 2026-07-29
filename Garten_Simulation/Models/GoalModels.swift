import Foundation

// MARK: - Goal Types & Weights

enum GoalType: String, Codable, CaseIterable {
    case year = "year"
    case month = "month"
    
    var localizationKey: String {
        switch self {
        case .year: return "goal.type.year"
        case .month: return "goal.type.month"
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
    static let yearTemplates: [GoalTemplate] = [
        GoalTemplate(
            id: "tech_business",
            titleKey: "goal.template.tech_business",
            type: .year,
            suggestedHabitIds: [:] // Kann später mit echten GameDatabase-Samen-IDs gefüllt werden
        ),
        GoalTemplate(
            id: "top_athlete",
            titleKey: "goal.template.top_athlete",
            type: .year,
            suggestedHabitIds: [:]
        ),
        GoalTemplate(
            id: "mental_mastery",
            titleKey: "goal.template.mental_mastery",
            type: .year,
            suggestedHabitIds: [:]
        )
    ]
}
