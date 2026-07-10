import json
import os

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "de": "Zusätzlich manuell eintragen",
    "en": "Also track manually",
    "es": "Registrar manualmente también",
    "fr": "Entrer manuellement aussi",
    "ja": "手動で入力する",
    "ko": "수동으로도 입력하기",
    "ru": "Также вводить вручную",
    "zh-Hans": "手动输入"
}

key = "apple.health.allow_manual"
if key not in data["strings"]:
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

for lang, text in translations.items():
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": text
        }
    }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
print("Updated translations")
