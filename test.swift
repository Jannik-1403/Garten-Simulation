import Foundation
var cal = Calendar.current
cal.locale = Locale(identifier: "en")
print("en: ", cal.standaloneMonthSymbols)
cal.locale = Locale(identifier: "de")
print("de: ", cal.standaloneMonthSymbols)
