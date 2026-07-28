import Foundation

// Simulate a situation where Region is US, but app language is zh-Hant
let date = Date(timeIntervalSince1970: 1672531200) // 2023-01-01

let defaultFormatted = date.formatted(date: .abbreviated, time: .shortened)
print("Default (depends on system): \(defaultFormatted)")

// Force using Bundle preferred localization
let appLang = Bundle.main.preferredLocalizations.first ?? "en"
let forcedLocale = Locale(identifier: appLang)
let forcedFormatted = date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, locale: forcedLocale))

print("Forced to \(appLang): \(forcedFormatted)")
