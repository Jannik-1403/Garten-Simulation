import json, re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

# Find keys with %% and extract the number (if it exists).
# E.g., 'Top 10%%' -> number is 10.
# If multiple, extract all numbers.

keys_with_percents = {}

for key, value in data["strings"].items():
    locs = value.get("localizations", {})
    # Look at German first to determine the numbers
    de_val = locs.get("de", {}).get("stringUnit", {}).get("value", "")
    if "%%" in de_val:
        # Find all numbers directly before %%
        # regex to match any optional digits before %%
        matches = re.findall(r'(\d+)%%', de_val)
        if not matches:
            # Maybe it's just '%%' without a number? 
            # E.g., '100 %%' -> find '(\d+)\s*%%'
            matches = re.findall(r'(\d+)\s*%%', de_val)
            if not matches:
                # Could be a variable like %lld%% which we removed, or just plain %%
                # But we know there are none of those.
                matches = ["0"] # Fallback if no number found, though shouldn't happen.
        
        # In case the text has '%@' or '%d', we shouldn't break existing formats.
        # But for these specific keys, they only contain static percentages.
        keys_with_percents[key] = matches

# Now modify the strings in ALL languages for these keys
for key in keys_with_percents:
    locs = data["strings"][key].get("localizations", {})
    for lang, loc in locs.items():
        if "stringUnit" in loc and "value" in loc["stringUnit"]:
            val = loc["stringUnit"]["value"]
            # Replace [number]%% or [number] %% with %@
            # Ensure we replace exactly the occurrences
            # Re.sub with count to replace each in order?
            # Actually, standardizing by replacing \d+\s*%% with %@
            new_val = re.sub(r'\d+\s*%%', '%@', val)
            
            # Also replace any remaining %% with %@
            new_val = new_val.replace("%%", "%@")
            
            loc["stringUnit"]["value"] = new_val

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

# Generate PercentHelper.swift
swift_code = """import SwiftUI

enum PercentHelper {
    static func localizedWithPercents(_ key: String) -> String {
        switch key {
"""

for key, numbers in keys_with_percents.items():
    formatted_args = ", ".join([f"{num}.formatted(.percent)" for num in numbers])
    swift_code += f'        case "{key}":\n'
    swift_code += f'            return String(format: String(localized: "{key}"), {formatted_args})\n'

swift_code += """        default:
            return String(localized: String.LocalizationValue(key))
        }
    }
}
"""

with open("Garten_Simulation/Localization/PercentHelper.swift", "w") as f:
    f.write(swift_code)

print(f"Processed {len(keys_with_percents)} keys.")
