import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

old_func = """    @ViewBuilder
    func dateLabel(for date: Date) -> some View {
        let appLocale = Locale(identifier: settings.appLanguage)
        
        let dayFmt = DateFormatter()
        dayFmt.locale = appLocale
        dayFmt.dateFormat = "EEE"
        
        let numFmt = DateFormatter()
        numFmt.locale = appLocale
        numFmt.dateFormat = "d.M."
        
        let dayStr = dayFmt.string(from: date).capitalized
        let numStr = numFmt.string(from: date)
        
        Text("\\(dayStr) \\(numStr)")
    }"""

new_func = """    func dateLabel(for date: Date) -> some View {
        let appLocale = Locale(identifier: settings.appLanguage)
        
        let dayFmt = DateFormatter()
        dayFmt.locale = appLocale
        dayFmt.dateFormat = "EEE"
        
        let numFmt = DateFormatter()
        numFmt.locale = appLocale
        numFmt.dateFormat = "d.M."
        
        let dayStr = dayFmt.string(from: date).capitalized
        let numStr = numFmt.string(from: date)
        
        return Text("\\(dayStr) \\(numStr)")
    }"""

content = content.replace(old_func, new_func)

with open(file_path, "w") as f:
    f.write(content)
