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
            Item3DText(text: String(localized: "goal.link.title", defaultValue: "Ziel-Beitrag"), size: 28, color: .blauPrimary)
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
                    
                    Item3DButton(
                        farbe: Color(UIColor.systemGray5),
                        sekundaerFarbe: Color(UIColor.systemGray4),
                        groesse: 44,
                        isRectangular: true,
                        aktion: { dismiss() }
                    ) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text(String(localized: "goal.link.none", defaultValue: "Gar nicht (0 Pkt)"))
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                Text(String(localized: "goal.link.no_goal", defaultValue: "Kein Jahresziel gesetzt."))
                    .foregroundColor(.secondary)
                Item3DButton(
                    farbe: Color.blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.darker(),
                    groesse: 44,
                    isRectangular: true,
                    aktion: { dismiss() }
                ) {
                    Text(String(localized: "common.ok", defaultValue: "OK"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
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
        Item3DButton(
            farbe: color,
            sekundaerFarbe: color.darker(),
            groesse: 44,
            isRectangular: true,
            aktion: action
        ) {
            HStack {
                Image(systemName: icon)
                Text(NSLocalizedString(weight.localizationKey, comment: ""))
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}
