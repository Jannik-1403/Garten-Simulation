import SwiftUI

struct PfadEinstellungenView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore

    @State private var zeigeResetBestaetigung = false

    var body: some View {
        List {
            // ... (rest of sections)


            // Info-Banner
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blauPrimary)
                    Text(String(localized: "pfad_schwierigkeit_hinweis"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.blauPrimary.opacity(0.06))
            }

            // Zurücksetzen
            Section {
                Button(role: .destructive) {
                    zeigeResetBestaetigung = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text(String(localized: "pfad_zuruecksetzen_button"))
                    }
                }
            }
        }
        .navigationTitle(String(localized: "pfad_einstellungen_titel"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            String(localized: "pfad_zuruecksetzen_titel"),
            isPresented: $zeigeResetBestaetigung
        ) {
            Button(String(localized: "pfad_zuruecksetzen_bestaetigen"), role: .destructive) {
                pfadStore.pfadZuruecksetzen(settings: settings, gardenStore: gardenStore)
            }
            Button(String(localized: "button.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "pfad_zuruecksetzen_nachricht"))
        }
    }
}

#Preview {
    let settings = SettingsStore()
    NavigationStack {
        PfadEinstellungenView()
            .environmentObject(settings)
            .environmentObject(GartenPfadStore(settings: settings))
            .environmentObject(GardenStore())
    }
}
