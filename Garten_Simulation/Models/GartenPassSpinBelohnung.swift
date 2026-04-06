import SwiftUI

/// Mögliche Belohnungen aus dem Eis-Glücksrad
enum GartenPassSpinBelohnung: Equatable {
    case coins(Int)
    case powerUp(id: String)
    case pflanze(id: String)
    case deko(id: String)
    case xp(Int)
    case seeds(Int)
}

struct GartenPassWheelLogic {
    
    /// Die 12 festen Segmente des Eis-Glücksrads
    static let segmente: [GartenPassSpinBelohnung] = [
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
    
    /// Führt einen Spin aus und gibt das Ergebnis sowie den Index zurück
    static func spin() -> (belohnung: GartenPassSpinBelohnung, index: Int) {
        let index = Int.random(in: 0..<segmente.count)
        return (segmente[index], index)
    }
}
