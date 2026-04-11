
import re
import os

app_strings_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"
base_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation"
languages = ["de", "en", "es", "fr", "pt", "it"]

def parse_app_strings(content):
    match = re.search(r'static let all: \[String: \[String: String\]\] = \[(.*?)\]\s*\}', content, re.DOTALL)
    if not match:
        return None
    dict_content = match.group(1)
    
    entries = {}
    pattern = r'"([^"]+)":\s*\[(.*?)\]'
    for key, inner_dict_str in re.findall(pattern, dict_content, re.DOTALL):
        inner_dict = {}
        inner_pattern = r'"([^"]+)":\s*"(.*?)"'
        for lang, val in re.findall(inner_pattern, inner_dict_str):
            inner_dict[lang] = val
        entries[key] = inner_dict
    return entries

with open(app_strings_path, "r", encoding="utf-8") as f:
    content = f.read()

all_entries = parse_app_strings(content)
if not all_entries:
    print("Failed to parse AppStrings.swift")
    exit(1)

sorted_keys = sorted(all_entries.keys())

for lang in languages:
    lproj_path = os.path.join(base_path, f"{lang}.lproj")
    if not os.path.exists(lproj_path):
        os.makedirs(lproj_path)
    
    strings_file_path = os.path.join(lproj_path, "Localizable.strings")
    
    with open(strings_file_path, "w", encoding="utf-8") as f:
        f.write(f"/* \n  Localizable.strings\n  Garten Simulation\n\n  Generated from AppStrings.swift\n*/\n\n")
        
        for key in sorted_keys:
            val = all_entries[key].get(lang)
            if val is None:
                # Fallback to English, then German
                val = all_entries[key].get("en", all_entries[key].get("de", ""))
            
            # Clean up the value for .strings format (escapes)
            # 1. Handle Swift Unicode escapes \u{XXXX} -> actual char
            val = re.sub(r'\\u\{([0-9A-Fa-f]{4})\}', lambda m: chr(int(m.group(1), 16)), val)
            
            # 2. Escape double quotes
            clean_val = val.replace('"', '\\"')
            f.write(f'"{key}" = "{clean_val}";\n')

    print(f"Synchronized {lang}.lproj/Localizable.strings")

print("All languages synchronized successfully.")
