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
    
    private var progress: Double {
        guard let goal = currentWeekGoal else { return 0 }
        return goalStore.progressForWeek(goalId: goal.id)
    }
    
    private var progressPercent: Int {
        Int(progress * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let goal = currentWeekGoal {
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
                                    // Track (Hellgrau mit gestrichelter Linie für mehr Details bei 0%)
                                    Capsule()
                                        .fill(Color(hex: "#F5F5F5"))
                                        .frame(height: 18)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                                .foregroundColor(Color.gray.opacity(0.3))
                                        )
                                    
                                    // Fill (Akzentfarbe)
                                    if progress > 0 {
                                        Capsule()
                                            .fill(Color(hex: "#4FC3F7"))
                                            .frame(width: max(geo.size.width * progress, 18), height: 18)
                                    }
                                }
                            }
                            .frame(height: 18)
                            
                            // 3. Prozentzahl und Text darunter
                            HStack {
                                Text(verbatim: "\(progressPercent)%")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4FC3F7"))
                                Spacer()
                                Text(String(localized: "goal.weekly.label.arrow", defaultValue: "Woche →"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4FC3F7"))
                            }
                        }
                        .padding(.horizontal, 4) // Weniger Padding, Balken länger
                    }
                    .padding(.top, 32) // Etwas weiter nach unten gesetzt
                    .padding(.bottom, 24)
                    .padding(.horizontal, 20)
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
                        Text(String(localized: "goal.weekly.add", defaultValue: "Wochenziel festlegen"))
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
                existingGoal: currentWeekGoal,
                type: .week,
                editTitle: $editTitle,
                goalStore: goalStore
            )
            .environmentObject(gardenStore)
        }
    }
}
