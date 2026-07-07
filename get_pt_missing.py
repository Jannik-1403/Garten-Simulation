import json

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

for key in ['target.reached.message', 'target.reached.title']:
    print(f"Key: {key}")
    locs = data['strings'].get(key, {}).get('localizations', {})
    print("EN:", locs.get('en', {}).get('stringUnit', {}).get('value', 'N/A'))
    print("DE:", locs.get('de', {}).get('stringUnit', {}).get('value', 'N/A'))
