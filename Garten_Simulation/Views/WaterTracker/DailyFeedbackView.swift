import SwiftUI

struct DailyHealthScoreCard: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @EnvironmentObject var gardenStore: GardenStore
    @State private var isExpanded: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                // MARK: Kopfzeile (Score)
                HStack(spacing: 16) {
                    MiniChunkyProgressRing(progress: Double(vm.dailyScore), goal: 100)
                        .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "fitness.score.title", defaultValue: "Tages-Score"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)

                // MARK: Ausgeklappte Begründung (Nur Issues)
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        // Divider
                        Rectangle()
                            .fill(Color(.tertiaryLabel).opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 16)

                        if vm.issueFeedbacks.isEmpty {
                            // Alles perfekt
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(.systemGreen))
                                Text(String(localized: "fitness.score.perfect", defaultValue: "Perfekt! Alle deine Werte liegen im optimalen Bereich. Weiter so!"))
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        } else {
                            // Begründungen für Warnungen/Kritische Punkte
                            VStack(spacing: 16) {
                                ForEach(vm.issueFeedbacks) { feedback in
                                    CategoryIssueRow(feedback: feedback)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(PillButtonStyle(
            farbe: .white,
            sekundaerFarbe: Color(white: 0.85),
            cornerRadius: 16,
            shadowDepth: 6
        ))
        .onAppear {
            vm.activeHabits = gardenStore.sichtbarePflanzen
            vm.reevaluate()
        }
        .onChange(of: gardenStore.sichtbarePflanzen) { newHabits in
            vm.activeHabits = newHabits
            vm.reevaluate()
        }
    }
}

// MARK: - MiniChunkyProgressRing

private struct MiniChunkyProgressRing: View {
    var progress: Double
    var goal: Double
    
    var percent: Double {
        if goal <= 0 { return 0 }
        return min(1.0, progress / goal)
    }
    
    var scoreColor: Color {
        if progress >= 80 { return Color(.systemGreen) }
        if progress >= 50 { return Color(.systemOrange) }
        return Color(.systemRed)
    }
    
    var body: some View {
        ZStack {
            // Background Shadow
            Circle()
                .stroke(scoreColor.opacity(0.15), lineWidth: 8)
                .offset(y: 2)
            
            // Background Track
            Circle()
                .stroke(scoreColor.opacity(0.2), lineWidth: 8)
            
            // Foreground Progress Shadow
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(scoreColor.opacity(0.5), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .offset(y: 2)
            
            // Foreground Progress
            Circle()
                .trim(from: 0.0, to: percent)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                
            VStack(spacing: 0) {
                Text("\(Int(progress))")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(scoreColor)
            }
        }
    }
}

// MARK: - CategoryIssueRow

private struct CategoryIssueRow: View {
    let feedback: CategoryFeedback

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(categoryName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(feedback.detailText)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var categoryName: String {
        switch feedback.category {
        case .water:     return String(localized: "fitness.category.water.analysis",     defaultValue: "Tägliche Wasseranalyse")
        case .sleep:     return String(localized: "fitness.category.sleep.analysis",     defaultValue: "Tägliche Schlafanalyse")
        case .strength:  return String(localized: "fitness.category.strength.analysis",  defaultValue: "Tägliche Kraftanalyse")
        case .running:   return String(localized: "fitness.category.running.analysis",   defaultValue: "Tägliche Laufanalyse")
        case .nutrition: return String(localized: "fitness.category.nutrition.analysis", defaultValue: "Tägliche Ernährungsanalyse")
        }
    }
}

#Preview {
    DailyHealthScoreCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
