import json

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

for k, v in list(data.get('strings', {}).items())[:2]:
    print(f"Key: {k}")
    print(v)
