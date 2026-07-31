import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

# The keys we want to remove
langs_to_remove = ["sv", "pt-PT"]

strings = data.get("strings", {})

# 1. Remove 1% languages
for key, item in strings.items():
    if "localizations" in item:
        for lang in langs_to_remove:
            if lang in item["localizations"]:
                del item["localizations"][lang]

# 2. Fix percentage: "%@ (+%lld %%)" to "%@ (+%@)" or similar.
# Let's find any key containing '%%'
for key in list(strings.keys()):
    if "%%" in key:
        print(f"Found key with %%: {key}")
        new_key = key.replace("%%", "％") # Use fullwidth percent to avoid Xcode warnings if we must, or replace format.
        # Let's just print them out first to see what we need to fix.

