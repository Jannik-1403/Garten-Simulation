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
            mult *= aktiv.effectMultiplier
        }
        
        // 2. Pflanzenspezifische Power-Ups
        for aktiv in aktivePowerUps where aktiv.isActive && aktiv.targetPlantId == plantId {
            mult *= aktiv.effectMultiplier
        }
        
        return mult
    }

    /// Gibt den aktuellen globalen XP-Multiplikator zurück (für Header-Anzeige)
    var globalXPMultiplikator: Double {
        var mult = 1.0
        for aktiv in aktivePowerUps where aktiv.isActive && aktiv.targetPlantId == nil {
            mult *= aktiv.effectMultiplier
        }
        return mult
    }

    func aktivierePowerUp(_ item: PowerUpItem, for plantId: String? = nil) {
        let neue = ActivePowerUp(
            powerUpId: item.id,
            name: item.name,
            symbolName: item.symbolName,
            symbolColor: item.symbolColor,
            effectMultiplier: item.effectMultiplier,
            durationHours: item.durationHours,
            howToUse: item.howToUse,
            targetPlantId: plantId
        )
        withAnimation {
            aktivePowerUps.append(neue)
            speichereAktivePowerUps()
        }
    }

    private func ladeAktivePowerUps() {
        if let data = UserDefaults.standard.data(forKey: "aktive_powerups"),
           let decoded = try? JSONDecoder().decode([ActivePowerUp].self, from: data) {
            aktivePowerUps = decoded
        }
    }

    /// Ist Zeitkapsel aktiv? (Streak-Schutz)
    var hatZeitkapsel: Bool {
        aktivePowerUps.contains { $0.isActive && $0.name == "item.zeitkapsel.name" }
    }

    /// Ist Regenmacher aktiv? (alle Pflanzen gratis gießen)
    var hatRegenmacher: Bool {
        aktivePowerUps.contains { $0.isActive && $0.name == "item.regenmacher.name" }
    }

    /// Ist Schädlingsschutz aktiv?
    var hatSchaedlingsschutz: Bool {
        aktivePowerUps.contains { $0.isActive && $0.name == "item.schaedlingsschutz.name" }
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
        let abgelaufene = aktivePowerUps.filter { $0.isExpired }
        if !abgelaufene.isEmpty {
            withAnimation {
                aktivePowerUps.removeAll { $0.isExpired }
                speichereAktivePowerUps()
            }
        }
    }

    private func speichereAktivePowerUps() {
        if let encoded = try? JSONEncoder().encode(aktivePowerUps) {
            UserDefaults.standard.set(encoded, forKey: "aktive_powerups")
        }
    }
}
