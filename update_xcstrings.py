import json
import sys

file_path = "Garten_Simulation/Localizable.xcstrings"
try:
    with open(file_path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading {file_path}: {e}")
    sys.exit(1)

translations = {
    "en": "Choose Activities",
    "de": "Apps auswählen",
    "ja": "アクティビティを選択",
    "ru": "Выбрать приложения",
    "fr": "Choisir des apps",
    "pt-BR": "Escolher apps",
    "zh-Hant": "選擇活動",
    "zh-Hans": "选择活动",
    "nl": "Kies apps",
    "pt": "Escolher atividades",
    "it": "Scegli app",
    "tr": "Uygulama seç",
    "hi": "गतिविधियां चुनें",
    "ko": "앱 선택",
    "pl": "Wybierz aplikacje",
    "es": "Elegir apps"
}

key = "screenTime.picker.header"
if key not in data["strings"]:
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

for lang, val in translations.items():
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": val
        }
    }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings")
