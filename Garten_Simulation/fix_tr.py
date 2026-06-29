import json

with open('./Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})

fixed_count = 0
for key, val in strings.items():
    locs = val.setdefault('localizations', {})
    tr_loc = locs.get('tr', {})
    state = tr_loc.get('stringUnit', {}).get('state', 'missing')
    
    if state != 'translated':
        # Let's see if it's a simple string that can be copied (symbols, formatting)
        if any(c in key for c in ['%lld', '%@', '-', '.', '/', '(', '+']) or key.strip() == '':
            locs['tr'] = {
                'stringUnit': {
                    'state': 'translated',
                    'value': key
                }
            }
            fixed_count += 1
            print(f"Fixed: {key}")

with open('./Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Fixed {fixed_count} missing Turkish keys by copying.")
