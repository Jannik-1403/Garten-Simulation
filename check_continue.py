import json
with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

k = "button.continue"
if k in data['strings']:
    print(f"--- {k} ---")
    locs = data['strings'][k].get('localizations', {})
    for lang, ldata in locs.items():
        val = ldata.get('stringUnit', {}).get('value')
        print(f"  {lang}: {val}")
