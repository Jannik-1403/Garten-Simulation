import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

def get_formats(text):
    return re.findall(r"%([0-9]*)\$?([a-zA-Z@])", text)

fixed_count = 0

for key, value in data["strings"].items():
    locs = value.setdefault("localizations", {})
    
    if "de" in locs:
        base_val = locs["de"].get("stringUnit", {}).get("value", key)
    else:
        base_val = key
        
    base_formats = get_formats(base_val)
    if not base_formats: continue
    
    # create a map of index (1-based) to format type from the base
    base_types = {}
    current_idx = 1
    for pos_str, type_char in base_formats:
        idx = int(pos_str) if pos_str else current_idx
        base_types[idx] = type_char
        current_idx += 1
        
    for lang, loc in locs.items():
        if lang == "de": continue
        if "stringUnit" not in loc or "value" not in loc["stringUnit"]: continue
        
        lang_val = loc["stringUnit"]["value"]
        lang_formats = get_formats(lang_val)
        
        if not lang_formats: continue
        
        has_error = False
        lang_idx = 1
        for pos_str, type_char in lang_formats:
            idx = int(pos_str) if pos_str else lang_idx
            # Check if this index exists in base and type matches
            if idx not in base_types or base_types[idx] != type_char:
                has_error = True
                print(f"[{lang}] Type mismatch in key '{key}': Base pos {idx} is {base_types.get(idx)}, but lang used {type_char} (value: {lang_val})")
                break
            lang_idx += 1
            
        if has_error:
            loc["stringUnit"]["value"] = base_val
            fixed_count += 1

if fixed_count > 0:
    with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Fixed {fixed_count} type mismatches by reverting to DE.")
else:
    print("No type mismatches found.")
