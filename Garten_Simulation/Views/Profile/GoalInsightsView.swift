import SwiftUI

struct GoalInsightsView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    
    var currentMonthGoal: GoalModel? {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return goalStore.activeGoals.first { goal in
            goal.type == .month &&
            calendar.component(.month, from: goal.createdAt) == currentMonth &&
            calendar.component(.year, from: goal.createdAt) == currentYear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "goal.insights.title", defaultValue: "Ziel-Analysen"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            if let goal = currentMonthGoal {
                let pointsDict = goalStore.calculatePointsForCurrentMonth(goalId: goal.id)
                let rankedHabits = pointsDict.sorted { $0.value > $1.value }
                
                if rankedHabits.isEmpty {
                    Text(String(localized: "goal.insights.empty", defaultValue: "Noch keine Punkte in diesem Monat gesammelt. Gieße deine Pflanzen!"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(rankedHabits.enumerated()), id: \.element.key) { index, element in
                            let (habitId, points) = element
                            if let habit = gardenStore.sichtbarePflanzen.first(where: { $0.id == habitId }) {
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Image(systemName: habit.symbolName)
                                        .foregroundColor(Color(habit.symbolColor))
                                        .font(.title3)
                                    
                                    Text(habit.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("\(points) Pkt")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            } else {
                Text(String(localized: "goal.insights.no_goal", defaultValue: "Kein Monatsziel für Analysen gesetzt."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
}
