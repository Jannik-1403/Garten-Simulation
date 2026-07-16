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
                            ZStack {
                                Circle()
                                    .fill(insight.isPositive ? Color.green.opacity(0.15) : AppColors.color(for: insight.iconColorName).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(insight.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                            .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(String(localized: String.LocalizationValue(insight.titleKey)))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(String(localized: String.LocalizationValue(insight.descriptionKey)))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let action = insight.suggestedAction {
                                    Button(action: {
                                        handleAction(action)
                                    }) {
                                        Text(buttonText(for: action))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(color.opacity(0.15))
                                            .foregroundColor(color)
                                            .cornerRadius(12)
                                    }
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
    }
    
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
        
        // Navigation or handling logic will depend on how Assessment is presented.
        // For now, we can try to dismiss and post a notification, or handle it via AppState if present.
        NotificationCenter.default.post(name: NSNotification.Name("AssessmentActionRequested"), object: nil, userInfo: ["action": action])
    }
}
