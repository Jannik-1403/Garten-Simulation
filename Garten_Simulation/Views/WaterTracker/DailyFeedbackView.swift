import SwiftUI

// MARK: - DailyHealthScoreCard
// Ersetzt die alte FitnessOverviewCard.
// Zeigt einen kumulierten Tages-Score. Beim Ausklappen werden nur noch
// problematische Bereiche (Warnungen/Kritisch) als "Begründung" angezeigt.

struct DailyHealthScoreCard: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Kopfzeile (Score)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Score Ring (3D Style)
                    ZStack {
                        // Hintergrund-Ring mit leichtem Inner-Shadow-Effekt
                        Circle()
                            .stroke(Color(white: 0.92), lineWidth: 7)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
                        
                        // Fortschritts-Ring (Gradient)
                        Circle()
                            .trim(from: 0, to: CGFloat(vm.dailyScore) / 100.0)
                            .stroke(
                                scoreColor.gradient,
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8), value: vm.dailyScore)
                            .shadow(color: scoreColor.opacity(0.5), radius: 4, x: 0, y: 2)
                        
                        // Score Text (Glücksrad-Style: Sehr fett + Schatten)
                        Text("\(vm.dailyScore)")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                            .shadow(color: .black.opacity(0.15), radius: 1, x: 1, y: 2)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "fitness.score.title", defaultValue: "Tages-Score"))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(vm.headerText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // MARK: Ausgeklappte Begründung (Nur Issues)
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 16) {
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
                        .padding(.vertical, 12)
                    } else {
                        // Begründungen für Warnungen/Kritische Punkte
                        ForEach(vm.issueFeedbacks) { feedback in
                            CategoryIssueRow(feedback: feedback)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        // "iTunes 3-D weißer Hintergrund"
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1) // Leichter Border-Schatten
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8) // Tiefer 3D-Schatten
        )
    }

    private var scoreColor: Color {
        if vm.dailyScore >= 80 { return Color(.systemGreen) }
        if vm.dailyScore >= 50 { return Color(.systemOrange) }
        return Color(.systemRed)
    }
}

// MARK: - CategoryIssueRow

private struct CategoryIssueRow: View {
    let feedback: CategoryFeedback

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: feedback.category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(statusColor)
                .frame(width: 24, height: 24)
                .padding(.top, 2)

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

    private var statusColor: Color {
        switch feedback.status {
        case .good:        return Color(.systemGreen)
        case .warning:     return Color(.systemOrange)
        case .critical:    return Color(.systemRed)
        case .unavailable: return Color(.tertiaryLabel)
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
