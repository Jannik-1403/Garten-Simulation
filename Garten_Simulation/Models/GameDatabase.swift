import Foundation
import SwiftUI

enum HabitCategory: String, CaseIterable, Codable {
    case fitness
    case health
    case mental
    case growth
    case lifestyle
    case finance

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).lowercased()
        
        switch raw {
        case "fitness", "endurance":
            self = .fitness
        case "health", "nutrition", "hygiene", "sleep":
            self = .health
        case "mental", "mentalhealth", "mindfulness":
            self = .mental
        case "growth", "learning", "creativity", "productivity":
            self = .growth
        case "lifestyle", "social", "noaddiction":
            self = .lifestyle
        case "finance":
            self = .finance
        default:
            self = .lifestyle
        }
    }

    var localizationKey: String { "category.\(self.rawValue)" }
    
    var icon: String {
        switch self {
        case .fitness:   return "figure.run"
        case .health:    return "fork.knife"
        case .mental:    return "brain.head.profile"
        case .growth:    return "book.fill"
        case .lifestyle: return "sun.max.fill"
        case .finance:   return "banknote.fill"
        }
    }
}

enum UnlockMethod: String, Codable {
    case streak7, streak10, streak14, streak21, streak30, streak50, streak100
    case levelUp
    case compassionDrop
}

enum ItemRarity: String, Codable {
    case common, rare, epic, legendary
}


// MARK: - STRUCTS


struct Plant: Identifiable, Codable {
    let id: String
    let name: String
    let symbolName: String
    let symbol: String // Neu: Emoji-Symbol
    let symbolColor: String
    let habitCategories: [HabitCategory]
    let symbolism: String
    let habitName: String
    let maxLevel: Int
    let xpPerCompletion: Int
    let waterNeedPerDay: Int
    let decayDays: Int
    let assetName: String?
    let minGartenLevel: Int

    init(id: String, name: String, symbolName: String, assetName: String? = nil, symbol: String = "🌱", symbolColor: String, habitCategories: [HabitCategory], symbolism: String, habitName: String = "", maxLevel: Int = 10, xpPerCompletion: Int = 10, waterNeedPerDay: Int = 1, decayDays: Int = 3, minGartenLevel: Int = 1) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.assetName = assetName
        self.symbol = symbol
        self.symbolColor = symbolColor
        self.habitCategories = habitCategories
        self.symbolism = symbolism
        self.habitName = habitName
        self.maxLevel = maxLevel
        self.xpPerCompletion = xpPerCompletion
        self.waterNeedPerDay = waterNeedPerDay
        self.decayDays = decayDays
        self.minGartenLevel = minGartenLevel
    }

    var basePrice: Int {
        let basis = xpPerCompletion * 10
        let levelBonus = maxLevel > 10 ? 50 : 0
        return basis + levelBonus
    }

    var localizedName: String {
        id.lowercased().hasPrefix("plant.") ? "\(id.lowercased()).name" : "plant.\(id.lowercased()).name"
    }
}

enum PowerUpTarget: String, Codable {
    case garden
    case plant
}

struct PowerUpItem: Identifiable, Codable {
    let id: String
    let name: String
    let symbolName: String
    let symbolColor: String
    let description: String
    let unlockMethod: UnlockMethod
    let rarity: ItemRarity
    let durationHours: Double?
    let effectMultiplier: Double
    let howToUse: String
    let target: PowerUpTarget
    let minGartenLevel: Int
    var quantity: Int

    init(
        id: String,
        name: String,
        symbolName: String,
        symbolColor: String,
        description: String,
        unlockMethod: UnlockMethod,
        rarity: ItemRarity,
        durationHours: Double? = 24.0,
        effectMultiplier: Double = 1.0,
        howToUse: String = "",
        target: PowerUpTarget = .garden,
        minGartenLevel: Int = 1
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.description = description
        self.unlockMethod = unlockMethod
        self.rarity = rarity
        self.durationHours = durationHours
        self.effectMultiplier = effectMultiplier
        self.howToUse = howToUse
        self.target = target
        self.minGartenLevel = minGartenLevel
        self.quantity = 0
    }

    var basePrice: Int {
        switch rarity {
        case .common:    return 50
        case .rare:      return 150
        case .epic:      return 350
        case .legendary: return 800
        }
    }
}

// MARK: - SWIFTUI COLOR HELPER

private func colorFromString(_ string: String) -> Color {
    switch string {
    case "green":   return .green
    case "mint":    return .mint
    case "teal":    return .teal
    case "cyan":    return .cyan
    case "yellow":  return .yellow
    case "orange":  return .orange
    case "red":     return .red
    case "pink":    return .pink
    case "purple":  return .purple
    case "blue":    return .blue
    case "indigo":  return .indigo
    case "brown":   return .brown
    case "gray":    return .gray
    default:        return .green
    }
}

extension Plant {
    var color: Color { colorFromString(symbolColor) }
}
extension PowerUpItem {
    var color: Color { colorFromString(symbolColor) }
}

// MARK: - DATABASE

struct GameDatabase {
    static let shared = GameDatabase()
    
    func plant(for id: String) -> Plant? {
        GameDatabase.allPlants.first { $0.id == id }
    }

    // MARK: Pflanzen (20 Stück)
    static let allPlants: [Plant] = [
        Plant(id: "plant.bambus",           name: "plant.bambus.name",             symbolName: "leaf.fill",                     assetName: "plant_bambus",    symbol: "🎋", symbolColor: "green",   habitCategories: [.fitness],      symbolism: "plant.bambus.symbolism",           habitName: "habit.krafttraining",          xpPerCompletion: 120, decayDays: 2, minGartenLevel: 3),
        Plant(id: "plant.apfelbaum",        name: "plant.apfelbaum.name",          symbolName: "heart.circle.fill",             assetName: "plant_apfelbaum", symbol: "🍎", symbolColor: "red",     habitCategories: [.health, .lifestyle],    symbolism: "plant.apfelbaum.symbolism",        habitName: "habit.gesund_kochen",          xpPerCompletion: 100, decayDays: 3, minGartenLevel: 1),
        Plant(id: "plant.wildgras",         name: "plant.wildgras.name",           symbolName: "wind",                          assetName: "plant_wildgras",  symbol: "🌿", symbolColor: "mint",    habitCategories: [.fitness],    symbolism: "plant.wildgras.symbolism",         habitName: "habit.joggen",                xpPerCompletion: 80,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.lotus",            name: "plant.lotus.name",              symbolName: "sparkles",                      assetName: "plant_lotus",     symbol: "🪷", symbolColor: "pink",    habitCategories: [.mental], symbolism: "plant.lotus.symbolism",            habitName: "habit.meditieren",            xpPerCompletion: 100, decayDays: 3, minGartenLevel: 1),
        Plant(id: "plant.sonnenblume",      name: "plant.sonnenblume.name",        symbolName: "sun.max.fill",                  assetName: "plant_sonnenblume",      symbol: "🌻", symbolColor: "yellow",  habitCategories: [.lifestyle, .mental],    symbolism: "plant.sonnenblume.symbolism",      habitName: "habit.frueh_aufstehen",       xpPerCompletion: 80,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.kaktus",           name: "plant.kaktus.name",             symbolName: "thermometer.sun.fill",          assetName: "plant_kaktus",           symbol: "🌵", symbolColor: "orange",  habitCategories: [.fitness, .health],      symbolism: "plant.kaktus.symbolism",           habitName: "habit.kalt_duschen",          xpPerCompletion: 120, decayDays: 5, minGartenLevel: 8),
        Plant(id: "plant.weinrebe",         name: "plant.weinrebe.name",           symbolName: "drop.fill",                     assetName: "plant_weintraube",       symbol: "🍇", symbolColor: "purple",  habitCategories: [.lifestyle, .health],  symbolism: "plant.weinrebe.symbolism",         habitName: "habit.kein_alkohol",          xpPerCompletion: 100, decayDays: 3, minGartenLevel: 1),
        Plant(id: "plant.kirschbaum",       name: "plant.kirschbaum.name",         symbolName: "camera.macro",                  assetName: "plant_kirschbaum",       symbol: "🍒", symbolColor: "pink",    habitCategories: [.health, .mental],      symbolism: "plant.kirschbaum.symbolism",       habitName: "habit.selfcare",              xpPerCompletion: 80,  decayDays: 3, minGartenLevel: 1),
        Plant(id: "plant.minzpflanze",      name: "plant.minzpflanze.name",       symbolName: "aqi.low",                       assetName: "plant_minzpflanze",      symbol: "🌱", symbolColor: "mint",    habitCategories: [.health],      symbolism: "plant.minzpflanze.symbolism",      habitName: "habit.zaehneputzen",          xpPerCompletion: 60,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.mandelbaum",       name: "plant.mandelbaum.name",        symbolName: "banknote.fill",                 assetName: "Mandelbaum",             symbol: "🪵", symbolColor: "green",   habitCategories: [.finance, .growth],      symbolism: "plant.mandelbaum.symbolism",       habitName: "habit.geld_sparen",           maxLevel: 12, xpPerCompletion: 100, decayDays: 5, minGartenLevel: 10),
        Plant(id: "plant.lavendel",         name: "plant.lavendel.name",          symbolName: "moon.stars.fill",               assetName: "Lavendel",               symbol: "🪻", symbolColor: "purple",  habitCategories: [.health, .mental],        symbolism: "plant.lavendel.symbolism",         habitName: "habit.schlafroutine",         xpPerCompletion: 80,  decayDays: 3, minGartenLevel: 12),
        Plant(id: "plant.efeu",             name: "plant.efeu.name",              symbolName: "figure.flexibility",            assetName: "Efeu",                   symbol: "🍃", symbolColor: "green",   habitCategories: [.fitness, .health],             symbolism: "plant.efeu.symbolism",             habitName: "habit.stretching",            xpPerCompletion: 60,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.aloe_vera",        name: "plant.aloe_vera.name",         symbolName: "iphone.slash",                  assetName: "Aloe",                   symbol: "🪴", symbolColor: "mint",    habitCategories: [.lifestyle, .mental],    symbolism: "plant.aloe_vera.symbolism",        habitName: "habit.bildschirmzeit",        xpPerCompletion: 80,  decayDays: 4, minGartenLevel: 15),
        Plant(id: "plant.erdbeerpflanze",   name: "plant.erdbeerpflanze.name",    symbolName: "heart.fill",                    assetName: "Erdbeerpflanze",         symbol: "🍓", symbolColor: "red",     habitCategories: [.health, .lifestyle],    symbolism: "plant.erdbeerpflanze.symbolism",   habitName: "habit.obst_gemuese",          xpPerCompletion: 80,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.zitronenbaum",     name: "plant.zitronenbaum.name",      symbolName: "bolt.circle.fill",              assetName: "Zitronenbaum",           symbol: "🍋", symbolColor: "yellow",  habitCategories: [.health, .lifestyle],    symbolism: "plant.zitronenbaum.symbolism",     habitName: "habit.wasser_trinken",        xpPerCompletion: 80,  decayDays: 3, minGartenLevel: 18),
        Plant(id: "plant.weizenfeld",       name: "plant.weizenfeld.name",        symbolName: "chart.bar.fill",                assetName: "Weizenfeld",             symbol: "🌾", symbolColor: "orange",  habitCategories: [.growth], symbolism: "plant.weizenfeld.symbolism",       habitName: "habit.deep_work",             xpPerCompletion: 120, decayDays: 2, minGartenLevel: 20),
        Plant(id: "plant.chrysantheme",     name: "plant.chrysantheme.name",      symbolName: "house.fill",                    assetName: "Chrysantheme",           symbol: "🌼", symbolColor: "yellow",  habitCategories: [.health, .lifestyle],      symbolism: "plant.chrysantheme.symbolism",     habitName: "habit.aufraeumen",            xpPerCompletion: 60,  decayDays: 2, minGartenLevel: 1),
        Plant(id: "plant.klee",             name: "plant.klee.name",              symbolName: "star.fill",                     assetName: "Klee",                   symbol: "🍀", symbolColor: "green",   habitCategories: [.mental, .lifestyle],  symbolism: "plant.klee.symbolism",             habitName: "habit.dankbarkeit",           xpPerCompletion: 60,  decayDays: 2, minGartenLevel: 1),
        
        // MARK: Spezial-Pflanzen (Durch Samen freischaltbar)
        Plant(id: "plant.mystic_seed",      name: "plant.mystic_seed.name",       symbolName: "leaf.arrow.triangle.circlepath", assetName: "plant_lotus", symbolColor: "indigo", habitCategories: [.mental], symbolism: "plant.mystic_seed.symbolism",    habitName: "habit.atemarbeit",            xpPerCompletion: 250, decayDays: 5, minGartenLevel: 25)
    ]

    // MARK: Müll-Items (20 Stück, Re-branded IDs)
    static let allTrashItems: [DecorationItem] = [
        DecorationItem(id: "trash.fast_food_abo",         nameKey: "trash.fast_food_abo.name",         descriptionKey: "trash.fast_food_abo.desc",         sfSymbol: "Brunnen",                price: 40,  category: .wasser),
        DecorationItem(id: "trash.endlos_scroll_tv",      nameKey: "trash.endlos_scroll_tv.name",      descriptionKey: "trash.endlos_scroll_tv.desc",      sfSymbol: "Vogelhaus",              price: 25,  category: .tiere),
        DecorationItem(id: "trash.luxus_auto",            nameKey: "trash.luxus_auto.name",            descriptionKey: "trash.luxus_auto.desc",            sfSymbol: "Laterne",                price: 20,  category: .beleuchtung),
        DecorationItem(id: "trash.party_pass",            nameKey: "trash.party_pass.name",            descriptionKey: "trash.party_pass.desc",            sfSymbol: "Trittstein-Pfad",        price: 30,  category: .pfade),
        DecorationItem(id: "trash.energy_drink_kiste",    nameKey: "trash.energy_drink_kiste.name",    descriptionKey: "trash.energy_drink_kiste.desc",    sfSymbol: "Gartenzerg",             price: 10,  category: .deko),
        DecorationItem(id: "trash.zigaretten_automat",    nameKey: "trash.zigaretten_automat.name",    descriptionKey: "trash.zigaretten_automat.desc",    sfSymbol: "Sonnenschirm",           price: 22,  category: .moebel),
        DecorationItem(id: "trash.online_shopping_app",   nameKey: "trash.online_shopping_app.name",   descriptionKey: "trash.online_shopping_app.desc",   sfSymbol: "Seerosenteich",           price: 50,  category: .wasser),
        DecorationItem(id: "trash.junk_mail_abo",         nameKey: "trash.junk_mail_abo.name",         descriptionKey: "trash.junk_mail_abo.desc",         sfSymbol: "Vogelbad",               price: 18,  category: .wasser),
        DecorationItem(id: "trash.nacht_snack_box",       nameKey: "trash.nacht_snack_box.name",       descriptionKey: "trash.nacht_snack_box.desc",       sfSymbol: "Holzzaun",               price: 12,  category: .deko),
        DecorationItem(id: "trash.alkohol_flatrate",      nameKey: "trash.alkohol_flatrate.name",      descriptionKey: "trash.alkohol_flatrate.desc",      sfSymbol: "Steinstatue",             price: 60,  category: .deko),
        DecorationItem(id: "trash.doomscrolling_handy",   nameKey: "trash.doomscrolling_handy.name",   descriptionKey: "trash.doomscrolling_handy.desc",   sfSymbol: "Windrad",                price: 15,  category: .deko),
        DecorationItem(id: "trash.binge_streaming",       nameKey: "trash.binge_streaming.name",       descriptionKey: "trash.binge_streaming.desc",       sfSymbol: "Haengematte",            price: 35,  category: .moebel),
        DecorationItem(id: "trash.fastfood_lieferdienst", nameKey: "trash.fastfood_lieferdienst.name", descriptionKey: "trash.fastfood_lieferdienst.desc", sfSymbol: "Gartenfackel",           price: 15,  category: .beleuchtung),
        DecorationItem(id: "trash.lootbox_zockerabo",     nameKey: "trash.lootbox_zockerabo.name",     descriptionKey: "trash.lootbox_zockerabo.desc",     sfSymbol: "Blumenkübel",            price: 10,  category: .deko),
        DecorationItem(id: "trash.luxus_uhr",             nameKey: "trash.luxus_uhr.name",             descriptionKey: "trash.luxus_uhr.desc",             sfSymbol: "Bienenhaus 1",           price: 45,  category: .tiere),
        DecorationItem(id: "trash.couch_abo",             nameKey: "trash.couch_abo.name",             descriptionKey: "trash.couch_abo.desc",             sfSymbol: "Igelhaus 1",             price: 20,  category: .tiere),
        DecorationItem(id: "trash.doener_dauerkarte",     nameKey: "trash.doener_dauerkarte.name",     descriptionKey: "trash.doener_dauerkarte.desc",     sfSymbol: "Kiesweg 1",              price: 25,  category: .pfade),
        DecorationItem(id: "trash.negativitaets_feed",    nameKey: "trash.negativitaets_feed.name",    descriptionKey: "trash.negativitaets_feed.desc",    sfSymbol: "Brücke 1",               price: 80,  category: .pfade),
        DecorationItem(id: "trash.schlaf_killer_koffein", nameKey: "trash.schlaf_killer_koffein.name", descriptionKey: "trash.schlaf_killer_koffein.desc", sfSymbol: "Gartenhütte",            price: 120, category: .moebel)
    ]

    // MARK: Decorations (modern API)
    static let allDecorations: [DecorationItem] = allTrashItems

    // MARK: Power-Up Items (15 Stück)
    static let allPowerUps: [PowerUpItem] = [
        PowerUpItem(id: "powerup.gartenschutz",      name: "item.gartenschutz.name",          symbolName: "Powerup-Gartenschutz",  symbolColor: "cyan",   description: "item.gartenschutz.description",               unlockMethod: .streak7,        rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.gartenschutz.usage",     target: .garden),
        PowerUpItem(id: "powerup.wunder_wasser",      name: "item.wunder_wasser.name",         symbolName: "Powerup-Wunderwasser",  symbolColor: "blue",   description: "item.wunder_wasser.description",                 unlockMethod: .levelUp,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.wunder_wasser.usage", target: .plant),
        PowerUpItem(id: "powerup.sturmfest",         name: "item.waechter_turm.name",          symbolName: "Powerup-WächterTurm",   symbolColor: "orange", description: "item.waechter_turm.description",unlockMethod: .streak14,       rarity: .rare,      durationHours: nil,  effectMultiplier: 1.0, howToUse: "item.waechter_turm.usage",   target: .plant),
        PowerUpItem(id: "powerup.duenger_blitz",      name: "item.duenger_blitz.name",          symbolName: "Powerup-Düngerblitz",   symbolColor: "yellow", description: "item.duenger_blitz.description",           unlockMethod: .streak7,        rarity: .common,    durationHours: 24.0,  effectMultiplier: 2.0, howToUse: "item.duenger_blitz.usage",   target: .plant),
        PowerUpItem(id: "powerup.zauberstab",        name: "item.zauberstab.name",            symbolName: "Powerup-Zauberstarb",    symbolColor: "indigo", description: "item.zauberstab.description",                   unlockMethod: .levelUp,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.zauberstab.usage",     target: .garden),
        PowerUpItem(id: "powerup.zeitkapsel",         name: "item.zeitkapsel.name",            symbolName: "Powerup-Zeitkapsel",    symbolColor: "purple", description: "item.zeitkapsel.description",       unlockMethod: .streak30,       rarity: .epic,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.zeitkapsel.usage",     target: .garden),
        PowerUpItem(id: "powerup.goldener_schluessel", name: "item.goldener_schluessel.name",   symbolName: "Powerup-GoldenerSchlüssel", symbolColor: "yellow", description: "item.goldener_schluessel.description",         unlockMethod: .streak21,       rarity: .epic,      durationHours: 24.0,  effectMultiplier: 1.5, howToUse: "item.goldener_schluessel.usage", target: .garden),
        PowerUpItem(id: "powerup.diamant_erde",       name: "item.diamant_erde.name",          symbolName: "Powerup-Diamanterde",   symbolColor: "cyan",   description: "item.diamant_erde.description",         unlockMethod: .streak100,      rarity: .legendary, durationHours: 24.0,  effectMultiplier: 1.1, howToUse: "item.diamant_erde.usage",   target: .plant),
        PowerUpItem(id: "powerup.tier_freund",        name: "item.tier_freund.name",           symbolName: "Powerup-Tier-Freund",   symbolColor: "orange", description: "item.tier_freund.description",          unlockMethod: .compassionDrop, rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.tier_freund.usage",    target: .garden),
        PowerUpItem(id: "powerup.gluecks_segen",     name: "item.gluecks_segen.name",         symbolName: "Powerup-Glückssegen",   symbolColor: "pink",   description: "item.gluecks_segen.description",            unlockMethod: .streak50,       rarity: .legendary, durationHours: 24.0,  effectMultiplier: 2.0, howToUse: "item.gluecks_segen.usage",   target: .garden),
        
    ]
    
    // MARK: - Alle 45 Titel (Spieler-Titel System)
    static let allTitles: [PlayerTitle] = [
        PlayerTitle(id: "titel_anfaenger",     plantID: nil,                      displayName: "titel.anfaenger",     color: "#4CAF50", isBonus: false),
        PlayerTitle(id: "titel_bambus",          plantID: "plant.bambus",           displayName: "titel.bambus",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_eiche",          plantID: "plant.eiche",            displayName: "titel.eiche",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_bonsai",         plantID: nil,                      displayName: "titel.bonsai",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_kaktus",         plantID: "plant.kaktus",           displayName: "titel.kaktus",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_rose",           plantID: nil,                      displayName: "titel.rose",          color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_sonnenblume",    plantID: "plant.sonnenblume",      displayName: "titel.sonnenblume",   color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_lavendel",       plantID: "plant.lavendel",         displayName: "titel.lavendel",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_tomate",         plantID: nil,                      displayName: "titel.tomate",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_minze",          plantID: "plant.minzpflanze",      displayName: "titel.minze",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_orchidee",       plantID: nil,                      displayName: "titel.orchidee",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_farn",           plantID: nil,                      displayName: "titel.farn",          color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_efeu",           plantID: "plant.efeu",             displayName: "titel.efeu",          color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_aloe",           plantID: "plant.aloe_vera",        displayName: "titel.aloe",          color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_tulpe",          plantID: nil,                      displayName: "titel.tulpe",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_monstera",       plantID: nil,                      displayName: "titel.monstera",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_kirschbaum",     plantID: "plant.kirschbaum",       displayName: "titel.kirschbaum",    color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_feigenkaktus",   plantID: nil,                      displayName: "titel.feigenkaktus",  color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_zitronenbaum",   plantID: "plant.zitronenbaum",     displayName: "titel.zitronenbaum",  color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_magnolia",       plantID: nil,                      displayName: "titel.magnolia",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_jasmin",         plantID: nil,                      displayName: "titel.jasmin",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_palme",          plantID: nil,                      displayName: "titel.palme",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_weinrebe",       plantID: "plant.weinrebe",         displayName: "titel.weinrebe",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_basilikum",      plantID: nil,                      displayName: "titel.basilikum",     color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_pfingstrose",    plantID: nil,                      displayName: "titel.pfingstrose",   color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_eukalyptus",     plantID: nil,                      displayName: "titel.eukalyptus",    color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_hanfpalme",      plantID: nil,                      displayName: "titel.hanfpalme",     color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_agave",          plantID: nil,                      displayName: "titel.agave",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_dahlie",         plantID: nil,                      displayName: "titel.dahlie",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_wisteria",       plantID: nil,                      displayName: "titel.wisteria",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_chrysantheme",  plantID: "plant.chrysantheme",     displayName: "titel.chrysantheme",  color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_papyrus",        plantID: nil,                      displayName: "titel.papyrus",       color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_bambusorchidee", plantID: nil,                      displayName: "titel.bambusorchidee",color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_geranium",       plantID: nil,                      displayName: "titel.geranium",      color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_lorbeer",        plantID: nil,                      displayName: "titel.lorbeer",       color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_feige",          plantID: nil,                      displayName: "titel.feige",         color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_passionsblume",  plantID: nil,                      displayName: "titel.passionsblume", color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_ingwer",         plantID: nil,                      displayName: "titel.ingwer",        color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_zimt",           plantID: nil,                      displayName: "titel.zimt",          color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_drachenpflanze", plantID: nil,                      displayName: "titel.drachenpflanze",color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_edelweiss",      plantID: nil,                      displayName: "titel.edelweiss",     color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_kirschlorbeer",  plantID: nil,                      displayName: "titel.kirschlorbeer", color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_bambusgras",     plantID: nil,                      displayName: "titel.bambusgras",    color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_bodendecker",    plantID: nil,                      displayName: "titel.bodendecker",   color: "#4ECDC4", isBonus: false),
        PlayerTitle(id: "titel_seerose",        plantID: nil,                      displayName: "titel.seerose",       color: "#4ECDC4", isBonus: false)
    ]
}

