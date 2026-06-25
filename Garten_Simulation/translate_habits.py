import re
from deep_translator import GoogleTranslator

langs = ["en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]
file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

pattern = re.compile(r'^\s*"(assessment\.[a-z]+\.profile\.[a-z_]+\.(?:build|break))":\s*\["de":\s*"([^"]+)"')

keys = []
de_texts = []
line_indices = []

for i, line in enumerate(lines):
    match = pattern.search(line)
    if match:
        keys.append(match.group(1))
        de_texts.append(match.group(2))
        line_indices.append(i)

if not keys:
    print("No keys found.")
    exit(0)

print(f"Found {len(keys)} keys to translate.")

# Join all texts with a unique delimiter that Google Translate is unlikely to mess up
# E.g. newline or ||
text_to_translate = " || ".join(de_texts)

translations = { "de": de_texts }

for lang in langs:
    print(f"Translating to {lang}...")
    try:
        translated = GoogleTranslator(source='de', target=lang).translate(text_to_translate)
        # Split back
        parts = [p.strip() for p in translated.split("||")]
        if len(parts) != len(de_texts):
            print(f"Warning: split count mismatch for {lang}! Using fallback.")
            translations[lang] = de_texts
        else:
            translations[lang] = parts
    except Exception as e:
        print(f"Failed {lang}: {e}")
        translations[lang] = de_texts

for idx, k in enumerate(keys):
    line_index = line_indices[idx]
    line = lines[line_index]
    
    parts = []
    order = ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]
    for lang in order:
        val = translations[lang][idx].replace('"', '\\"')
        parts.append(f'"{lang}": "{val}"')
        
    leading_space = len(line) - len(line.lstrip())
    new_line = " " * leading_space + f'"{k}": [{", ".join(parts)}],\n'
    lines[line_index] = new_line

with open(file_path, "w", encoding="utf-8") as f:
    f.writelines(lines)

print("Done!")
