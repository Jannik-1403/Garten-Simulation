import json
import re

path = 'Garten_Simulation/Localizable.xcstrings'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Read GameDatabase.swift
with open('Garten_Simulation/Models/GameDatabase.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract all habitName: "..."
habit_names = re.findall(r'habitName:\s*"([^"]+)"', content)

added_count = 0
for hn in habit_names:
    if hn not in data['strings']:
        # Infer a German name based on the key
        # z.B. habit.kalt_duschen -> Kalt duschen
        # plant.bambus.habit -> Bambus
        name = hn.split('.')[-1].replace('_', ' ').title()
        if name == 'Habit':
            name = hn.split('.')[1].replace('_', ' ').title()

        data['strings'][hn] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": name
                    }
                }
            }
        }
        added_count += 1
        print(f"Added {hn} -> {name}")

# Also replace "Habits" -> "Gewohnheiten" and "Habit" -> "Gewohnheit" in all DE strings
# Let's fix the grammar for "Starte heute mit dem Gewohnheit" -> "der Gewohnheit"
for key, item in data['strings'].items():
    if 'localizations' in item and 'de' in item['localizations']:
        string_unit = item['localizations']['de'].get('stringUnit')
        if string_unit and 'value' in string_unit:
            val = string_unit['value']
            if val == "Starte heute mit dem Gewohnheit 'Kontostand prüfen'. 30 Sekunden täglich. Das ist der erste Schritt raus aus der Verdrängung.":
                string_unit['value'] = "Starte heute mit der Gewohnheit 'Kontostand prüfen'. 30 Sekunden täglich. Das ist der erste Schritt raus aus der Verdrängung."

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Added {added_count} missing habit names.")
