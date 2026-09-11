import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# The keys in 'localizations' define the languages used for a specific string.
# Let's find all languages that exist in the file.
all_langs = set()
for key, entry in data.get("strings", {}).items():
    if "localizations" in entry:
        all_langs.update(entry["localizations"].keys())

print("All languages:", all_langs)

key_to_add = "plant.level"
if key_to_add in data["strings"]:
    entry = data["strings"][key_to_add]
    if "localizations" not in entry:
        entry["localizations"] = {}
    
    for lang in all_langs:
        if lang not in entry["localizations"]:
            entry["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": "Level %lld"
                }
            }
            print(f"Added {lang} for {key_to_add}")

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

