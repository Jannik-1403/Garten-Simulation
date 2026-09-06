import json

with open("Localizable.xcstrings", "r") as f:
    data = json.load(f)

translations = {
    "developer.cheats.title": {
        "de": "Cheats",
        "en": "Cheats",
        "es": "Trucos",
        "fr": "Triches",
        "it": "Trucchi",
        "pt-BR": "Trapaças",
        "zh-Hans": "作弊"
    },
    "developer.cheats.addCoins": {
        "de": "+ 100.000 Münzen",
        "en": "+ 100,000 Coins",
        "es": "+ 100.000 Monedas",
        "fr": "+ 100 000 Pièces",
        "it": "+ 100.000 Monete",
        "pt-BR": "+ 100.000 Moedas",
        "zh-Hans": "+ 100,000 金币"
    }
}

for key, trans_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang, val in trans_dict.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open("Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Translations patched.")
