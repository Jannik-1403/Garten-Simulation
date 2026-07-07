import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, value in data["strings"].items():
    locs = value.setdefault("localizations", {})
    
    # We want to replace standard percent sign with fullwidth percent sign (U+FF05)
    # ONLY if it's next to a digit or space, e.g., "100%" or "100 %"
    
    for lang, loc in locs.items():
        if "stringUnit" in loc and "value" in loc["stringUnit"]:
            old_val = loc["stringUnit"]["value"]
            # Replace % with ％ (Fullwidth Percent Sign) if it follows a digit (with optional space)
            # Actually, to be safe and suppress all warnings, replace all standalone % signs.
            # But let's avoid replacing format specifiers like %@ or %lld.
            
            # Regex: match % that is NOT followed by l, d, @, f, s, or $
            new_val = re.sub(r'%(?![ld@fs$0-9])', '％', old_val)
            # Also catch % at the end of the string
            new_val = re.sub(r'%$', '％', new_val)
            # Catch "50 %" which has a space before it
            new_val = new_val.replace(" %", " ％")
            # Catch "50%"
            new_val = re.sub(r'(\d)%', r'\1％', new_val)
            
            if old_val != new_val:
                loc["stringUnit"]["value"] = new_val

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Percentage signs replaced with fullwidth variants to suppress Xcode warnings.")
