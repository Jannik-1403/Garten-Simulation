import re

filepath = "Garten_Simulation/Views/Profile/AutoBackupListView.swift"
with open(filepath, "r") as f:
    content = f.read()

# Replace date formatting
old_date = "Text(date.formatted(date: .abbreviated, time: .shortened))"
new_date = 'Text(date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, locale: Locale(identifier: Bundle.main.preferredLocalizations.first ?? "en"))))'

content = content.replace(old_date, new_date)

with open(filepath, "w") as f:
    f.write(content)
print("Updated Date format in AutoBackupListView.swift")
