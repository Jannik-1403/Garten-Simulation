import SwiftUI

// MARK: - FitnessOverviewCard
// Aufklappbare Fitness-Übersicht mit einer Zeile pro Kategorie.
// Kopfzeile zeigt nur Problembereiche: "Achtung bei: Wasser, Schlaf"

struct FitnessOverviewCard: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @ObservedObject private var feedbackStore = FeedbackStore.shared
    @State private var expandedCategory: FitnessCategory? = nil

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Kopfzeile (immer sichtbar)
            headerRow

            if !vm.categoryFeedbacks.isEmpty {
                Divider()
                    .padding(.leading, 16)
            }

            // MARK: Kategorie-Zeilen
            ForEach(Array(vm.categoryFeedbacks.enumerated()), id: \.element.id) { index, feedback in
                VStack(spacing: 0) {
                    CategoryRow(
                        feedback: feedback,
                        isExpanded: expandedCategory == feedback.category
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            expandedCategory = expandedCategory == feedback.category ? nil : feedback.category
                        }
                    }

                    if index < vm.categoryFeedbacks.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Kopfzeile
    private var headerRow: some View {
        HStack(spacing: 12) {
            // Status-Punkt
            Circle()
                .fill(headerColor)
                .frame(width: 8, height: 8)

            Text(vm.headerText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .animation(.easeInOut(duration: 0.2), value: vm.headerText)

            Spacer()

            // Daumen-Buttons
            HStack(spacing: 20) {
                ThumbButton(
                    isUp: true,
                    currentRating: feedbackStore.todayRatingValue(forKey: vm.primaryKey.rawValue)
                ) {
                    feedbackStore.rate(key: vm.primaryKey.rawValue, value: .up)
                }
                ThumbButton(
                    isUp: false,
                    currentRating: feedbackStore.todayRatingValue(forKey: vm.primaryKey.rawValue)
                ) {
                    feedbackStore.rate(key: vm.primaryKey.rawValue, value: .down)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var headerColor: Color {
        let hasCritical = vm.categoryFeedbacks.contains { $0.status == .critical }
        let hasWarning  = vm.categoryFeedbacks.contains { $0.status == .warning }
        if hasCritical { return Color(.systemRed) }
        if hasWarning  { return Color(.systemOrange) }
        return Color(.systemGreen)
    }
}

// MARK: - CategoryRow

private struct CategoryRow: View {
    let feedback: CategoryFeedback
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Kompakte Zeile
            HStack(spacing: 12) {
                // Icon + Status-Farbe
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: feedback.category.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(statusColor)
                }

                // Summary
                Text(feedback.summaryText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Chevron
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)

            // Aufgeklappter Detail-Text
            if isExpanded {
                Text(feedback.detailText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 60)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
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
}

// MARK: - ThumbButton (shared)

struct ThumbButton: View {
    let isUp: Bool
    let currentRating: FeedbackRatingValue
    let action: () -> Void

    private var isActive: Bool {
        isUp ? currentRating == .up : currentRating == .down
    }

    private var activeColor: Color {
        isUp ? Color(.systemGreen) : Color(.systemRed)
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: isUp ? "hand.thumbsup" : "hand.thumbsdown")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isActive ? activeColor : Color(.tertiaryLabel))
                .contentShape(Rectangle())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isUp
            ? String(localized: "feedback.thumb.up",   defaultValue: "Hilfreich")
            : String(localized: "feedback.thumb.down", defaultValue: "Nicht hilfreich"))
    }
}

#Preview {
    FitnessOverviewCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
