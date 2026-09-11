import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

keys_to_remove = [k for k in data.get('strings', {}).keys() if k.startswith("prog_breathwork_") or k.startswith("plant.mystic_seed.") or k == "habit.atemarbeit"]

for k in keys_to_remove:
    del data['strings'][k]

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Removed {len(keys_to_remove)} keys.")
