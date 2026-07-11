import SwiftUI

struct CheatPunishmentOverlay: View {
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 20) {
            Text(String(localized: "cheat_punishment.title", defaultValue: "🚨 SYSTEMZUGRIFF BLOCKIERT"))
                .font(.title).bold()
                .foregroundColor(.black)
            
            Text(String(localized: "cheat_punishment.message", defaultValue: "Du hast die App- & Website-Aktivitäten in den iOS-Einstellungen deaktiviert. Damit hast du das Fundament deines Gartens zerstört."))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding()
            
            Text(String(localized: "cheat_punishment.warning", defaultValue: "Dein Garten verliert aktuell jede Stunde 1 Leben. Schalte die Bildschirmzeit in den Einstellungen wieder ein, um das Sterben zu stoppen."))
                .foregroundColor(.gray)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(String(localized: "cheat_punishment.button.settings", defaultValue: "Zu den Einstellungen")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            gardenStore.punishForCheating()
        }
    }
}
