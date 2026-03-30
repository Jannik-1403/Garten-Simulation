import Foundation
import SwiftUI

// MARK: - ENUMS

enum HabitCategory: String, Codable, CaseIterable {
    case fitness        = "Fitness"
    case nutrition      = "Ernährung"
    case endurance      = "Ausdauer"
    case learning       = "Lernen"
    case mentalHealth   = "Mental Health"
    case sleep          = "Schlaf"
    case hygiene        = "Hygiene"
    case finance        = "Finanzen"
    case social         = "Soziales"
    case creativity     = "Kreativität"
    case mindfulness    = "Achtsamkeit"
    case productivity   = "Produktivität"
    case noAddiction    = "Suchtfreiheit"
    case lifestyle      = "Lifestyle"
}

enum ItemRarity: String, Codable {
    case common    = "Gewöhnlich"
    case rare      = "Selten"
    case epic      = "Episch"
    case legendary = "Legendär"
}

enum UnlockMethod: String, Codable {
    case streak7        = "7-Tage-Streak"
    case streak10       = "10-Tage-Streak"
    case streak14       = "14-Tage-Streak"
    case streak21       = "21-Tage-Streak"
    case streak30       = "30-Tage-Streak"
    case streak50       = "50-Tage-Streak"
    case streak100      = "100-Tage-Streak"
    case levelUp        = "Level-Up"
    case compassionDrop = "Mitleids-Drop"
}

enum TrashEffect: String, Codable {
    case xpReduction   = "XP-Abzug"
    case growthBlock   = "Wachstum blockiert"
    case passiveDrain  = "Passiver Energieabzug"
    case weatherNerf   = "Wetter-Nerf"
    case currencyDrain = "Währungsverlust"
    case levelDown     = "Level-Down Risiko"
    case streakPenalty = "Streak-Penalty"
    case randomXPLoss  = "Zufälliger XP-Verlust"
}

// MARK: - STRUCTS

struct Plant: Identifiable, Codable {
    let id: String
    let name: String
    let symbolName: String      // SF Symbol – direkt in Image(systemName:) nutzen
    let symbolColor: String     // Farb-String für die Extension unten
    let habitCategory: HabitCategory
    let symbolism: String
    let maxLevel: Int
    let xpPerCompletion: Int
    let waterNeedPerDay: Int
    let decayDays: Int
    var growthStage: Int
    var currentXP: Int
    var isAlive: Bool

    init(
        id: String,
        name: String,
        symbolName: String,
        symbolColor: String,
        habitCategory: HabitCategory,
        symbolism: String,
        maxLevel: Int = 10,
        xpPerCompletion: Int = 10,
        waterNeedPerDay: Int = 1,
        decayDays: Int = 3
    ) {
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
        self.growthStage = 0
        self.currentXP = 0
        self.isAlive = true
    }
}

struct TrashItem: Identifiable, Codable {
    let id: String
    let name: String
    let symbolName: String
    let symbolColor: String
    let description: String
    let weedGenerated: String
    let effect: TrashEffect
    let effectValue: Int
    let cost: Int
    let targetCategory: HabitCategory?

    init(
        id: String,
        name: String,
        symbolName: String,
        symbolColor: String,
        description: String,
        weedGenerated: String,
        effect: TrashEffect,
        effectValue: Int,
        cost: Int,
        targetCategory: HabitCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.description = description
        self.weedGenerated = weedGenerated
        self.effect = effect
        self.effectValue = effectValue
        self.cost = cost
        self.targetCategory = targetCategory
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
}

// MARK: - SWIFTUI COLOR HELPER
// Nutzung in der View:
//   Image(systemName: plant.symbolName)
//       .foregroundColor(plant.color)
//       .font(.system(size: 40))

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
extension TrashItem {
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
        Plant(id: "plant.wildgras",         name: "plant.wildgras.name",           symbolName: "wind",                          symbolColor: "mint",    habitCategory: .endurance,    symbolism: "plant.wildgras.symbolism",         xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.eiche",            name: "plant.eiche.name",              symbolName: "tree.fill",                     symbolColor: "brown",   habitCategory: .learning,     symbolism: "plant.eiche.symbolism",             maxLevel: 15, xpPerCompletion: 15, decayDays: 4),
        Plant(id: "plant.lotus",            name: "plant.lotus.name",              symbolName: "sparkles",                      symbolColor: "pink",    habitCategory: .mentalHealth, symbolism: "plant.lotus.symbolism",                             xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.sonnenblume",      name: "plant.sonnenblume.name",        symbolName: "sun.max.fill",                  symbolColor: "yellow",  habitCategory: .lifestyle,    symbolism: "plant.sonnenblume.symbolism",                xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.kaktus",           name: "plant.kaktus.name",             symbolName: "thermometer.sun.fill",          symbolColor: "orange",  habitCategory: .fitness,      symbolism: "plant.kaktus.symbolism",                     xpPerCompletion: 12, decayDays: 5),
        Plant(id: "plant.weinrebe",         name: "plant.weinrebe.name",           symbolName: "drop.fill",                     symbolColor: "purple",  habitCategory: .noAddiction,  symbolism: "plant.weinrebe.symbolism",                       xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.kirschbaum",       name: "plant.kirschbaum.name",         symbolName: "camera.macro",                  symbolColor: "pink",    habitCategory: .hygiene,      symbolism: "plant.kirschbaum.symbolism",            xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.palme",            name: "plant.palme.name",              symbolName: "sun.horizon.fill",              symbolColor: "yellow",  habitCategory: .lifestyle,    symbolism: "plant.palme.symbolism",           xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.minzpflanze",      name: "plant.minzpflanze.name",       symbolName: "aqi.low",                       symbolColor: "mint",    habitCategory: .hygiene,      symbolism: "plant.minzpflanze.symbolism",                     xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.rosmarin",         name: "plant.rosmarin.name",          symbolName: "flame.fill",                    symbolColor: "orange",  habitCategory: .nutrition,    symbolism: "plant.rosmarin.symbolism",              xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.mandelbaum",       name: "plant.mandelbaum.name",        symbolName: "banknote.fill",                 symbolColor: "green",   habitCategory: .finance,      symbolism: "plant.mandelbaum.symbolism",                   maxLevel: 12, xpPerCompletion: 10, decayDays: 5),
        Plant(id: "plant.bambus_schilf",    name: "plant.bambus_schilf.name",     symbolName: "pencil.and.scribble",           symbolColor: "teal",    habitCategory: .mindfulness,  symbolism: "plant.bambus_schilf.symbolism",                         xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.lavendel",         name: "plant.lavendel.name",          symbolName: "moon.stars.fill",               symbolColor: "purple",  habitCategory: .sleep,        symbolism: "plant.lavendel.symbolism",                xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.efeu",             name: "plant.efeu.name",              symbolName: "figure.flexibility",            symbolColor: "green",   habitCategory: .fitness,      symbolism: "plant.efeu.symbolism",           xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.aloe_vera",        name: "plant.aloe_vera.name",         symbolName: "iphone.slash",                  symbolColor: "mint",    habitCategory: .lifestyle,    symbolism: "plant.aloe_vera.symbolism",        xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.erdbeerpflanze",   name: "plant.erdbeerpflanze.name",    symbolName: "heart.fill",                    symbolColor: "red",     habitCategory: .nutrition,    symbolism: "plant.erdbeerpflanze.symbolism",             xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.zitronenbaum",     name: "plant.zitronenbaum.name",      symbolName: "bolt.circle.fill",              symbolColor: "yellow",  habitCategory: .nutrition,    symbolism: "plant.zitronenbaum.symbolism",                       xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.weizenfeld",       name: "plant.weizenfeld.name",        symbolName: "chart.bar.fill",                symbolColor: "orange",  habitCategory: .productivity, symbolism: "plant.weizenfeld.symbolism",                      xpPerCompletion: 12, decayDays: 2),
        Plant(id: "plant.orchidee",         name: "plant.orchidee.name",          symbolName: "paintbrush.pointed.fill",       symbolColor: "pink",    habitCategory: .creativity,   symbolism: "plant.orchidee.symbolism",            xpPerCompletion: 10, decayDays: 2),
        Plant(id: "plant.pilzkolonie",      name: "plant.pilzkolonie.name",       symbolName: "person.3.fill",                 symbolColor: "brown",   habitCategory: .social,       symbolism: "plant.pilzkolonie.symbolism",               xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.mangrove",         name: "plant.mangrove.name",          symbolName: "shield.fill",                   symbolColor: "teal",    habitCategory: .mentalHealth, symbolism: "plant.mangrove.symbolism",              xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.klee",             name: "plant.klee.name",              symbolName: "star.fill",                     symbolColor: "green",   habitCategory: .mindfulness,  symbolism: "plant.klee.symbolism",                     xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.farn",             name: "plant.farn.name",              symbolName: "eye.slash.fill",                symbolColor: "green",   habitCategory: .lifestyle,    symbolism: "plant.farn.symbolism",               xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.chrysantheme",     name: "plant.chrysantheme.name",      symbolName: "house.fill",                    symbolColor: "yellow",  habitCategory: .hygiene,      symbolism: "plant.chrysantheme.symbolism",                          xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.walnussbaum",      name: "plant.walnussbaum.name",       symbolName: "book.fill",                     symbolColor: "brown",   habitCategory: .learning,     symbolism: "plant.walnussbaum.symbolism",             xpPerCompletion: 12, decayDays: 4),
        Plant(id: "plant.pfirsichbaum",     name: "plant.pfirsichbaum.name",      symbolName: "heart.circle.fill",             symbolColor: "orange",  habitCategory: .mentalHealth, symbolism: "plant.pfirsichbaum.symbolism",             xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.brennnessel",      name: "plant.brennnessel.name",       symbolName: "bolt.heart.fill",               symbolColor: "red",     habitCategory: .fitness,      symbolism: "plant.brennnessel.symbolism",         xpPerCompletion: 15, decayDays: 2),
        Plant(id: "plant.bonsai_mini",      name: "plant.bonsai.name",            symbolName: "timer",                         symbolColor: "green",   habitCategory: .mindfulness,  symbolism: "plant.bonsai.symbolism", maxLevel: 20, xpPerCompletion: 10, decayDays: 5),
        Plant(id: "plant.seerose",          name: "plant.seerose.name",           symbolName: "drop.circle.fill",              symbolColor: "cyan",    habitCategory: .endurance,    symbolism: "plant.seerose.symbolism",                     xpPerCompletion: 10, decayDays: 3),
        Plant(id: "plant.zuckerrohr",       name: "plant.zuckerrohr.name",        symbolName: "xmark.circle.fill",             symbolColor: "red",     habitCategory: .nutrition,    symbolism: "plant.zuckerrohr.symbolism",         xpPerCompletion: 12, decayDays: 2),
        Plant(id: "plant.basilikum",        name: "plant.basilikum.name",         symbolName: "leaf",                          symbolColor: "green",   habitCategory: .nutrition,    symbolism: "plant.basilikum.symbolism",                xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.kakaobaum",        name: "plant.kakaobaum.name",         symbolName: "gift.fill",                     symbolColor: "brown",   habitCategory: .mindfulness,  symbolism: "plant.kakaobaum.symbolism",                  xpPerCompletion: 8,  decayDays: 4),
        Plant(id: "plant.feigenbaum",       name: "plant.feigenbaum.name",        symbolName: "clock.arrow.2.circlepath",      symbolColor: "orange",  habitCategory: .nutrition,    symbolism: "plant.feigenbaum.symbolism",                     xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.korallenbusch",    name: "plant.korallenbusch.name",     symbolName: "person.2.fill",                 symbolColor: "cyan",    habitCategory: .social,       symbolism: "plant.korallenbusch.symbolism",        xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.eukalyptus",       name: "plant.eukalyptus.name",        symbolName: "lungs.fill",                    symbolColor: "mint",    habitCategory: .mentalHealth, symbolism: "plant.eukalyptus.symbolism",             xpPerCompletion: 8,  decayDays: 3),
        Plant(id: "plant.thymian",          name: "plant.thymian.name",           symbolName: "checkmark.circle.fill",         symbolColor: "green",   habitCategory: .productivity, symbolism: "plant.thymian.symbolism",          xpPerCompletion: 6,  decayDays: 2),
        Plant(id: "plant.ginkgo",           name: "plant.ginkgo.name",            symbolName: "brain.head.profile",            symbolColor: "yellow",  habitCategory: .learning,     symbolism: "plant.ginkgo.symbolism",        xpPerCompletion: 10, decayDays: 4),
        Plant(id: "plant.mammutbaum",       name: "plant.mammutbaum.name",        symbolName: "mountain.2.fill",               symbolColor: "brown",   habitCategory: .productivity, symbolism: "plant.mammutbaum.symbolism",  maxLevel: 20, xpPerCompletion: 20, decayDays: 5),
        Plant(id: "plant.passionsblume",    name: "plant.passionsblume.name",     symbolName: "lock.fill",                     symbolColor: "indigo",  habitCategory: .noAddiction,  symbolism: "plant.passionsblume.symbolism",                            xpPerCompletion: 12, decayDays: 3),
        Plant(id: "plant.ingwerpflanze",    name: "plant.ingwerpflanze.name",     symbolName: "bolt.slash.fill",               symbolColor: "orange",  habitCategory: .noAddiction,  symbolism: "plant.ingwerpflanze.symbolism",            xpPerCompletion: 8,  decayDays: 2),
        Plant(id: "plant.teestrauch",       name: "plant.teestrauch.name",        symbolName: "cup.and.saucer.fill",           symbolColor: "brown",   habitCategory: .lifestyle,    symbolism: "plant.teestrauch.symbolism",                   xpPerCompletion: 6,  decayDays: 3),
        Plant(id: "plant.olivenbaum",       name: "plant.olivenbaum.name",        symbolName: "infinity",                      symbolColor: "green",   habitCategory: .lifestyle,    symbolism: "plant.olivenbaum.symbolism",      maxLevel: 15, xpPerCompletion: 10, decayDays: 5)
    ]

    // MARK: Müll-Items (20 Stück)
    static let allTrashItems: [TrashItem] = [
        TrashItem(id: "trash.ultra_konsole",          name: "trash.ultra_konsole.name",          symbolName: "gamecontroller.fill",               symbolColor: "gray",   description: "trash.ultra_konsole.description",               weedGenerated: "Zocker-Ranken",        effect: .growthBlock,    effectValue: -20, cost: 500,  targetCategory: .fitness),
        TrashItem(id: "trash.fast_food_abo",          name: "trash.fast_food_abo.name",          symbolName: "bag.fill",                          symbolColor: "red",    description: "trash.fast_food_abo.description",                       weedGenerated: "Fett-Moos",            effect: .xpReduction,    effectValue: -15, cost: 300,  targetCategory: .nutrition),
        TrashItem(id: "trash.endlos_scroll_tv",       name: "trash.endlos_scroll_tv.name",       symbolName: "tv.fill",                           symbolColor: "gray",   description: "trash.endlos_scroll_tv.description",                                   weedGenerated: "Zeitdieb-Pilze",       effect: .passiveDrain,   effectValue: -10, cost: 400,  targetCategory: nil),
        TrashItem(id: "trash.luxus_auto",             name: "trash.luxus_auto.name",             symbolName: "car.fill",                          symbolColor: "gray",   description: "trash.luxus_auto.description",             weedGenerated: "Abgas-Nebel",          effect: .weatherNerf,    effectValue: -30, cost: 800,  targetCategory: nil),
        TrashItem(id: "trash.party_pass",             name: "trash.party_pass.name",             symbolName: "party.popper.fill",                 symbolColor: "orange", description: "trash.party_pass.description",             weedGenerated: "Chaos-Konfetti",       effect: .streakPenalty,  effectValue: -2,  cost: 350,  targetCategory: nil),
        TrashItem(id: "trash.energy_drink_kiste",     name: "trash.energy_drink_kiste.name",     symbolName: "bolt.fill",                         symbolColor: "red",    description: "trash.energy_drink_kiste.description",                 weedGenerated: "Zitter-Unkraut",       effect: .xpReduction,    effectValue: -25, cost: 200,  targetCategory: .fitness),
        TrashItem(id: "trash.zigaretten_automat",     name: "trash.zigaretten_automat.name",     symbolName: "smoke.fill",                        symbolColor: "gray",   description: "trash.zigaretten_automat.description",                 weedGenerated: "Rauch-Smog",           effect: .xpReduction,    effectValue: -10, cost: 250,  targetCategory: nil),
        TrashItem(id: "trash.online_shopping_app",    name: "trash.online_shopping_app.name",    symbolName: "cart.fill",                         symbolColor: "orange", description: "trash.online_shopping_app.description",                       weedGenerated: "Geld-Fresser-Wurzeln", effect: .currencyDrain,  effectValue: -20, cost: 450,  targetCategory: .finance),
        TrashItem(id: "trash.junk_mail_abo",          name: "trash.junk_mail_abo.name",          symbolName: "envelope.fill",                     symbolColor: "gray",   description: "trash.junk_mail_abo.description",                  weedGenerated: "Ablenkungspollen",     effect: .growthBlock,    effectValue: -15, cost: 100,  targetCategory: .learning),
        TrashItem(id: "trash.nacht_snack_box",        name: "trash.nacht_snack_box.name",        symbolName: "moon.fill",                         symbolColor: "purple", description: "trash.nacht_snack_box.description",               weedGenerated: "Nacht-Schimmel",       effect: .levelDown,      effectValue: -1,  cost: 200,  targetCategory: .sleep),
        TrashItem(id: "trash.alkohol_flatrate",       name: "trash.alkohol_flatrate.name",       symbolName: "wineglass.fill",                    symbolColor: "red",    description: "trash.alkohol_flatrate.description",             weedGenerated: "Fäulnis-Tropfen",      effect: .levelDown,      effectValue: -1,  cost: 350,  targetCategory: .noAddiction),
        TrashItem(id: "trash.doomscrolling_handy",    name: "trash.doomscrolling_handy.name",    symbolName: "hand.tap.fill",                     symbolColor: "gray",   description: "trash.doomscrolling_handy.description",                     weedGenerated: "Pixel-Parasiten",      effect: .passiveDrain,   effectValue: -5,  cost: 300,  targetCategory: nil),
        TrashItem(id: "trash.binge_streaming",        name: "trash.binge_streaming.name",        symbolName: "film.fill",                         symbolColor: "gray",   description: "trash.binge_streaming.description",                 weedGenerated: "Schlaf-Fresser",       effect: .growthBlock,    effectValue: -20, cost: 400,  targetCategory: .sleep),
        TrashItem(id: "trash.fastfood_lieferdienst",  name: "trash.fastfood_lieferdienst.name",  symbolName: "bicycle",                           symbolColor: "orange", description: "trash.fastfood_lieferdienst.description",         weedGenerated: "Fettflecken",          effect: .weatherNerf,    effectValue: -25, cost: 200,  targetCategory: .nutrition),
        TrashItem(id: "trash.lootbox_zockerabo",      name: "trash.lootbox_zockerabo.name",      symbolName: "dice.fill",                         symbolColor: "purple", description: "trash.lootbox_zockerabo.description",                  weedGenerated: "Glücks-Parasiten",     effect: .randomXPLoss,   effectValue: -3,  cost: 600,  targetCategory: nil),
        TrashItem(id: "trash.luxus_uhr",              name: "trash.luxus_uhr.name",              symbolName: "clock.fill",                        symbolColor: "gray",   description: "trash.luxus_uhr.description",      weedGenerated: "Status-Käfer",         effect: .xpReduction,    effectValue: -10, cost: 700,  targetCategory: .finance),
        TrashItem(id: "trash.couch_abo",              name: "trash.couch_abo.name",              symbolName: "rectangle.fill",                    symbolColor: "brown",  description: "trash.couch_abo.description",               weedGenerated: "Faulheits-Moos",       effect: .growthBlock,    effectValue: -50, cost: 300,  targetCategory: .fitness),
        TrashItem(id: "trash.doener_dauerkarte",       name: "trash.doener_dauerkarte.name",       symbolName: "fork.knife",                        symbolColor: "orange", description: "trash.doener_dauerkarte.description",     weedGenerated: "Salzige Erde",         effect: .growthBlock,    effectValue: -30, cost: 150,  targetCategory: .nutrition),
        TrashItem(id: "trash.negativitaets_feed",      name: "trash.negativitaets_feed.name",      symbolName: "antenna.radiowaves.left.and.right", symbolColor: "red",    description: "trash.negativitaets_feed.description",          weedGenerated: "Stress-Dornen",        effect: .xpReduction,    effectValue: -12, cost: 0,    targetCategory: .mentalHealth),
        TrashItem(id: "trash.schlaf_killer_koffein",  name: "trash.schlaf_killer_koffein.name",  symbolName: "cup.and.saucer.fill",               symbolColor: "brown",  description: "trash.schlaf_killer_koffein.description",         weedGenerated: "Übernacht-Rost",       effect: .levelDown,      effectValue: -1,  cost: 100,  targetCategory: .sleep)
    ]

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
