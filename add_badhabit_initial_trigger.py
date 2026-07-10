import json
import os

langs = ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

initial_trigger = {
    "de": "Schlechte Gewohnheit gekauft",
    "en": "Bad Habit purchased",
    "es": "Mal hábito comprado",
    "fr": "Mauvaise habitude achetée",
    "it": "Cattiva abitudine acquistata",
    "pt": "Mau hábito comprado",
    "ja": "悪い習慣を購入しました",
    "ko": "나쁜 습관 구매함",
    "pl": "Kupiono zły nawyk",
    "nl": "Slechte gewoonte gekocht",
    "tr": "Kötü alışkanlık satın alındı"
}

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def add_key(key_name, translations):
    if key_name not in data["strings"]:
        data["strings"][key_name] = {
            "extractionState": "manual",
            "localizations": {}
        }
    else:
        if "localizations" not in data["strings"][key_name]:
            data["strings"][key_name]["localizations"] = {}
    
    for lang, text in translations.items():
        data["strings"][key_name]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

add_key("badhabit.initial_trigger", initial_trigger)

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

print("Success")
