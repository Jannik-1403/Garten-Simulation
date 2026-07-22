import Foundation
var cal = Calendar.current
cal.locale = Locale(identifier: "en")
print("current mutated to en:", cal.standaloneMonthSymbols[0])

var cal2 = Calendar(identifier: .gregorian)
cal2.locale = Locale(identifier: "en")
print("gregorian mutated to en:", cal2.standaloneMonthSymbols[0])
