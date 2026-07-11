import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Update weed_banner_subtitle
for lang, loc in data['strings'].get('weed_banner_subtitle', {}).get('localizations', {}).items():
    val = loc['stringUnit']['value']
    if lang == 'de':
        loc['stringUnit']['value'] = "Nur %@ Belohnung"
    elif lang == 'en':
        loc['stringUnit']['value'] = "Only %@ reward"

# Update weed_banner_title_multi
for lang, loc in data['strings'].get('weed_banner_title_multi', {}).get('localizations', {}).items():
    val = loc['stringUnit']['value']
    if lang == 'de':
        loc['stringUnit']['value'] = "%d Unkräuter"
    elif lang == 'en':
        loc['stringUnit']['value'] = "%d Weeds"

# Update weed_banner_title
for lang, loc in data['strings'].get('weed_banner_title', {}).get('localizations', {}).items():
    val = loc['stringUnit']['value']
    if lang == 'de':
        loc['stringUnit']['value'] = "Unkraut!"
    elif lang == 'en':
        loc['stringUnit']['value'] = "Weeds!"

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
