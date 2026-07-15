import json

with open('missing_translations.json', 'r') as f:
    missing = json.load(f)

for lang, keys in missing.items():
    print(f"\nLanguage: {lang} (Total missing: {len(keys)})")
    for key in keys[:10]:
        print(f"  - {key}")

