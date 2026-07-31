import json

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

for k, v in list(data.get('strings', {}).items())[10:12]:
    print(f"Key: {k}")
    print(json.dumps(v, indent=2))
