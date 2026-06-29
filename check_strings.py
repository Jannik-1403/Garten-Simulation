import json

with open('./Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})
total = len(strings)
tr_missing = []
raw_keys = []

for key, val in strings.items():
    locs = val.get('localizations', {})
    tr_loc = locs.get('tr', {})
    state = tr_loc.get('stringUnit', {}).get('state', 'missing')
    
    if state != 'translated':
        tr_missing.append((key, state))
        
    if ' ' in key and len(key) > 20: # simple heuristic for raw keys
        raw_keys.append(key)

print(f"Total keys: {total}")
print(f"Missing/Untranslated in TR: {len(tr_missing)}")
for k, s in tr_missing[:20]:
    print(f" - {k}: {s}")

print(f"\nPotential raw keys (sentences instead of identifiers): {len(raw_keys)}")
for k in raw_keys[:20]:
    print(f" - {k}")

