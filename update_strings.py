import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

key = "shop.item.coins_label"
if key not in data["strings"]:
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

translations = {
    "de": "Münzen",
    "en": "Coins",
    "es": "Monedas",
    "fr": "Pièces",
    "it": "Monete",
    "pt": "Moedas",
    "nl": "Munten",
    "pl": "Monety",
    "tr": "Jeton",
    "ja": "コイン",
    "ko": "코인"
}

for lang, val in translations.items():
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": val
        }
    }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings")
