import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

translations = {
    "fitness.strength.summary.daysago": {
        "en": "(%lld days ago)",
        "es": "(Hace %lld días)",
        "fr": "(Il y a %lld jours)",
        "pt-BR": "(Há %lld dias)"
    }
}

for key, trans in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    data["strings"][key]["extractionState"] = "manual"
    
    for lang, text in trans.items():
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated translations again.")
