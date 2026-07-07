import json

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Delete pt-PT entirely if it exists in the main languages list? Wait, in xcstrings, languages are in each key.
# There is no global list of languages. Just remove 'pt-PT' from 'localizations' of every string.

target_langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    '0': {l: '0' for l in target_langs},
    '': {l: '' for l in target_langs},
    ' ': {l: ' ' for l in target_langs},
    '%@: %lld': {l: '%@: %lld' for l in target_langs},
    '%lld / %lld %@': {l: '%lld / %lld %@' for l in target_langs},
    '%lld erledigt': {
        'de': '%lld erledigt', 'en': '%lld done', 'fr': '%lld terminé', 'it': '%lld completato',
        'ja': '%lld 完了', 'ko': '%lld 완료', 'nl': '%lld voltooid', 'pl': '%lld ukończono',
        'pt': '%lld concluído', 'es': '%lld completado', 'tr': '%lld tamamlandı'
    },
    '%lld Min': {
        'de': '%lld Min', 'en': '%lld min', 'fr': '%lld min', 'it': '%lld min',
        'ja': '%lld 分', 'ko': '%lld 분', 'nl': '%lld min', 'pl': '%lld min',
        'pt': '%lld min', 'es': '%lld min', 'tr': '%lld dk'
    },
    'Auswahl': {
        'de': 'Auswahl', 'en': 'Selection', 'fr': 'Sélection', 'it': 'Selezione',
        'ja': '選択', 'ko': '선택', 'nl': 'Selectie', 'pl': 'Wybór',
        'pt': 'Seleção', 'es': 'Selección', 'tr': 'Seçim'
    },
    'common.awesome': {
        'de': 'Fantastisch', 'en': 'Awesome', 'fr': 'Génial', 'it': 'Fantastico',
        'ja': '素晴らしい', 'ko': '멋진', 'nl': 'Geweldig', 'pl': 'Niesamowite',
        'pt': 'Incrível', 'es': 'Impresionante', 'tr': 'Harika'
    },
    'focus.paywall.button': {
        'de': 'Jetzt freischalten', 'en': 'Unlock now', 'fr': 'Débloquer maintenant', 'it': 'Sblocca ora',
        'ja': '今すぐロック解除', 'ko': '지금 잠금 해제', 'nl': 'Nu ontgrendelen', 'pl': 'Odblokuj teraz',
        'pt': 'Desbloquear agora', 'es': 'Desbloquear ahora', 'tr': 'Şimdi aç'
    },
    'Minuten': {
        'de': 'Minuten', 'en': 'Minutes', 'fr': 'Minutes', 'it': 'Minuti',
        'ja': '分', 'ko': '분', 'nl': 'Minuten', 'pl': 'Minuty',
        'pt': 'Minutos', 'es': 'Minutos', 'tr': 'Dakika'
    },
    'target.reached.message': {
        'pt': 'Você atingiu sua meta diária e sua planta foi regada!'
    },
    'target.reached.title': {
        'pt': 'Muito bem!'
    }
}

for key, value in data.get('strings', {}).items():
    if 'localizations' not in value:
        value['localizations'] = {}
    
    # Remove pt-PT
    if 'pt-PT' in value['localizations']:
        del value['localizations']['pt-PT']
        
    # Add missing translations
    if key in translations:
        for lang, trans in translations[key].items():
            if lang not in value['localizations'] or value['localizations'][lang].get('stringUnit', {}).get('state') != 'translated':
                value['localizations'][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": trans
                    }
                }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Patching completed.")
