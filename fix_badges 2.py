import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

keys_to_update = {
    "shop.badge.popular": {
        "zh-Hant": "熱門",
        "zh-Hans": "热门"
    },
    "shop.badge.best_value": {
        "zh-Hant": "超值",
        "zh-Hans": "超值"
    }
}

count = 0
for key, translations in keys_to_update.items():
    if key in strings:
        localizations = strings[key].setdefault("localizations", {})
        for lang, translation in translations.items():
            localizations[lang] = {"stringUnit": {"state": "translated", "value": translation}}
            count += 1

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Updated {count} translations for shop badges.")
