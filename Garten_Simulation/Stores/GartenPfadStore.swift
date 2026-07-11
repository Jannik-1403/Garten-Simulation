import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class GartenPfadStore: ObservableObject {
    @Published var straenge: [PfadStrang] = []
    @Published var verschmelzungen: [PfadVerschmelzung] = []
    @Published var alleTags: [PfadStrangTag] = []
    @Published var istPfadAktiv: Bool = false
    @Published var zoomSkala: CGFloat = 1.0
    @Published var focusedPflanzenID: String? = nil // Neu: Filter für einen spezifischen Habit-Pfad
    
    // Legacy support for overlays (adapted for new system)
    @Published var zeigeMeilensteinOverlay: Bool = false
    @Published var letzterMeilensteinTitel: String = ""
    @Published var belohnungsText: String = ""
    
    // Pfad 90 Tage Abschluss
    @Published var zeigePfadAbschlussOverlay: Bool = false
    @Published var letzteAbschlussPflanzeID: String? = nil
    @Published var letzterAbschlussCoins: Int = 0
    
    private var modelContext: ModelContext?
    private var settings: SettingsStore
    private(set) var gardenStore: GardenStore?
    private var gardenCancellable: AnyCancellable?
    
    private var isSyncingEveryPlant = false

    init(modelContext: ModelContext? = nil, settings: SettingsStore) {
        self.modelContext = modelContext
        self.settings = settings
        ladePfad()
    }

    func setContext(_ context: ModelContext, settings: SettingsStore, gardenStore: GardenStore) {
        self.modelContext = context
        self.settings = settings
        self.gardenStore = gardenStore
        ladePfad()
        
        // Initial sync handled by the sink below or manually if needed
        // self.ensureEveryPlantHasPath(gardenStore: gardenStore)
        
        // Auto-sync when plants change (ensures paths are created after GardenStore finishes loading)
        gardenCancellable = gardenStore.$pflanzen
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.ensureEveryPlantHasPath(gardenStore: gardenStore)
            }
        
        // Migration: Alte Kalender-basierte Daten bereinigen
        migrateToTrueJourney()
        
        // Einmaliges Update der Inhalte beim Laden, um die Pushup-Problematik zu fixen
        if istPfadAktiv {
            pfadInhaltAktualisieren(pflanzen: gardenStore.pflanzen)
        }
        
        // Jetzt wo Context da ist, Nachholen prüfen
        ensureEveryPlantHasPath(gardenStore: gardenStore)
        pfadNachholenFallsNoetig(settings: settings, gardenStore: gardenStore)
    }
    
    /// Stellt sicher, dass jede physische Pflanze im Garten einen Pfad-Strang hat
    func ensureEveryPlantHasPath(gardenStore: GardenStore) {
        guard let context = modelContext, !isSyncingEveryPlant else { return }
        isSyncingEveryPlant = true
        
        defer { isSyncingEveryPlant = false }
        
        var hasChanges = false
        for pflanze in gardenStore.pflanzen {
            let pflanzeID = pflanze.id
            
            // Clean up duplicates: if there are multiple active strands for the same plant instance, keep the one with the most progress (highest number of completed tags)
            let existingStrands = straenge.filter { $0.pflanzenID == pflanzeID && $0.istAktiv }
            var strangToKeep: PfadStrang? = nil
            
            if existingStrands.count > 1 {
                print("[PfadStore] VORSICHT: Mehrere Stränge für \(pflanze.name) gefunden. Bereinige Duplikate...")
                let sortedByProgress = existingStrands.sorted { s1, s2 in
                    let count1 = alleTags.filter { $0.strang?.id == s1.id && $0.istErledigt }.count
                    let count2 = alleTags.filter { $0.strang?.id == s2.id && $0.istErledigt }.count
                    return count1 > count2
                }
                
                strangToKeep = sortedByProgress.first
                
                // Delete the others
                for strand in sortedByProgress.dropFirst() {
                    context.delete(strand)
                    hasChanges = true
                }
                
                // Reload after deletion
                if hasChanges {
                    try? context.save()
                    ladePfad()
                }
            } else {
                strangToKeep = existingStrands.first
            }
            
            if pflanze.plantID.hasPrefix("custom_") {
                if let existingStrang = strangToKeep {
                    context.delete(existingStrang)
                    hasChanges = true
                }
                continue
            }
            
            // Verwende alleTags zum Zählen der Tags anstatt strangToKeep?.tags.count um SwiftData Lazy-Loading Bugs zu vermeiden
            let tagsCount = strangToKeep != nil ? alleTags.filter { $0.strang?.id == strangToKeep!.id }.count : 0
            
            if strangToKeep == nil || tagsCount == 0 {
                // Completely missing or broken (no tags)
                print("[PfadStore] Erstelle/Repariere Pfad für: \(pflanze.name) (\(pflanzeID))")
                if let brokenStrang = strangToKeep {
                    context.delete(brokenStrang) // Falls es ein broken Strang ohne Tags war
                }
                
                let ziel = settings.ausgewaehltesZiel.isEmpty ? "fit" : settings.ausgewaehltesZiel
                let sRaw = pflanze.individualSchwierigkeit ?? PfadSchwierigkeit.anfaenger.rawValue
                let difficulty = PfadSchwierigkeit(rawValue: sRaw) ?? .anfaenger
                pflanzeHinzufuegen(pflanze, ziel: ziel, schwierigkeit: difficulty)
                hasChanges = true
            }
        }
        
        if hasChanges {
            do {
                try context.save()
                ladePfad()
                objectWillChange.send()
            } catch {
                print("[PfadStore] Fehler beim Speichern der neuen Pfade: \(error)")
            }
        }
    }
    
    /// Migration: Alte Pfade hatten für jeden Tag ein geplantes Kalender-Datum.
    /// Im True-Journey-System ist `datum` nur noch ein Completion-Timestamp.
    /// Diese Funktion räumt alte `datum`-Werte bei nicht erledigten Tags auf.
    private func migrateToTrueJourney() {
        var didMigrate = false
        for tag in alleTags {
            if !tag.istErledigt && tag.datum != nil {
                // Nicht erledigter Tag hatte ein altes geplantes Datum → löschen
                tag.datum = nil
                didMigrate = true
            }
        }
        if didMigrate {
            try? modelContext?.save()
            print("[Migration] True Journey: Alte Kalender-Daten bereinigt.")
        }
    }

    func ladePfad() {
        guard let context = modelContext else { return }
        
        let strangDescriptor = FetchDescriptor<PfadStrang>(sortBy: [SortDescriptor(\.reihenfolgeIndex)])
        let mergeDescriptor = FetchDescriptor<PfadVerschmelzung>(sortBy: [SortDescriptor(\.tagNummer)])
        let tagDescriptor = FetchDescriptor<PfadStrangTag>(sortBy: [SortDescriptor(\.tagNummer)])
        
        do {
            straenge = try context.fetch(strangDescriptor)
            verschmelzungen = try context.fetch(mergeDescriptor)
            alleTags = try context.fetch(tagDescriptor)
            istPfadAktiv = !straenge.isEmpty
            
            // Tags den Strängen zuweisen (umgeht SwiftData Lazy-Loading)
            for strang in straenge {
                let zugehoerigeTags = alleTags.filter { $0.strang?.id == strang.id }
                if strang.tags.count != zugehoerigeTags.count {
                    // SwiftData hat die Relationship nicht geladen — manuell erzwingen
                    _ = strang.tags // access triggert lazy load
                }
            }
        } catch {
            print("Fehler beim Laden des Pfads: \(error)")
        }
    }

    // MARK: - Pfad generieren
    func pfadStarten(ziel: String, pflanzen: [HabitModel]) {
        guard let context = modelContext else { return }
        
        // Alten Pfad sauber löschen
        do {
            let sFetch = FetchDescriptor<PfadStrang>()
            let allStraenge = try context.fetch(sFetch)
            for s in allStraenge { context.delete(s) }
            
            let vFetch = FetchDescriptor<PfadVerschmelzung>()
            let allMerges = try context.fetch(vFetch)
            for m in allMerges { context.delete(m) }
            
            try context.save()
        } catch {
            print("[PfadStore] Fehler bei Initialisierung: \(error)")
        }

        let zielSchluessel = PfadDatenbank.zielZuSchluessel(ziel)

        var neueStraenge: [PfadStrang] = []

        // Strang für jede Pflanze erstellen
        for (index, pflanze) in pflanzen.enumerated() {
            let sRaw = pflanze.individualSchwierigkeit ?? PfadSchwierigkeit.anfaenger.rawValue
            let habitSchwierigkeit = PfadSchwierigkeit(rawValue: sRaw) ?? .anfaenger
            
            let strang = PfadStrang(
                id: UUID(),
                pflanzenID: pflanze.id, // Instanz-ID
                pflanzenName: pflanze.habitName,
                pflanzenSymbol: pflanze.symbolName,
                farbe: strangFarbe(index: index),
                istAktiv: true,
                startTag: 1,
                verschmelzungTag: verschmelzungsTag(schwierigkeit: habitSchwierigkeit, strangIndex: index),
                reihenfolgeIndex: index
            )

            // Tags generieren
            let tagVorlagen = PfadDatenbank.strangTagsGenerieren(
                ziel: ziel,
                pflanzenID: pflanze.plantID,
                strangIndex: index,
                schwierigkeit: habitSchwierigkeit,
                verschmelzungTag: strang.verschmelzungTag
            )

            context.insert(strang)   // ← VOR den Tags
            for vorlage in tagVorlagen {
                let strangTag = PfadStrangTag(
                    tagNummer: vorlage.tagNummer,
                    titelKey: vorlage.titelKey,
                    beschreibungKey: vorlage.beschreibungKey,
                    istErledigt: false,
                    istMeilenstein: vorlage.istMeilenstein,
                    istVerschmelzungsPunkt: vorlage.tagNummer == strang.verschmelzungTag,
                    datum: nil,
                    igelAsset: GameDatabase.shared.plant(for: pflanze.plantID)?.igelAsset ?? "Igel-wandern"
                )
                strangTag.strang = strang
                context.insert(strangTag)
            }
            neueStraenge.append(strang)
        }

        // Verschmelzungs-Punkte erstellen (aktuell Dummy-Fallback)
        erstelleVerschmelzungen(aktuelleStraenge: neueStraenge, pflanzen: pflanzen, schwierigkeit: .anfaenger)

        // NEU: Empfohlene dritte Pflanze als gesperrten Strang hinzufügen
        if let empfohlenePflanzenID = PfadDatenbank.empfohleneDrittePflanze(fuer: zielSchluessel) {
            let bereitsVorhanden = pflanzen.contains { $0.plantID == empfohlenePflanzenID }
            
            if !bereitsVorhanden {
                let gesperrterStrang = PfadStrang(
                    id: UUID(),
                    pflanzenID: "locked_\(empfohlenePflanzenID)",
                    pflanzenName: empfohlenePflanzenID, // Wird lokalisiert
                    pflanzenSymbol: "leaf.fill",
                    farbe: "#AAAAAA",
                    istAktiv: false,
                    startTag: 1,
                    verschmelzungTag: verschmelzungsTag(schwierigkeit: .anfaenger, strangIndex: pflanzen.count),
                    reihenfolgeIndex: pflanzen.count
                )
                
                // Leere Tags generieren (für Sichtbarkeit der Linie)
                for i in 1...90 {
                    let tag = PfadStrangTag(
                        tagNummer: i,
                        titelKey: "pfad_gesperrt_titel",
                        beschreibungKey: "pfad_gesperrt_desc",
                        istErledigt: false,
                        istMeilenstein: [7, 14, 21, 30, 45, 60, 90].contains(i),
                        istVerschmelzungsPunkt: i == gesperrterStrang.verschmelzungTag,
                        datum: nil,
                        igelAsset: ""
                    )
                    tag.strang = gesperrterStrang
                    context.insert(tag)
                }
                context.insert(gesperrterStrang)
            }
        }

        try? context.save()
        ladePfad()
    }

    private func erstelleVerschmelzungen(aktuelleStraenge: [PfadStrang], pflanzen: [HabitModel], schwierigkeit: PfadSchwierigkeit) {
        guard let context = modelContext, !aktuelleStraenge.isEmpty else { return }
        
        let totalCount = aktuelleStraenge.count
        let maxTiers = Int(ceil(log2(Double(totalCount))))
        
        guard maxTiers >= 1 else { return }
        
        for tier in 1...maxTiers {
            let groupSize = Int(pow(2.0, Double(tier)))
            let prevGroupSize = groupSize / 2
            let day = getTierDay(tier: tier, difficulty: schwierigkeit)
            
            for i in stride(from: 0, to: totalCount, by: groupSize) {
                let firstIdx = i
                let secondIdx = i + prevGroupSize
                
                if secondIdx < totalCount {
                    let merge = PfadVerschmelzung(
                        tagNummer: day,
                        strangIDs: [aktuelleStraenge[firstIdx].id.uuidString, aktuelleStraenge[secondIdx].id.uuidString],
                        istErreicht: false,
                        neuerStrangFarbe: aktuelleStraenge[firstIdx].farbe
                    )
                    context.insert(merge)
                    
                    // Den verschmelzungTag für den einkommenden Strang setzen/aktualisieren
                    // (Wir nehmen immer den frühesten Tag, an dem ein Strang in einen anderen mündet)
                    if aktuelleStraenge[secondIdx].verschmelzungTag == nil {
                        aktuelleStraenge[secondIdx].verschmelzungTag = day
                    }
                }
            }
        }
    }

    private func getTierDay(tier: Int, difficulty: PfadSchwierigkeit) -> Int {
        let baseDays: [Int]
        switch difficulty {
        case .anfaenger:       baseDays = [20, 45, 65, 80]
        case .fortgeschritten: baseDays = [14, 30, 50, 70]
        case .experte:         baseDays = [7, 21, 35, 50]
        }
        return baseDays[safe: tier - 1] ?? (80 + tier * 2)
    }

    // Verschmelzungs-Tags je nach Schwierigkeit
    private func verschmelzungsTag(schwierigkeit: PfadSchwierigkeit, strangIndex: Int) -> Int? {
        // Dummy-Fallback; die echte Logik ist jetzt in erstelleVerschmelzungen
        return nil
    }

    // Strang-Farben
    private func strangFarbe(index: Int) -> String {
        let farben = ["#58CC02", "#1CB0F6", "#FF9600", "#FF4040", "#9B59B6"]
        return farben[safe: index] ?? "#58CC02"
    }

    private func igelVerteilen(anzahl: Int) -> [String] {
        let assets = SettingsStore.alleIgelAssets
        var gemischteAssets: [String] = []
        while gemischteAssets.count < anzahl {
            var runde = assets.shuffled()
            if let letzter = gemischteAssets.last, runde.first == letzter {
                if runde.count > 1 { runde.swapAt(0, 1) }
            }
            gemischteAssets.append(contentsOf: runde)
        }
        return Array(gemischteAssets.prefix(anzahl))
    }

    // Neue Pflanze zum Pfad hinzufügen (wenn im Shop gekauft)
    func pflanzeHinzufuegen(_ pflanze: HabitModel, ziel: String, schwierigkeit: PfadSchwierigkeit) {
        guard let context = modelContext else { return }
        pflanze.individualSchwierigkeit = schwierigkeit.rawValue
        
        // Falls Dummy-Strang existierte, löschen wir diesen 
        if let dummy = straenge.first(where: { $0.pflanzenID == pflanze.plantID && !$0.istAktiv }) {
            context.delete(dummy)
            straenge.removeAll(where: { $0.id == dummy.id })
            
            let fetchDesc = FetchDescriptor<PfadStrangTag>()
            if let allTags = try? context.fetch(fetchDesc) {
                for t in allTags where t.strang?.id == dummy.id {
                    context.delete(t)
                }
            }
        }
        
        let neuerIndex = straenge.count

        let strang = PfadStrang(
            id: UUID(),
            pflanzenID: pflanze.id,
            pflanzenName: pflanze.name,
            pflanzenSymbol: pflanze.symbolName,
            farbe: strangFarbe(index: neuerIndex),
            istAktiv: true,
            startTag: tagHeute(),
            verschmelzungTag: verschmelzungsTag(schwierigkeit: schwierigkeit, strangIndex: neuerIndex),
            reihenfolgeIndex: neuerIndex
        )

        let tagVorlagen = PfadDatenbank.strangTagsGenerieren(
            ziel: ziel,
            pflanzenID: pflanze.plantID,
            strangIndex: neuerIndex,
            schwierigkeit: schwierigkeit,
            verschmelzungTag: strang.verschmelzungTag
        )
        // Strang ZUERST inserieren, damit SwiftData die inverse Relationship aufbauen kann
        context.insert(strang)

        for vorlage in tagVorlagen {
            let strangTag = PfadStrangTag(
                tagNummer: vorlage.tagNummer,
                titelKey: vorlage.titelKey,
                beschreibungKey: vorlage.beschreibungKey,
                istErledigt: false,
                istMeilenstein: vorlage.istMeilenstein,
                istVerschmelzungsPunkt: vorlage.tagNummer == strang.verschmelzungTag,
                datum: nil,
                igelAsset: GameDatabase.shared.plant(for: pflanze.plantID)?.igelAsset ?? "Igel-wandern"
            )
            strangTag.strang = strang
            context.insert(strangTag)
        }
        try? context.save()
        ladePfad()
    }

    // Veraltet, benutze stattdessen pflanzeHinzufuegen mit Schwierigkeit
    func strangAktivieren(pflanzenID: String) {
        // Nicht mehr genutzt
    }

    func tagHeute() -> Int {
        // alleTags direkt nutzen — kein Lazy-Loading Problem
        let aktiveStraengeIDs = Set(straenge.filter { $0.istAktiv }.map { $0.id })
        let offeneTags = alleTags.filter { tag in
            !tag.istErledigt && (tag.strang.map { aktiveStraengeIDs.contains($0.id) } ?? false)
        }
        return offeneTags.map { $0.tagNummer }.min() ?? 1
    }

    func istTagVollstaendigErledigt(tagNummer: Int) -> Bool {
        // Ein Tag ist vollständig erledigt, wenn JEDER aktive Strang an diesem Tag 'istErledigt' ist
        let relevanteTags = alleTags.filter { $0.tagNummer == tagNummer }
        if relevanteTags.isEmpty { return false }
        return relevanteTags.allSatisfy { $0.istErledigt }
    }

    // MARK: - Tag erledigen (Adapted for Multi-Strand)

    func tagErledigen(tag: PfadStrangTag, gardenStore: GardenStore, settings: SettingsStore, pflanzenID: String? = nil) {
        guard !tag.istErledigt else { return }

        tag.istErledigt = true
        tag.datum = Date() // Merken, WANN dieser Task abgeschlossen wurde
        FeedbackManager.shared.playSuccess()
        
        // Merge check
        if tag.istVerschmelzungsPunkt, let merge = verschmelzungen.first(where: { $0.tagNummer == tag.tagNummer }) {
            merge.istErreicht = true
        }

        gardenStore.xpHinzufuegen(amount: 50)
        gardenStore.coinsGutschreiben(amount: 20, beschreibung: String(localized: "pfad_tag_erledigt_belohnung"))

        if tag.istMeilenstein {
            meilensteinBelohnungAusloesen(tag: tag, gardenStore: gardenStore, settings: settings, pflanzenID: pflanzenID)
        }

        try? modelContext?.save()
        objectWillChange.send()
    }

    private func meilensteinBelohnungAusloesen(tag: PfadStrangTag, gardenStore: GardenStore, settings: SettingsStore, pflanzenID: String? = nil) {
        let coins: Int
        let xp: Int
        
        let resolvedPflanzenID = pflanzenID ?? tag.strang?.pflanzenID
        
        if tag.tagNummer == 90 {
            if let pid = resolvedPflanzenID, let habit = gardenStore.pflanzen.first(where: { $0.id == pid }) {
                let schwierigkeit = PfadSchwierigkeit(rawValue: habit.individualSchwierigkeit ?? "") ?? .anfaenger
                switch schwierigkeit {
                case .anfaenger: coins = 500
                case .fortgeschritten: coins = 1000
                case .experte: coins = 1500
                }
                self.letzterAbschlussCoins = coins
                self.letzteAbschlussPflanzeID = habit.id
                self.zeigePfadAbschlussOverlay = true
                return
            } else {
                // Fallback
                coins = 100
                xp = 500
                gardenStore.coinsGutschreiben(amount: coins, beschreibung: String(localized: "pfad_abgeschlossen_belohnung"))
                gardenStore.xpHinzufuegen(amount: xp)
                let pattern = String(localized: "pfad_belohnung_meisterschaft")
                belohnungsText = String(format: pattern, coins, xp)
            }
        } else {
            coins = 50
            xp = 100
            gardenStore.coinsGutschreiben(amount: coins, beschreibung: String(localized: "pfad_meilenstein_belohnung"))
            gardenStore.xpHinzufuegen(amount: xp)
            let pattern = String(localized: "pfad_belohnung_meilenstein")
            belohnungsText = String(format: pattern, coins, xp)
        }
        
        letzterMeilensteinTitel = NSLocalizedString(tag.titelKey, comment: "")
        zeigeMeilensteinOverlay = true
    }

    func restartPath(habit: HabitModel, newDifficulty: String) {
        guard let strang = straenge.first(where: { $0.pflanzenID == habit.id }) else { return }
        
        // SwiftData Modelle zurücksetzen
        for t in strang.tags {
            t.istErledigt = false
            t.datum = nil
        }
        
        // HabitModel aktualisieren
        habit.pfadCheckedDates = []
        habit.individualSchwierigkeit = newDifficulty
        habit.pfadAktiviertAm = Date() // Setzt es auf 'heute' aktiv
        
        // Speichern
        try? modelContext?.save()
        gardenStore?.savePlants()
        
        // UI aktualisieren
        pfadInhaltAktualisieren(pflanzen: gardenStore?.pflanzen ?? [])
        objectWillChange.send()
    }

    func debugJumpToDay89() {
        for strang in straenge {
            guard let habit = gardenStore?.pflanzen.first(where: { $0.id == strang.pflanzenID }) else {
                print("Pfad: Pflanze nicht gefunden für Strang \(strang.pflanzenID)")
                continue
            }
            
            // Setze das Startdatum der Pflanze so weit zurück, dass Tag 90 "heute" ist
            habit.pfadAktiviertAm = Date().addingTimeInterval(-89 * 24 * 3600)
            
            let sortedTags = strang.tags.sorted(by: { $0.tagNummer < $1.tagNummer })
            for tag in sortedTags {
                if tag.tagNummer < 90 {
                    tag.istErledigt = true
                    // Tag 89 war "gestern", Tag 88 war "vorgestern", etc.
                    let daysAgo = 90 - tag.tagNummer
                    tag.datum = Date().addingTimeInterval(-TimeInterval(daysAgo) * 24 * 3600)
                    
                    if let datum = tag.datum, !habit.pfadCheckedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: datum) }) {
                        habit.pfadCheckedDates.append(datum)
                    }
                } else {
                    tag.istErledigt = false
                    tag.datum = nil
                }
            }
            
            // Ganz wichtig: alle heutigen Check-Ins entfernen, damit Tag 90 heute klickbar ist
            habit.pfadCheckedDates.removeAll(where: { Calendar.current.isDateInToday($0) })
        }
        
        try? modelContext?.save()
        gardenStore?.savePlants()
        
        // Neu laden aus der DB, um UI Updates zu erzwingen
        ladePfad()
        objectWillChange.send()
    }

    func pfadInhaltAktualisieren(pflanzen: [HabitModel]) {
        guard let context = modelContext else { return }
        let ziel = settings.ausgewaehltesZiel.isEmpty ? "fit" : settings.ausgewaehltesZiel

        for strang in straenge {
            // Wir suchen die Pflanze anhand ihrer Instanz-ID (pflanzenID)
            let matchingPlant = pflanzen.first(where: { $0.id == strang.pflanzenID })
            let sRaw = matchingPlant?.individualSchwierigkeit ?? PfadSchwierigkeit.anfaenger.rawValue
            let schwierigkeit = PfadSchwierigkeit(rawValue: sRaw) ?? .anfaenger

            let tagVorlagen = PfadDatenbank.strangTagsGenerieren(
                ziel: ziel,
                pflanzenID: matchingPlant?.plantID ?? "",
                strangIndex: strang.reihenfolgeIndex,
                schwierigkeit: schwierigkeit,
                verschmelzungTag: strang.verschmelzungTag
            )
            
            for tag in strang.tags {
                // Wir aktualisieren nur noch nicht erledigte Tage
                guard !tag.istErledigt else { continue }
                if let vorlage = tagVorlagen.first(where: { $0.tagNummer == tag.tagNummer }) {
                    tag.titelKey = vorlage.titelKey
                    tag.beschreibungKey = vorlage.beschreibungKey
                }
            }
        }
        
        try? context.save()
        objectWillChange.send()
    }



    func pfadNachholenFallsNoetig(settings: SettingsStore, gardenStore: GardenStore) {
        guard !istPfadAktiv,
              settings.onboardingAbgeschlossen,
              gardenStore.pflanzen.count >= 1 else { return }
        
        // Statt den Screen zu zeigen, starten wir den Pfad einfach automatisch mit Standardwerten
        pfadZuruecksetzen(settings: settings, gardenStore: gardenStore)
    }

    func pfadZuruecksetzen(settings: SettingsStore, gardenStore: GardenStore) {
        guard let context = modelContext else { return }
        
        do {
            // Delete Straenge (Tags will be deleted via cascade)
            let sFetch = FetchDescriptor<PfadStrang>()
            let allStraenge = try context.fetch(sFetch)
            for s in allStraenge { context.delete(s) }
            
            // Delete Verschmelzungen
            let vFetch = FetchDescriptor<PfadVerschmelzung>()
            let allMerges = try context.fetch(vFetch)
            for m in allMerges { context.delete(m) }
            
            try context.save()
        } catch {
            print("[PfadStore] Fehler beim Zurücksetzen: \(error)")
        }

        straenge = []
        verschmelzungen = []
        istPfadAktiv = false

        let ziel = settings.ausgewaehltesZiel.isEmpty ? "fit" : settings.ausgewaehltesZiel
        guard gardenStore.pflanzen.count >= 1 else { return }

        pfadStarten(ziel: ziel, pflanzen: gardenStore.pflanzen)
    }

    func partnerTags(for tag: PfadStrangTag) -> [PfadStrangTag] {
        guard let masterStrang = tag.strang else { return [] }
        let tagNummer = tag.tagNummer
        
        var partner: [PfadStrangTag] = []
        for strang in straenge {
            guard strang.id != masterStrang.id else { continue }
            
            // Logik: Verschmilzt dieser Strang heute mit dem masterStrang?
            let istVerschmolzen = (strang.verschmelzungTag != nil && tagNummer >= (strang.verschmelzungTag ?? 999))
            
            if istVerschmolzen {
                if let pTag = strang.tags.first(where: { $0.tagNummer == tagNummer }) {
                    partner.append(pTag)
                }
            }
        }
        return partner
    }
    
    var connectedPlantPairs: [(String, String)] {
        var pairs: [(String, String)] = []
        for merge in verschmelzungen {
            // Find the ID for the stränge in this merge
            let plantIDs = straenge.filter { s in merge.strangIDs.contains(s.id.uuidString) }.map { $0.pflanzenID }
            // If we have at least 2, create pairs (usually it's 2 or more merging into one path)
            if plantIDs.count >= 2 {
                for i in 0..<plantIDs.count-1 {
                    pairs.append((plantIDs[i], plantIDs[i+1]))
                }
            }
        }
        return pairs
    }
    
    // NEU: Gruppierung für 90-Tage Ansicht
    func getGroups(forDay day: Int) -> [[Int]] {
        // Filterung: Wenn eine Pflanze fokussiert ist, zeigen wir nur den Strang dieser Pflanze
        if let focusedID = focusedPflanzenID {
            if let index = straenge.firstIndex(where: { $0.pflanzenID == focusedID }) {
                return [[index]]
            }
        }

        let n = straenge.count
        if n == 0 { return [] }
        
        // Parent-Array für Union-Find
        var parents = Array(0..<n)
        func find(_ i: Int) -> Int {
            var curr = i
            while parents[curr] != curr {
                parents[curr] = parents[parents[curr]]
                curr = parents[curr]
            }
            return curr
        }
        func union(_ i: Int, _ j: Int) {
            let rootI = find(i)
            let rootJ = find(j)
            if rootI != rootJ { parents[rootI] = rootJ }
        }
        
        // Nutze die echten Verschmelzungsdaten aus der Datenbank
        for merge in verschmelzungen {
            if merge.tagNummer <= day {
                let indices = merge.strangIDs.compactMap { idStr in
                    straenge.firstIndex(where: { $0.id.uuidString == idStr })
                }
                if indices.count >= 2 {
                    for k in 0..<indices.count-1 {
                        union(indices[k], indices[k+1])
                    }
                }
            }
        }
        
        var grouped: [Int: [Int]] = [:]
        for i in 0..<n {
            let root = find(i)
            grouped[root, default: []].append(i)
        }
        
        // Sortieren nach dem ersten Index, um die Reihenfolge stabil zu halten
        return grouped.values
            .map { $0.sorted() }
            .sorted { ($0.first ?? 0) < ($1.first ?? 0) }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
