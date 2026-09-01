import re

with open("Garten_Simulation/Views/BodyDataFactoryView.swift", "r") as f:
    content = f.read()

replacement = """        case .m:
            let day = cal.component(.day, from: date)
            return String(localized: "body.tracking.chart.day", defaultValue: "\\(day).")
        case .sixM:
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "MMM"
            return formatter.string(from: date)
        case .j:
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            let month = cal.component(.month, from: date)
            return formatter.veryShortMonthSymbols[month - 1]"""

pattern = r"        case \.m:.*?return letters\[safe: month - 1\] \?\? \"\""

new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open("Garten_Simulation/Views/BodyDataFactoryView.swift", "w") as f:
    f.write(new_content)
