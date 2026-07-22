import Foundation
var cal = Calendar.current
cal.locale = Locale(identifier: "de")
print("Changed to de:", cal.standaloneMonthSymbols[0])
