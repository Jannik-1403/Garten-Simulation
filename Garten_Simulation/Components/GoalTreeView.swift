import SwiftUI

// MARK: - Goal Tree View
// Stammbaum-Ansicht: Oben das 5-Jahresziel, darunter Monat, Woche, dann Gewohnheiten

struct GoalTreeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var goalStore = GoalStore.shared
    @EnvironmentObject var gardenStore: GardenStore
    
    @State private var addingType: GoalType? = nil
    @State private var newGoalTitle = ""
    
    private var fiveYearGoal: GoalModel? {
        goalStore.activeGoals.first { $0.type == .year }
    }
    
    private var currentMonthGoal: GoalModel? {
        let cal = Calendar.current
        let now = Date()
        return goalStore.activeGoals.first {
            $0.type == .month &&
            cal.component(.month, from: $0.createdAt) == cal.component(.month, from: now) &&
            cal.component(.year, from: $0.createdAt) == cal.component(.year, from: now)
        }
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
    
    private var linkedHabits: [HabitModel] {
        guard let goal = fiveYearGoal else { return [] }
        return Array(goalStore.habitLinks
            .filter { $0.goalId == goal.id && $0.weight != .none }
            .compactMap { link in
                gardenStore.pflanzen.first { $0.id.uuidString == link.habitId }
            }
            .prefix(4))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 24)
                        
                        // Level 1: 5-Jahresziel
                        treeNode(
                            level: 0,
                            iconName: "star.fill",
                            iconColor: .yellow,
                            label: String(localized: "goal.type.year", defaultValue: "5-Jahresziel"),
                            value: fiveYearGoal?.title,
                            emptyLabel: String(localized: "goal.tree.add.year", defaultValue: "5-Jahresziel festlegen"),
                            color: .yellow,
                            addAction: { addingType = .year }
                        )
                        
                        connector()
                        
                        // Level 2: Monatsziel
                        treeNode(
                            level: 1,
                            iconName: "calendar",
                            iconColor: .blauPrimary,
                            label: String(localized: "goal.type.month", defaultValue: "Monatsziel"),
                            value: currentMonthGoal?.title,
                            emptyLabel: String(localized: "goal.tree.add.month", defaultValue: "Monatsziel setzen"),
                            color: .blauPrimary,
                            addAction: { addingType = .month }
                        )
                        
                        connector()
                        
                        // Level 3: Wochenziel
                        treeNode(
                            level: 1,
                            iconName: "flag.fill",
                            iconColor: .orange,
                            label: String(localized: "goal.type.week", defaultValue: "Wochenziel"),
                            value: currentWeekGoal?.title,
                            emptyLabel: String(localized: "goal.tree.add.week", defaultValue: "Wochenziel setzen"),
                            color: .orange,
                            addAction: { addingType = .week }
                        )
                        
                        connector()
                        
                        // Level 4: Gewohnheiten Fundament
                        habitFoundation()
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle(String(localized: "goal.tree.title", defaultValue: "Dein Ziel-Stammbaum"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { addingType != nil },
            set: { if !$0 { addingType = nil; newGoalTitle = "" } }
        )) {
            addGoalSheet()
        }
    }
    
    // MARK: - Tree Node
    @ViewBuilder
    private func treeNode(
        level: Int,
        iconName: String,
        iconColor: Color,
        label: String,
        value: String?,
        emptyLabel: String,
        color: Color,
        addAction: @escaping () -> Void
    ) -> some View {
        let hasGoal = value != nil
        
        Item3DButton(
            farbe: hasGoal ? Color(.systemBackground) : color.opacity(0.12),
            sekundaerFarbe: hasGoal ? Color(.systemGray5) : color.opacity(0.25),
            groesse: level == 0 ? 80 : 60,
            isRectangular: true,
            aktion: hasGoal ? {} : addAction
        ) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: level == 0 ? 22 : 17, weight: .bold))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(label.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.secondary)
                        .kerning(1.1)
                    
                    if let val = value {
                        Text(val)
                            .font(.system(size: level == 0 ? 20 : 17, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                    } else {
                        Text(emptyLabel)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(color)
                    }
                }
                
                Spacer()
                
                if hasGoal {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 20))
                } else {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(color)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
    
    // MARK: - Connector
    @ViewBuilder
    private func connector() -> some View {
        HStack {
            Spacer().frame(width: 38)
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: 2, height: 32)
            Spacer()
        }
    }
    
    // MARK: - Habit Foundation
    @ViewBuilder
    private func habitFoundation() -> some View {
        Item3DButton(
            farbe: Color(.systemBackground),
            sekundaerFarbe: Color(.systemGray5),
            groesse: 60,
            isRectangular: true,
            aktion: {}
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(String(localized: "goal.tree.habits.title", defaultValue: "FUNDAMENT").uppercased())
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .kerning(1.1)
                        Text(String(localized: "goal.tree.habits.subtitle", defaultValue: "Gewohnheiten, Routinen & To-dos"))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    
                    Text(verbatim: "\(gardenStore.pflanzen.filter { !$0.isDead }.count)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                }
                
                if !linkedHabits.isEmpty {
                    Divider()
                    VStack(spacing: 6) {
                        ForEach(linkedHabits, id: \.id) { habit in
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))
                                Text(habit.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
    
    // MARK: - Add Goal Sheet
    @ViewBuilder
    private func addGoalSheet() -> some View {
        NavigationView {
            Form {
                if let type = addingType {
                    Section(header: Text(goalPrompt(for: type))) {
                        TextField(goalPlaceholder(for: type), text: $newGoalTitle)
                    }
                }
            }
            .navigationTitle(addingType.map { String(localized: $0.localizationKey) } ?? "")
            .navigationBarItems(
                leading: Button(String(localized: "common.cancel")) {
                    addingType = nil
                    newGoalTitle = ""
                },
                trailing: Button(String(localized: "common.save")) {
                    if !newGoalTitle.isEmpty, let type = addingType {
                        let newGoal = GoalModel(title: newGoalTitle, type: type)
                        goalStore.addGoal(newGoal)
                        addingType = nil
                        newGoalTitle = ""
                    }
                }
                .disabled(newGoalTitle.isEmpty)
            )
        }
        .presentationDetents([.medium])
    }
    
    private func goalPrompt(for type: GoalType) -> String {
        switch type {
        case .year: return String(localized: "goal.tree.prompt.year", defaultValue: "Deine große Vision für die nächsten 5 Jahre")
        case .month: return String(localized: "goal.tree.prompt.month", defaultValue: "Dein Fokus diesen Monat")
        case .week: return String(localized: "goal.tree.prompt.week", defaultValue: "Dein wichtigstes Ziel diese Woche")
        }
    }
    
    private func goalPlaceholder(for type: GoalType) -> String {
        switch type {
        case .year: return String(localized: "goal.tree.placeholder.year", defaultValue: "Z.B. 10 Mio. Umsatz aufbauen")
        case .month: return String(localized: "goal.tree.placeholder.month", defaultValue: "Z.B. 300 Punkte erreichen")
        case .week: return String(localized: "goal.tree.placeholder.week", defaultValue: "Z.B. 3x ins Gym gehen")
        }
    }
}

#Preview {
    GoalTreeView()
        .environmentObject(GardenStore())
}
