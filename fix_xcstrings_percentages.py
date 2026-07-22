import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# Keys to fix and what to replace
replacements = {
    "paywall.feature.pro_gardener.bullet2": ("25%", "%@"),
    "prog_nutrition_d4_t2": ("100%", "%@"),
    "prog_strength_d3_desc": ("100%", "%@"),
    "prog_water_d2_desc": ("60%", "%@"),
    "prog_water_d2_t1": ("60%", "%@"),
    "shop.insufficient_coins.get_pro": ("%50", "%@"), # Turkish format
    "weather.effect.gems_minus": ("-30%", "%@"),
    "weather.effect.gems_plus": ("+50%", "%@"),
    "weather.effect.xp_plus": ("+50%", "%@")
}

for key, (old_str, new_str) in replacements.items():
    if key in data["strings"]:
        locs = data["strings"][key].get("localizations", {})
        for lang, loc in locs.items():
            if "stringUnit" in loc and "value" in loc["stringUnit"]:
                val = loc["stringUnit"]["value"]
                # Sometimes the percentage is formatted differently, e.g., "100 %" or "% 50" (Turkish)
                # We'll just regex replace any number + % or % + number for that specific key.
                import re
                # Replaces things like "25%", "25 %", "%25", "% 25"
                new_val = re.sub(r'(?:\+|-)?\s*(?:\d+\s*%|%\s*\d+)', '%@', val)
                if new_val != val:
                    print(f"Fixed {key} in {lang}: {val} -> {new_val}")
                    loc["stringUnit"]["value"] = new_val

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
