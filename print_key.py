import json

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

keys = [
    "focus.generic.title", 
    "focus.generic.subtitle", 
    "focus.generic.placeholder", 
    "profile.focus.title", 
    "profile.focus.start"
]

for k in keys:
    if k in data['strings']:
        print(f"--- {k} ---")
        locs = data['strings'][k].get('localizations', {})
        for lang, ldata in locs.items():
            val = ldata.get('stringUnit', {}).get('value')
            print(f"  {lang}: {val}")
    else:
        print(f"--- {k} NOT FOUND ---")
