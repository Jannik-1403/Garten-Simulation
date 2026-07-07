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
    
    func getBoost(for habit: HabitModel) -> PartnerAppBoost? {
        // Erkennt automatisch das Land des Nutzers (z.B. "DE", "US", "KR")
        let userRegion = Locale.current.region?.identifier ?? "DE"
        
        // ==========================================
        // STUFE 1: VORGEFERTIGTE TEMPLATES (Exaktes Match)
        // ==========================================
        if !habit.plantID.hasPrefix("custom_") {
            switch habit.plantID {
                
            // Sport (Krafttraining, Joggen, Stretching)
            case "plant.bambus", "plant.wildgras", "plant.efeu":
                if userRegion == "DE" {
                    return PartnerAppBoost(
                        appName: "adidas",
                        tagline: String(localized: "partner.adidas.tagline", defaultValue: "Bereit fürs Training? Hol dir das beste Equipment."),
                        iconAssetName: "icon_adidas",
                        fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1508115448")!,
                        supportedRegions: ["DE"]
                    )
                } else {
                    return PartnerAppBoost(
                        appName: "Freeletics",
                        tagline: String(localized: "partner.freeletics.tagline", defaultValue: "Erreiche deine Ziele mit dem Nr. 1 KI-Coach."),
                        iconAssetName: "icon_freeletics",
                        fallbackStoreURL: URL(string: "https://apps.apple.com/app/id654810212")!,
                        supportedRegions: nil
                    )
                }
                
            // Finanzen
            case "plant.mandelbaum": // Geld sparen
                if userRegion == "DE" || userRegion == "AT" {
                    return PartnerAppBoost(
                        appName: "Finanzguru",
                        tagline: String(localized: "partner.finanzguru.tagline", defaultValue: "Brauchst du Hilfe bei deinen Finanzen?"),
                        iconAssetName: "icon_finanzguru",
                        fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1214803082")!,
                        supportedRegions: ["DE", "AT"]
                    )
                }
                return nil
                
            // Ernährung
            case "plant.apfelbaum", "plant.erdbeerpflanze": // Gesund kochen, Obst & Gemüse
                return PartnerAppBoost(
                    appName: "YAZIO",
                    tagline: String(localized: "partner.yazio.tagline", defaultValue: "Kalorien zählen & Fasten leicht gemacht."),
                    iconAssetName: "icon_yazio",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id946099227")!,
                    supportedRegions: nil
                )
                
            // Lernen / Growth
            case "plant.weizenfeld": // Deep Work / Lesen
                if userRegion == "DE" || userRegion == "AT" || userRegion == "CH" {
                    return PartnerAppBoost(
                        appName: "BookBeat",
                        tagline: String(localized: "partner.bookbeat.tagline", defaultValue: "Tausende Hörbücher direkt auf deinem iPhone."),
                        iconAssetName: "icon_bookbeat",
                        fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1056652614")!,
                        supportedRegions: ["DE", "AT", "CH"]
                    )
                } else {
                    return PartnerAppBoost(
                        appName: "Babbel",
                        tagline: String(localized: "partner.babbel.tagline", defaultValue: "Lerne eine neue Sprache in 15 Minuten am Tag."),
                        iconAssetName: "icon_babbel",
                        fallbackStoreURL: URL(string: "https://apps.apple.com/app/id829587759")!,
                        supportedRegions: nil
                    )
                }
                
            // HIER IST DEIN SCHUTZSCHILD:
            // Templates, die keinen Partner haben, geben sofort 'nil' zurück.
            // z.B. "Früh aufstehen", "Kalt duschen", "Zähneputzen", etc. zeigen NIEMALS falsche Werbung!
            default:
                return nil
            }
        }
        
        // ==========================================
        // STUFE 2: SELBST ERSTELLTE GEWOHNHEITEN (Keyword Fallback)
        // ==========================================
        // Wenn der Code hier ankommt, war es eine "custom_" Pflanze
        let title = habit.habitName.lowercased()
        
        // Finanzen Fallback
        if userRegion == "DE" || userRegion == "AT" {
            let financeKeywords = ["geld", "sparen", "finanzen", "budget", "aktien", "investieren"]
            if financeKeywords.contains(where: { title.contains($0) }) {
                return PartnerAppBoost(
                    appName: "Finanzguru",
                    tagline: String(localized: "partner.finanzguru.tagline", defaultValue: "Brauchst du Hilfe bei deinen Finanzen?"),
                    iconAssetName: "icon_finanzguru",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1214803082")!,
                    supportedRegions: ["DE", "AT"]
                )
            }
        }
        
        // Ernährung Fallback
        let nutritionKeywords = ["essen", "kalorien", "abnehmen", "fasten", "diät", "gesund", "kochen", "ernährung"]
        if nutritionKeywords.contains(where: { title.contains($0) }) {
            return PartnerAppBoost(
                appName: "YAZIO",
                tagline: String(localized: "partner.yazio.tagline", defaultValue: "Kalorien zählen & Fasten leicht gemacht."),
                iconAssetName: "icon_yazio",
                fallbackStoreURL: URL(string: "https://apps.apple.com/app/id946099227")!,
                supportedRegions: nil
            )
        }
        
        // Sport Fallback
        let fitnessKeywords = ["joggen", "laufen", "gym", "krafttraining", "workout", "fitness", "sport", "stretching", "yoga"]
        if fitnessKeywords.contains(where: { title.contains($0) }) {
            if userRegion == "DE" {
                return PartnerAppBoost(
                    appName: "adidas",
                    tagline: String(localized: "partner.adidas.tagline", defaultValue: "Bereit fürs Training? Hol dir das beste Equipment."),
                    iconAssetName: "icon_adidas",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1508115448")!,
                    supportedRegions: ["DE"]
                )
            } else {
                return PartnerAppBoost(
                    appName: "Freeletics",
                    tagline: String(localized: "partner.freeletics.tagline", defaultValue: "Erreiche deine Ziele mit dem Nr. 1 KI-Coach."),
                    iconAssetName: "icon_freeletics",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id654810212")!,
                    supportedRegions: nil
                )
            }
        }
        
        // Lernen / Lesen Fallback
        let learningKeywords = ["lesen", "lernen", "sprache", "buch", "hörbuch", "weiterbildung", "studium"]
        if learningKeywords.contains(where: { title.contains($0) }) {
             if userRegion == "DE" || userRegion == "AT" || userRegion == "CH" {
                return PartnerAppBoost(
                    appName: "BookBeat",
                    tagline: String(localized: "partner.bookbeat.tagline", defaultValue: "Tausende Hörbücher direkt auf deinem iPhone."),
                    iconAssetName: "icon_bookbeat",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id1056652614")!,
                    supportedRegions: ["DE", "AT", "CH"]
                )
             } else {
                return PartnerAppBoost(
                    appName: "Babbel",
                    tagline: String(localized: "partner.babbel.tagline", defaultValue: "Lerne eine neue Sprache in 15 Minuten am Tag."),
                    iconAssetName: "icon_babbel",
                    fallbackStoreURL: URL(string: "https://apps.apple.com/app/id829587759")!,
                    supportedRegions: nil
                )
             }
        }
        
        // Wenn der User irgendwas völlig Abstruses eingibt ("Jeden Tag Katze streicheln") -> kein Boost
        return nil
    }
}
