import re

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

required_langs = {"de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"}

# Find all dictionary entries: "key": ["lang": "val", ...]
pattern = re.compile(r'"([^"]+)":\s*\[(.*?)\]')
matches = pattern.findall(content)

errors = []
for key, dict_str in matches:
    # Find all languages in this dictionary
    langs_found = set(re.findall(r'"([a-z]{2})":', dict_str))
    
    missing = required_langs - langs_found
    if missing:
        errors.append(f"Key '{key}' is missing languages: {missing}")

if errors:
    print(f"Found {len(errors)} incomplete keys:")
    for e in errors:
        print(e)
else:
    print("All keys are 100% fully translated in all languages!")

