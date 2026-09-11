import json

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Define translations for both keys
translations_title = {
  "de": "Journal",
  "en": "Journal",
  "fr": "Journal",
  "es": "Diario",
  "it": "Diario",
  "pt": "Diário",
  "pt-BR": "Diário",
  "nl": "Dagboek",
  "tr": "Günlük",
  "pl": "Dziennik",
  "ru": "Журнал",
  "ja": "ジャーナル",
  "ko": "일기",
  "hi": "जर्नल",
  "zh-Hans": "日记",
  "zh-Hant": "日記"
}

translations_empty = {
  "de": "Noch keine Einträge",
  "en": "No entries yet",
  "fr": "Aucune entrée pour l'instant",
  "es": "Aún no hay entradas",
  "it": "Ancora nessuna voce",
  "pt": "Ainda sem entradas",
  "pt-BR": "Ainda sem entradas",
  "nl": "Nog geen invoer",
  "tr": "Henüz giriş yok",
  "pl": "Brak wpisów",
  "ru": "Пока нет записей",
  "ja": "まだ入力がありません",
  "ko": "아직 항목이 없습니다",
  "hi": "अभी तक कोई प्रविष्टि नहीं",
  "zh-Hans": "暂无记录",
  "zh-Hant": "暫無記錄"
}

def add_key(key_name, translations_dict):
    if key_name not in data["strings"]:
        data["strings"][key_name] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    localizations = data["strings"][key_name]["localizations"]
    
    for lang, translation in translations_dict.items():
        localizations[lang] = {
            "stringUnit": {
                "state": "translated",
                "value": translation
            }
        }

add_key("habit.gratitude.title", translations_title)
add_key("habit.gratitude.empty", translations_empty)

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Keys added successfully.")
