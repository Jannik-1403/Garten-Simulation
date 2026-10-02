import re

# 1. Fix Slider Drag Gesture
file_path_pflanze = "Garten_Simulation/Components/PflanzenCard.swift"
with open(file_path_pflanze, "r") as f:
    content = f.read()

content = content.replace("DragGesture(minimumDistance: 15)", "DragGesture(minimumDistance: 0)")

with open(file_path_pflanze, "w") as f:
    f.write(content)

# 2. Fix Localization issue with explicit locale binding
file_path_daily = "Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift"
with open(file_path_daily, "r") as f:
    content = f.read()

old_labels = """    @ViewBuilder
    func dateLabel(for date: Date) -> some View {
        if Calendar.current.isDateInToday(date) {
            Text(String(localized: "history.today", defaultValue: "Heute"))
                .environment(\\.locale, Locale(identifier: settings.appLanguage))
        } else if Calendar.current.isDateInYesterday(date) {
            Text(String(localized: "history.yesterday", defaultValue: "Gestern"))
                .environment(\\.locale, Locale(identifier: settings.appLanguage))"""

new_labels = """    @ViewBuilder
    func dateLabel(for date: Date) -> some View {
        let appLocale = Locale(identifier: settings.appLanguage)
        if Calendar.current.isDateInToday(date) {
            Text(String(localized: "history.today", defaultValue: "Heute", table: "Localizable", locale: appLocale))
        } else if Calendar.current.isDateInYesterday(date) {
            Text(String(localized: "history.yesterday", defaultValue: "Gestern", table: "Localizable", locale: appLocale))"""
content = content.replace(old_labels, new_labels)

with open(file_path_daily, "w") as f:
    f.write(content)

