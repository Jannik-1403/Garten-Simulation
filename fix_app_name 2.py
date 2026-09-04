import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

strings = data.get("strings", {})
app_name_entry = strings.get("app_name_grovy")
if app_name_entry:
    localizations = app_name_entry.get("localizations", {})
    for lang in localizations:
        if lang not in ["zh-Hans", "zh-Hant"]:
            localizations[lang]["stringUnit"]["value"] = "Grovy"

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated app_name_grovy")
