import SwiftUI

/// Zeigt bei einer Pflanze, wie viele Punkte sie zum 5-Jahresziel und Wochenziel beiträgt.
struct GoalPointsBannerView: View {
    let pflanze: HabitModel
    @ObservedObject var goalStore: GoalStore
    @State private var showYearWeightSheet = false
    @State private var showWeekWeightSheet = false
    
    private var fiveYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    private var currentWeekGoal: GoalModel? {
        let cal = Calendar.current
        let now = Date()
        return goalStore.activeGoals.first {
            $0.type == .week &&
            cal.component(.weekOfYear, from: $0.createdAt) == cal.component(.weekOfYear, from: now) &&
            cal.component(.yearForWeekOfYear, from: $0.createdAt) == cal.component(.yearForWeekOfYear, from: now)
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            if let goal = fiveYearGoal {
                goalRow(
                    goal: goal,
                    iconName: "star.fill",
                    iconColor: .yellow,
                    showSheet: $showYearWeightSheet
                )
                .sheet(isPresented: $showYearWeightSheet) {
                    GoalWeightEditSheet(pflanze: pflanze, goal: goal, goalStore: goalStore)
                }
            }
            
            if let goal = currentWeekGoal {
                goalRow(
                    goal: goal,
                    iconName: "flag.fill",
                    iconColor: .orange,
                    showSheet: $showWeekWeightSheet
                )
                .sheet(isPresented: $showWeekWeightSheet) {
                    GoalWeightEditSheet(pflanze: pflanze, goal: goal, goalStore: goalStore)
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func goalRow(goal: GoalModel, iconName: String, iconColor: Color, showSheet: Binding<Bool>) -> some View {
        let weight = goalStore.weightForHabit(habitId: pflanze.id, goalId: goal.id)
        
        Item3DButton(
            farbe: Color(.systemBackground),
            sekundaerFarbe: Color(.systemGray5),
            groesse: 60,
            isRectangular: true,
            aktion: { showSheet.wrappedValue = true }
        ) {
            HStack(spacing: 14) {
                // Icon 2.25x größer, nichts anderes verschoben
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 36, weight: .bold)) // 2.25x von 16pt
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString(goal.type.localizationKey, comment: ""))
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                    Text(goal.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if let w = weight {
                    let col: Color = w == .massive ? .green : (w == .bit ? .orange : .red)
                    Text(verbatim: "\(w.rawValue) Pkt")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(col)
                } else {
                    Text(String(localized: "goal.link.none.short", defaultValue: "Nicht verknüpft"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Weight Edit Sheet
struct GoalWeightEditSheet: View {
    let pflanze: HabitModel
    let goal: GoalModel
    @ObservedObject var goalStore: GoalStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWeight: GoalWeight = .none
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    Text(NSLocalizedString(goal.type.localizationKey, comment: ""))
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(1.2)
                    Text(goal.title)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)
                
                Divider()
                
                Text(String(localized: "goal.link.question", defaultValue: "Wie stark trägt diese Gewohnheit bei?"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                
                // Saubere 3 Buttons nebeneinander
                HStack(spacing: 10) {
                    weightButton(weight: .massive, label: "20 Pkt", color: .green)
                    weightButton(weight: .bit, label: "5 Pkt", color: .orange)
                    weightButton(weight: .none, label: "0 Pkt", color: .red)
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .navigationTitle(pflanze.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        goalStore.linkHabitToGoal(habitId: pflanze.id, goalId: goal.id, weight: selectedWeight)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            selectedWeight = goalStore.weightForHabit(habitId: pflanze.id, goalId: goal.id) ?? .none
        }
    }
    
    @ViewBuilder
    private func weightButton(weight: GoalWeight, label: String, color: Color) -> some View {
        let isSelected = selectedWeight == weight
        
        Button {
            selectedWeight = weight
        } label: {
            VStack(spacing: 6) {
                Text(label)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? .white : color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.1))
                    .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : color.opacity(0.3), lineWidth: isSelected ? 0 : 1.5)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}
