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
                // Quest-Tracker Stil
                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.yellow)
                    Item3DText(text: goal.title, size: 16, color: .primary)
                    Spacer()
                    // Kleiner Fortschrittsbalken (z.B. basierend auf Punkten im Monat, hier vereinfacht)
                    ProgressView(value: 0.3)
                        .progressViewStyle(.linear)
                        .frame(width: 60)
                        .tint(.blauPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
            } else {
                // Kein Monatsziel gesetzt
                Item3DButton(
                    farbe: Color.blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.darker(),
                    groesse: 44,
                    isRectangular: true,
                    aktion: { showGoalInput = true }
                ) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(String(localized: "goal.monthly.add", defaultValue: "Neues Monatsziel setzen"))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
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
