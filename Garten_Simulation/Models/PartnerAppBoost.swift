import Foundation

struct PartnerAppBoost: Identifiable {
    let id = UUID()
    let targetCategories: [HabitCategory]
    let appName: String
    let subtitleKey: String
    let iconName: String
    let url: String
    let discountTextKey: String?
}

let availableHabitBoosts: [PartnerAppBoost] = [
    PartnerAppBoost(targetCategories: [.fitness], appName: "Hevy", subtitleKey: "boost.hevy.subtitle", iconName: "icon_hevy", url: "https://apps.apple.com/de/app/hevy-krafttraining-logbuch/id1458732410", discountTextKey: "boost.hevy.discount"),
    PartnerAppBoost(targetCategories: [.growth], appName: "Blinkist", subtitleKey: "boost.blinkist.subtitle", iconName: "icon_blinkist", url: "https://apps.apple.com/de/app/blinkist-gro%C3%9Fes-wissen-in-kurz/id568839295", discountTextKey: "boost.blinkist.discount"),
    PartnerAppBoost(targetCategories: [.mental], appName: "Headspace", subtitleKey: "boost.headspace.subtitle", iconName: "icon_headspace", url: "https://apps.apple.com/de/app/headspace-meditation-schlaf/id493145008", discountTextKey: nil),
    PartnerAppBoost(targetCategories: [.health], appName: "YAZIO", subtitleKey: "boost.yazio.subtitle", iconName: "icon_yazio", url: "https://apps.apple.com/de/app/yazio-kalorienz%C3%A4hler-fasten/id946099227", discountTextKey: "boost.yazio.discount"),
    PartnerAppBoost(targetCategories: [.finance], appName: "Finanzguru", subtitleKey: "boost.finanzguru.subtitle", iconName: "icon_finanzguru", url: "https://apps.apple.com/de/app/finanzguru-konten-vertr%C3%A4ge/id1214803082", discountTextKey: nil)
]
