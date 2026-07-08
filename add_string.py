import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

key = "plant.streak.current"
translations = {
    "de": "Deine aktuelle Garten Streak",
    "en": "Your current Garden Streak",
    "nl": "Je huidige Tuinstreak",
    "fr": "Votre séquence de jardin actuelle",
    "it": "La tua serie giardino attuale",
    "ja": "現在のガーデン連続",
    "ko": "현재 정원 연속",
    "pl": "Twoja obecna passa ogrodu",
    "pt": "Sua sequência de jardim atual",
    "es": "Tu racha de jardín actual",
    "tr": "Mevcut Bahçe Serisi"
}

if key not in data["strings"]:
    data["strings"][key] = {"extractionState": "manual", "localizations": {}}

for lang, text in translations.items():
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": text
        }
    }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
