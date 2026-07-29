import SwiftUI

struct MonthlyGoalBannerView: View {
    @ObservedObject var goalStore = GoalStore.shared
    @State private var showGoalInput = false
    @State private var newGoalTitle = ""
    
    private var currentMonthGoal: GoalModel? {
        // Für den echten Fall: Hole das Monatsziel für diesen Monat
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return goalStore.activeGoals.first { goal in
            goal.type == .month &&
            calendar.component(.month, from: goal.createdAt) == currentMonth &&
            calendar.component(.year, from: goal.createdAt) == currentYear
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let goal = currentMonthGoal {
                // Schlanker schwebender Banner
                HStack(spacing: 12) {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "goal.type.month", defaultValue: "Monatsziel").uppercased())
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                            .kerning(1.2)
                        Text(goal.title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    ProgressView(value: 0.0)
                        .progressViewStyle(.circular)
                        .tint(.blauPrimary)
                        .scaleEffect(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 16)
            } else {
                // Kein Monatsziel gesetzt - Schlanker Button
                Button {
                    showGoalInput = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blauPrimary)
                        Text(String(localized: "goal.monthly.add", defaultValue: "Monatsziel setzen"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showGoalInput) {
            NavigationView {
                Form {
                    Section(header: Text(String(localized: "goal.monthly.prompt", defaultValue: "Was ist dein Fokus diesen Monat?"))) {
                        TextField(String(localized: "goal.monthly.placeholder", defaultValue: "Z.B. 300 Punkte erreichen"), text: $newGoalTitle)
                    }
                }
                .navigationTitle(String(localized: "goal.monthly.title", defaultValue: "Monatsziel"))
                .navigationBarItems(
                    leading: Button("Abbrechen") { showGoalInput = false },
                    trailing: Button("Speichern") {
                        if !newGoalTitle.isEmpty {
                            let newGoal = GoalModel(title: newGoalTitle, type: .month)
                            goalStore.addGoal(newGoal)
                            showGoalInput = false
                        }
                    }
                )
            }
        }
    }
}
