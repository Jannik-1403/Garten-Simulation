import re

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

required_langs = {"de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"}

pattern = re.compile(r'("([^"]+)":\s*\[(.*?)\])', re.DOTALL)
matches = pattern.findall(content)

new_content = content
fixed = 0

for full_match, key, dict_str in matches:
    lang_matches = re.findall(r'"([a-z]{2})":\s*"([^"]*)"', dict_str)
    existing_dict = dict(lang_matches)
    langs_found = set(existing_dict.keys())
    
    missing = required_langs - langs_found
    if missing:
        # Get source text (prefer english, then german, then any)
        if 'en' in existing_dict and existing_dict['en'].strip():
            src_text = existing_dict['en']
        elif 'de' in existing_dict and existing_dict['de'].strip():
            src_text = existing_dict['de']
        else:
            if len(existing_dict) > 0:
                src_lang = list(existing_dict.keys())[0]
                src_text = existing_dict[src_lang]
            else:
                src_text = key # fallback
            
        new_dict_str = dict_str
        for lang in missing:
            res = src_text.replace('"', '\\"').replace('\n', ' ')
            new_dict_str += f', "{lang}": "{res}"'
        
        replacement = f'"{key}": [{new_dict_str}]'
        new_content = new_content.replace(full_match, replacement)
        fixed += 1

if fixed > 0:
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print(f"Filled {fixed} incomplete keys with fallback text successfully!")
else:
    print("Everything was already complete.")
