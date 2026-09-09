import SwiftUI

// MARK: - DailyFeedbackView

struct DailyFeedbackView: View {
    @StateObject private var vm = DailyFeedbackViewModel()
    @ObservedObject private var feedbackStore = FeedbackStore.shared

    var body: some View {
        VStack(spacing: 10) {
            // Feedback-Text: kein Card, kein Rahmen, zentriert
            Text(vm.feedbackText)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.3), value: vm.feedbackText)

            // Daumen-Buttons
            HStack(spacing: 28) {
                ThumbButton(
                    isUp: true,
                    currentRating: feedbackStore.todayRatingValue(forKey: vm.currentKey.rawValue)
                ) {
                    feedbackStore.rate(key: vm.currentKey.rawValue, value: .up)
                }

                ThumbButton(
                    isUp: false,
                    currentRating: feedbackStore.todayRatingValue(forKey: vm.currentKey.rawValue)
                ) {
                    feedbackStore.rate(key: vm.currentKey.rawValue, value: .down)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ThumbButton

private struct ThumbButton: View {
    let isUp: Bool
    let currentRating: FeedbackRatingValue
    let action: () -> Void

    private var isActive: Bool {
        isUp ? currentRating == .up : currentRating == .down
    }

    private var activeColor: Color {
        isUp ? Color(.systemGreen) : Color(.systemRed)
    }

    private var iconName: String {
        isUp ? "hand.thumbsup" : "hand.thumbsdown"
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isActive ? activeColor : Color(.tertiaryLabel))
                .contentShape(Rectangle())
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isUp
            ? String(localized: "feedback.thumb.up", defaultValue: "Hilfreich")
            : String(localized: "feedback.thumb.down", defaultValue: "Nicht hilfreich"))
    }
}

#Preview {
    DailyFeedbackView()
        .padding()
}
