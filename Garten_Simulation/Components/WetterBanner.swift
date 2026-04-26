import SwiftUI

struct WetterBanner: View {
    let event: WetterEvent
    var aktion: (() -> Void)? = nil

    var body: some View {
        Item3DButton(
            farbe: event.bannerFarbe,
            sekundaerFarbe: event.bannerFarbeSekundaer,
            groesse: 66, // Standard height for the banner
            isRectangular: true,
            aktion: aktion
        ) {
            HStack(spacing: 12) {
                Image(systemName: event.systemIcon)
                    .font(.system(size: 24, weight: .semibold))

                VStack(alignment: .leading, spacing: 0) {
                    Text(event.untertitel)
                        .font(.caption)
                        .opacity(0.85)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(event.titel)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1, height: 28)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 12) {
        WetterBanner(event: .normal)
        WetterBanner(event: .regen)
        WetterBanner(event: .schnee)
    }
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.97))
}
