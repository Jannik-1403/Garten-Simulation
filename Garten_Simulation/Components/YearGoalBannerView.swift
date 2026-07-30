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
    
    private var progressInCurrentLevel: Double {
        if currentLevel == 60 && pointsInCurrentLevel == 0 && pointsInfo.earned > 0 { return 1.0 }
        let ppl = pointsPerLevel
        if ppl == 0 { return 0 }
        return min(Double(pointsInCurrentLevel) / Double(ppl), 1.0)
    }
    
    private var progressPercentString: String {
        let percent = progressInCurrentLevel * 100
        if percent == 0 { return "0%" }
        if percent >= 100 { return "100%" }
        return String(format: "%.1f%%", percent) 
    }
    
    private var pointsInfo: (earned: Int, target: Int) {
        guard let goal = fiveYearGoal else { return (0, 0) }
        return goalStore.getPointsForFiveYears(goalId: goal.id)
    }
    
    private var currentLevel: Int {
        let (earned, target) = pointsInfo
        guard target > 0 else { return 1 }
        let ppl = pointsPerLevel
        if ppl == 0 { return 1 }
        let level = (earned / ppl) + 1
        return min(level, 60) // Max Level 60
    }
    
    private var pointsInCurrentLevel: Int {
        let (earned, target) = pointsInfo
        guard target > 0 else { return 0 }
        let ppl = pointsPerLevel
        if ppl == 0 { return 0 }
        return earned % ppl
    }
    
    private var pointsPerLevel: Int {
        let (_, target) = pointsInfo
        guard target > 0 else { return 1 }
        return target / 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let goal = fiveYearGoal {
                Button {
                    editTitle = goal.title
                    showEditSheet = true
                } label: {
                    VStack(spacing: 24) {
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
                                                .strokeBorder(style: progressInCurrentLevel == 0 ? StrokeStyle(lineWidth: 1.5, dash: [4, 4]) : StrokeStyle(lineWidth: 0))
                                                .foregroundColor(Color.gray.opacity(progressInCurrentLevel == 0 ? 0.3 : 0))
                                        )
                                    
                                    // Fill (Akzentfarbe)
                                    if progressInCurrentLevel > 0 {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(hex: "#4FC3F7"))
                                            .frame(width: max(geo.size.width * progressInCurrentLevel, 18), height: 18)
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
                                    Text(verbatim: "\(pointsInCurrentLevel) / \(pointsPerLevel) Pkt.")
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
                    .padding(.top, 40) // Etwas weiter nach unten gesetzt, damit Platz für Level ist
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                    .overlay(
                        Text("Level \(currentLevel)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#0288D1"))
                            .padding(.top, 16)
                            .padding(.leading, 16),
                        alignment: .topLeading
                    )

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
