import json
import re

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

for key, item in data['strings'].items():
    if 'localizations' in item and 'de' in item['localizations']:
        string_unit = item['localizations']['de'].get('stringUnit')
        if string_unit and 'value' in string_unit:
            val = string_unit['value']
            # Replace Habit -> Gewohnheit, Habits -> Gewohnheiten
            new_val = val
            new_val = re.sub(r'\bHabits\b', 'Gewohnheiten', new_val)
            new_val = re.sub(r'\bhabits\b', 'Gewohnheiten', new_val)
            new_val = re.sub(r'\bHabit\b', 'Gewohnheit', new_val)
            new_val = re.sub(r'\bhabit\b', 'Gewohnheit', new_val)
            new_val = re.sub(r'\bBad Habit\b', 'Schlechte Gewohnheit', new_val, flags=re.IGNORECASE)
            new_val = re.sub(r'\bBad Habits\b', 'Schlechte Gewohnheiten', new_val, flags=re.IGNORECASE)
            
            if new_val != val:
                print(f"Changing {key}: {val} -> {new_val}")
                string_unit['value'] = new_val

with open('Garten_Simulation/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
