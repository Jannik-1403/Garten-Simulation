import json

with open('missing_translations.json', 'r') as f:
    missing = json.load(f)

# Need to reload missing since we updated pt-BR
with open('./Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})

all_missing_keys = set()
for lang, keys in missing.items():
    all_missing_keys.update(keys)

print(f"Total unique keys needing translation: {len(all_missing_keys)}")

sources = {}
for key in all_missing_keys:
    # Try to get en, then de, then fallback to key
    locs = strings.get(key, {}).get('localizations', {})
    en_val = locs.get('en', {}).get('stringUnit', {}).get('value')
    de_val = locs.get('de', {}).get('stringUnit', {}).get('value')
    
    if de_val:
        sources[key] = f"DE: {de_val}"
    elif en_val:
        sources[key] = f"EN: {en_val}"
    else:
        sources[key] = f"KEY: {key}"

with open('translation_sources.json', 'w') as f:
    json.dump(sources, f, indent=2, ensure_ascii=False)

