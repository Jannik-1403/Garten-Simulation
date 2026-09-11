import json

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(filepath, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs_to_delete = ['ar', 'da', 'sv', 'zh']

for key, string_obj in data.get("strings", {}).items():
    if "localizations" in string_obj:
        localizations = string_obj["localizations"]
        
        # Copy newly added 'zh' translation to 'zh-Hans' and 'zh-Hant' if missing
        if "zh" in localizations:
            zh_val = localizations["zh"]
            if "zh-Hans" not in localizations:
                localizations["zh-Hans"] = zh_val
            if "zh-Hant" not in localizations:
                localizations["zh-Hant"] = zh_val
                
        # Copy 'pt' translation to 'pt-BR' if 'pt-BR' is missing
        if "pt" in localizations and "pt-BR" not in localizations:
            localizations["pt-BR"] = localizations["pt"]
            
        # Delete the unwanted languages
        for lang in langs_to_delete:
            if lang in localizations:
                del localizations[lang]

with open(filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Fixed localizations.")
