import SwiftUI

// MARK: - Erfolg Kategorie
enum ErfolgKategorie: String, CaseIterable, Identifiable {
    case streak     = "Streak"
    case gewohnheit = "Tageszeit"
    case seltenheit = "Pflanzen"
    case coins      = "Coins"
    
    var id: String { self.rawValue }

    var titel: String {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        switch self {
        case .streak:     return AppStrings.get("category.streak",   language: lang)
        case .gewohnheit: return AppStrings.get("category.daytime",  language: lang)
        case .seltenheit: return AppStrings.get("category.plants",   language: lang)
        case .coins:      return AppStrings.get("category.coins",    language: lang)
        }
    }

    var icon: String {
        switch self {
        case .streak:     return "flame.fill"
        case .gewohnheit: return "clock.fill"
        case .seltenheit: return "leaf.fill"
        case .coins:      return "circle.fill"
        }
    }
}

// MARK: - Erfolg Auslöser
enum ErfolgAuslöser {
    case coins(ziel: Int)           // z.B. 1000 Coins gesammelt
    case pflanzen(ziel: Int)        // z.B. 10 Pflanzen im Garten
    case streak(tage: Int)          // z.B. 7 Tage Streak
    case gewohnheitCount(ziel: Int) // z.B. 50× erledigt
    case morgensErledigt(ziel: Int) // z.B. 10× vor 9 Uhr erledigt
    case abendsErledigt(ziel: Int)  // z.B. 10× nach 20 Uhr erledigt
    case seltenheit(stufe: String)  // z.B. "Gold" Seltenheit erreicht
}

// MARK: - Erfolg Model
struct ErfolgModel: Identifiable, Equatable {
    let id: String
    let titel: String
    let beschreibung: String
    let icon: String // SF Symbol
    let farbe: Color
    let kategorie: ErfolgKategorie
    let ziel: Int
    let aktuell: Int
    let freigeschaltetAm: Date?
    
    var istFreigeschaltet: Bool {
        freigeschaltetAm != nil
    }
    
    var fortschritt: Double {
        Double(min(aktuell, ziel)) / Double(max(1, ziel))
    }
    
    static func == (lhs: ErfolgModel, rhs: ErfolgModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Platzhalter Daten
extension ErfolgModel {
    static let platzhalterErfolge: [ErfolgModel] = [
        // MARK: Streak
        ErfolgModel(id: "streak-3",    titel: "achievement.streak3.title",   beschreibung: "achievement.streak3.desc",   icon: "flame.fill",            farbe: .orange,      kategorie: .streak,     ziel: 3,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "streak-7",    titel: "achievement.streak7.title",   beschreibung: "achievement.streak7.desc",   icon: "flame.fill",            farbe: .orange,      kategorie: .streak,     ziel: 7,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "streak-30",   titel: "achievement.streak30.title",  beschreibung: "achievement.streak30.desc",  icon: "flame.fill",            farbe: .red,         kategorie: .streak,     ziel: 30,    aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "streak-100",  titel: "achievement.streak100.title", beschreibung: "achievement.streak100.desc", icon: "crown.fill",            farbe: .goldPrimary, kategorie: .streak,     ziel: 100,   aktuell: 0,    freigeschaltetAm: nil),

        // MARK: Coins
        ErfolgModel(id: "coin-100",    titel: "achievement.coin100.title",   beschreibung: "achievement.coin100.desc",   icon: "circle.fill",           farbe: .goldPrimary, kategorie: .coins,      ziel: 100,   aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "coin-1000",   titel: "achievement.coin1000.title",  beschreibung: "achievement.coin1000.desc",  icon: "circle.fill",           farbe: .goldPrimary, kategorie: .coins,      ziel: 1000,  aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "coin-5000",   titel: "achievement.coin5000.title",  beschreibung: "achievement.coin5000.desc",  icon: "circle.fill",           farbe: .orange,      kategorie: .coins,      ziel: 5000,  aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "coin-10000",  titel: "achievement.coin10000.title", beschreibung: "achievement.coin10000.desc", icon: "circle.fill",           farbe: .red,         kategorie: .coins,      ziel: 10000, aktuell: 0,    freigeschaltetAm: nil),

        // MARK: Pflanzen
        ErfolgModel(id: "pfl-1",       titel: "achievement.pfl1.title",      beschreibung: "achievement.pfl1.desc",      icon: "leaf.fill",             farbe: .green,       kategorie: .seltenheit, ziel: 1,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "pfl-5",       titel: "achievement.pfl5.title",      beschreibung: "achievement.pfl5.desc",      icon: "leaf.fill",             farbe: .green,       kategorie: .seltenheit, ziel: 5,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "pfl-10",      titel: "achievement.pfl10.title",     beschreibung: "achievement.pfl10.desc",     icon: "leaf.fill",             farbe: .green,       kategorie: .seltenheit, ziel: 10,    aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "pfl-25",      titel: "achievement.pfl25.title",     beschreibung: "achievement.pfl25.desc",     icon: "crown.fill",            farbe: .goldPrimary, kategorie: .seltenheit, ziel: 25,    aktuell: 0,    freigeschaltetAm: nil),

        // MARK: Tageszeit
        ErfolgModel(id: "morgen-5",    titel: "achievement.morgen5.title",   beschreibung: "achievement.morgen5.desc",   icon: "sunrise.fill",          farbe: .orange,      kategorie: .gewohnheit, ziel: 5,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "morgen-30",   titel: "achievement.morgen30.title",  beschreibung: "achievement.morgen30.desc",  icon: "sunrise.fill",          farbe: .yellow,      kategorie: .gewohnheit, ziel: 30,    aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "abend-5",     titel: "achievement.abend5.title",    beschreibung: "achievement.abend5.desc",    icon: "moon.stars.fill",       farbe: .blauPrimary, kategorie: .gewohnheit, ziel: 5,     aktuell: 0,    freigeschaltetAm: nil),
        ErfolgModel(id: "abend-30",    titel: "achievement.abend30.title",   beschreibung: "achievement.abend30.desc",   icon: "moon.stars.fill",      farbe: .lilaPrimary, kategorie: .gewohnheit, ziel: 30,    aktuell: 0,    freigeschaltetAm: nil),
    ]
}
