import json
import time
import re
from deep_translator import GoogleTranslator

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = {
    'en': 'en',
    'es': 'es',
    'fr': 'fr',
    'it': 'it',
    'pt': 'pt',
    'ja': 'ja',
    'ko': 'ko',
    'pl': 'pl',
    'nl': 'nl',
    'tr': 'tr',
    'ru': 'ru',
    'hi': 'hi',
    'zh-Hans': 'zh-CN',
    'zh-Hant': 'zh-TW'
}

def protect_placeholders(text):
    # Protect %lld, %@, %d, %f, etc.
    placeholders = re.findall(r'%[0-9]*\.?[0-9]*[a-zA-Z@]', text)
    protected_text = text
    for i, p in enumerate(placeholders):
        protected_text = protected_text.replace(p, f" VVAR{i}V ", 1)
    return protected_text, placeholders

def restore_placeholders(text, placeholders):
    restored_text = text
    for i, p in enumerate(placeholders):
        # The translator might change spaces around it, we just replace the token
        restored_text = re.sub(rf'\s*VVAR{i}V\s*', p, restored_text, count=1, flags=re.IGNORECASE)
    return restored_text.strip()

for apple_lang, google_lang in langs.items():
    print(f"Translating to {apple_lang}...")
    translator = GoogleTranslator(source='auto', target=google_lang)
    
    # Collect what needs translation
    keys_to_translate = []
    texts_to_translate = []
    
    for key, value in data.get('strings', {}).items():
        locs = value.setdefault('localizations', {})
        if apple_lang not in locs or locs[apple_lang].get('stringUnit', {}).get('state') != 'translated':
            # Use English or German as source if available, else key
            src = key
            if 'de' in locs and locs['de'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['de']['stringUnit']['value']
            elif 'en' in locs and locs['en'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['en']['stringUnit']['value']
            
            keys_to_translate.append(key)
            texts_to_translate.append(src)
            
    # Batch translation (limit batch size to avoid errors)
    batch_size = 50
    for i in range(0, len(keys_to_translate), batch_size):
        batch_keys = keys_to_translate[i:i+batch_size]
        batch_texts = texts_to_translate[i:i+batch_size]
        
        # Protect placeholders
        protected_batch = []
        placeholders_batch = []
        for text in batch_texts:
            pt, ph = protect_placeholders(text)
            protected_batch.append(pt)
            placeholders_batch.append(ph)
            
        try:
            translated_batch = translator.translate_batch(protected_batch)
            
            # Restore and save
            for j, translated_text in enumerate(translated_batch):
                if translated_text:
                    final_text = restore_placeholders(translated_text, placeholders_batch[j])
                    key = batch_keys[j]
                    data['strings'][key]['localizations'][apple_lang] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": final_text
                        }
                    }
        except Exception as e:
            print(f"Error in batch {i}: {e}")
            time.sleep(2) # Backoff on error
            continue
            
        time.sleep(0.5) # Slight delay to respect rate limits

    # Save progress after each language
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Finished {apple_lang}")

print("All translations completed successfully!")
