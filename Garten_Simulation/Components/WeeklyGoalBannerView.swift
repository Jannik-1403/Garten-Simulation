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
                    farbe: .white,
                    sekundaerFarbe: Color(UIColor.systemGray5),
                    groesse: 90,
                    isRectangular: true,
                    aktion: {
                        editTitle = goal.title
                        showEditSheet = true
                    }
                ) {
                    VStack(spacing: 14) {
                        // Titel Zeile
                        HStack {
                            Spacer()
                            Text(goal.title)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(UIColor.systemGray3))
                        }
                        
                        // Dicker 3D Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Track
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGray5))
                                    .frame(height: 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                
                                // Fill
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.darker()]), startPoint: .top, endPoint: .bottom)
                                    )
                                    .frame(width: max(geo.size.width * progress, progress > 0 ? 16 : 0), height: 16)
                                    .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            }
                        }
                        .frame(height: 16)
                        
                        // Labels
                        HStack {
                            Text(verbatim: "\(progressPercent)%")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color.green.darker())
                            Spacer()
                            Text(String(localized: "goal.type.week", defaultValue: "Wochenziel"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color.green.darker())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            } else {
                Item3DButton(
                    farbe: .white,
                    sekundaerFarbe: Color(UIColor.systemGray5),
                    groesse: 70,
                    isRectangular: true,
                    aktion: {
                        editTitle = ""
                        showEditSheet = true
                    }
                ) {
                    HStack(spacing: 12) {
                        Image("Goal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text(String(localized: "goal.weekly.add", defaultValue: "Wochenziel festlegen"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
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
