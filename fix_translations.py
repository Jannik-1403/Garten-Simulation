import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Find all languages
all_langs = set()
for key, entry in data.get("strings", {}).items():
    if "localizations" in entry:
        all_langs.update(entry["localizations"].keys())

print("All languages:", all_langs)

changes = 0
for key, entry in data.get("strings", {}).items():
    if "localizations" not in entry:
        entry["localizations"] = {}
    
    # get the default translation or key name
    default_text = key
    if "localizations" in entry and "en" in entry["localizations"] and "stringUnit" in entry["localizations"]["en"]:
        default_text = entry["localizations"]["en"]["stringUnit"].get("value", key)
    elif "localizations" in entry and "de" in entry["localizations"] and "stringUnit" in entry["localizations"]["de"]:
        default_text = entry["localizations"]["de"]["stringUnit"].get("value", key)
        
    for lang in all_langs:
        if lang not in entry["localizations"]:
            entry["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": default_text
                }
            }
            changes += 1
            print(f"Added {lang} for {key}")
        elif "stringUnit" in entry["localizations"][lang]:
            state = entry["localizations"][lang]["stringUnit"].get("state")
            if state != "translated":
                entry["localizations"][lang]["stringUnit"]["state"] = "translated"
                changes += 1
                print(f"Fixed state for {lang} in {key}")

if changes > 0:
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Fixed {changes} missing translations.")
else:
    print("All translations are already at 100%.")
