import SwiftUI

struct StreakIceInfoPopup: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()

                VStack(spacing: 24) {
                    Item3DButton(
                        icon: "flame.fill",
                        farbe: Color.cyan,
                        sekundaerFarbe: Color.blue,
                        groesse: 90,
                        isPermanentlyPressed: false,
                        isDisabled: false
                    )
                    .padding(.top, 30)

                    Text(String(localized: "pfad.ice.title", defaultValue: "Streak-Eis"))
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.primary)

                    Text(String(localized: "pfad.ice.desc", defaultValue: "Das Streak-Eis schützt deinen Streak. Du verlierst ihn nicht, wenn du an einem Tag nicht gießt.\n\nDu erhältst 1 neues Eis für jede vollendete Woche (7 Tage Ring). Maximal 3 Eis können gleichzeitig aktiv sein."))
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Spacer()

                    Item3DButton(
                        farbe: Color(hex: "#58CC02"),
                        sekundaerFarbe: Color(hex: "#3a8000"),
                        groesse: 56,
                        isRectangular: true,
                        aktion: {
                            dismiss()
                        }
                    ) {
                        Text(String(localized: "common.verstanden", defaultValue: "Verstanden"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
