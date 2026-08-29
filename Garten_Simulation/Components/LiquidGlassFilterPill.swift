import SwiftUI

struct LiquidGlassFilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Item3DPillButton(
            farbe: isSelected ? Color.blauPrimary : Color(UIColor.secondarySystemGroupedBackground),
            sekundaerFarbe: isSelected ? Color.blauPrimary.darker() : Color(UIColor.tertiarySystemGroupedBackground),
            groesse: 36,
            isPermanentlyPressed: isSelected,
            aktion: action
        ) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .white : .primary)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 8)
        }
    }
}
