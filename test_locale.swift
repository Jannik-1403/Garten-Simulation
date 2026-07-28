import Foundation

let locale = Locale(identifier: "en")
let text = String(localized: "widget_water_alltime", defaultValue: "GESAMT", locale: locale)
print(text)
