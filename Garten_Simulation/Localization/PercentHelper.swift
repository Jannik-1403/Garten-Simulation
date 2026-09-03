import SwiftUI

enum PercentHelper {
    private static func format1(_ key: String.LocalizationValue, _ arg1: String) -> String {
        return String(format: String(localized: key), arg1)
    }
    
    private static func format2(_ key: String.LocalizationValue, _ arg1: String, _ arg2: String) -> String {
        return String(format: String(localized: key), arg1, arg2)
    }
    
    static func localizedWithPercents(_ key: String) -> String {
        let p0: String = "0%"
        let p1: String = "1%"
        let p2: String = "2%"
        let p5: String = "5%"
        let p10: String = "10%"
        let p12: String = "12%"
        let p15: String = "15%"
        let p20: String = "20%"
        let p25: String = "25%"
        let p30: String = "30%"
        let p50: String = "50%"
        let p80: String = "80%"
        let p90: String = "90%"
        let p95: String = "95%"
        let p100: String = "100%"
        let p150: String = "150%"
        
        switch key {
        case "assessment.benchmark.top10": return format1("assessment.benchmark.top10", p10)
        case "assessment.benchmark.top30": return format1("assessment.benchmark.top30", p30)
        case "assessment.finance.pitfall.reserves": return format1("assessment.finance.pitfall.reserves", p10)
        case "assessment.finance.profile.impulsiver.break": return format2("assessment.finance.profile.impulsiver.break", p1, p50)
        case "assessment.finance.profile.impulsiver.build": return format1("assessment.finance.profile.impulsiver.build", p80)
        case "assessment.finance.profile.kontrolleur.build": return format1("assessment.finance.profile.kontrolleur.build", p1)
        case "assessment.finance.q12": return format1("assessment.finance.q12", p15)
        case "assessment.finance.q13": return format2("assessment.finance.q13", p12, p2)
        case "assessment.fitness.profile.ausreden_sucher.desc": return format1("assessment.fitness.profile.ausreden_sucher.desc", p1)
        case "assessment.fitness.profile.maschine.desc": return format1("assessment.fitness.profile.maschine.desc", p1)
        case "assessment.fitness.profile.schoenwetter_sportler.desc": return format1("assessment.fitness.profile.schoenwetter_sportler.desc", p1)
        case "assessment.fitness.q1.d": return format1("assessment.fitness.q1.d", p100)
        case "assessment.fitness.q5.c": return format1("assessment.fitness.q5.c", p50)
        case "assessment.growth.pitfall.efficiency": return format2("assessment.growth.pitfall.efficiency", p80, p0)
        case "assessment.growth.profile.aufgeber.break": return format1("assessment.growth.profile.aufgeber.break", p10)
        case "assessment.growth.profile.fakeWorker.desc": return format1("assessment.growth.profile.fakeWorker.desc", p1)
        case "assessment.growth.profile.macher.desc": return format1("assessment.growth.profile.macher.desc", p1)
        case "assessment.growth.profile.traeumer.desc": return format1("assessment.growth.profile.traeumer.desc", p1)
        case "assessment.growth.q3": return format2("assessment.growth.q3", p80, p20)
        case "assessment.health.profile.erschoepfer.desc": return format1("assessment.health.profile.erschoepfer.desc", p1)
        case "assessment.health.profile.optimierer.break": return format2("assessment.health.profile.optimierer.break", p100, p80)
        case "assessment.health.profile.optimierer.desc": return format1("assessment.health.profile.optimierer.desc", p1)
        case "assessment.health.profile.vergifter.desc": return format1("assessment.health.profile.vergifter.desc", p1)
        case "assessment.health.q1": return format1("assessment.health.q1", p20)
        case "assessment.health.q11.d": return format1("assessment.health.q11.d", p90)
        case "assessment.lifestyle.profile.gefangener.desc": return format1("assessment.lifestyle.profile.gefangener.desc", p1)
        case "assessment.lifestyle.q6.c": return format2("assessment.lifestyle.q6.c", p50, p50)
        case "assessment.lifestyle.q11.a": return format1("assessment.lifestyle.q11.a", p100)
        case "assessment.mental.profile.glaeserner.break": return format1("assessment.mental.profile.glaeserner.break", p1)
        case "assessment.mental.profile.unerschuetterlicher.break": return format1("assessment.mental.profile.unerschuetterlicher.break", p1)
        case "assessment.mental.profile.unerschuetterlicher.desc": return format1("assessment.mental.profile.unerschuetterlicher.desc", p1)
        case "assessment.mental.q10.c": return format1("assessment.mental.q10.c", p95)
        case "assessment.mental.q13": return format1("assessment.mental.q13", p100)
        case "assessment.source.cat.top10": return format1("assessment.source.cat.top10", p10)
        case "assessment.source.cat.top30": return format1("assessment.source.cat.top30", p30)
        case "benchmark.top": return format1("benchmark.top", p1)
        case "effekt.frostwarnung.beschreibung": return format1("effekt.frostwarnung.beschreibung", p50)
        case "effekt.regen.beschreibung": return format1("effekt.regen.beschreibung", p25)
        case "effekt.sonnenschein.beschreibung": return format1("effekt.sonnenschein.beschreibung", p150)
        case "inventory.item.desc.growth_boost": return format1("inventory.item.desc.growth_boost", p50)
        case "item.diamant_erde.description": return format1("item.diamant_erde.description", p10)
        case "level_unlock_coin_5_desc": return format1("level_unlock_coin_5_desc", p5)
        case "level_unlock_coin_10_desc": return format1("level_unlock_coin_10_desc", p10)
        case "level_unlock_coin_15_desc": return format1("level_unlock_coin_15_desc", p15)
        case "level_unlock_coin_20_desc": return format1("level_unlock_coin_20_desc", p20)
        case "onboarding_legal_benefit_3": return format1("onboarding_legal_benefit_3", p100)
        case "paywall.feature.coin_bonus.desc": return format1("paywall.feature.coin_bonus.desc", p25)
        case "paywall.feature.coin_bonus.title": return format1("paywall.feature.coin_bonus.title", p25)
        case "shop.insufficient_coins.get_pro": return format1("shop.insufficient_coins.get_pro", p50)
        case "weather.effect.gems_minus": return format1("weather.effect.gems_minus", p30)
        case "weather.effect.gems_plus": return format1("weather.effect.gems_plus", p50)
        case "weather.effect.xp_plus": return format1("weather.effect.xp_plus", p50)
        case "weather.schnee.subtitle": return format1("weather.schnee.subtitle", p50)
        default:
            return String(localized: String.LocalizationValue(key))
        }
    }
}
