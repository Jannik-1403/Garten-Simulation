import SwiftUI

struct DynamicAssessmentInsightsView: View {
    let category: AssessmentInsightCategory
    let color: Color
    @EnvironmentObject var gardenStore: GardenStore
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(String(localized: "assessment.insight.header", defaultValue: "Was man verbessern kann"))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, -8)
            
            let insights = AssessmentInsightGenerator.generateInsights(for: category, store: gardenStore)
            
            if insights.isEmpty {
                Text(String(localized: "assessment.insight.empty", defaultValue: "Im Moment sieht alles gut aus! Bleib am Ball."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 16) {
                            Image(insight.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .scaleEffect(insight.iconName == "Goal" ? 2.2 : 1.0)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(PercentHelper.localizedWithPercents(insight.titleKey))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(PercentHelper.localizedWithPercents(insight.descriptionKey))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let action = insight.suggestedAction {
                                    Button(action: {
                                        handleAction(action)
                                    }) {
                                        Text(buttonText(for: action))
                                    }
                                    .buttonStyle(DuolingoButtonStyle(
                                        size: .small,
                                        fillWidth: false,
                                        backgroundColor: color,
                                        shadowColor: color.darker()
                                    ))
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                    
                    if index < insights.count - 1 {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .padding(24)
        .scoreCardStyle()
        .padding(.horizontal, 20)
        .sheet(isPresented: $showGenericFocusSetup) {
            GenericFocusTimerSetupSheet { habit in
                genericFocusHabit = habit
            }
        }
        .fullScreenCover(item: $genericFocusHabit) { habit in
            GenericFocusSessionContainer(habit: habit)
        }
        .sheet(item: $selectedPlant) { plant in
            PflanzeDetailSheet(pflanze: plant)
        }
        .sheet(isPresented: $showShop) {
            UnifiedShopView()
        }
    }
    
    @State private var showGenericFocusSetup = false
    @State private var genericFocusHabit: HabitModel? = nil
    @State private var selectedPlant: HabitModel? = nil
    @State private var showShop = false
    
    private func buttonText(for action: InsightAction) -> String {
        switch action {
        case .openPlant:
            return String(localized: "assessment.insight.action.open_plant", defaultValue: "Details ansehen")
        case .setReminder:
            return String(localized: "assessment.insight.action.set_reminder", defaultValue: "Erinnerung setzen")
        case .startFocusSession:
            return String(localized: "assessment.insight.action.start_focus", defaultValue: "Fokus-Modus testen")
        case .addHabit:
            return String(localized: "assessment.insight.action.add_habit", defaultValue: "Challenge annehmen")
        }
    }
    
    private func handleAction(_ action: InsightAction) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        switch action {
        case .startFocusSession:
            showGenericFocusSetup = true
        case .openPlant(let plantID), .setReminder(let plantID):
            if let plant = gardenStore.pflanzen.first(where: { $0.plantID == plantID }) {
                selectedPlant = plant
            }
        case .addHabit:
            showShop = true
        }
        
        // Navigation or handling logic will depend on how Assessment is presented.
        // For now, we can try to dismiss and post a notification, or handle it via AppState if present.
        NotificationCenter.default.post(name: NSNotification.Name("AssessmentActionRequested"), object: nil, userInfo: ["action": action])
    }
}
