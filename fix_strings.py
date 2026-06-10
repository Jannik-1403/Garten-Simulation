import os
import re

swift_file = "Garten_Simulation/Localization/AppStrings.swift"

with open(swift_file, 'r', encoding='utf-8') as f:
    swift_content = f.read()

# Parse AppStrings into a dictionary of dictionaries
# e.g., db["trash.energy_drink_kiste.name"]["en"] = "Energy-Drink-Kiste"
pattern = r'"([^"]+)":\s*\[(.*?)\]'
matches = re.finditer(pattern, swift_content)

db = {}
for match in matches:
    key = match.group(1)
    dict_str = match.group(2)
    
    # parse the inner dictionary
    inner_pattern = r'"([a-z]{2})":\s*"([^"]+)"'
    inner_matches = re.finditer(inner_pattern, dict_str)
    
    db[key] = {}
    for im in inner_matches:
        lang = im.group(1)
        val = im.group(2)
        db[key][lang] = val

# Now rewrite Localizable.strings for all languages based on AppStrings
for lang in ["en", "de", "es", "fr", "it", "pt"]:
    lproj_path = f"Garten_Simulation/Localization/{lang}.lproj/Localizable.strings"
    if not os.path.exists(lproj_path):
        lproj_path = f"Garten_Simulation/{lang}.lproj/Localizable.strings"
        if not os.path.exists(lproj_path):
            continue
            
    print(f"Fixing {lproj_path}...")
    
    with open(lproj_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    new_lines = []
    for line in lines:
        if line.strip().startswith('"trash.'):
            # Try to replace the value
            key_match = re.search(r'^"([^"]+)"', line)
            if key_match:
                key = key_match.group(1)
                if key in db and lang in db[key]:
                    val = db[key][lang]
                    # escaping
                    val = val.replace('"', '\\"')
                    new_lines.append(f'"{key}" = "{val}";\n')
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
        else:
            new_lines.append(line)
            
    with open(lproj_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
