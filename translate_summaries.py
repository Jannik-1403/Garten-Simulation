import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

translations = {
    "fitness.water.summary.good": {
        "en": "%lld / %lld ml ✓",
        "es": "%lld / %lld ml ✓",
        "fr": "%lld / %lld ml ✓",
        "pt-BR": "%lld / %lld ml ✓"
    },
    "fitness.water.summary": {
        "en": "%lld / %lld ml",
        "es": "%lld / %lld ml",
        "fr": "%lld / %lld ml",
        "pt-BR": "%lld / %lld ml"
    },
    "fitness.sleep.summary": {
        "en": "%@ / %@ h",
        "es": "%@ / %@ h",
        "fr": "%@ / %@ h",
        "pt-BR": "%@ / %@ h"
    },
    "fitness.strength.summary.min": {
        "en": "%lld / %lld min",
        "es": "%lld / %lld min",
        "fr": "%lld / %lld min",
        "pt-BR": "%lld / %lld min"
    },
    "fitness.running.summary": {
        "en": "%lld / %lld steps",
        "es": "%lld / %lld pasos",
        "fr": "%lld / %lld pas",
        "pt-BR": "%lld / %lld passos"
    },
    "fitness.nutrition.summary.good": {
        "en": "%lld / %lld kcal ✓",
        "es": "%lld / %lld kcal ✓",
        "fr": "%lld / %lld kcal ✓",
        "pt-BR": "%lld / %lld kcal ✓"
    },
    "fitness.nutrition.summary": {
        "en": "%lld / %lld kcal",
        "es": "%lld / %lld kcal",
        "fr": "%lld / %lld kcal",
        "pt-BR": "%lld / %lld kcal"
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

print("Updated summaries.")
