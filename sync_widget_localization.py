import os
import re
import time
from deep_translator import GoogleTranslator

base_path = "/Users/jannikschill/Documents/Garten-Simulation/GartenWidget"
languages = ["de", "en", "es", "fr", "pt", "it", "ja", "ko", "pl", "nl", "tr"]

en_path = os.path.join(base_path, "en.lproj", "Localizable.strings")
with open(en_path, "r", encoding="utf-8") as f:
    en_content = f.read()

pattern = re.compile(r'"([^"]+)"\s*=\s*"([^"\\]*(?:\\.[^"\\]*)*)";')
en_dict = dict(pattern.findall(en_content))

ordered_keys = []
for line in en_content.splitlines():
    match = re.search(r'"([^"]+)"', line)
    if match and match.group(1) in en_dict and match.group(1) not in ordered_keys:
        ordered_keys.append(match.group(1))

for lang in languages:
    lproj_path = os.path.join(base_path, f"{lang}.lproj")
    os.makedirs(lproj_path, exist_ok=True)
    strings_path = os.path.join(lproj_path, "Localizable.strings")
    
    existing_dict = {}
    if os.path.exists(strings_path):
        with open(strings_path, "r", encoding="utf-8") as f:
            existing_dict = dict(pattern.findall(f.read()))
            
    new_lines = []
    if lang != "en":
        translator = GoogleTranslator(source='en', target=lang)
        
    for key in ordered_keys:
        en_text = en_dict[key].replace('\\"', '"').replace('\\n', '\n')
        
        if key in existing_dict and lang != "en":
            new_lines.append(f'"{key}" = "{existing_dict[key]}";')
        elif lang == "en":
            escaped_en = en_text.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
            new_lines.append(f'"{key}" = "{escaped_en}";')
        else:
            try:
                res = translator.translate(en_text)
                translated = res if res else en_text
            except Exception as e:
                print(f"Error {lang}: {e}")
                time.sleep(1)
                try:
                    res = translator.translate(en_text)
                    translated = res if res else en_text
                except:
                    translated = en_text
            time.sleep(0.05)
            
            escaped = translated.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
            new_lines.append(f'"{key}" = "{escaped}";')
            
    with open(strings_path, "w", encoding="utf-8") as f:
        f.write("\n".join(new_lines) + "\n")
        
    print(f"Synchronized widget strings for {lang}")
