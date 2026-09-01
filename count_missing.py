import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = set()
for key, value in data["strings"].items():
    if "localizations" in value:
        for lang in value["localizations"].keys():
            languages.add(lang)

print("Languages:", sorted(list(languages)))
missing_count = 0
for key, value in data["strings"].items():
    for lang in languages:
        if "localizations" not in value or lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            missing_count += 1

print(f"Total missing translations across all languages: {missing_count}")
