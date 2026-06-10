import re
import time
from deep_translator import GoogleTranslator

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

languages = ["de", "en", "es", "fr", "pt", "it", "ja", "ko", "pl", "nl", "tr"]
new_keys = {
    "settings.language.ja": "Japanese",
    "settings.language.ko": "Korean",
    "settings.language.pl": "Polish",
    "settings.language.nl": "Dutch",
    "settings.language.tr": "Turkish"
}

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

lines_to_add = []
for key, en_text in new_keys.items():
    translations = {}
    for lang in languages:
        if lang == "en":
            translations[lang] = en_text
            continue
            
        try:
            res = GoogleTranslator(source='en', target=lang).translate(en_text)
            translations[lang] = res if res else en_text
        except Exception as e:
            print(f"Failed {lang}: {e}")
            translations[lang] = en_text
        time.sleep(0.05)
        
    dict_str = ", ".join([f'"{l}": "{t}"' for l, t in translations.items()])
    lines_to_add.append(f'        "{key}": [{dict_str}],\n')

pattern = r'("settings\.language\.pt":\s*\[.*?\]),\n'
match = re.search(pattern, content)
if match:
    insert_pos = match.end()
    new_content = content[:insert_pos] + "".join(lines_to_add) + content[insert_pos:]
    with open(app_strings_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("Keys added successfully.")
else:
    print("Could not find insertion point.")
