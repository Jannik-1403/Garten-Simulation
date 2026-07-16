import Foundation

enum AssessmentInsightCategory {
    case finance
    case health
    case mental
    case growth
    case fitness
    case lifestyle
}

enum InsightAction {
    case openPlant(plantID: String)
    case setReminder(plantID: String)
    case startFocusSession
    case addHabit(category: HabitCategory)
}

struct AssessmentInsight {
    let titleKey: String
    let descriptionKey: String
    let iconName: String
    let iconColorName: String
    let isPositive: Bool
    let suggestedAction: InsightAction?
}

struct AssessmentInsightGenerator {
    static func generateInsights(for category: AssessmentInsightCategory, store: GardenStore) -> [AssessmentInsight] {
        var insights: [AssessmentInsight] = []
        
        let allPlants = store.pflanzen
        
        switch category {
        case .finance:
            let financePlants = allPlants.filter { $0.habitCategory == .finance }
            if financePlants.isEmpty {
                insights.append(AssessmentInsight(
                    titleKey: "assessment.insight.finance.no_habit.title",
                    descriptionKey: "assessment.insight.finance.no_habit.desc",
                    iconName: "exclamationmark.circle.fill",
                    iconColorName: "Red",
                    isPositive: false,
                    suggestedAction: .addHabit(category: .finance)
                ))
            } else {
                for plant in financePlants {
                    if !plant.hasActiveReminder {
                        insights.append(AssessmentInsight(
                            titleKey: "assessment.insight.missing_reminder.title",
                            descriptionKey: "assessment.insight.missing_reminder.desc",
                            iconName: "bell.badge.fill",
                            iconColorName: "Yellow",
                            isPositive: false,
                            suggestedAction: .setReminder(plantID: plant.plantID)
                        ))
                        break
                    }
                }
            }
            
        case .health, .fitness:
            let healthPlants = allPlants.filter { $0.habitCategory == .health || $0.habitCategory == .fitness }
            if healthPlants.isEmpty {
                insights.append(AssessmentInsight(
                    titleKey: "assessment.insight.health.no_habit.title",
                    descriptionKey: "assessment.insight.health.no_habit.desc",
                    iconName: "heart.slash.fill",
                    iconColorName: "Red",
                    isPositive: false,
                    suggestedAction: .addHabit(category: category == .health ? .health : .fitness)
                ))
            } else {
                for plant in healthPlants {
                    if plant.streak < 3 {
                        insights.append(AssessmentInsight(
                            titleKey: "assessment.insight.low_streak.title",
                            descriptionKey: "assessment.insight.low_streak.desc",
                            iconName: "flame.fill",
                            iconColorName: "Orange",
                            isPositive: false,
                            suggestedAction: .openPlant(plantID: plant.plantID)
                        ))
                        break
                    }
                }
            }
            
        case .mental, .growth:
            if store.focusSessions.isEmpty {
                insights.append(AssessmentInsight(
                    titleKey: "assessment.insight.no_focus.title",
                    descriptionKey: "assessment.insight.no_focus.desc",
                    iconName: "brain.head.profile",
                    iconColorName: "Purple",
                    isPositive: false,
                    suggestedAction: .startFocusSession
                ))
            } else {
                insights.append(AssessmentInsight(
                    titleKey: "assessment.insight.focus_active.title",
                    descriptionKey: "assessment.insight.focus_active.desc",
                    iconName: "checkmark.seal.fill",
                    iconColorName: "Green",
                    isPositive: true,
                    suggestedAction: nil
                ))
            }
            
        case .lifestyle:
            insights.append(AssessmentInsight(
                titleKey: "assessment.insight.lifestyle.review.title",
                descriptionKey: "assessment.insight.lifestyle.review.desc",
                iconName: "leaf.fill",
                iconColorName: "Green",
                isPositive: true,
                suggestedAction: nil
            ))
        }
        
        // General 90-Day Challenge Check
        if store.completed90DayChallenges == 0 && allPlants.contains(where: { plant in GameDatabase.allPlants.first(where: { p in p.id == plant.plantID })?.has90DayChallenge == true }) {
            insights.append(AssessmentInsight(
                titleKey: "assessment.insight.challenge_waiting.title",
                descriptionKey: "assessment.insight.challenge_waiting.desc",
                iconName: "trophy.fill",
                iconColorName: "Yellow",
                isPositive: false,
                suggestedAction: nil
            ))
        }
        
        return insights
    }
}
