import json

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Define translation for "Journal öffnen" (Open Journal)
translations = {
  "de": "Journal öffnen",
  "en": "Open Journal",
  "fr": "Ouvrir le journal",
  "es": "Abrir diario",
  "it": "Apri diario",
  "pt": "Abrir diário",
  "pt-BR": "Abrir diário",
  "nl": "Dagboek openen",
  "tr": "Günlüğü Aç",
  "pl": "Otwórz dziennik",
  "ru": "Открыть журнал",
  "ja": "ジャーナルを開く",
  "ko": "일기 열기",
  "hi": "जर्नल खोलें",
  "zh-Hans": "打开日记",
  "zh-Hant": "打開日記"
}

key_name = "habit.gratitude.open_journal"

if key_name not in data["strings"]:
    data["strings"][key_name] = {
        "extractionState": "manual",
        "localizations": {}
    }

localizations = data["strings"][key_name]["localizations"]

for lang, translation in translations.items():
    localizations[lang] = {
        "stringUnit": {
            "state": "translated",
            "value": translation
        }
    }

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Key added successfully.")
