import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, item in data["strings"].items():
    if "localizations" in item:
        for lang, loc in item["localizations"].items():
            if "stringUnit" in loc and "value" in loc["stringUnit"]:
                val = loc["stringUnit"]["value"]
                # Remove valid format specifiers from the string to see if any stray % or %% is left
                clean_val = re.sub(r'%(lld|d|f|@|\d+\$[d@f])', '', val)
                if '%' in clean_val:
                    print(f"Warning in Key '{key}' [{lang}]: {val}")
