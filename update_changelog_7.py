import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - To-Do & Achievement Badge Translations Fix\n"
new_entry += "- Die englischen Standardtexte ('Add To-Do', 'Enter To-Do...', 'Custom To-Do') wurden nun in der Übersetzungsdatei für Chinesisch und alle weiteren Sprachen korrekt übersetzt (z.B. '新增待辦事項').\n"
new_entry += "- Die falsche Übersetzung des 'Speichern'-Buttons (Save) auf Chinesisch ('節省' statt '儲存') wurde behoben.\n"
new_entry += "- Bei der Erfolgs-Vorschau (Achievements) wurde ein Logikfehler behoben, wodurch die Seltenheit (z.B. 'BRONZE') hartcodiert auf Englisch angezeigt wurde. Nun wird der dynamisch übersetzte Begriff (z.B. '青銅') verwendet.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
