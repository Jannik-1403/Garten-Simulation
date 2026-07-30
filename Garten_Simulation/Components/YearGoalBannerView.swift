import SwiftUI

struct YearGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showEditSheet = false
    @State private var editTitle = ""
    
    private var fiveYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    private var linkedHabitsCount: Int {
        guard let goal = fiveYearGoal else { return 0 }
        return goalStore.habitLinks.filter { $0.goalId == goal.id && $0.weight != .none }.count
    }
    
    private var totalPoints: Int {
        guard let goal = fiveYearGoal else { return 0 }
        return goalStore.goalLogs.filter { $0.goalId == goal.id }.reduce(0) { $0 + $1.pointsEarned }
    }
    
    private var topHabitName: String? {
        guard let goal = fiveYearGoal else { return nil }
        let logs = goalStore.goalLogs.filter { $0.goalId == goal.id }
        guard !logs.isEmpty else { return nil }
        let counts = Dictionary(grouping: logs, by: \.habitId).mapValues { $0.reduce(0) { $0 + $1.pointsEarned } }
        if let topId = counts.max(by: { $0.value < $1.value })?.key {
            return gardenStore.pflanzen.first { $0.id == topId }?.name
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = fiveYearGoal {
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(.systemGray5),
                    groesse: 80,
                    isRectangular: true,
                    aktion: {
                        editTitle = goal.title
                        showEditSheet = true
                    }
                ) {
                    VStack(spacing: 10) {
                        Text(String(localized: "goal.type.year", defaultValue: "5-Jahresziel"))
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .kerning(1.4)
                        
                        Text(goal.title)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        HStack(spacing: 16) {
                            Label(
                                title: { Text(verbatim: "\(totalPoints) Pkt").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.blauPrimary) },
                                icon: { Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12)) }
                            )
                            Label(
                                title: { Text(verbatim: "\(linkedHabitsCount) Habits").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.green) },
                                icon: { Image(systemName: "leaf.fill").foregroundColor(.green).font(.system(size: 12)) }
                            )
                            if let top = topHabitName {
                                Label(
                                    title: { Text(top).font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary).lineLimit(1) },
                                    icon: { Image(systemName: "crown.fill").foregroundColor(.orange).font(.system(size: 12)) }
                                )
                            }
                            Spacer()
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                }
            } else {
                Item3DButton(
                    farbe: Color.yellow.opacity(0.12),
                    sekundaerFarbe: Color.yellow.opacity(0.25),
                    groesse: 60,
                    isRectangular: true,
                    aktion: {
                        editTitle = ""
                        showEditSheet = true
                    }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text(String(localized: "goal.year.add", defaultValue: "5-Jahresziel festlegen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.yellow)
                    }
                    .padding(20)
                }
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showEditSheet) {
            GoalEditSheet(
                existingGoal: fiveYearGoal,
                type: .year,
                editTitle: $editTitle,
                goalStore: goalStore
            )
        }
    }
}
