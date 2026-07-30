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
        
        Button {
            showSheet.wrappedValue = true
        } label: {
            HStack(spacing: 14) {
                // Icon 2.2x größer als vorher
                Image("Goal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundColor(iconColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(NSLocalizedString(goal.type.localizationKey, comment: ""))
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(0.8)
                    Text(goal.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
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
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary) // Pfeil so schwarz wie bei To-Dos
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
        }
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        .buttonStyle(.plain)
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
        
        Item3DButton(
            farbe: isSelected ? color : Color(UIColor.systemGray5),
            sekundaerFarbe: isSelected ? color.darker() : Color(UIColor.systemGray4),
            groesse: 65,
            isRectangular: true,
            aktion: { selectedWeight = weight }
        ) {
            VStack(spacing: 6) {
                Text(label)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(isSelected ? .white : color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
    }
}
