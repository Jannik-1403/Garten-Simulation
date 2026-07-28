import json
import time
import translators as ts

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = {
    'pt': 'pt',
    'nl': 'nl',
    'zh-Hans': 'zh-CN',
    'ko': 'ko',
    'ja': 'ja',
    'tr': 'tr',
    'es': 'es',
    'fr': 'fr',
    'en': 'en',
    'ru': 'ru',
    'pl': 'pl',
    'it': 'it',
    'hi': 'hi',
    'zh-Hant': 'zh-TW',
    'pt-BR': 'pt'
}

keys_to_translate = [
    "widget_intent_history_title",
    "widget_intent_routine_desc",
    "widget_intent_routine_title",
    "widget_intent_streak_title",
    "widget_intent_water_desc",
    "widget_intent_water_title",
    "widget_period_alltime",
    "widget_period_month",
    "widget_period_today",
    "widget_period_type",
    "widget_period_week",
    "widget_routine_type",
    "widget_style_dark",
    "widget_style_light",
    "widget_style_type"
]

strings = data.get('strings', {})

for app_lang, tl_lang in langs.items():
    print(f"Translating to {app_lang}...")
    for key in keys_to_translate:
        if key not in strings: continue
        de_text = strings[key]['localizations']['de']['stringUnit']['value']
        if not de_text: continue
        
        locs = strings[key].setdefault('localizations', {})
        if app_lang not in locs or locs[app_lang].get('stringUnit', {}).get('value', '') == '':
            try:
                res = ts.translate_text(de_text, from_language='de', to_language=tl_lang, translator='google')
                locs[app_lang] = {"stringUnit": {"state": "translated", "value": res}}
                time.sleep(0.5)
            except Exception as e:
                print(f"Error for {key} in {app_lang}: {e}")

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Done")
