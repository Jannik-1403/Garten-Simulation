import sys
from datetime import datetime

file_path = "CHANGELOG.md"
with open(file_path, "r") as f:
    content = f.read()

today = datetime.now().strftime("%Y-%m-%d")

new_entry = f"## [{today}] - Body Tracking Chart Aggregation\n"
new_entry += "- **Body Tracking:** Bei den Filtern '6 Monate' und 'Jahr' werden die Datenpunkte im Diagramm nun zu übersichtlichen Wochendurchschnitten zusammengefasst.\n"
new_entry += "- **Body Tracking:** Der Header über dem Diagramm zeigt nun für den ausgewählten Zeitraum immer den Durchschnittswert ('DURCHSCHNITT') statt des aktuellsten Gewichts, analog zu Apple Health.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
