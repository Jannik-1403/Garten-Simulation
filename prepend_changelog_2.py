import sys
from datetime import datetime

file_path = "CHANGELOG.md"
with open(file_path, "r") as f:
    content = f.read()

today = datetime.now().strftime("%Y-%m-%d")

new_entry = f"## [{today}] - Update Display Mode Text & Remove 'Sonstiges'\n"
new_entry += "- **Profil & Einstellungen:** Der Beschreibungstext für den Anzeigemodus ('Name der Pflanze ohne die verknüpfte Gewohnheit') wurde in 15 Sprachen präzisiert und gekürzt.\n"
new_entry += "- **Schlechte Gewohnheiten:** Die überflüssige Kategorie 'Sonstiges' (.pflanzen) wurde aus den Trash-Items/Dekorationen entfernt.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
