import os
from datetime import datetime

file_path = "CHANGELOG.md"
entry = f"""
## [{datetime.now().strftime('%Y-%m-%d')}] - AI Coach Export
- Hinzugefügt: `ExportDailySummaryIntent` ermöglicht den Datenexport der App für Shortcuts und KI-Coaches (HealthKit, Statistiken, Schlechte Gewohnheiten, Fortschritt).
- Hinzugefügt: "KI & Daten-Export" Button im Developer-Menü zum schnellen Testen (Kopieren des JSON in die Zwischenablage).
- Alle UI-Texte in `Localizable.xcstrings` 100% übersetzt (11 Sprachen).
"""

content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

with open(file_path, "w") as f:
    f.write(entry + "\n" + content)
