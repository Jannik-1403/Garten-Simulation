import re

path = "Garten_Simulation/Views/Profile/PDFExportConfigView.swift"
with open(path, "r") as f:
    content = f.read()

# Replace String(localized: "...", defaultValue: "...")
# with String(localized: "...", defaultValue: "...", locale: Locale(identifier: settings.appLanguage))
content = re.sub(
    r'String\(localized: ("[^"]+"), defaultValue: ("[^"]+")\)',
    r'String(localized: \1, defaultValue: \2, locale: Locale(identifier: settings.appLanguage))',
    content
)

with open(path, "w") as f:
    f.write(content)

