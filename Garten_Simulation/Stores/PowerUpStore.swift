import SwiftUI
import Combine

@MainActor
class PowerUpStore: ObservableObject {
    @Published var aktivePowerUps: [ActivePowerUp] = []
    private var timer: Timer?

    init() {
        ladeAktivePowerUps()
        starteTimer()
    }

    /// Berechnet den XP-Multiplikator für eine bestimmte Pflanze
    func xpMultiplikator(for plantId: String) -> Double {
        var mult = 1.0
        
        // 1. Globale Power-Ups
        for aktiv in aktivePowerUps where aktiv.isActive && aktiv.targetPlantId == nil {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        // 2. Pflanzenspezifische Power-Ups
        for aktiv in aktivePowerUps where aktiv.isActive && aktiv.targetPlantId == plantId {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        
        return mult
    }

    /// Gibt den aktuellen globalen XP-Multiplikator zurück (für Header-Anzeige)
    var globalXPMultiplikator: Double {
        var mult = 1.0
        for aktiv in aktivePowerUps where aktiv.isActive && aktiv.targetPlantId == nil {
            if let base = GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId }) {
                mult *= base.effectMultiplier
            }
        }
        return mult
    }

    func aktivierePowerUp(_ item: PowerUpItem, for plantId: String? = nil) {
        let neue = ActivePowerUp(
            id: UUID(),
            powerUpId: item.id,
            appliedAt: Date(),
            durationHours: item.durationHours ?? 24,
            targetPlantId: plantId
        )
        withAnimation {
            aktivePowerUps.append(neue)
            speichereAktivePowerUps()
        }
    }

    private func ladeAktivePowerUps() {
        if let data = SharedUserDefaults.suite.data(forKey: "aktive_powerups"),
           let decoded = try? JSONDecoder().decode([ActivePowerUp].self, from: data) {
            aktivePowerUps = decoded
        }
    }

    /// Ist Zeitkapsel aktiv? (Streak-Schutz)
    var hatZeitkapsel: Bool {
        aktivePowerUps.contains { aktiv in
            aktiv.isActive && 
            GameDatabase.allPowerUps.first(where: { $0.id == aktiv.powerUpId })?.name == "item.zeitkapsel.name"
        }
    }


    // MARK: Timer — prüft jede Minute ob Power-Ups abgelaufen sind
    private func starteTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            if let self {
                Task { @MainActor in
                    self.pruefeAbgelaufene()
                }
            }
        }
    }

    private func pruefeAbgelaufene() {
        let abgelaufeneCount = aktivePowerUps.filter { !$0.isActive }.count
        if abgelaufeneCount > 0 {
            withAnimation {
                aktivePowerUps.removeAll { !$0.isActive }
                speichereAktivePowerUps()
            }
        }
    }

    private func speichereAktivePowerUps() {
        if let encoded = try? JSONEncoder().encode(aktivePowerUps) {
            SharedUserDefaults.suite.set(encoded, forKey: "aktive_powerups")
        }
    }

    func reset() {
        withAnimation {
            aktivePowerUps.removeAll()
            SharedUserDefaults.suite.removeObject(forKey: "aktive_powerups")
        }
    }

    func zufaelligesPowerUpHinzufuegen() {
        // TODO: Zufälliges Power-Up aus PowerUpStore gutschreiben
        if let randomPU = GameDatabase.allPowerUps.randomElement() {
            aktivierePowerUp(randomPU)
        }
    }
}
