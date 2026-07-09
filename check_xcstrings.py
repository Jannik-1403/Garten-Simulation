import json

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val in data["strings"].items():
    if "%" in key:
        print(f"Key with %: {key}")
    
    locs = val.get("localizations", {})
    for lang, loc in locs.items():
        if "value" in loc.get("stringUnit", {}):
            v = loc["stringUnit"]["value"]
            if "%%" in v or ("%" in v and ("lld%" in v or "d%" in v or "@%" in v or "f%" in v)):
                print(f"Warning format in {lang} for {key}: {v}")
            if "%d" in v and "%@" in v:
                # Count order
                d_idx = v.find("%d")
                a_idx = v.find("%@")
                print(f"Order check in {lang} for {key}: %d at {d_idx}, %@ at {a_idx}")

