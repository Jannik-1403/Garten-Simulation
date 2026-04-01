import Foundation
import SwiftUI

enum HabitCategory: String, CaseIterable, Codable {
    case fitness
    case nutrition
    case endurance
    case learning
    case mentalHealth
    case lifestyle
    case noAddiction
    case hygiene
    case finance
    case mindfulness
    case sleep
    case productivity
    case creativity
    case social

    var localizationKey: String { "category.\(self.rawValue)" }
    
    var icon: String {
        switch self {
        case .fitness:      return "figure.run"
        case .nutrition:    return "fork.knife"
        case .endurance:    return "heart.fill"
        case .learning:     return "book.fill"
        case .mentalHealth: return "brain.head.profile"
        case .lifestyle:    return "sun.max.fill"
        case .noAddiction:  return "lock.fill"
        case .hygiene:      return "bubbles.and.sparkles.fill"
        case .finance:      return "banknote.fill"
        case .mindfulness:  return "leaf.fill"
        case .sleep:        return "moon.stars.fill"
        case .productivity: return "briefcase.fill"
        case .creativity:   return "paintbrush.fill"
        case .social:       return "person.2.fill"
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
    let symbolColor: String
    let habitCategory: HabitCategory
    let symbolism: String
    let maxLevel: Int
    let xpPerCompletion: Int
    let waterNeedPerDay: Int
    let decayDays: Int

    init(id: String, name: String, symbolName: String, symbolColor: String, habitCategory: HabitCategory, symbolism: String, maxLevel: Int = 10, xpPerCompletion: Int = 10, waterNeedPerDay: Int = 1, decayDays: Int = 3) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.habitCategory = habitCategory
        self.symbolism = symbolism
        self.maxLevel = maxLevel
        self.xpPerCompletion = xpPerCompletion
        self.waterNeedPerDay = waterNeedPerDay
        self.decayDays = decayDays
    }

    var basePrice: Int {
        let basis = xpPerCompletion * 10
        let levelBonus = maxLevel > 10 ? 50 : 0
        return basis + levelBonus
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
    let howToUse: String
    let effectMultiplier: Double
    let target: PowerUpTarget
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
        target: PowerUpTarget = .garden
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

    // MARK: Pflanzen (44 Stück)
    static let allPlants: [Plant] = [
        Plant(id: "plant.bambus",           name: "plant.bambus.name",             symbolName: "leaf.fill",                     symbolColor: "green",   habitCategory: .fitness,      symbolism: "plant.bambus.symbolism",              xpPerCompletion: 12, decayDays: 2),
        Plant(id: "plant.apfelbaum",        name: "plant.apfelbaum.name",          symbolName: "heart.circle.fill",             symbolColor: "red",     habitCategory: .nutrition,    symbolism: "plant.apfelbaum.symbolism",          xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.wildgras",         name: "plant.wildgras.name",           symbolName: "wind",                          symbolColor: "mint",    habitCategory: .endurance,    symbolism: "plant.wildgras.symbolism",          xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.eiche",            name: "plant.eiche.name",              symbolName: "tree.fill",                     symbolColor: "brown",   habitCategory: .learning,     symbolism: "plant.eiche.symbolism",             maxLevel: 15, xpPerCompletion: 15, decayDays: 4),
        Plant(id: "plant.lotus",            name: "plant.lotus.name",              symbolName: "sparkles",                      symbolColor: "pink",    habitCategory: .mentalHealth, symbolism: "plant.lotus.symbolism",                             xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.sonnenblume",      name: "plant.sonnenblume.name",        symbolName: "sun.max.fill",                  symbolColor: "yellow",  habitCategory: .lifestyle,    symbolism: "plant.sonnenblume.symbolism",               xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.kaktus",           name: "plant.kaktus.name",             symbolName: "thermometer.sun.fill",          symbolColor: "orange",  habitCategory: .fitness,      symbolism: "plant.kaktus.symbolism",                    xpPerCompletion: 12, decayDays: 5),
        Plant(id: "plant.weinrebe",         name: "plant.weinrebe.name",           symbolName: "drop.fill",                     symbolColor: "purple",  habitCategory: .noAddiction,  symbolism: "plant.weinrebe.symbolism",                      xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.kirschbaum",       name: "plant.kirschbaum.name",         symbolName: "camera.macro",                  symbolColor: "pink",    habitCategory: .hygiene,      symbolism: "plant.kirschbaum.symbolism",           xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.palme",            name: "plant.palme.name",              symbolName: "sun.horizon.fill",              symbolColor: "yellow",  habitCategory: .lifestyle,    symbolism: "plant.palme.symbolism",          xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.minzpflanze",      name: "plant.minzpflanze.name",       symbolName: "aqi.low",                       symbolColor: "mint",    habitCategory: .hygiene,      symbolism: "plant.minzpflanze.symbolism",                    xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.rosmarin",         name: "plant.rosmarin.name",          symbolName: "flame.fill",                    symbolColor: "orange",  habitCategory: .nutrition,    symbolism: "plant.rosmarin.symbolism",             xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.mandelbaum",       name: "plant.mandelbaum.name",        symbolName: "banknote.fill",                 symbolColor: "green",   habitCategory: .finance,      symbolism: "plant.mandelbaum.symbolism",                  maxLevel: 12, xpPerCompletion: 10, decayDays: 5),
        Plant(id: "plant.bambus_schilf",    name: "plant.bambus_schilf.name",     symbolName: "pencil.and.scribble",           symbolColor: "teal",    habitCategory: .mindfulness,  symbolism: "plant.bambus_schilf.symbolism",                        xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.lavendel",         name: "plant.lavendel.name",          symbolName: "moon.stars.fill",               symbolColor: "purple",  habitCategory: .sleep,        symbolism: "plant.lavendel.symbolism",               xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.efeu",             name: "plant.efeu.name",              symbolName: "figure.flexibility",            symbolColor: "green",   habitCategory: .fitness,      symbolism: "plant.efeu.symbolism",          xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.aloe_vera",        name: "plant.aloe_vera.name",         symbolName: "iphone.slash",                  symbolColor: "mint",    habitCategory: .lifestyle,    symbolism: "plant.aloe_vera.symbolism",        xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.erdbeerpflanze",   name: "plant.erdbeerpflanze.name",    symbolName: "heart.fill",                    symbolColor: "red",     habitCategory: .nutrition,    symbolism: "plant.erdbeerpflanze.symbolism",            xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.zitronenbaum",     name: "plant.zitronenbaum.name",      symbolName: "bolt.circle.fill",              symbolColor: "yellow",  habitCategory: .nutrition,    symbolism: "plant.zitronenbaum.symbolism",                      xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.weizenfeld",       name: "plant.weizenfeld.name",        symbolName: "chart.bar.fill",                symbolColor: "orange",  habitCategory: .productivity, symbolism: "plant.weizenfeld.symbolism",                     xpPerCompletion: 12, decayDays: 2),
        Plant(id: "plant.orchidee",         name: "plant.orchidee.name",          symbolName: "paintbrush.pointed.fill",       symbolColor: "pink",    habitCategory: .creativity,   symbolism: "plant.orchidee.symbolism",           xpPerCompletion: 10, decayDays: 2),
        Plant(id: "plant.pilzkolonie",      name: "plant.pilzkolonie.name",       symbolName: "person.3.fill",                 symbolColor: "brown",   habitCategory: .social,       symbolism: "plant.pilzkolonie.symbolism",              xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.mangrove",         name: "plant.mangrove.name",          symbolName: "shield.fill",                   symbolColor: "teal",    habitCategory: .mentalHealth, symbolism: "plant.mangrove.symbolism",             xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.klee",             name: "plant.klee.name",              symbolName: "star.fill",                     symbolColor: "green",   habitCategory: .mindfulness,  symbolism: "plant.klee.symbolism",                    xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.farn",             name: "plant.farn.name",              symbolName: "eye.slash.fill",                symbolColor: "green",   habitCategory: .lifestyle,    symbolism: "plant.farn.symbolism",              xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.chrysantheme",     name: "plant.chrysantheme.name",      symbolName: "house.fill",                    symbolColor: "yellow",  habitCategory: .hygiene,      symbolism: "plant.chrysantheme.symbolism",                         xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.walnussbaum",      name: "plant.walnussbaum.name",       symbolName: "book.fill",                     symbolColor: "brown",   habitCategory: .learning,     symbolism: "plant.walnussbaum.symbolism",            xpPerCompletion: 12, decayDays: 4),
        Plant(id: "plant.pfirsichbaum",     name: "plant.pfirsichbaum.name",      symbolName: "heart.circle.fill",             symbolColor: "orange",  habitCategory: .mentalHealth, symbolism: "plant.pfirsichbaum.symbolism",            xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.brennnessel",      name: "plant.brennnessel.name",       symbolName: "bolt.heart.fill",               symbolColor: "red",     habitCategory: .fitness,      symbolism: "plant.brennnessel.symbolism",        xpPerCompletion: 15, decayDays: 2),
        Plant(id: "plant.bonsai_mini",      name: "plant.bonsai.name",            symbolName: "timer",                         symbolColor: "green",   habitCategory: .mindfulness,  symbolism: "plant.bonsai.symbolism", maxLevel: 20, xpPerCompletion: 10, decayDays: 5),
        Plant(id: "plant.seerose",          name: "plant.seerose.name",           symbolName: "drop.circle.fill",              symbolColor: "cyan",    habitCategory: .endurance,    symbolism: "plant.seerose.symbolism",                    xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.zuckerrohr",       name: "plant.zuckerrohr.name",        symbolName: "xmark.circle.fill",             symbolColor: "red",     habitCategory: .nutrition,    symbolism: "plant.zuckerrohr.symbolism",        xpPerCompletion: 12, decayDays: 2),
        Plant(id: "plant.basilikum",        name: "plant.basilikum.name",         symbolName: "leaf",                          symbolColor: "green",   habitCategory: .nutrition,    symbolism: "plant.basilikum.symbolism",               xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.kakaobaum",        name: "plant.kakaobaum.name",         symbolName: "gift.fill",                     symbolColor: "brown",   habitCategory: .mindfulness,  symbolism: "plant.kakaobaum.symbolism",                 xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.feigenbaum",       name: "plant.feigenbaum.name",        symbolName: "clock.arrow.2.circlepath",      symbolColor: "orange",  habitCategory: .nutrition,    symbolism: "plant.feigenbaum.symbolism",                    xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.korallenbusch",    name: "plant.korallenbusch.name",     symbolName: "person.2.fill",                 symbolColor: "cyan",    habitCategory: .social,       symbolism: "plant.korallenbusch.symbolism",       xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.eukalyptus",       name: "plant.eukalyptus.name",        symbolName: "lungs.fill",                    symbolColor: "mint",    habitCategory: .mentalHealth, symbolism: "plant.eukalyptus.symbolism",            xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.thymian",          name: "plant.thymian.name",           symbolName: "checkmark.circle.fill",         symbolColor: "green",   habitCategory: .productivity, symbolism: "plant.thymian.symbolism",         xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.ginkgo",           name: "plant.ginkgo.name",            symbolName: "brain.head.profile",            symbolColor: "yellow",  habitCategory: .learning,     symbolism: "plant.ginkgo.symbolism",       xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.mammutbaum",       name: "plant.mammutbaum.name",        symbolName: "mountain.2.fill",               symbolColor: "brown",   habitCategory: .productivity, symbolism: "plant.mammutbaum.symbolism",  maxLevel: 20, xpPerCompletion: 20, decayDays: 5),
        Plant(id: "plant.passionsblume",    name: "plant.passionsblume.name",     symbolName: "lock.fill",                     symbolColor: "indigo",  habitCategory: .noAddiction,  symbolism: "plant.passionsblume.symbolism",                           xpPerCompletion: 12, decayDays: 3),
        Plant(id: "plant.ingwerpflanze",    name: "plant.ingwerpflanze.name",     symbolName: "bolt.slash.fill",               symbolColor: "orange",  habitCategory: .noAddiction,  symbolism: "plant.ingwerpflanze.symbolism",           xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.teestrauch",       name: "plant.teestrauch.name",        symbolName: "cup.and.saucer.fill",           symbolColor: "brown",   habitCategory: .lifestyle,    symbolism: "plant.teestrauch.symbolism",                  xpPerCompletion: 6,  decayDays: 3),
        Plant(id: "plant.olivenbaum",       name: "plant.olivenbaum.name",        symbolName: "infinity",                      symbolColor: "green",   habitCategory: .lifestyle,    symbolism: "plant.olivenbaum.symbolism",      maxLevel: 15, xpPerCompletion: 10, decayDays: 5)
    ]

    // MARK: Müll-Items (20 Stück, Re-branded IDs)
    static let allTrashItems: [DecorationItem] = [
        DecorationItem(id: "trash.ultra_konsole",         nameKey: "trash.ultra_konsole.name",         descriptionKey: "trash.ultra_konsole.desc",         sfSymbol: "chair.fill",            price: 15,  category: .moebel),
        DecorationItem(id: "trash.fast_food_abo",         nameKey: "trash.fast_food_abo.name",         descriptionKey: "trash.fast_food_abo.desc",         sfSymbol: "drop.circle.fill",     price: 40,  category: .deko),
        DecorationItem(id: "trash.endlos_scroll_tv",      nameKey: "trash.endlos_scroll_tv.name",      descriptionKey: "trash.endlos_scroll_tv.desc",      sfSymbol: "bird.fill",            price: 25,  category: .deko),
        DecorationItem(id: "trash.luxus_auto",            nameKey: "trash.luxus_auto.name",            descriptionKey: "trash.luxus_auto.desc",            sfSymbol: "lightbulb.fill",       price: 20,  category: .deko),
        DecorationItem(id: "trash.party_pass",            nameKey: "trash.party_pass.name",            descriptionKey: "trash.party_pass.desc",            sfSymbol: "circle.grid.3x3.fill", price: 30,  category: .deko),
        DecorationItem(id: "trash.energy_drink_kiste",    nameKey: "trash.energy_drink_kiste.name",    descriptionKey: "trash.energy_drink_kiste.desc",    sfSymbol: "face.smiling.fill",    price: 10,  category: .deko),
        DecorationItem(id: "trash.zigaretten_automat",    nameKey: "trash.zigaretten_automat.name",    descriptionKey: "trash.zigaretten_automat.desc",    sfSymbol: "umbrella.fill",        price: 22,  category: .moebel),
        DecorationItem(id: "trash.online_shopping_app",   nameKey: "trash.online_shopping_app.name",   descriptionKey: "trash.online_shopping_app.desc",   sfSymbol: "shield.fill",           price: 50,  category: .deko),
        DecorationItem(id: "trash.junk_mail_abo",         nameKey: "trash.junk_mail_abo.name",         descriptionKey: "trash.junk_mail_abo.desc",         sfSymbol: "drop.fill",            price: 18,  category: .deko),
        DecorationItem(id: "trash.nacht_snack_box",       nameKey: "trash.nacht_snack_box.name",       descriptionKey: "trash.nacht_snack_box.desc",       sfSymbol: "rail.fill",            price: 12,  category: .deko),
        DecorationItem(id: "trash.alkohol_flatrate",      nameKey: "trash.alkohol_flatrate.name",      descriptionKey: "trash.alkohol_flatrate.desc",      sfSymbol: "figure.stand",          price: 60,  category: .moebel),
        DecorationItem(id: "trash.doomscrolling_handy",   nameKey: "trash.doomscrolling_handy.name",   descriptionKey: "trash.doomscrolling_handy.desc",   sfSymbol: "fanblades.fill",       price: 15,  category: .moebel),
        DecorationItem(id: "trash.binge_streaming",       nameKey: "trash.binge_streaming.name",       descriptionKey: "trash.binge_streaming.desc",       sfSymbol: "bed.double.fill",       price: 35,  category: .moebel),
        DecorationItem(id: "trash.fastfood_lieferdienst", nameKey: "trash.fastfood_lieferdienst.name", descriptionKey: "trash.fastfood_lieferdienst.desc", sfSymbol: "flame.fill",           price: 15,  category: .deko),
        DecorationItem(id: "trash.lootbox_zockerabo",     nameKey: "trash.lootbox_zockerabo.name",     descriptionKey: "trash.lootbox_zockerabo.desc",     sfSymbol: "basket.fill",          price: 10,  category: .moebel),
        DecorationItem(id: "trash.luxus_uhr",             nameKey: "trash.luxus_uhr.name",             descriptionKey: "trash.luxus_uhr.desc",             sfSymbol: "hexagon.fill",         price: 45,  category: .deko),
        DecorationItem(id: "trash.couch_abo",             nameKey: "trash.couch_abo.name",             descriptionKey: "trash.couch_abo.desc",             sfSymbol: "leaf.arrow.triangle.circlepath", price: 20, category: .deko),
        DecorationItem(id: "trash.doener_dauerkarte",     nameKey: "trash.doener_dauerkarte.name",     descriptionKey: "trash.doener_dauerkarte.desc",     sfSymbol: "cloud.fill",           price: 25,  category: .deko),
        DecorationItem(id: "trash.negativitaets_feed",    nameKey: "trash.negativitaets_feed.name",    descriptionKey: "trash.negativitaets_feed.desc",    sfSymbol: "archway",               price: 80,  category: .deko),
        DecorationItem(id: "trash.schlaf_killer_koffein", nameKey: "trash.schlaf_killer_koffein.name", descriptionKey: "trash.schlaf_killer_koffein.desc", sfSymbol: "house.fill",           price: 120, category: .moebel)
    ]

    // MARK: Decorations (modern API)
    static let allDecorations: [DecorationItem] = allTrashItems

    // MARK: Power-Up Items (15 Stück)
    static let allPowerUps: [PowerUpItem] = [
        PowerUpItem(id: "powerup.frostschutz",       name: "item.frostschutz_schild.name",   symbolName: "snowflake",             symbolColor: "cyan",   description: "item.frostschutz_schild.description",                         unlockMethod: .streak7,        rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.frostschutz_schild.usage", target: .garden),
        PowerUpItem(id: "powerup.wunder_wasser",      name: "item.wunder_wasser.name",         symbolName: "drop.fill",             symbolColor: "blue",   description: "item.wunder_wasser.description",                 unlockMethod: .levelUp,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.wunder_wasser.usage", target: .garden),
        PowerUpItem(id: "powerup.sturmfest",         name: "item.sturmfeste_glocke.name",     symbolName: "bell.fill",             symbolColor: "orange", description: "item.sturmfeste_glocke.description",unlockMethod: .streak14,       rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.sturmfeste_glocke.usage", target: .garden),
        PowerUpItem(id: "powerup.duenger_blitz",      name: "item.duenger_blitz.name",          symbolName: "bolt.fill",             symbolColor: "yellow", description: "item.duenger_blitz.description",           unlockMethod: .streak7,        rarity: .common,    durationHours: 24.0,  effectMultiplier: 2.0, howToUse: "item.duenger_blitz.usage",   target: .plant),
        PowerUpItem(id: "powerup.unkraut_bot",        name: "item.unkraut_bot.name",           symbolName: "cpu",                   symbolColor: "indigo", description: "item.unkraut_bot.description",                  unlockMethod: .levelUp,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.unkraut_bot.usage",    target: .garden),
        PowerUpItem(id: "powerup.sonnenspiegel",      name: "item.sonnenspiegel.name",         symbolName: "sun.max.fill",          symbolColor: "yellow", description: "item.sonnenspiegel.description",                  unlockMethod: .streak10,       rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.sonnenspiegel.usage",  target: .garden),
        PowerUpItem(id: "powerup.zeitkapsel",         name: "item.zeitkapsel.name",            symbolName: "timer",                 symbolColor: "purple", description: "item.zeitkapsel.description",       unlockMethod: .streak30,       rarity: .epic,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.zeitkapsel.usage",     target: .garden),
        PowerUpItem(id: "powerup.regenmacher",        name: "item.regenmacher.name",           symbolName: "cloud.rain.fill",       symbolColor: "cyan",   description: "item.regenmacher.description",             unlockMethod: .compassionDrop, rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.regenmacher.usage",    target: .garden),
        PowerUpItem(id: "powerup.gold_giesskanne",    name: "item.goldene_giesskanne.name",     symbolName: "trophy.fill",           symbolColor: "yellow", description: "item.goldene_giesskanne.description",                      unlockMethod: .streak21,       rarity: .epic,      durationHours: 24.0,  effectMultiplier: 1.5, howToUse: "item.goldene_giesskanne.usage", target: .garden),
        PowerUpItem(id: "powerup.schaedlingsschutz",   name: "item.schaedlingsschutz.name",      symbolName: "shield.fill",           symbolColor: "green",  description: "item.schaedlingsschutz.description",    unlockMethod: .levelUp,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.schaedlingsschutz.usage", target: .garden),
        PowerUpItem(id: "powerup.nebel_ventilator",   name: "item.nebel_ventilator.name",      symbolName: "wind",                  symbolColor: "mint",   description: "item.nebel_ventilator.description",               unlockMethod: .compassionDrop, rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.nebel_ventilator.usage", target: .garden),
        PowerUpItem(id: "powerup.kompost_boost",      name: "item.kompost_boost.name",         symbolName: "arrow.3.trianglepath",  symbolColor: "green",  description: "item.kompost_boost.description",                       unlockMethod: .streak7,        rarity: .rare,      durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.kompost_boost.usage", target: .plant),
        PowerUpItem(id: "powerup.diamant_erde",       name: "item.diamant_erde.name",          symbolName: "diamond.fill",          symbolColor: "cyan",   description: "item.diamant_erde.description",         unlockMethod: .streak100,      rarity: .legendary, durationHours: 24.0,  effectMultiplier: 1.1, howToUse: "item.diamant_erde.usage",   target: .plant),
        PowerUpItem(id: "powerup.tier_freund",        name: "item.tier_freund.name",           symbolName: "hare.fill",             symbolColor: "orange", description: "item.tier_freund.description",          unlockMethod: .compassionDrop, rarity: .common,    durationHours: 24.0,  effectMultiplier: 1.0, howToUse: "item.tier_freund.usage",    target: .garden),
        PowerUpItem(id: "powerup.regenbogen",        name: "item.regenbogen_event.name",      symbolName: "rainbow",               symbolColor: "pink",   description: "item.regenbogen_event.description",            unlockMethod: .streak50,       rarity: .legendary, durationHours: 24.0,  effectMultiplier: 2.0, howToUse: "item.regenbogen_event.usage", target: .garden)
    ]
}

