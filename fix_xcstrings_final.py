import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# 1. Fix the %l issue (replace with %lld)
for key, val in data.get("strings", {}).items():
    locs = val.get("localizations", {})
    for lang, loc_data in locs.items():
        if "stringUnit" in loc_data:
            s_val = loc_data["stringUnit"].get("value", "")
            # replace %l with %lld if it's followed by a word character or space (not l, d, @)
            new_val = re.sub(r"%l(?![ld@])", "%lld", s_val)
            if new_val != s_val:
                print(f"[{lang}] Fixed %l in {key}: {s_val} -> {new_val}")
                loc_data["stringUnit"]["value"] = new_val

# 2. Fix the mismatch by defining substitutions at the root level if missing
mismatch_keys = {
    "widget_streak_current": {"arg1": {"argNum": 1, "formatSpecifier": "d"}},
    "widget_water_times": {"arg1": {"argNum": 1, "formatSpecifier": "d"}},
    "wonder_water.rescue.body_format": {"arg1": {"argNum": 1, "formatSpecifier": "@"}},
    "wonder_water.rescue.action_format": {"arg1": {"argNum": 1, "formatSpecifier": "@"}},
    "xp_bis_naechste": {
        "arg1": {"argNum": 1, "formatSpecifier": "@"},
        "arg2": {"argNum": 2, "formatSpecifier": "d"}
    }
}
for key, subs in mismatch_keys.items():
    if key in data["strings"]:
        data["strings"][key]["substitutions"] = subs
        print(f"Added substitutions for {key}")

# 3. Save
with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
