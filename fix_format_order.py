import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

def get_formats(text):
    return re.findall(r"%[0-9]*\$?[a-zA-Z@]", text)

fixed_count = 0

for key, value in data["strings"].items():
    locs = value.setdefault("localizations", {})
    
    if "de" in locs:
        base_val = locs["de"].get("stringUnit", {}).get("value", key)
    else:
        base_val = key
        
    base_formats = get_formats(base_val)
    if len(base_formats) < 2:
        continue # Only a problem if there are multiple formats
        
    for lang, loc in locs.items():
        if lang == "de": continue
        if "stringUnit" not in loc or "value" not in loc["stringUnit"]: continue
        
        lang_val = loc["stringUnit"]["value"]
        lang_formats = get_formats(lang_val)
        
        if len(lang_formats) != len(base_formats):
            continue # Already caught by previous script if completely missing
            
        # If the order is different, they MUST use positional $ markers.
        if lang_formats != base_formats:
            # Check if all lang formats use positional markers
            all_positional = all("$" in f for f in lang_formats)
            if not all_positional:
                print(f"[{lang}] Out of order format specifiers without positional markers in key '{key}':")
                print(f"   Base: {base_formats}")
                print(f"   Lang: {lang_formats}")
                loc["stringUnit"]["value"] = base_val
                fixed_count += 1

if fixed_count > 0:
    with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Fixed {fixed_count} out-of-order format specifiers by reverting to DE.")
else:
    print("No out-of-order format specifiers found.")
