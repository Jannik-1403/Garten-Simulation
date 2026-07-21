import json
import sys

with open('Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

source_lang = data.get('sourceLanguage', 'en')
missing_translations = {}

for key, value in data.get('strings', {}).items():
    localizations = value.get('localizations', {})
    
    # We don't know all target languages upfront, let's collect them
    for lang, lang_data in localizations.items():
        if lang_data.get('stringUnit', {}).get('state') != 'translated':
            if lang not in missing_translations:
                missing_translations[lang] = []
            missing_translations[lang].append(key)

print("Source language:", source_lang)
for lang, keys in missing_translations.items():
    print(f"Language {lang}: {len(keys)} missing translations")
    for k in keys[:5]:
        print(f"  - {k}")
    if len(keys) > 5:
        print("  ...")

# To find all target languages in the file:
all_langs = set()
for key, value in data.get('strings', {}).items():
    localizations = value.get('localizations', {})
    for lang in localizations.keys():
        all_langs.add(lang)

print("\nAll target languages found:", all_langs)

# Check which strings don't even have a localization entry for some languages
for lang in all_langs:
    if lang == source_lang:
        continue
    missing_entries = []
    for key, value in data.get('strings', {}).items():
        if 'localizations' not in value or lang not in value['localizations']:
            missing_entries.append(key)
    
    if missing_entries:
        print(f"Language {lang} has {len(missing_entries)} missing localizations entries")
        for k in missing_entries[:5]:
            print(f"  - {k}")
        if len(missing_entries) > 5:
            print("  ...")
