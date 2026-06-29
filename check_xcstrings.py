import json
import re

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

def extract_specifiers(s):
    return re.findall(r'%([0-9]+\$)?([a-zA-Z@]+)', s)

errors = []

for key, value in data['strings'].items():
    # Use 'de' as baseline
    baseline = []
    if 'localizations' in value and 'de' in value['localizations']:
        loc = value['localizations']['de']
        if 'stringUnit' in loc and 'value' in loc['stringUnit']:
            baseline = extract_specifiers(loc['stringUnit']['value'])
    else:
        baseline = extract_specifiers(key)
        
    baseline_types = [s[1] for s in baseline]
    if not baseline_types: continue
    
    if 'localizations' in value:
        for lang, loc in value['localizations'].items():
            if 'stringUnit' in loc and 'value' in loc['stringUnit']:
                val = loc['stringUnit']['value']
                val_specs_full = extract_specifiers(val)
                val_types = [s[1] for s in val_specs_full]
                
                if sorted(baseline_types) == sorted(val_types) and baseline_types != val_types:
                    has_positionals = any(s[0] for s in val_specs_full)
                    if not has_positionals:
                        errors.append((key, lang, val, f"Baseline: {baseline_types}, Val: {val_types}"))
                        
for err in errors:
    print(f"Key: {err[0]}\nLang: {err[1]}\nVal: {err[2]}\nError: {err[3]}\n")
