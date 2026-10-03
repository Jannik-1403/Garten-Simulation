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
        let isBtnDisabled = isDisabled || (delta < 0 ? value <= 0 : value >= target)
        return Item3DButton(
            icon: systemImage,
            farbe: .orangePrimary,
            sekundaerFarbe: Color.orangePrimary.darker(),
            groesse: 52,
            iconSkalierung: 0.45,
            isDisabled: isBtnDisabled
        ) {
            onChange(value + delta)
        }
        .buttonRepeatBehavior(.enabled)
    }
}

#Preview {
    @Previewable @State var count = 12
    HabitCounterControl(value: count, target: 50, unit: "Liegestütze") { count = min(max(0, $0), 50) }
        .padding()
}
