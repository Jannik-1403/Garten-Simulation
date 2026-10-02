import re

file_path = "Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift"
with open(file_path, "r") as f:
    content = f.read()

# Remove showCalendarSheet variable
content = content.replace("@State private var showCalendarSheet: Bool = false\n", "")

# Remove sheet
old_sheet = """        .sheet(isPresented: $showCalendarSheet) {
            HistoryCalendarSheet(vm: vm)
                .environmentObject(gardenStore)
                .environment(\\.locale, Locale(identifier: settings.appLanguage))
        }"""
content = content.replace(old_sheet, "")

with open(file_path, "w") as f:
    f.write(content)
