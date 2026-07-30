import SwiftUI

struct WeeklyGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @State private var showGoalInput = false
    @State private var newGoalTitle = ""
    
    private var currentWeekGoal: GoalModel? {
        let calendar = Calendar.current
        let currentWeek = calendar.component(.weekOfYear, from: Date())
        let currentYear = calendar.component(.yearForWeekOfYear, from: Date())
        
        return goalStore.activeGoals.first { goal in
            goal.type == .week &&
            calendar.component(.weekOfYear, from: goal.createdAt) == currentWeek &&
            calendar.component(.yearForWeekOfYear, from: goal.createdAt) == currentYear
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentWeekGoal {
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(.systemGray5),
                    groesse: 60,
                    isRectangular: true,
                    aktion: { showGoalInput = true } // Or maybe show details/edit
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(localized: "goal.type.week"))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text(goal.title)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        
                        ProgressView(value: 0.0) // Platzhalter für echten Progress
                            .progressViewStyle(.linear)
                            .tint(.orange)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    }
                    .padding(20)
                }
            } else {
                Item3DButton(
                    farbe: Color.blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.darker(),
                    groesse: 56,
                    isRectangular: true,
                    aktion: { showGoalInput = true }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text(String(localized: "goal.weekly.add", defaultValue: "Wochenziel festlegen"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(20)
                }
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showGoalInput) {
            NavigationView {
                Form {
                    Section(header: Text(String(localized: "goal.weekly.prompt", defaultValue: "Was ist dein wichtigstes Ziel für diese Woche?"))) {
                        TextField(String(localized: "goal.weekly.placeholder", defaultValue: "Z.B. 3x ins Gym gehen"), text: $newGoalTitle)
                    }
                }
                .navigationTitle(String(localized: "goal.type.week"))
                .navigationBarItems(
                    leading: Button(String(localized: "common.cancel")) { showGoalInput = false },
                    trailing: Button(String(localized: "common.save")) {
                        if !newGoalTitle.isEmpty {
                            let newGoal = GoalModel(title: newGoalTitle, type: .week)
                            goalStore.addGoal(newGoal)
                            showGoalInput = false
                        }
                    }
                )
            }
            .presentationDetents([.medium])
        }
    }
}
