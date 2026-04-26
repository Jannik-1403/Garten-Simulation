import SwiftUI
import Combine

@MainActor
class TitelStore: ObservableObject {
    @Published var freigeschalteteTitelIDs: Set<String> = []
    @Published var aktiverTitelID: String? = nil
    @Published var neuerTitelZumAnzeigen: PlayerTitle? = nil  // für Overlay

    private let freigeschaltetKey = "freigeschalteteTitel"
    private let aktivKey = "aktiverTitel"

    init() {
        // UserDefaults laden
        if let data = SharedUserDefaults.suite.data(forKey: freigeschaltetKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            freigeschalteteTitelIDs = ids
        }
        aktiverTitelID = SharedUserDefaults.suite.string(forKey: aktivKey)

        // Anfänger-Titel immer verfügbar + Standard wenn noch nichts aktiv
        freigeschalteteTitelIDs.insert("titel_anfaenger")
        if aktiverTitelID == nil {
            aktiverTitelID = "titel_anfaenger"
        }
    }

    // Aufgerufen vom GardenStore wenn eine Pflanze Diamant erreicht
    func pruefUndSchalteFreiSofern(plantID: String) {
        // Suche passenden Titel in der Datenbank
        guard let titel = GameDatabase.allTitles.first(where: { $0.plantID == plantID }),
              !freigeschalteteTitelIDs.contains(titel.id) else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            freigeschalteteTitelIDs.insert(titel.id)
            speichernPublic()

            // Ersten Titel automatisch aktivieren falls noch keiner aktiv
            if aktiverTitelID == nil {
                aktiverTitelID = titel.id
                SharedUserDefaults.suite.set(aktiverTitelID, forKey: aktivKey)
            }

            neuerTitelZumAnzeigen = titel  // triggert Overlay
        }
    }

    func setzeAktivenTitel(_ titel: PlayerTitle) {
        aktiverTitelID = titel.id
        SharedUserDefaults.suite.set(titel.id, forKey: aktivKey)
        objectWillChange.send()
    }

    func aktiverTitel() -> PlayerTitle? {
        guard let id = aktiverTitelID else { return nil }
        return GameDatabase.allTitles.first(where: { $0.id == id })
    }

    func istFreigeschaltet(_ id: String) -> Bool {
        freigeschalteteTitelIDs.contains(id)
    }

    func freigeschalteteTitel() -> [PlayerTitle] {
        GameDatabase.allTitles.filter { freigeschalteteTitelIDs.contains($0.id) }
    }

    func alleTitel() -> [PlayerTitle] {
        GameDatabase.allTitles
    }

    func speichernPublic() {
        if let data = try? JSONEncoder().encode(freigeschalteteTitelIDs) {
            SharedUserDefaults.suite.set(data, forKey: freigeschaltetKey)
        }
        SharedUserDefaults.suite.set(aktiverTitelID, forKey: aktivKey)
    }
}
