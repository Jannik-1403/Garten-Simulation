import json

with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

print("sourceLanguage:", data.get('sourceLanguage'))
