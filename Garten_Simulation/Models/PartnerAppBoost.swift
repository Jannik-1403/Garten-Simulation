import Foundation

// Das Datenmodell für deine Empfehlungs-Karten
struct PartnerAppBoost: Identifiable {
    let id = UUID()
    let appName: String
    let tagline: String
    let iconAssetName: String   // Der Name des Bildes in deiner Assets.xcassets
    let fallbackStoreURL: URL
    let supportedRegions: [String]? // nil bedeutet: Weltweit verfügbar
}

// Der zentrale Store, der steuert, wer was sieht
class PartnerBoostStore {
    
    static let shared = PartnerBoostStore()
    
    func getBoost(for category: HabitCategory) -> PartnerAppBoost? {
        // Erkennt automatisch das Land des Nutzers (z.B. "DE", "US", "KR")
        let userRegion = Locale.current.region?.identifier ?? "DE"
        
        switch category {
        case .finance:
            // Finanzguru funktioniert NUR in Deutschland und Österreich
            if userRegion == "DE" || userRegion == "AT" {
                return PartnerAppBoost(
                    appName: "Finanzguru",
                    tagline: String(localized: "partner.finanzguru.tagline", defaultValue: "Brauchst du Hilfe bei deinen Finanzen?"),
                    iconAssetName: "icon_finanzguru",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id1214803082")!,
                    supportedRegions: ["DE", "AT"]
                )
            }
            return nil // Für internationale Nutzer unsichtbar
            
        case .health:
            // YAZIO funktioniert global extrem stark
            return PartnerAppBoost(
                appName: "YAZIO",
                tagline: String(localized: "partner.yazio.tagline", defaultValue: "Kalorien zählen & Fasten leicht gemacht."),
                iconAssetName: "icon_yazio",
                fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id946099227")!,
                supportedRegions: nil
            )
            
        case .fitness:
            // Strategischer Split: In DE pushen wir Adidas (Equipment), global Freeletics (Workouts)
            if userRegion == "DE" {
                return PartnerAppBoost(
                    appName: "adidas",
                    tagline: String(localized: "partner.adidas.tagline", defaultValue: "Bereit fürs Training? Hol dir das beste Equipment."),
                    iconAssetName: "icon_adidas",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id1508115448")!,
                    supportedRegions: ["DE"]
                )
            } else {
                return PartnerAppBoost(
                    appName: "Freeletics",
                    tagline: String(localized: "partner.freeletics.tagline", defaultValue: "Erreiche deine Ziele mit dem Nr. 1 KI-Coach."),
                    iconAssetName: "icon_freeletics",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id654810212")!,
                    supportedRegions: nil
                )
            }
            
        case .growth:
            // BookBeat für die Lese-Gewohnheit in DACH
            if userRegion == "DE" || userRegion == "AT" || userRegion == "CH" {
                return PartnerAppBoost(
                    appName: "BookBeat",
                    tagline: String(localized: "partner.bookbeat.tagline", defaultValue: "Tausende Hörbücher direkt auf deinem iPhone."),
                    iconAssetName: "icon_bookbeat",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id1056652614")!,
                    supportedRegions: ["DE", "AT", "CH"]
                )
            } else {
                // Babbel als Alternative für Growth international
                return PartnerAppBoost(
                    appName: "Babbel",
                    tagline: String(localized: "partner.babbel.tagline", defaultValue: "Lerne eine neue Sprache in 15 Minuten am Tag."),
                    iconAssetName: "icon_babbel",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id829587759")!,
                    supportedRegions: nil
                )
            }
            
        case .lifestyle, .seeds, .mental:
            // Babbel als Fallback
            return PartnerAppBoost(
                appName: "Babbel",
                tagline: String(localized: "partner.babbel.tagline", defaultValue: "Lerne eine neue Sprache in 15 Minuten am Tag."),
                iconAssetName: "icon_babbel",
                fallbackStoreURL: URL(string: "https://apps.apple.com/de/app/id829587759")!,
                supportedRegions: nil
            )
        }
    }
}
