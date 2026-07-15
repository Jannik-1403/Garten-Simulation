import json

with open('./Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

source_lang = data.get('sourceLanguage', 'en')
strings = data.get('strings', {})

missing = {}

for key, value in strings.items():
    localizations = value.get('localizations', {})
    
    # We should gather all target languages first
    # Actually, the user wants ALL project languages to be 100%.
    # Let's find out all languages mentioned in the file across all keys.
    pass

all_langs = set()
for key, value in strings.items():
    localizations = value.get('localizations', {})
    for lang in localizations.keys():
        all_langs.add(lang)

print("All languages found:", all_langs)

for lang in all_langs:
    missing_count = 0
    needs_review_count = 0
    for key, value in strings.items():
        localizations = value.get('localizations', {})
        if lang not in localizations:
            missing_count += 1
            if lang not in missing:
                missing[lang] = []
            missing[lang].append(key)
        else:
            state = localizations[lang].get('stringUnit', {}).get('state', '')
            if state != 'translated':
                needs_review_count += 1
                if lang not in missing:
                    missing[lang] = []
                missing[lang].append(key)
    print(f"Language {lang}: {missing_count} missing entirely, {needs_review_count} not 'translated'")

with open('missing_translations.json', 'w') as f:
    json.dump(missing, f, indent=2)

