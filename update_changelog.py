import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - Lokalisierung & Chinesisch Fixes\n"
new_entry += "- Die fehlerhaften Übersetzungen für Chinesisch wurden behoben.\n"
new_entry += "- Die 'Custom To-Do' Ansicht ist nun zu 100% übersetzt (Titel, Icons, Platzhalter).\n"
new_entry += "- Fehlerhafte Kategorien ('Sucht & Laster', 'Ernährung', etc.) werden nun in Chinesisch richtig dargestellt.\n"
new_entry += "- Shop Tabs ('Gute', 'Schlechte', 'Gewohnheiten') sind repariert und vollständig lokalisiert.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
