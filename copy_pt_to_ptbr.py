import json

with open('./Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})

for key, value in strings.items():
    localizations = value.get('localizations', {})
    
    # If pt-BR doesn't exist or is missing, but pt exists, copy pt to pt-BR
    pt = localizations.get('pt')
    pt_br = localizations.get('pt-BR')
    
    if pt:
        # We also need to copy it if pt-BR exists but is incomplete/needs review, but let's just overwrite pt-BR with pt if pt is 'translated' or just copy it.
        localizations['pt-BR'] = pt

with open('./Garten_Simulation/Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

