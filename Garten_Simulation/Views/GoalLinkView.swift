import SwiftUI

struct GoalLinkView: View {
    let habitId: String
    let habitName: String
    
    @ObservedObject var goalStore = GoalStore.shared
    @Environment(\.dismiss) var dismiss
    
    var yearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"))
                .font(.title2.bold())
                .padding(.top, 20)
            
            if let goal = yearGoal {
                Text(String(format: NSLocalizedString("goal.link.question", comment: ""), habitName, goal.title))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    GoalWeightButton(weight: .massive, icon: "flame.fill", color: .orange) {
                        goalStore.linkHabitToGoal(habitId: habitId, goalId: goal.id, weight: .massive)
                        dismiss()
                    }
                    
                    GoalWeightButton(weight: .bit, icon: "leaf.fill", color: .green) {
                        goalStore.linkHabitToGoal(habitId: habitId, goalId: goal.id, weight: .bit)
                        dismiss()
                    }
                    
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text(String(localized: "goal.link.none", defaultValue: "Gar nicht (0 Pkt)"))
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                Text(String(localized: "goal.link.no_goal", defaultValue: "Kein Jahresziel gesetzt."))
                    .foregroundColor(.secondary)
                Button("OK") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
    }
}

struct GoalWeightButton: View {
    let weight: GoalWeight
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(NSLocalizedString(weight.localizationKey, comment: ""))
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
        }
    }
}
