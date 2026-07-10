import json

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_keys = {
    "focus.phone_prompt.title": "Wirst du das Handy weglegen?",
    "focus.phone_prompt.yes": "Ja, weglegen",
    "focus.phone_prompt.no": "Nein, ich brauche es",
    "focus.phone_prompt.message": "Wähle danach die Apps aus, die für diesen Fokus blockiert werden sollen."
}

for key, default_value in new_keys.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {
                "de": {
                    "stringUnit": {
                        "state": "translated",
                        "value": default_value
                    }
                }
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Keys added.")
