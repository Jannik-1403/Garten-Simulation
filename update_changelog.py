import os
import datetime

changelog_path = "CHANGELOG.md"
entry = f"""
## {datetime.date.today().strftime('%Y-%m-%d')}
- **Localization:** Systematische Überprüfung der gesamten App-Dateien durchgeführt.
- **Fix:** Verbliebene hardcodierte Strings in verschiedenen Views (SplashScreen, PfadTagDetailView, ScreenTimeSuggestionsView, SeltenheitsBadge, ProfilComponents, DuolingoButton) durch native `String(localized:)` ersetzt.
- **Translation:** `Localizable.xcstrings` um neue Keys erweitert und vollautomatisch (100% Abdeckung) in alle 16 Projektsprachen übersetzt.
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
