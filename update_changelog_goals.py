import os
from datetime import datetime

file_path = "Garten_Simulation/../CHANGELOG.md"
new_entry = f"""## {datetime.now().strftime('%Y-%m-%d %H:%M')} - Ziel-System (Goals) Modelle
- **GoalModels.swift**: Neue Datenstrukturen (`GoalModel`, `GoalHabitLink`, `GoalLog`, `GoalTemplate`) für Jahres- und Monatsziele hinzugefügt.
- **GoalStore.swift**: Separater Store zur sauberen Verwaltung der Ziele und Berechnung der Punkte basierend auf Habit-Gewichtungen (20 Pkt vs 5 Pkt).
- **GardenStore Integration**: `giessen`-Funktion ruft nun den `GoalStore` auf, um Habit-Abschlüsse ins Ziel-System zu übertragen.
- **Localizations**: Neue Übersetzungen für Goal-Typen und -Gewichtungen in allen Sprachen ergänzt.

"""

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except FileNotFoundError:
    content = ""

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_entry + content)

print("CHANGELOG updated")
