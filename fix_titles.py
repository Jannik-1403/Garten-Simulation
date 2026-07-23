import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

strings = data.get("strings", {})

def update_val(key, old_prefix, new_val):
    if key in strings and "localizations" in strings[key]:
        for lang, loc in strings[key]["localizations"].items():
            val = loc.get("stringUnit", {}).get("value", "")
            if val.startswith("Ebene 1: ") or val.startswith("Level 1: "):
                loc["stringUnit"]["value"] = val.replace("Ebene 1: ", "").replace("Level 1: ", "")
            elif val.startswith("Ebene 2: ") or val.startswith("Level 2: "):
                loc["stringUnit"]["value"] = val.replace("Ebene 2: ", "").replace("Level 2: ", "")
            elif val.startswith("Ebene 3: ") or val.startswith("Level 3: "):
                loc["stringUnit"]["value"] = val.replace("Ebene 3: ", "").replace("Level 3: ", "")
            elif val.startswith("Ebene 4: ") or val.startswith("Level 4: "):
                loc["stringUnit"]["value"] = val.replace("Ebene 4: ", "").replace("Level 4: ", "")
            
            # also hard replace just in case it doesn't match
            if lang == "de":
                loc["stringUnit"]["value"] = new_val

update_val("screenTime.layer1.title", "Ebene 1: ", "Tägliches Limit")
update_val("screenTime.layer4.title", "Ebene 4: ", "Immer blockiert")

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

