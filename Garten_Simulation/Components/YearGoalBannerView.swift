import SwiftUI

struct YearGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    var onTap: (() -> Void)? = nil
    @State private var showGoalInput = false
    @State private var newGoalTitle = ""
    private var currentYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentYearGoal {
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(.systemGray5),
                    groesse: 60,
                    isRectangular: true,
                    aktion: { onTap?() }
                ) {
                    VStack(spacing: 12) {
                        Text(String(localized: "goal.type.year", defaultValue: "5-Jahresziel"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .kerning(1.2)
                        
                        Text(goal.title)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        ProgressView(value: 0.0)
                            .progressViewStyle(.linear)
                            .tint(.blauPrimary)
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .padding(.top, 8)
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                }
                .padding(.horizontal, 24)
            } else {
                Item3DButton(
                    farbe: Color.yellow.opacity(0.12),
                    sekundaerFarbe: Color.yellow.opacity(0.25),
                    groesse: 60,
                    isRectangular: true,
                    aktion: { onTap?() }
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
                .padding(.horizontal, 24)
            }
        }
    }
}
