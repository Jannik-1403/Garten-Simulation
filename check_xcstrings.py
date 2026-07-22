import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

expected_langs = set(['de', 'en', 'es', 'fr', 'it', 'pt', 'pt-BR', 'zh-Hans', 'zh-Hant', 'ja', 'ko', 'hi', 'tr', 'ru', 'nl', 'pl'])
# Find all languages present in the file across any key
all_langs = set()
for key, item in data["strings"].items():
    if "localizations" in item:
        all_langs.update(item["localizations"].keys())

print("All languages detected in file:", all_langs)

missing_count = 0
for key, item in data["strings"].items():
    if "localizations" not in item:
        print(f"Key '{key}' has NO localizations!")
        missing_count += 1
        continue
    
    locs = item["localizations"]
    missing = all_langs - set(locs.keys())
    for l in locs:
        if locs[l].get("stringUnit", {}).get("state") != "translated":
            missing.add(l)
    
    if missing:
        print(f"Key '{key}' is missing or untranslated for: {missing}")
        missing_count += 1

print(f"Total keys missing translations: {missing_count}")
