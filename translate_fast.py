import json
import time
import re
import translators as ts
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = {
    'ru': 'ru',
    'hi': 'hi',
    'zh-Hans': 'zh-CHS',
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

engines = ['google', 'bing', 'caiyun']

tasks = []
# Pre-gather all tasks to translate
for apple_lang, engine_lang in langs.items():
    for key, value in data.get('strings', {}).items():
        locs = value.setdefault('localizations', {})
        if apple_lang not in locs or locs[apple_lang].get('stringUnit', {}).get('state') != 'translated':
            src = key
            if 'de' in locs and locs['de'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['de']['stringUnit']['value']
            elif 'en' in locs and locs['en'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['en']['stringUnit']['value']
                
            tasks.append({
                'apple_lang': apple_lang,
                'engine_lang': engine_lang,
                'key': key,
                'src': src
            })

print(f"Total keys to translate: {len(tasks)}")

lock = threading.Lock()
completed_count = 0
save_interval = 100

def translate_task(task):
    global completed_count
    pt, ph = protect_placeholders(task['src'])
    
    translated_text = None
    for engine in engines:
        try:
            translated_text = ts.translate_text(pt, translator=engine, to_language=task['engine_lang'])
            break
        except Exception as e:
            time.sleep(1)
            continue
            
    if translated_text:
        final_text = restore_placeholders(translated_text, ph)
        return task, final_text
    return task, None

with ThreadPoolExecutor(max_workers=10) as executor:
    futures = [executor.submit(translate_task, task) for task in tasks]
    for future in as_completed(futures):
        task, final_text = future.result()
        if final_text:
            with lock:
                locs = data['strings'][task['key']].setdefault('localizations', {})
                locs[task['apple_lang']] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": final_text
                    }
                }
                completed_count += 1
                
                if completed_count % save_interval == 0:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(data, f, ensure_ascii=False, indent=2)
                    print(f"Progress: {completed_count}/{len(tasks)}")

# Final save
with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("All translations completed successfully!")
