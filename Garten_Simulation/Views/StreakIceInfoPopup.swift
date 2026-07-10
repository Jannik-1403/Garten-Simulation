import SwiftUI

struct StreakIceInfoPopup: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("Streak_Eis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .shadow(color: .cyan.opacity(0.3), radius: 10, y: 5)
                    .padding(.top, 40)

                Text(String(localized: "pfad.ice.title", defaultValue: "Streak-Eis"))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.primary)

                Text(String(localized: "pfad.ice.desc", defaultValue: "Das Streak-Eis schützt deinen Streak. Du verlierst ihn nicht, wenn du an einem Tag nicht gießt.\n\nDu erhältst 1 neues Eis für jede vollendete Woche (7 Tage Ring). Maximal 3 Eis können gleichzeitig aktiv sein."))
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}
