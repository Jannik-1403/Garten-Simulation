import json
import time
import re
import translators as ts

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = {
    'ru': 'ru',
    'hi': 'hi',
    'zh-Hans': 'zh-CHS', # Bing uses zh-CHS / zh-CHT
    'zh-Hant': 'zh-CHT'
}

def protect_placeholders(text):
    placeholders = re.findall(r'%[0-9]*\.?[0-9]*[a-zA-Z@]', text)
    protected_text = text
    for i, p in enumerate(placeholders):
        protected_text = protected_text.replace(p, f" VVAR{i}V ", 1)
    return protected_text, placeholders

def restore_placeholders(text, placeholders):
    restored_text = text
    for i, p in enumerate(placeholders):
        restored_text = re.sub(rf'\s*VVAR{i}V\s*', p, restored_text, count=1, flags=re.IGNORECASE)
    return restored_text.strip()

engines = ['bing', 'google', 'caiyun']

for apple_lang, engine_lang in langs.items():
    print(f"Translating to {apple_lang}...")
    
    count = 0
    save_interval = 20
    
    for key, value in data.get('strings', {}).items():
        locs = value.setdefault('localizations', {})
        if apple_lang not in locs or locs[apple_lang].get('stringUnit', {}).get('state') != 'translated':
            src = key
            if 'de' in locs and locs['de'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['de']['stringUnit']['value']
            elif 'en' in locs and locs['en'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['en']['stringUnit']['value']
            
            pt, ph = protect_placeholders(src)
            
            translated_text = None
            for engine in engines:
                try:
                    translated_text = ts.translate_text(pt, translator=engine, to_language=engine_lang)
                    break
                except Exception as e:
                    time.sleep(2)
                    continue
            
            if translated_text:
                final_text = restore_placeholders(translated_text, ph)
                locs[apple_lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": final_text
                    }
                }
                count += 1
                
                if count % save_interval == 0:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                        
            time.sleep(0.5)

    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Finished {apple_lang}")

print("All translations completed successfully!")
