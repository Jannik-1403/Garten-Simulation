import SwiftUI

extension View {
    func assessmentDismissToolbar(onDismiss: @escaping () -> Void) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .overlay(alignment: .topTrailing) {
                LiquidGlassDismissButton {
                    onDismiss()
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
            }
    }
}

struct ResultHabitsCard: View {
    let buildHabitsKey: String
    let breakHabitsKey: String
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 16) {
            HabitSection(
                title: String(localized: "assessment.habits.build.title"),
                icon: "plus.circle.fill",
                iconColor: .green,
                text: NSLocalizedString(buildHabitsKey, comment: "")
            )

            HabitSection(
                title: String(localized: "assessment.habits.break.title"),
                icon: "minus.circle.fill",
                iconColor: .red,
                text: NSLocalizedString(breakHabitsKey, comment: "")
            )
        }
        .padding(.horizontal, 20)
    }
}

struct AssessmentRetakeButton: View {
    let action: () -> Void
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        Button(action: action) {
            Label(
                String(localized: "assessment.btn.retake"),
                systemImage: "arrow.counterclockwise"
            )
            .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .buttonStyle(DuolingoButtonStyle(
            size: .medium,
            backgroundColor: Color(hex: "#4FC3F7"),
            shadowColor: Color(hex: "#0288D1"),
            foregroundColor: .white
        ))
        .padding(.horizontal, 20)
    }
}

struct HabitSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let text: String

    private let shadowDepth: CGFloat = 6
    private var topColor: Color { Color(UIColor.systemBackground) }
    private var shadowColor: Color { Color.secondary.opacity(0.18) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .textCase(.uppercase)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary.opacity(0.85))
                .lineSpacing(4)
                .padding(.leading, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(topColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(shadowColor)
                .offset(y: shadowDepth)
        )
        .padding(.bottom, shadowDepth)
    }
}
