import SwiftUI

struct YearGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    
    private var currentYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentYearGoal {
                VStack(spacing: 12) {
                    Text(String(localized: "goal.type.year", defaultValue: "1-Jahresziel"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(1.2)
                    
                    Text(goal.title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    ProgressView(value: 0.0) // Platzhalter für Progress
                        .progressViewStyle(.linear)
                        .tint(.blauPrimary)
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.top, 8)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(Color(.systemBackground))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
                .padding(.horizontal, 24)
            }
        }
    }
}
