import SwiftUI

struct MonthlyGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showEditSheet = false
    @State private var editTitle = ""
    
    private var currentMonthGoal: GoalModel? {
        let calendar = Calendar.current
        let now = Date()
        return goalStore.activeGoals.first { goal in
            goal.type == .month &&
            calendar.component(.month, from: goal.createdAt) == calendar.component(.month, from: now) &&
            calendar.component(.year, from: goal.createdAt) == calendar.component(.year, from: now)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentMonthGoal {
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(UIColor.systemGray5),
                    groesse: 44,
                    isRectangular: true,
                    aktion: {
                        editTitle = goal.title
                        showEditSheet = true
                    }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blauPrimary)
                            .font(.system(size: 15, weight: .bold))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "goal.type.month", defaultValue: "Monatsziel").uppercased())
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.secondary)
                                .kerning(1.2)
                            Text(goal.title)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
            } else {
                Item3DButton(
                    farbe: Color.blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.darker(),
                    groesse: 44,
                    isRectangular: true,
                    aktion: {
                        editTitle = ""
                        showEditSheet = true
                    }
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                        Text(String(localized: "goal.monthly.add", defaultValue: "Monatsziel setzen"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 16)
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            GoalEditSheet(
                existingGoal: currentMonthGoal,
                type: .month,
                editTitle: $editTitle,
                goalStore: goalStore
            )
            .environmentObject(gardenStore)
        }
    }
}
