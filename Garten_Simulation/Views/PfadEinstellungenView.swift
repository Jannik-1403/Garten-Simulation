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
                    Text(settings.localizedString(for: "pfad_schwierigkeit_hinweis"))
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
                        Text(settings.localizedString(for: "pfad_zuruecksetzen_button"))
                    }
                }
            }
        }
        .navigationTitle(settings.localizedString(for: "pfad_einstellungen_titel"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            settings.localizedString(for: "pfad_zuruecksetzen_titel"),
            isPresented: $zeigeResetBestaetigung
        ) {
            Button(settings.localizedString(for: "pfad_zuruecksetzen_bestaetigen"), role: .destructive) {
                pfadStore.pfadZuruecksetzen(settings: settings, gardenStore: gardenStore)
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) {}
        } message: {
            Text(settings.localizedString(for: "pfad_zuruecksetzen_nachricht"))
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
