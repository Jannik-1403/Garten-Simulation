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
                    VStack(spacing: 16) {
                        // Titel mittig drinnen im 3D-Stil (wie Glücksrad)
                        HStack {
                            Spacer()
                            ZStack {
                                // Lower layer (shadow)
                                Text(goal.title)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.blauPrimary.opacity(0.35))
                                    .offset(y: 4)

                                // Upper layer (visible text)
                                Text(goal.title)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.blauPrimary)
                            }
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                            Spacer()
                        }
                        
                        // Dicker 3D Progress Bar in Grün
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
                                
                                // Fill
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
                            Text(String(localized: "goal.label.fiveyears", defaultValue: "5 Jahre"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color.green.darker())
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.green.darker())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28) // Mehr Platz unten
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
                            .foregroundColor(.orange)
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
