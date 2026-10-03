import SwiftUI

/// Zähler-Steuerung für Gewohnheiten mit numerischem Tagesziel
/// (z. B. 50 Liegestütze = 100 %). Gedrückt halten auf +/− wiederholt die Aktion.
struct HabitCounterControl: View {
    let value: Int
    let target: Int
    let unit: String?
    var isDisabled: Bool = false
    let onChange: (Int) -> Void

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(value) / Double(target))
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                counterButton(systemImage: "minus", delta: -1)
                    .disabled(isDisabled || value <= 0)

                VStack(spacing: 2) {
                    Text(verbatim: "\(value) / \(target)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(value)))
                        .foregroundStyle(Color.primary)
                    if let unit, !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)

                counterButton(systemImage: "plus", delta: 1)
                    .disabled(isDisabled || value >= target)
            }

            HStack(spacing: 10) {
                ProgressView(value: progress)
                    .tint(Color.orangePrimary)
                Text(verbatim: "\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.orangePrimary)
                    .monospacedDigit()
                    .frame(width: 45, alignment: .trailing)
            }
        }
        .animation(.snappy, value: value)
        .sensoryFeedback(.selection, trigger: value)
    }

    private func counterButton(systemImage: String, delta: Int) -> some View {
        Button {
            onChange(value + delta)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .black))
                .frame(width: 52, height: 52)
                .foregroundStyle(.white)
                .background(Circle().fill(Color.orangePrimary))
        }
        .buttonStyle(.plain)
        .buttonRepeatBehavior(.enabled)
        .opacity(isDisabled ? 0.4 : 1)
    }
}

#Preview {
    @Previewable @State var count = 12
    HabitCounterControl(value: count, target: 50, unit: "Liegestütze") { count = min(max(0, $0), 50) }
        .padding()
}
