import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "fitness.nutrition.protein.detail": {
        "en": "Protein: %lld / %lld g", "fr": "Protéines: %lld / %lld g", "es": "Proteína: %lld / %lld g", "it": "Proteine: %lld / %lld g",
        "pt": "Proteína: %lld / %lld g", "pt-BR": "Proteína: %lld / %lld g", "nl": "Eiwit: %lld / %lld g", "pl": "Białko: %lld / %lld g",
        "ru": "Белок: %lld / %lld г", "tr": "Protein: %lld / %lld g", "ja": "たんぱく質: %lld / %lld g", "ko": "단백질: %lld / %lld g",
        "zh-Hans": "蛋白质: %lld / %lld 克", "zh-Hant": "蛋白質: %lld / %lld 克", "hi": "प्रोटीन: %lld / %lld ग्राम"
    },
    "fitness.nutrition.fiber.detail": {
        "en": "Fiber: %lld / %lld g", "fr": "Fibres: %lld / %lld g", "es": "Fibra: %lld / %lld g", "it": "Fibre: %lld / %lld g",
        "pt": "Fibra: %lld / %lld g", "pt-BR": "Fibra: %lld / %lld g", "nl": "Vezels: %lld / %lld g", "pl": "Błonnik: %lld / %lld g",
        "ru": "Клетчатка: %lld / %lld г", "tr": "Lif: %lld / %lld g", "ja": "食物繊維: %lld / %lld g", "ko": "식이섬유: %lld / %lld g",
        "zh-Hans": "膳食纤维: %lld / %lld 克", "zh-Hant": "膳食纖維: %lld / %lld 克", "hi": "फाइबर: %lld / %lld ग्राम"
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

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated 2 keys.")
