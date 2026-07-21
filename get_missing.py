import json

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

source_lang = data.get('sourceLanguage', 'de')
all_langs = {'pt-BR', 'zh-Hant', 'fr', 'en', 'ko', 'de', 'ja', 'zh-Hans', 'nl', 'es', 'hi', 'it', 'pt', 'ru', 'tr', 'pl'}

missing_info = {}

for key, value in data.get('strings', {}).items():
    localizations = value.get('localizations', {})
    
    missing_for = []
    for lang in all_langs:
        if lang == source_lang:
            continue
        if lang not in localizations:
            missing_for.append(lang)
        elif localizations[lang].get('stringUnit', {}).get('state') != 'translated':
            missing_for.append(lang)
            
    if missing_for:
        missing_info[key] = {
            'missing_languages': missing_for,
            'source_text': key # Often key is the default text, or we can look up English
        }
        if 'en' in localizations and localizations['en'].get('stringUnit', {}).get('state') == 'translated':
            missing_info[key]['en_text'] = localizations['en']['stringUnit']['value']
        if source_lang in localizations and localizations[source_lang].get('stringUnit', {}).get('state') == 'translated':
            missing_info[key]['source_value'] = localizations[source_lang]['stringUnit']['value']
            
print(json.dumps(missing_info, indent=2))
