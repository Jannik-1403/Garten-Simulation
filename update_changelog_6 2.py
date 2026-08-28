import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - Screen Time Translations Fix\n"
new_entry += "- Die englischen Standard-Texte ('Schedule currently active' und 'No changes can be made while the schedule is active') auf der Bildschirmzeit-Seite wurden für alle restlichen Sprachen in der Lokalisierungsdatei übersetzt. (u.a. in Chinesisch: '時間表目前處於活動狀態')\n"
new_entry += "- Weitere unübersetzte Texte wie 'Are you sure?', 'With Phone' und 'Off' wurden ebenfalls identifiziert und in über 15 Sprachen in die `Localizable.xcstrings` injiziert, damit nicht mehr die rohen Key-Namen angezeigt werden.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
