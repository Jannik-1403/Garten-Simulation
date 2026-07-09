import json

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

keys_to_delete = []
for key in data.get('strings', {}).keys():
    if key.startswith('screenTime.layer1') or key.startswith('screenTime.layer2') or key.startswith('focus.giveup') or key.startswith('FOCUS.GIVEUP'):
        keys_to_delete.append(key)

for key in keys_to_delete:
    del data['strings'][key]

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    
print(f"Deleted {len(keys_to_delete)} keys.")
