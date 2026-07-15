import json

with open('missing_translations.json', 'r') as f:
    missing = json.load(f)

with open('translation_sources.json', 'r') as f:
    sources = json.load(f)

de_missing = missing.get('de', [])
en_missing = missing.get('en', [])

print("--- DE MISSING ---")
for key in de_missing:
    print(f"KEY: {key} | SOURCE: {sources.get(key, '')}")

print("\n--- EN MISSING ---")
for key in en_missing:
    print(f"KEY: {key} | SOURCE: {sources.get(key, '')}")

