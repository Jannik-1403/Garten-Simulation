import SwiftUI

/// Zeigt bei einer Pflanze, wie viele Punkte sie zum 5-Jahresziel und Wochenziel beiträgt.
/// Ganz unten in der PflanzeDetailSheet, nach dem Verkaufen-Button.
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
    
    private func weightFor(goal: GoalModel) -> GoalWeight? {
        goalStore.weightForHabit(habitId: pflanze.id, goalId: goal.id)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // 5-Jahresziel Punkte
            if let goal = fiveYearGoal {
                let weight = weightFor(goal: goal)
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(.systemGray5),
                    groesse: 56,
                    isRectangular: true,
                    aktion: { showYearWeightSheet = true }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "goal.type.year", defaultValue: "5-Jahresziel"))
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
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(col)
                        } else {
                            Text(String(localized: "goal.link.none.short", defaultValue: "Nicht verknüpft"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .sheet(isPresented: $showYearWeightSheet) {
                    GoalWeightEditSheet(pflanze: pflanze, goal: goal, goalStore: goalStore)
                }
            }
            
            // Wochenziel Punkte
            if let goal = currentWeekGoal {
                let weight = weightFor(goal: goal)
                Item3DButton(
                    farbe: Color(.systemBackground),
                    sekundaerFarbe: Color(.systemGray5),
                    groesse: 56,
                    isRectangular: true,
                    aktion: { showWeekWeightSheet = true }
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 16))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "goal.type.week", defaultValue: "Wochenziel"))
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
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(col)
                        } else {
                            Text(String(localized: "goal.link.none.short", defaultValue: "Nicht verknüpft"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .sheet(isPresented: $showWeekWeightSheet) {
                    GoalWeightEditSheet(pflanze: pflanze, goal: goal, goalStore: goalStore)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Quick Weight Edit Sheet (inline für einzelnes Ziel)
struct GoalWeightEditSheet: View {
    let pflanze: HabitModel
    let goal: GoalModel
    @ObservedObject var goalStore: GoalStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedWeight: GoalWeight = .none
    
    private var goalColor: Color {
        switch goal.type {
        case .year: return .yellow
        case .month: return .blauPrimary
        case .week: return .orange
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text(NSLocalizedString(goal.type.localizationKey, comment: ""))
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(1.2)
                    Text(goal.title)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                Divider()
                
                Text(String(localized: "goal.link.question", defaultValue: "Wie sehr trägt diese Gewohnheit bei?"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                HStack(spacing: 12) {
                    ForEach([GoalWeight.massive, .bit, .none], id: \.self) { weight in
                        let baseColor: Color = weight == .massive ? .green : (weight == .bit ? .orange : .red)
                        let isSelected = selectedWeight == weight
                        
                        Item3DButton(
                            farbe: isSelected ? baseColor : Color(UIColor.systemGray5),
                            sekundaerFarbe: isSelected ? baseColor.darker() : Color(UIColor.systemGray4),
                            groesse: 56,
                            isRectangular: true,
                            aktion: { selectedWeight = weight }
                        ) {
                            VStack(spacing: 4) {
                                Text(verbatim: "\(weight.rawValue)")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(isSelected ? .white : baseColor)
                                Text("Pkt")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(isSelected ? .white.opacity(0.8) : baseColor.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
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
}
