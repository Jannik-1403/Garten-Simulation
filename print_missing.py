import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

for key, value in data["strings"].items():
    for lang in languages:
        if "localizations" not in value or lang not in value["localizations"] or value["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
            print(f"Key missing {lang}: {key}")
