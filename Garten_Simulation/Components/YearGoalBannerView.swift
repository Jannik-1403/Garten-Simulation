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
    
    private var progressPercent: Int {
        Int(progress * 100)
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
                            // Lower layer (shadow / accent color)
                            Text(goal.title)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#4FC3F7"))
                                .offset(y: 3)
                            
                            // Upper layer (Dunkleres Blau statt Anthrazit)
                            Text(goal.title)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(Color(hex: "#0277BD"))
                        }
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        
                        VStack(spacing: 12) {
                            // 2. Langer, dicker Fortschrittsbalken
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    // Track (Hellgrau mit gestrichelter Linie für mehr Details bei 0%)
                                    Capsule()
                                        .fill(Color(hex: "#F5F5F5"))
                                        .frame(height: 14)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                                .foregroundColor(Color.gray.opacity(0.3))
                                        )
                                    
                                    // Fill (Akzentfarbe)
                                    if progress > 0 {
                                        Capsule()
                                            .fill(Color(hex: "#4FC3F7"))
                                            .frame(width: max(geo.size.width * progress, 14), height: 14)
                                    }
                                }
                            }
                            .frame(height: 14)
                            
                            // 3. Prozentzahl und Text darunter
                            HStack {
                                Text(verbatim: "\(progressPercent)%")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4FC3F7"))
                                Spacer()
                                Text(String(localized: "goal.fiveyears.label.arrow", defaultValue: "5 Years →"))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4FC3F7"))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 24)
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
