import SwiftUI

struct CheatPunishmentOverlay: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
                .padding(.bottom, 10)
            
            Text(String(localized: "cheat_punishment.title", defaultValue: "🚨 SYSTEMZUGRIFF BLOCKIERT"))
                .font(.title2).bold()
                .foregroundColor(.black)
            
            Text(String(localized: "cheat_punishment.message", defaultValue: "Du hast die App- & Website-Aktivitäten in den iOS-Einstellungen deaktiviert. Damit hast du das Fundament deines Gartens zerstört."))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal, 30)
            
            Text(String(localized: "cheat_punishment.warning", defaultValue: "Dein Garten verliert aktuell jede Stunde 1 Leben. Schalte die Bildschirmzeit in den Einstellungen wieder ein, um das Sterben zu stoppen."))
                .foregroundColor(.gray)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Item3DButton(
                farbe: .black,
                sekundaerFarbe: Color(UIColor.darkGray),
                groesse: 60,
                isRectangular: true,
                aktion: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            ) {
                Text(String(localized: "cheat_punishment.button.settings", defaultValue: "Zu den Einstellungen"))
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            gardenStore.punishForCheating()
        }
    }
}
