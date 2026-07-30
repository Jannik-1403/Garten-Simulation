import Foundation

/// Zentrale Steuerung für Features, die sich aktuell in Entwicklung befinden
/// oder erst in einem zukünftigen Update (z.B. Pro-Version) freigeschaltet werden sollen.
struct FeatureFlags {
    
    /// Steuert, ob die Pro-Version Features (wie z.B. Abos, besondere Routinen)
    /// in der App sichtbar sind. 
    /// MUSS VOR DEM APP STORE RELEASE AUF `false` STEHEN!
    static let isProVersionEnabled = true
    
    // NEU: Schalter für die neuen "Speed & Focus" Features, To-Dos und Pflanzen
    static let isSpeedAndFocusUpdateEnabled = true
    
}
