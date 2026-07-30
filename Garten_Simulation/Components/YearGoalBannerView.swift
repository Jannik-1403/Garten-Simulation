import SwiftUI

struct YearGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    @State private var showEditSheet = false
    @State private var editTitle = ""
    
    private var fiveYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    private var progress: Double {
        guard let goal = fiveYearGoal else { return 0 }
        return goalStore.progressForFiveYears(goalId: goal.id)
    }
    
    private var progressPercentString: String {
        let percent = progress * 100
        if percent == 0 { return "0%" }
        if percent >= 100 { return "100%" }
        return String(format: "%.2f%%", percent) // 2 decimal places to see progress faster
    }
    
    private var pointsInfo: (earned: Int, target: Int) {
        guard let goal = fiveYearGoal else { return (0, 0) }
        return goalStore.getPointsForFiveYears(goalId: goal.id)
    }
    
    private var currentLevel: Int {
        let (earned, target) = pointsInfo
        guard target > 0 else { return 1 }
        // 5 Jahre = 60 Monate = 60 Level. Ein Level ist ein Monat voller Punkte.
        let pointsPerLevel = target / 60
        if pointsPerLevel == 0 { return 1 }
        let level = (earned / pointsPerLevel) + 1
        return min(level, 60) // Max Level 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let goal = fiveYearGoal {
                Button {
                    editTitle = goal.title
                    showEditSheet = true
                } label: {
                    VStack(spacing: 24) {
                        // Level Anzeige oben links
                        HStack {
                            Text("Level \(currentLevel)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#4FC3F7").opacity(0.15))
                                .foregroundColor(Color(hex: "#0288D1"))
                                .clipShape(Capsule())
                            Spacer()
                        }
                        
                        // 1. Titel im 3D-Stil
                        ZStack {
                            // Lower layer (Dunkleres Blau für den Schatten/3D-Tiefe)
                            Text(goal.title)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#0288D1"))
                                .offset(y: 4)
                            
                            // Upper layer (Leuchtendes Blau für die Front)
                            Text(goal.title)
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#4FC3F7"))
                        }
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 12) {
                            // 2. Langer, dicker Fortschrittsbalken
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    // Track (Hellgrau, gestrichelt NUR bei 0%)
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#F5F5F5"))
                                        .frame(height: 18)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(style: progress == 0 ? StrokeStyle(lineWidth: 1.5, dash: [4, 4]) : StrokeStyle(lineWidth: 0))
                                                .foregroundColor(Color.gray.opacity(progress == 0 ? 0.3 : 0))
                                        )
                                    
                                    // Fill (Akzentfarbe)
                                    if progress > 0 {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "#4FC3F7"))
                                            .frame(width: max(geo.size.width * progress, 18), height: 18)
                                    }
                                }
                            }
                            .frame(height: 18)
                            
                            // 3. Prozentzahl und Text darunter
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(verbatim: progressPercentString)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#4FC3F7"))
                                    Text(verbatim: "\(pointsInfo.earned) / \(pointsInfo.target) Pkt.")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color.gray)
                                }
                                Spacer()
                                Text(String(localized: "goal.fiveyears.label.arrow", defaultValue: "5 Years →"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4FC3F7"))
                            }
                        }
                        .padding(.horizontal, 4) // Weniger Padding, Balken länger
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle()) // Macht den gesamten Banner-Bereich klickbar

                }
                .buttonStyle(.plain)
                .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))
                .padding(.horizontal, 24)
            } else {
                Button {
                    editTitle = ""
                    showEditSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image("Goal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text(String(localized: "goal.fiveyears.add", defaultValue: "5-Jahres Ziel festlegen"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "#4FC3F7"))
                            .font(.title2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .contentShape(Rectangle()) // Macht den gesamten Banner-Bereich klickbar
                }
                .buttonStyle(.plain)
                .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))
                .padding(.horizontal, 24)
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
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
