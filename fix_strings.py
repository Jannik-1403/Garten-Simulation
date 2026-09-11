import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

if "fitness.nutrition.summary" in data.get("strings", {}):
    localizations = data["strings"]["fitness.nutrition.summary"].get("localizations", {})
    for lang, lang_data in localizations.items():
        if "stringUnit" in lang_data:
            old_val = lang_data["stringUnit"]["value"]
            if "%@" in old_val:
                lang_data["stringUnit"]["value"] = old_val.replace("%@", "%lld")
                print(f"Fixed {lang}: {old_val} -> {lang_data['stringUnit']['value']}")

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')

