import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class GartenPfadStore: ObservableObject {
    @Published var pfadTage: [PfadTag] = []
    @Published var istPfadAktiv: Bool = false
    @Published var aktuellerTagIndex: Int = 0
    @Published var zeigeMeilensteinOverlay: Bool = false
    @Published var letzterMeilensteinTitel: String = ""
    @Published var belohnungsText: String = ""
    
    private var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        ladePfad()
    }
    
    func setContext(_ context: ModelContext, settings: SettingsStore, gardenStore: GardenStore) {
        self.modelContext = context
        ladePfad()
        // Jetzt wo Context da ist, Nachholen prüfen
        pfadNachholenFallsNoetig(settings: settings, gardenStore: gardenStore)
    }
    
    func ladePfad() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<PfadTag>(sortBy: [SortDescriptor(\.tagNummer)])
        do {
            pfadTage = try context.fetch(descriptor)
            istPfadAktiv = !pfadTage.isEmpty
            updateAktuellerTagIndex()
        } catch {
            print("Fehler beim Laden des Pfads: \(error)")
        }
    }
    
    func pfadStarten(ziel: String, pflanzeEins: String, pflanzeZwei: String) {
        guard let context = modelContext else { return }
        
        // Alten Pfad löschen falls vorhanden
        try? context.delete(model: PfadTag.self)
        
        let vorlagen = PfadDatenbank.pfadGenerieren(ziel: ziel, pflanzeEins: pflanzeEins, pflanzeZwei: pflanzeZwei)
        let heute = Calendar.current.startOfDay(for: Date())
        
        for vorlage in vorlagen {
            let datum = Calendar.current.date(byAdding: .day, value: vorlage.tagNummer - 1, to: heute)
            let tag = PfadTag(
                tagNummer: vorlage.tagNummer,
                titel: vorlage.titelKey,
                beschreibung: vorlage.beschreibungKey,
                pflanzenIDs: (vorlage.tagNummer <= 7) ? [pflanzeEins] : [pflanzeEins, pflanzeZwei],
                istErledigt: false,
                istMeilenstein: vorlage.istMeilenstein,
                neuerPflanzenHinweis: vorlage.neuerPflanzenHinweis,
                phase: vorlage.phase,
                datum: datum
            )
            context.insert(tag)
        }
        
        try? context.save()
        ladePfad()
    }
    
    func tagErledigen(tag: PfadTag, gardenStore: GardenStore, settings: SettingsStore) {
        guard !tag.istErledigt else { return }
        
        // Nur heute oder Vergangenheit erledigen möglich
        if let datum = tag.datum, datum > Date() {
            // Optional: User Feedback dass es noch nicht Zeit ist
            return
        }
        
        tag.istErledigt = true
        
        // Belohnung
        gardenStore.xpHinzufuegen(amount: 50)
        gardenStore.coinsGutschreiben(amount: 20, beschreibung: settings.localizedString(for: "pfad_tag_erledigt_belohnung"))
        
        if tag.istMeilenstein {
            meilensteinBelohnungAusloesen(tag: tag, gardenStore: gardenStore, settings: settings)
        }
        
        try? modelContext?.save()
        objectWillChange.send()
        updateAktuellerTagIndex()
    }
    
    private func meilensteinBelohnungAusloesen(tag: PfadTag, gardenStore: GardenStore, settings: SettingsStore) {
        let coins = 100
        let xp = 500
        
        if tag.tagNummer == 90 {
            gardenStore.coinsGutschreiben(amount: coins, beschreibung: settings.localizedString(for: "pfad_abgeschlossen_belohnung"))
            gardenStore.xpHinzufuegen(amount: xp)
            let pattern = settings.localizedString(for: "pfad_belohnung_meisterschaft")
            belohnungsText = String(format: pattern, coins, xp)
        } else {
            // Normale Meilensteine (7, 14, 30, 60)
            let mCoins = 50
            let mXP = 100
            gardenStore.coinsGutschreiben(amount: mCoins, beschreibung: settings.localizedString(for: "pfad_meilenstein_belohnung"))
            gardenStore.xpHinzufuegen(amount: mXP)
            let pattern = settings.localizedString(for: "pfad_belohnung_meilenstein")
            belohnungsText = String(format: pattern, mCoins, mXP)
        }
        
        letzterMeilensteinTitel = settings.localizedString(for: tag.titel)
        zeigeMeilensteinOverlay = true
    }
    
    private func updateAktuellerTagIndex() {
        let heute = Calendar.current.startOfDay(for: Date())
        if let index = pfadTage.firstIndex(where: {
            if let d = $0.datum {
                return Calendar.current.isDate(d, inSameDayAs: heute)
            }
            return false
        }) {
            aktuellerTagIndex = index
        } else if let lastErledigt = pfadTage.lastIndex(where: { $0.istErledigt }) {
            aktuellerTagIndex = min(lastErledigt + 1, pfadTage.count - 1)
        } else {
            aktuellerTagIndex = 0
        }
    }
    
    var heutigerTag: PfadTag? {
        let heute = Calendar.current.startOfDay(for: Date())
        return pfadTage.first {
            if let d = $0.datum {
                return Calendar.current.isDate(d, inSameDayAs: heute)
            }
            return false
        }
    }
    
    var abgeschlosseneProzent: Double {
        guard !pfadTage.isEmpty else { return 0 }
        let erledigt = pfadTage.filter { $0.istErledigt }.count
        return Double(erledigt) / Double(pfadTage.count)
    }
    
    func pfadNachholenFallsNoetig(settings: SettingsStore, gardenStore: GardenStore) {
        // Nur ausführen wenn:
        // 1. Pfad noch nicht aktiv
        // 2. Onboarding bereits abgeschlossen
        // 3. Mindestens 2 Pflanzen im Garten vorhanden
        guard !istPfadAktiv,
              settings.onboardingAbgeschlossen,
              gardenStore.pflanzen.count >= 2 else { return }
        
        let ziel = settings.ausgewaehltesZiel.isEmpty 
            ? "fit" 
            : settings.ausgewaehltesZiel
        
        let pflanzeEins = gardenStore.pflanzen[0].plantID
        let pflanzeZwei = gardenStore.pflanzen[1].plantID
        
        pfadStarten(ziel: ziel, pflanzeEins: pflanzeEins, pflanzeZwei: pflanzeZwei)
    }
}
