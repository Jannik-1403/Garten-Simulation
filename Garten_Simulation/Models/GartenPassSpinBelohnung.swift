import SwiftUI

/// Mögliche Belohnungen aus dem Eis-Glücksrad
enum GartenPassSpinBelohnung: Equatable {
    case coins(Int)
    case powerUp(id: String)
    case pflanze(id: String)
    case deko(id: String)
    case xp(Int)
    case seeds(Int)
    case weed // NEU: Unkraut als Strafe
}

struct GartenPassWheelLogic {
    
    /// Basis-Konfiguration (ohne Unkraut)
    static let basisSegmente: [GartenPassSpinBelohnung] = [
        .coins(50),      // 0
        .xp(100),        // 1
        .seeds(2),       // 2
        .powerUp(id: "powerup.duenger_blitz"), // 3
        .coins(150),     // 4
        .xp(250),        // 5
        .seeds(1),       // 6
        .powerUp(id: "powerup.goldener_schluessel"), // 7
        .coins(500),     // 8 (Jackpot)
        .xp(500),        // 9 (XP Jackpot)
        .seeds(5),       // 10 (Samen Jackpot)
        .powerUp(id: "powerup.gluecks_segen") // 11 (Ultimate Item)
    ]
    
    /// Berechnet die Segmente basierend auf der Anzahl der Dekorationen
    static func segmente(fuerDekorationen count: Int) -> [GartenPassSpinBelohnung] {
        var current = basisSegmente
        
        // Regel: Jede 3 Dekorationen wird ein "gutes" Feld durch Unkraut ersetzt
        // Wir ersetzen zuerst die kleinsten Belohnungen (Indices: 0, 1, 4, 5, 2, 6)
        let replacementIndices = [0, 1, 4, 5, 2, 6]
        let weedCount = min(count / 3, replacementIndices.count)
        
        for i in 0..<weedCount {
            current[replacementIndices[i]] = .weed
        }
        
        return current
    }
    
    /// Führt einen Spin aus und gibt das Ergebnis sowie den Index zurück
    static func spin(decorationCount: Int = 0) -> (belohnung: GartenPassSpinBelohnung, index: Int) {
        let segs = segmente(fuerDekorationen: decorationCount)
        let index = Int.random(in: 0..<segs.count)
        return (segs[index], index)
    }
}
