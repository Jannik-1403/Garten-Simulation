import re
import time
from deep_translator import GoogleTranslator

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

pattern = re.compile(r'("[^"]+"):\s*\[(.*?)\]', re.DOTALL)

translator = GoogleTranslator(source='en', target='tr')

def translate_text(text):
    if not text: return ""
    try:
        res = translator.translate(text)
        return res if res is not None else text
    except Exception as e:
        print(f"Error translating {text}: {e}")
        time.sleep(1)
        try:
            res = translator.translate(text)
            return res if res is not None else text
        except:
            return text

matches = list(pattern.finditer(content))
total = len(matches)
print(f"Found {total} strings to translate.")

new_content = content

# Process backwards
for i, match in enumerate(reversed(matches)):
    full_match = match.group(0)
    key = match.group(1)
    inner = match.group(2)
    
    if '"tr":' in inner:
        continue
        
    en_pattern = r'"en":\s*"([^"\\]*(?:\\.[^"\\]*)*)"'
    en_match = re.search(en_pattern, inner)
    
    if en_match:
        text_to_translate = en_match.group(1).replace('\\"', '"').replace('\\n', '\n')
    else:
        de_pattern = r'"de":\s*"([^"\\]*(?:\\.[^"\\]*)*)"'
        de_match = re.search(de_pattern, inner)
        if de_match:
            text_to_translate = de_match.group(1).replace('\\"', '"').replace('\\n', '\n')
        else:
            text_to_translate = key.strip('"')

    translated = translate_text(text_to_translate)
    time.sleep(0.02)
    
    translated = translated.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
    
    new_inner = inner + f', "tr": "{translated}"'
    new_match = f'{key}: [{new_inner}]'
    
    start, end = match.span()
    new_content = new_content[:start] + new_match + new_content[end:]
    
    if (total - i) % 50 == 0:
        print(f"Translated {total - i} / {total}")
        with open(app_strings_path, "w", encoding="utf-8") as f:
            f.write(new_content)

with open(app_strings_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("Translation to Turkish completed.")
