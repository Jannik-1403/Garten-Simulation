import SwiftUI

// Ein kompakter Badge, der die neue SeltenheitsStufe mit Icon und Farbverlauf anzeigt.
struct SeltenheitsBadge: View {
    let stufe: SeltenheitsStufe
    var zeigeTitel: Bool = true
    var kompakt: Bool = false

    var body: some View {
        let paddingV: CGFloat = kompakt ? 4 : 6
        let paddingH: CGFloat = kompakt ? 8 : 10
        let iconSize: CGFloat = kompakt ? 12 : 14
        let fontSize: CGFloat = kompakt ? 12 : 13

        HStack(spacing: 6) {
            Image(systemName: stufe.iconName)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: iconSize, weight: .semibold))
            if zeigeTitel {
                Text(stufe.titel)
                    .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, paddingV)
        .padding(.horizontal, paddingH)
        .background(stufe.gradient)
        .clipShape(Capsule())
        .shadow(color: stufe.secondaryColor.opacity(0.35), radius: 3, x: 0, y: 2)
        .accessibilityLabel("Seltenheit: \(stufe.titel)")
    }
}

#Preview {
    VStack(spacing: 12) {
        SeltenheitsBadge(stufe: .bronze)
        SeltenheitsBadge(stufe: .silber)
        SeltenheitsBadge(stufe: .gold)
        SeltenheitsBadge(stufe: .platin)
        HStack(spacing: 8) {
            SeltenheitsBadge(stufe: .gold, zeigeTitel: false)
            SeltenheitsBadge(stufe: .silber, kompakt: true)
        }
    }
    .padding()
    .background(Color.appHintergrund)
}
