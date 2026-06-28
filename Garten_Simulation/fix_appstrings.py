import re
from deep_translator import GoogleTranslator
import time

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

required_langs = {"de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"}

pattern = re.compile(r'("([^"]+)":\s*\[(.*?)\])', re.DOTALL)
matches = pattern.findall(content)

translators = {lang: GoogleTranslator(source='en', target=lang) for lang in required_langs if lang != 'en'}
translators['en'] = GoogleTranslator(source='de', target='en')

new_content = content
print(f"Found {len(matches)} keys to check.")
fixed = 0

for full_match, key, dict_str in matches:
    lang_matches = re.findall(r'"([a-z]{2})":\s*"([^"]*)"', dict_str)
    existing_dict = dict(lang_matches)
    langs_found = set(existing_dict.keys())
    
    missing = required_langs - langs_found
    if missing:
        print(f"Translating {len(missing)} missing for {key}...")
        
        # Get source text (prefer english, then german, then any)
        if 'en' in existing_dict and existing_dict['en'].strip():
            src_lang = 'en'
            src_text = existing_dict['en']
        elif 'de' in existing_dict and existing_dict['de'].strip():
            src_lang = 'de'
            src_text = existing_dict['de']
        else:
            if len(existing_dict) > 0:
                src_lang = list(existing_dict.keys())[0]
                src_text = existing_dict[src_lang]
            else:
                src_lang = 'en'
                src_text = key # fallback
            
        new_dict_str = dict_str
        for lang in missing:
            try:
                if src_lang == 'en':
                    res = translators[lang].translate(src_text)
                else:
                    res = GoogleTranslator(source=src_lang, target=lang).translate(src_text)
                res = res.replace('"', '\\"')
                res = res.replace('\n', ' ')
                new_dict_str += f', "{lang}": "{res}"'
            except Exception as e:
                print(f"Failed to translate {key} to {lang}: {e}")
                new_dict_str += f', "{lang}": "{src_text}"'
        
        replacement = f'"{key}": [{new_dict_str}]'
        new_content = new_content.replace(full_match, replacement)
        fixed += 1

if fixed > 0:
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print(f"Fixed {fixed} incomplete keys successfully!")
else:
    print("Everything was already complete.")
