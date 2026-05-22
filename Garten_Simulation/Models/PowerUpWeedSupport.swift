import Foundation

enum PowerUpWeedSupport {
    static let zauberstabID = "powerup.zauberstab"
    static let gartenschutzID = "powerup.gartenschutz"

    /// Asset-Katalog: Unkraut_Schild.imageset
    static let unkrautSchildAssetName = "Unkraut_Schild"

    static let weedPowerUpIDs: Set<String> = [zauberstabID, gartenschutzID]

    static func isWeedPowerUp(_ id: String) -> Bool {
        weedPowerUpIDs.contains(id)
    }
}
