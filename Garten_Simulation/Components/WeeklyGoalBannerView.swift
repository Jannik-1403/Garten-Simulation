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
        VStack(alignment: .leading, spacing: 8) {
            if let goal = currentWeekGoal {
                // Titel oben drüber
                HStack {
                    Text(goal.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 2)
                
                Item3DButton(
                    farbe: .white,
                    sekundaerFarbe: Color(UIColor.systemGray5),
                    groesse: 65,
                    isRectangular: true,
                    aktion: {
                        editTitle = goal.title
                        showEditSheet = true
                    }
                ) {
                    VStack(spacing: 14) {
                        // Dicker 3D Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Track
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.systemGray6))
                                    .frame(height: 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                    )
                                
                                // Fill (3D Look für den Progress Bar)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.darker())
                                        .frame(height: 16)
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green)
                                        .frame(height: 16)
                                        .offset(y: -2)
                                }
                                .frame(width: max(geo.size.width * progress, progress > 0 ? 16 : 0))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.green.darker())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 24)
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
                .padding(.horizontal, 24)
            }
        }
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
