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
    
    // Fortschritt: Wochentag / 7 (Mo=0...So=6)
    private var progress: Double {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date()) // 1=So, 2=Mo,...
        // Normalisieren: Mo=1...So=7
        let adjusted = (weekday + 5) % 7  // Mo=0...So=6
        return Double(adjusted) / 7.0
    }
    
    private var progressPercent: Int {
        Int(progress * 100)
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
                    VStack(alignment: .leading, spacing: 10) {
                        // Titel Zeile
                        HStack {
                            Text(goal.title)
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(.systemGray3))
                        }
                        
                        // Dicker grüner Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 12)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.green)
                                    .frame(width: max(geo.size.width * progress, progress > 0 ? 24 : 0), height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        // Labels
                        HStack {
                            Text(verbatim: "\(progressPercent)%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                            Spacer()
                            Text(String(localized: "goal.type.week", defaultValue: "Wochenziel"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
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
            .environmentObject(gardenStore)
        }
    }
}
