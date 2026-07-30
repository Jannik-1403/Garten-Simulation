import SwiftUI

struct YearGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showEditSheet = false
    @State private var editTitle = ""
    
    private var fiveYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    // Fortschritt: Anteil der vergangenen Zeit in 5 Jahren
    private var progress: Double {
        guard let goal = fiveYearGoal else { return 0 }
        let total: Double = 5 * 365 * 24 * 3600
        let elapsed = Date().timeIntervalSince(goal.createdAt)
        return min(max(elapsed / total, 0), 1)
    }
    
    private var progressPercent: Int {
        Int(progress * 100)
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
                            Text(String(localized: "goal.label.fiveyears", defaultValue: "5 Jahre"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
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
            .environmentObject(gardenStore)
        }
    }
}
