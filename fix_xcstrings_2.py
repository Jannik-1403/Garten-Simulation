import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

key = "Noch %lld XP bis %@"
if key in data.get("strings", {}):
    item = data["strings"][key]
    
    if "ko" in item.get("localizations", {}):
        val = item["localizations"]["ko"]["stringUnit"]["value"]
        if "%2$@" in val and "%1$lld" in val:
            item["localizations"]["ko"]["stringUnit"]["value"] = "%lld XP 남음 (%@)"
            
    if "tr" in item.get("localizations", {}):
        val = item["localizations"]["tr"]["stringUnit"]["value"]
        if "%2$@" in val and "%1$lld" in val:
            item["localizations"]["tr"]["stringUnit"]["value"] = "%lld XP kaldı (%@)"

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
