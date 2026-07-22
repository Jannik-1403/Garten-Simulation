import Foundation
let preferred = Bundle.main.preferredLocalizations.first ?? "en"
let formatter = DateFormatter()
formatter.locale = Locale(identifier: preferred)
print(formatter.standaloneMonthSymbols[0])
