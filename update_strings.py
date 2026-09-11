import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_key = "plant.level"
new_entry = {
    "localizations": {
        "en": {
            "stringUnit": {
                "state": "translated",
                "value": "Level %lld"
            }
        },
        "de": {
            "stringUnit": {
                "state": "translated",
                "value": "Level %lld"
            }
        }
    }
}

if new_key not in data["strings"]:
    data["strings"][new_key] = new_entry
    print(f"Added {new_key}")
else:
    print(f"{new_key} already exists.")

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

