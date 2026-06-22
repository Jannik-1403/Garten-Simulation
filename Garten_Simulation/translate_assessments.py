import re
import time
from deep_translator import GoogleTranslator
import json

# Languages
langs = ["en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

data = {}

# 1. Parse de.lproj/Localizable.strings
with open('de.lproj/Localizable.strings', 'r', encoding='utf-8') as f:
    for line in f:
        match = re.search(r'"(assessment\.[^"]+)"\s*=\s*"(.*?)";', line)
        if match:
            key, text = match.groups()
            data[key] = text

# 2. Parse AppStrings.swift
with open('Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()
    matches = re.finditer(r'"(assessment\.[^"]+)":\s*\["de":\s*"(.*?)"', content)
    for m in matches:
        key, text = m.groups()
        data[key] = text

print(f"Found {len(data)} assessment keys.")

# Group by text to avoid redundant translations
unique_texts = list(set(data.values()))
print(f"Found {len(unique_texts)} unique texts to translate.")

translations = {text: {"de": text} for text in unique_texts}

# Translate in chunks to avoid limits
def chunk_text(texts, max_len=4000):
    chunk = []
    length = 0
    for t in texts:
        if length + len(t) > max_len:
            yield chunk
            chunk = []
            length = 0
        chunk.append(t)
        length += len(t) + 5
    if chunk:
        yield chunk

for lang in langs:
    print(f"Translating to {lang}...")
    translator = GoogleTranslator(source='de', target=lang)
    for chunk in chunk_text(unique_texts):
        # Join with a special separator
        separator = " ||| "
        combined = separator.join(chunk)
        try:
            res = translator.translate(combined)
            res_parts = res.split(separator)
            if len(res_parts) == len(chunk):
                for i, t in enumerate(chunk):
                    translations[t][lang] = res_parts[i].strip()
            else:
                # Fallback to individual
                for t in chunk:
                    translations[t][lang] = translator.translate(t)
        except Exception as e:
            print(f"Error {lang}: {e}")
            for t in chunk:
                try:
                    translations[t][lang] = translator.translate(t)
                except:
                    translations[t][lang] = t
        time.sleep(1)

# Generate output
with open('TranslatedAssessment.json', 'w', encoding='utf-8') as f:
    json.dump({k: translations[v] for k, v in data.items()}, f, ensure_ascii=False, indent=2)

print("Translation complete!")
