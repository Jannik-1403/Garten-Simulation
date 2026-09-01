import json

patch_data = {
  "%lld.": "%lld日"
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, zh_text in patch_data.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "localizations": {
                "zh-Hans": {"stringUnit": {"state": "translated", "value": zh_text}},
                "zh-Hant": {"stringUnit": {"state": "translated", "value": zh_text}}
            }
        }
    else:
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        data["strings"][key]["localizations"]["zh-Hans"] = {"stringUnit": {"state": "translated", "value": zh_text}}
        data["strings"][key]["localizations"]["zh-Hant"] = {"stringUnit": {"state": "translated", "value": zh_text}}

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Patched day formatting.")
