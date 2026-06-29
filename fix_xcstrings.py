import json

file_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r') as f:
    data = json.load(f)

# powerup.active.plant in ko
data['strings']['powerup.active.plant']['localizations']['ko']['stringUnit']['value'] = "%2$dh에 대해 %1$@에서 활성"

# stufe.naechste.hinweis in ko
data['strings']['stufe.naechste.hinweis']['localizations']['ko']['stringUnit']['value'] = "%2$@에 대한 %1$lld XP 남음"

# stufe.naechste.hinweis in tr
data['strings']['stufe.naechste.hinweis']['localizations']['tr']['stringUnit']['value'] = "%2$@ için %1$lld XP kaldı"

# xp_bis_naechste in ja
data['strings']['xp_bis_naechste']['localizations']['ja']['stringUnit']['value'] = "%2$@ まで %1$d XP"

# xp_bis_naechste in ko
data['strings']['xp_bis_naechste']['localizations']['ko']['stringUnit']['value'] = "%2$@까지 %1$d XP"

# xp_bis_naechste in tr
data['strings']['xp_bis_naechste']['localizations']['tr']['stringUnit']['value'] = "%2$@'a kadar %1$d XP"

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Fixed Localizable.xcstrings")
