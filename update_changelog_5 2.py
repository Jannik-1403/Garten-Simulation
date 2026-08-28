import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - General Localization & Error Message Improvements\n"
new_entry += "- Die Fehlermeldungen bei der Einrichtung der Bildschirmzeit und beim Daten-Export/Import wurden überarbeitet. Statt rohen, englischen Systemfehlern (wie 'Schedule currently active now') werden nun saubere, lokalisierte Texte angezeigt.\n"
new_entry += "- Der wenig professionelle Text 'Laser Focus' wurde im gesamten Projekt durch passendere Begriffe wie 'Fokus-Session aktiv' oder 'Tiefenarbeit' ersetzt.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
