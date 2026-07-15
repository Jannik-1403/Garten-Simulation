import json

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

target_langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    'plant.card.challenge.progress': {
        'de': 'Tag %lld von %lld', 'en': 'Day %lld of %lld', 'fr': 'Jour %lld sur %lld', 'it': 'Giorno %lld di %lld',
        'ja': '%lld / %lld日目', 'ko': '%lld / %lld일', 'nl': 'Dag %lld van %lld', 'pl': 'Dzień %lld z %lld',
        'pt': 'Dia %lld de %lld', 'es': 'Día %lld de %lld', 'tr': '%lld. Gün / %lld'
    },
    'plant.card.challenge.not_activated': {
        'de': 'Noch nicht aktiviert', 'en': 'Not activated yet', 'fr': 'Pas encore activé', 'it': 'Non ancora attivato',
        'ja': '未アクティベート', 'ko': '아직 활성화되지 않음', 'nl': 'Nog niet geactiveerd', 'pl': 'Jeszcze nie aktywowane',
        'pt': 'Ainda não ativado', 'es': 'Aún no activado', 'tr': 'Henüz etkinleştirilmedi'
    }
}

for key, value in data.get('strings', {}).items():
    pass

for key in translations:
    if key not in data['strings']:
        data['strings'][key] = {"localizations": {}}
    for lang, trans in translations[key].items():
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Challenge strings injected.")
