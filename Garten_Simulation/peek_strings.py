import json

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

count = 0
for k, v in data.get('strings', {}).items():
    print(f"Key: {k}")
    if 'localizations' in v:
        for lang in ['de', 'en']:
            if lang in v['localizations']:
                print(f"  {lang}: {v['localizations'][lang]}")
    count += 1
    if count > 5:
        break
