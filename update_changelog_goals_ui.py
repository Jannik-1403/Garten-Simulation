import os
from datetime import datetime

file_path = "Garten_Simulation/../CHANGELOG.md"
new_entry = f"""## {datetime.now().strftime('%Y-%m-%d %H:%M')} - Ziel-System (Goals) UI Integration
- **Onboarding**: `GoalOnboardingView` ersetzt die alte Ziele-Auswahl und erzwingt das Setzen eines Jahresziels (Progressive Disclosure).
- **Garten (Quest Tracker)**: `MonthlyGoalBannerView` wurde dezent über dem Garten integriert, um den Fokus des Monats zu zeigen.
- **Profil**: `GoalInsightsView` zeigt jetzt eine Rangliste der Gewohnheiten, die im Monat am meisten Punkte gebracht haben.
- **Shop**: Nach der Erstellung einer Pflanze fragt `GoalLinkView` nun nach der Gewichtung der Gewohnheit für das Jahresziel (20 Pkt vs 5 Pkt vs 0 Pkt).

"""

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
except FileNotFoundError:
    content = ""

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_entry + content)

print("CHANGELOG updated")
