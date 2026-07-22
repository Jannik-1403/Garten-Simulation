import os
import datetime

changelog_path = "CHANGELOG.md"
entry = f"""
## {datetime.date.today().strftime('%Y-%m-%d')} (Widget Localization Update)
- **Localization:** 26 alte Strings aus dem Widget in den zentralen iOS String Catalog (Localizable.xcstrings) migriert.
- **Translation:** Diese Strings wurden automatisch in alle 16 Projektsprachen übersetzt (150 neue Einträge).
- **Cleanup:** Veraltete `.lproj` Ordner und `Localizable.strings` aus dem GartenWidget gelöscht, sodass die App jetzt exklusiv nur noch ein einheitliches System verwendet.
"""

content = ""
if os.path.exists(changelog_path):
    with open(changelog_path, "r", encoding="utf-8") as f:
        content = f.read()

with open(changelog_path, "w", encoding="utf-8") as f:
    if "# Changelog" in content:
        f.write(content.replace("# Changelog", "# Changelog\n" + entry, 1))
    else:
        f.write("# Changelog\n" + entry + "\n" + content)
