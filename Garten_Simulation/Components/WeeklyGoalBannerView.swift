import SwiftUI

struct WeeklyGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showEditSheet = false
    @State private var editTitle = ""
    
    private var currentWeekGoal: GoalModel? {
        let cal = Calendar.current
        let now = Date()
        return goalStore.activeGoals.first {
            $0.type == .week &&
            cal.component(.weekOfYear, from: $0.createdAt) == cal.component(.weekOfYear, from: now) &&
            cal.component(.yearForWeekOfYear, from: $0.createdAt) == cal.component(.yearForWeekOfYear, from: now)
        }
    }
    
    // Punkte die diese Woche für dieses Wochenziel gesammelt wurden
    private var weeklyPoints: Int {
        guard let goal = currentWeekGoal else { return 0 }
        let cal = Calendar.current
        let now = Date()
        return goalStore.goalLogs
            .filter {
                $0.goalId == goal.id &&
                cal.component(.weekOfYear, from: $0.date) == cal.component(.weekOfYear, from: now) &&
                cal.component(.yearForWeekOfYear, from: $0.date) == cal.component(.yearForWeekOfYear, from: now)
            }
            .reduce(0) { $0 + $1.pointsEarned }
    }
    
    // Top Habit für diese Woche
    private var topHabitName: String? {
        guard let goal = currentWeekGoal else { return nil }
        let cal = Calendar.current
        let now = Date()
        let thisWeekLogs = goalStore.goalLogs.filter {
            $0.goalId == goal.id &&
            cal.component(.weekOfYear, from: $0.date) == cal.component(.weekOfYear, from: now)
        }
        guard !thisWeekLogs.isEmpty else { return nil }
        let counts = Dictionary(grouping: thisWeekLogs, by: \.habitId).mapValues { $0.reduce(0) { $0 + $1.pointsEarned } }
        if let topId = counts.max(by: { $0.value < $1.value })?.key {
            return gardenStore.pflanzen.first { $0.id == topId }?.name
        }
        return nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentWeekGoal {
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
                        Text(String(localized: "goal.type.week", defaultValue: "Wochenziel"))
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .kerning(1.4)
                        
                        Text(goal.title)
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        HStack(spacing: 16) {
                            Label(
                                title: { Text(verbatim: "\(weeklyPoints) Pkt").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.orange) },
                                icon: { Image(systemName: "flame.fill").foregroundColor(.orange).font(.system(size: 12)) }
                            )
                            if let top = topHabitName {
                                Label(
                                    title: { Text(top).font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary).lineLimit(1) },
                                    icon: { Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12)) }
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
                    farbe: Color.orange.opacity(0.12),
                    sekundaerFarbe: Color.orange.opacity(0.25),
                    groesse: 60,
                    isRectangular: true,
                    aktion: {
                        editTitle = ""
                        showEditSheet = true
                    }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        Text(String(localized: "goal.weekly.add", defaultValue: "Wochenziel festlegen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                    }
                    .padding(20)
                }
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showEditSheet) {
            GoalEditSheet(
                existingGoal: currentWeekGoal,
                type: .week,
                editTitle: $editTitle,
                goalStore: goalStore
            )
        }
    }
}
