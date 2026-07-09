import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val in data["strings"].items():
    locs = val.get("localizations", {})
    for lang, loc in locs.items():
        if "value" in loc.get("stringUnit", {}):
            v = loc["stringUnit"]["value"]
            # Fix percentages
            if "20% Rabatt" in v:
                v = v.replace("20% Rabatt", "%@ Rabatt")
                loc["stringUnit"]["value"] = v
            if "20%" in v:
                v = v.replace("20%", "%@")
                loc["stringUnit"]["value"] = v
            if ">50%" in v:
                v = v.replace(">50%", "%@")
                loc["stringUnit"]["value"] = v
            if "%%" in v:
                v = v.replace("%%", "%")
                loc["stringUnit"]["value"] = v
            
            # Fix positional specifier mismatch if there's exactly one %d and one %@
            if "%d" in v and "%@" in v:
                v = v.replace("%d", "%2$d", 1)
                v = v.replace("%@", "%1$@", 1)
                loc["stringUnit"]["value"] = v
            # If there's %d%d or similar, add spaces or format correctly (only for weed progress in hindi)
            if "सुरक्षा:%d%dफील्ड से" in v:
                v = v.replace("%d%d", "%1$d %2$d ")
                loc["stringUnit"]["value"] = v

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Fixed formatting warnings.")
